local astal = require("astal")
local timeout = astal.timeout
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")
local notifd = Notifd.get_default()
local widgets = {}



return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    notifd.on_notified = function(_, id)
        local n = notifd:get_notification(id)

        timeout(3000, function()
            n:dismiss()
        end)

        -- keep track of widgets
        widgets[id] = Widget.Window({
            margin = 8,
            class_name = "Notifications",
            anchor = WindowAnchor.TOP,
            Widget.Button({
                label = n.body .. n.summary,
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
            }),
        })
    end

    notifd.on_resolved = function(_, id)
        -- remove resolved notification's widget
        widgets[id]:destroy()
    end
end
