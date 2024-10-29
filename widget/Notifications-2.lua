local astal = require("astal")
local timeout = astal.timeout
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")
local notifd = Notifd.get_default()
local widgets = {}

notifd.on_notified = function(_, id)
    local n = notifd:get_notification(id)

    timeout(5000, function()
        n:dismiss()
    end)

    -- keep track of widgets
    widgets[id] = Widget.Window({
        Widget.Button({
            label = "close",
            on_clicked = function()
                n:dismiss() -- notifd will emit resolved
            end,
        }),
    })
end

notifd.on_resolved = function(_, id)
    -- remove resolved notification's widget
    widgets[id]:destroy()
end


return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    local window = Widget.Window({
        class_name = "Notifications",
        anchor = WindowAnchor.TOP,
        visible = true,
        margin = 8,
        Widget.Box({
            vertical = true,
            class_name = "Notification",
        }),
    })

    return window
end
