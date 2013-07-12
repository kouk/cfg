local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local widget_fun = require("widget_fun")
local vicious = require("vicious")
module("widgets")

-- Battery widget
batterywidget = wibox.widget.textbox()
vicious.register(batterywidget, vicious.widgets.bat, widget_fun.batclosure(),
                    31, "BAT0")

-- CPU load widget
cpubar = awful.widget.progressbar()
local colour1, colour2
colour1 = beautiful.gradient_1 or "#4f7f4fff"
colour2 = beautiful.gradient_2 or "#d3d3d3ff"
gradient_colour = {type="linear", from={0.5, 0.5}, to={100, 20},
                   stops={{0, colour1}, {1, colour2}}}
cpubar:set_color(gradient_colour)
cpubar:set_background_color(beautiful.bg_widget)
cpubar:set_ticks(true)
vicious.register(cpubar, vicious.widgets.cpu, "$1", 1)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

