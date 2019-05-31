local z = {}

z.appName = "zoom.us"

function z.inMeeting()
    local zoom_app = hs.application.get(z.appName)
    if zoom_app == nil then
        return false
    else
        local item = zoom_app:getMenuItems()[2]["AXTitle"]
        if string.find(item, "Meeting") then
            return true
        else
            return false
        end
    end
end

return z
