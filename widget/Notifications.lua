local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")

local notifd = Notifd.get_default()

notifd.on_notified = function(_, id)
    local n = notifd:get_notification(id)
    print(n.body, n.summary)
end

return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    class_name = "Bar"
    return Widget.Window({
        anchor = WindowAnchor.TOP + WindowAnchor.RIGHT,
    })
end
