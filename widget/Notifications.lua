local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")

return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local notifd = Notifd.get_default()
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    notifd.on_notified = function(_, id)
        local n = notifd:get_notification(id)
        local window = Widget.Window({
            class_name = "Notifications",
            anchor = WindowAnchor.TOP,
            margin = 8,
            Widget.Box({
                vertical = true,
                class_name = "Notification",
                Widget.Button({
                    on_click_release = function(_, event)
                        if event.button == "PRIMARY" then
                            for i in ipairs(n.actions) do
                                n:invoke(i)
                            end
                        end
                        if event.button == "SECONDARY" then
                            n:dismiss()
                        end
                    end,
                    Widget.Label({
                        label = n.summary .. n.body,
                    }),
                }),
            }),
        })

        return window
    end
end
