-- Hammerspoon script to automatically update your Slack status when in in a video conference
-- meeting. Currently supports Zoom and Bluejeans
--
-- To use:
--
-- * Install and set up the Slack_status.sh script (make sure it's in your path)
-- * Ensure there is a 'videoconference' preset (one is created by default during setup)
-- * Install Hammerspoon (brew cask install hammerspoon) if you don't have it already.
-- * Symlink this file to ~/.hammerspoon
-- * Add the following line to ~/.hammerspoon/init.lua
--      local videoconference_detect = require("videoconference_detect")

bj = require("bluejeans")
z = require("zoom")

local vc = {}

-- Configuration
vc.check_interval = 5 -- How often to check if you're in a meeting, in seconds

-- Initialization
vc.in_vc = nil
vc.logger = hs.logger.new("vcdetect")

function vc.update_status(status)
    task = hs.execute("slack_status.sh " .. status, true)
end

function vc.on_air()
    vc.in_vc = true
    hs.notify.show("Joined video conference meeting", "Updating Slack status", "")
    vc.update_status("videoconference")
end

function vc.off_air()
    vc.in_vc = false
    hs.notify.show("Left video conference meeting", "Updating Slack status", "")
    vc.update_status("none")
end

function vc.inMeeting()
    return (bj.inMeeting() or z.inMeeting())
end

function vc.meetingCheck()
    vc.logger.d("check for meeting")
    if vc.inMeeting() then
        if vc.in_vc == false or vc.in_vc == nil then
            vc.logger.i("going on air")
            vc.on_air()
        end
    else
        if vc.in_vc == true or vc.in_vc == nil then
            vc.logger.i("going off air")
            vc.off_air()
        end
    end
end

vc.meetingCheck()

vc.vcTimer = hs.timer.new(vc.check_interval, vc.meetingCheck)

function vc.vcWatcherCallback(appName, eventType, appOvcect)
    if ((appName == bj.appName) or (appName == z.appName)) then
        vc.logger.d("vc called back with " .. eventType .. " event")
        if (eventType == hs.application.watcher.activated or
            eventType == hs.application.watcher.deactivated) then

            vc.meetingCheck()

            if not vc.vcTimer:running() then
                vc.logger.i("restarting timer to monitor in/out of meetings")
                vc.vcTimer:start()
            end
        elseif eventType == hs.application.watcher.launched then
            vc.logger.i("starting timer to monitor in/out of meetings")
            vc.vcTimer:start()
        elseif eventType == hs.application.watcher.terminated then
            vc.logger.i("stopping timer to monitor in/out of meetings")
            vc.vcTimer:stop()
            vc.meetingCheck()
        end
    end
end

vc.vcWatcher = hs.application.watcher.new(vc.vcWatcherCallback)
vc.vcWatcher:start()

return vc
