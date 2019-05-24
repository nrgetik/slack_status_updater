-- Hammerspoon script to automatically update your slack status when in BlueJeans
--
-- To use:
--
-- * Install and set up the slack_status.sh script (make sure it's in your
--   path)
-- * Ensure there is a 'bluejeans' preset (one is created by default during setup)
-- * Install hammerspoon (brew cask install hammerspoon) if you don't have it
--   already.
-- * Copy this file to ~/.hammerspoon
-- * Add the following line to ~/.hammerspoon/init.lua
--      local bluejeans_detect = require("bluejeans_detect")

-- Configuration
check_interval=5 -- How often to check if you're in bluejeans, in seconds

-- Initialization
inbluejeans = nil
-- local lightbox = require("lightbox")
local logger = hs.logger.new("bluejeansdetect")

function update_status(status)
    task = hs.execute("slack_status.sh " .. status, true)
end

function on_air()
    inbluejeans = true
    hs.notify.show("Started BlueJeans meeting", "Updating slack status", "")
    update_status("bluejeans")
    -- lightbox.on()
end

function off_air()
    inbluejeans = false
    hs.notify.show("Left BlueJeans meeting", "Updating slack status", "")
    update_status("none")
    -- lightbox.off()
end

function isInMeeting()
    local bluejeans_app = hs.application.find("BlueJeans")
    if bluejeans_app == nil then return false end
    return meeting_menu_is_present(bluejeans_app)
end

function meeting_menu_is_present(app)
    return string.find(app:mainWindow():title(), "Meeting")
end

function meetingCheck()
    logger.d("check for meeting")
    if isInMeeting() then
        if inbluejeans == false or inbluejeans == nil then
            logger.i("going on air")
            on_air()
        end
    else
        if inbluejeans == true or inbluejeans == nil then
            logger.i("going off air")
            off_air()
        end
    end
end

meetingCheck()

bluejeansTimer = hs.timer.new(check_interval, meetingCheck)

function bluejeansWatcherCallback(appName, eventType, appObject)
    if (appName == "BlueJeans") then
        logger.d("bluejeans called back with " .. eventType .. " event")
        if (eventType == hs.application.watcher.activated or
            eventType == hs.application.watcher.deactivated) then

            meetingCheck()
            if not bluejeansTimer:running() then
                logger.i("restarting timer to monitor in/out of meetings")
                bluejeansTimer:start()
            end
        elseif eventType == hs.application.watcher.launched then
            logger.i("starting timer to monitor in/out of meetings")
            bluejeansTimer:start()
        elseif eventType == hs.application.watcher.terminated then
            logger.i("stopping timer to monitor in/out of meetings")
            bluejeansTimer:stop()
            meetingCheck()
        end
    end
end

bluejeansWatcher = hs.application.watcher.new(bluejeansWatcherCallback)
bluejeansWatcher:start()
