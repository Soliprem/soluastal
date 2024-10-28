local astal = require("astal")
local App = require("astal.gtk3.app")
local Widget = require("astal.gtk3.widget")
local Variable = astal.Variable
local Gdk = astal.require("Gdk", "3.0")
local GLib = astal.require("GLib")
local bind = astal.bind
local Mpris = astal.require("AstalMpris")
local Battery = astal.require("AstalBattery")
local Wp = astal.require("AstalWp")
local Network = astal.require("AstalNetwork")
local Tray = astal.require("AstalTray")
local Hyprland = astal.require("AstalHyprland")
local map = require("lib").map

local function Spacer(space)
    return Widget.Box({
        height_request = space,
    })
end

local function Launcher()
    return Widget.Button({
        on_click_release = function(_, event)
            if event.button == "PRIMARY" then
                os.execute("pkill fuzzel || fuzzel")
            end
        end,
        Widget.Label({
            label = "🐧",
        }),
    })
end

local function Separator(space)
    return Widget.Label({
        height_request = space,
        label = "—",
        css = "margin: 0px"
    })
end

local function SysTray()
    local tray = Tray.get_default()

    return Widget.Box({
        vertical = true,
        bind(tray, "items"):as(function(items)
            return map(items, function(item)
                if item.icon_theme_path ~= nil then
                    App:add_icons(item.icon_theme_path)
                end

                local menu = item:create_menu()

                return Widget.Button({
                    tooltip_markup = bind(item, "tooltip_markup"),
                    on_destroy = function()
                        if menu ~= nil then
                            menu:destroy()
                        end
                    end,
                    on_click_release = function(self)
                        if menu ~= nil then
                            menu:popup_at_widget(self, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, nil)
                        end
                    end,
                    Widget.Icon({
                        g_icon = bind(item, "gicon"),
                        css = "margin: 2px",
                    }),
                })
            end)
        end),
    })
end

local function FocusedClient()
    local hypr = Hyprland.get_default()
    local focused = bind(hypr, "focused-client")

    return Widget.Box({
        vertical = true,
        class_name = "Focused",
        visible = focused,
        focused:as(function(client)
            return client and Widget.Label({
                label = bind(client, "title"):as(tostring),
            })
        end),
    })
end

local function Wifi()
    local wifi = Network.get_default().wifi

    return Widget.Icon({
        tooltip_text = bind(wifi, "ssid"):as(tostring),
        class_name = "Wifi",
        icon = bind(wifi, "icon-name"),
    })
end

local function AudioSlider()
    local speaker = Wp.get_default().audio.default_speaker

    return Widget.Box({
        vertical = true,
        -- css = "min-height: 140px;",
        class_name = "AudioSlider",
        Widget.Slider({
            inverted = true,
            vertical = true,
            -- vexpand = true,
            height_request = 140,
            on_dragged = function(self)
                speaker.volume = self.value
            end,
            value = bind(speaker, "volume"),
        }),
        Widget.Icon({
            icon = bind(speaker, "volume-icon"),
        }),
    })
end

local function BatteryLevel()
    local bat = Battery.get_default()

    return Widget.Box({
        vertical = true,
        class_name = "Battery",
        visible = bind(bat, "is-present"),
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

local function Media()
    local player = Mpris.Player.new("spotify")

    return Widget.Box({
        vertical = true,
        class_name = "Media",
        visible = bind(player, "available"),
        Widget.Box({
            vertical = true,
            class_name = "Cover",
            halign = "CENTER",
            css = bind(player, "cover-art"):as(function(cover)
                return "background-image: url('" .. (cover or "") .. "');"
            end),
        }),
        -- Widget.Label({
        --     label = bind(player, "metadata"):as(function()
        --         return (player.title or "") .. " - " .. (player.artist or "")
        --     end),
        -- }),
    })
end

local function Workspaces()
    local hypr = Hyprland.get_default()

    return Widget.Box({
        vertical = true,
        class_name = "Workspaces",
        bind(hypr, "workspaces"):as(function(wss)
            table.sort(wss, function(a, b)
                return a.id < b.id
            end)

            return map(wss, function(ws)
                return Widget.Button({
                    class_name = bind(hypr, "focused-workspace"):as(function(fw)
                        return fw == ws and "focused" or ""
                    end),
                    on_clicked = function()
                        ws:focus()
                    end,
                    label = bind(ws, "id"):as(function(v)
                        if v == -99 then
                            return
                        end
                        return type(v) == "number" and string.format("%.0f", v) or v
                    end),
                })
            end)
        end),
    })
end

local function Time(format)
    local time = Variable(""):poll(1000, function()
        return GLib.DateTime.new_now_local():format(format)
    end)

    return Widget.Label({
        class_name = "Time",
        on_destroy = function()
            time:drop()
        end,
        label = time(),
    })
end

return function(gdkmonitor)
    local WindowAnchor = astal.require("Astal", "3.0").WindowAnchor

    return Widget.Window({
        class_name = "Bar",
        margin = 8,
        gdkmonitor = gdkmonitor,
        anchor = WindowAnchor.TOP + WindowAnchor.BOTTOM + WindowAnchor.RIGHT,
        exclusivity = "EXCLUSIVE",

        Widget.CenterBox({
            vertical = true,
            Widget.Box({
                vertical = true,
                valign = "START",
                Launcher(),
                Workspaces(),
                -- FocusedClient(),
            }),
            Widget.Box({
                vertical = true,
                Media(),
            }),
            Widget.Box({
                vertical = true,
                valign = "END",
                Spacer(10),
                AudioSlider(),
                -- BatteryLevel(),
                Separator(10),
                SysTray(),
                Spacer(5),
                Wifi(),
                Separator(10),
                Time("%H"),
                Time("%M"),
            }),
        }),
    })
end
