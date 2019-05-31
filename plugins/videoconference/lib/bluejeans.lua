local bj = {}

bj.appName = "BlueJeans"

function bj.inMeeting()
    local bluejeans_app = hs.application.get(bj.appName)
    if bluejeans_app == nil then
        return false
    else
        for k,v in pairs(bluejeans_app:visibleWindows()) do
            if string.find(v:title(), "Meeting — ID") then
                return true
            end
        end
        return false
    end
end

return bj
