local astal = require("astal")
local timeout = astal.timeout
local Widget = require("astal.gtk3.widget")
local Notifd = require("lgi").require("AstalNotifd")
local popup_timeout = 3000

local function ternary(condition, if_true, if_false)
    if condition then
        return if_true
    else
        return if_false
    end
end


local function notif_item(n)
    return Widget.Button({
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
    })
end

return function(gdkmonitor)
    gdkmonitor = gdkmonitor
    local notifd = Notifd.get_default()
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor
    local window = Widget.Window({
        class_name = "Notifications",
        anchor = WindowAnchor.TOP,
        visible = true,
        margin = 8,

        setup = function(self)
            local count = 0
            self:hook(notifd, "notified", function()
                count = count + 1
                self.visible = true
            end)
            self:hook(notifd, "resolved", function()
                count = count - 1
                if count == 0 then
                    timeout(popup_timeout, function()
                        self.visible = false
                    end)
                end
            end)
        end,
        Widget.Box({
            vertical = true,
            class_name = "Notification",
            setup = function(self)
                self:hook(notifd, "notified", function(_, id)
                    local n = notifd:get_notification(id)
                    local e_timeout = ternary(n.expire_timeout > 0, n.expire_timeout * 1000, popup_timeout)
                    local widget = notif_item(n)

                    self:add(widget)

                    timeout(e_timeout, function()
                        widget:destroy()
                    end)
                end)
            end,
        }),
    })

    return window
end
