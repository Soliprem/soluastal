local astal = require("astal")
local bind = astal.bind
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")

local notifd = Notifd.get_default()

notifd.on_notified = function(_, id)
    local n = notifd:get_notification(id)
    return n.body, n.summary
end

local function Notification()
    local notif = notifd.on_notified()

    return Widget.Box({
        class_name = "Battery",
        visible = bind(notif, "is-present"),
        Widget.Icon({
            icon = bind(bat, "battery-icon-name"),
        }),
        Widget.Label({
            label = bind(bat, "percentage"):as(function(p)
                return tostring(math.floor(p * 100)) .. "%"
            end),
        }),
    })
end

return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    return Widget.Window({
        class_name = "Notification",
        anchor = WindowAnchor.TOP + WindowAnchor.RIGHT,
        Widget.Box({
            Notification()
        })
        -- Widget.Label({
        --     label = notifd.on_notified
        -- }),
    })
end
