--[[

     Original author:

         Holo Awesome WM config 2.0
         github.com/copycat-killer

--]]

-- {{{ Required libraries
local gears       = require("gears")
local awful       = require("awful")
awful.rules       = require("awful.rules")
local wibox       = require("wibox")
local beautiful   = require("beautiful")
local naughty     = require("naughty")
local lain        = require("lain")
local custom_conf = require("config")

-- Load custom configuration
f = io.open(os.getenv("HOME").."/.config/awesome/config_do_not_commit.lua")
if f then
    custom_conf  = require("config_do_not_commit")
end
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("skype")
run_once("parcellite")
run_once("xset b on")
run_once("numlockx on")
run_once('setxkbmap lt')
run_once("xterm")
-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/holo/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "xterm"
editor     = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "google-chrome-beta"
gui_editor = "gvim"
musiplr   = terminal .. " -e ncmpcpp "

local layouts = {
    lain.layout.uselesstile,
    awful.layout.suit.fair,
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.top
}
-- }}}

-- {{{ Tags
tags = {
   single_screen = { " Design ", " Terminal ", " Time ", " Zone " },

   first_screen = { " Design ", " Time ", " Chat " },
   second_screen = { " Terminal ", " Zone ", " Hideout " },

   layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
if screen.count() == 1 then
   tags[1] = awful.tag(tags.single_screen, 1, tags.layout)
   chat_tag = tags[1][4]
end
if screen.count() == 2 then
   tags[1] = awful.tag(tags.first_screen, 1, tags.layout)
   tags[2] = awful.tag(tags.second_screen, 2, tags.layout)
   chat_tag = tags[2][2]
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Wibox
markup = lain.util.markup
blue   = "#80CCE6"
white   = "#FFFFFF"
space3 = markup.font("Tamsyn 3", " ")
space2 = markup.font("Tamsyn 2", " ")

-- Menu icon
awesome_icon = wibox.widget.imagebox()
awesome_icon:set_image(beautiful.awesome_icon)

-- Clock
mytextclock = awful.widget.textclock(markup("#FFFFFF", space3 .. "%H:%M" .. space2))
clock_icon = wibox.widget.imagebox()
clock_icon:set_image(beautiful.clock)
clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_bg)

-- Calendar
mytextcalendar = awful.widget.textclock(markup("#FFFFFF", space3 .. "%Y %B %d, %A<span font='Tamsyn 5'> </span>"))
calendar_icon = wibox.widget.imagebox()
calendar_icon:set_image(beautiful.calendar)
calendarwidget = wibox.widget.background()
calendarwidget:set_widget(mytextcalendar)
calendarwidget:set_bgimage(beautiful.widget_bg)
lain.widgets.calendar:attach(calendarwidget, { fg = "#FFFFFF", position = "bottom_right" })

if custom_conf.imap_enabled
then
    -- Imap
    mailpopup = lain.widgets.imap({
        timeout  = custom_conf.imap_timeout,
        server   = custom_conf.imap_host,
        mail     = custom_conf.imap_username,
        password = custom_conf.imap_password,
        is_plain = false,
        settings = function()
            mail_notification_preset.fg = white
            mail  = ""
            count = ""

            if mailcount > 0 then
                mail = "New e-mails "
                count = mailcount .. " "
            end

            widget:set_markup(markup(blue, mail) .. markup(white, count))
        end
    })
    mailwidget = wibox.widget.background()
    mailwidget:set_widget(mailpopup)
    mailwidget:set_bgimage(beautiful.widget_bg)
end

-- Temperature
mytemp = lain.widgets.temp({
    settings = function()
        widget:set_markup(coretemp_now .. "℃")
    end
})
tempwidget = wibox.widget.background()
tempwidget:set_widget(mytemp)
tempwidget:set_bgimage(beautiful.widget_bg)

-- Load
myload = lain.widgets.sysload({
    settings = function()
        widget:set_markup(load_1 .. '  ' .. load_5 .. '  ' .. load_15)
    end
})
loadwidget = wibox.widget.background()
loadwidget:set_widget(myload)
loadwidget:set_bgimage(beautiful.widget_bg)

-- MPD
mpd_icon = wibox.widget.imagebox()
mpd_icon:set_image(beautiful.mpd)
prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.play)

mpdwidget = lain.widgets.mpd({
    settings = function ()
        if mpd_now.state == "play" then
            mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
            mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
            widget:set_markup(markup.font("Tamsyn 4", " ")
                              .. markup.font("Tamsyn 8",
                              mpd_now.artist
                              .. " - " ..
                              mpd_now.title
                              .. markup.font("Tamsyn 10", " ")))
            play_pause_icon:set_image(beautiful.pause)
        elseif mpd_now.state == "pause" then
            widget:set_markup(markup.font("Tamsyn 4", " ") ..
                              markup.font("Tamsyn 8", "MPD PAUSED") ..
                              markup.font("Tamsyn 10", " "))
            play_pause_icon:set_image(beautiful.play)
        else
            widget:set_markup("")
            play_pause_icon:set_image(beautiful.play)
        end
    end
})

musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_bg)
musicwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(musicplr) end)))
mpd_icon:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(musicplr) end)))
prev_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
    mpdwidget.update()
end)))
next_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
    mpdwidget.update()
end)))
stop_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
    mpdwidget.update()
end)))
play_pause_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
    mpdwidget.update()
end)))

-- ALSA volume bar
myvolumebar = lain.widgets.alsabar({
    width  = 80,
    height = 10,
    colors = {
        background = "#383838",
        unmute     = "#80CCE6",
        mute       = "#FF9F9F"
    },
    notifications = {
        font      = "Tamsyn",
        font_size = "12",
        bar_size  = 32
    }
})
alsamargin = wibox.layout.margin(myvolumebar.bar, 5, 8, 80)
wibox.layout.margin.set_top(alsamargin, 12)
wibox.layout.margin.set_bottom(alsamargin, 12)
volumewidget = wibox.widget.background()
volumewidget:set_widget(alsamargin)
volumewidget:set_bgimage(beautiful.widget_bg)

-- CPU
cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(space3 .. "CPU " .. cpu_now.usage
                          .. "%" .. markup.font("Tamsyn 5", " "))
    end
})
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_bg)
cpu_icon = wibox.widget.imagebox()
cpu_icon:set_image(beautiful.cpu)

-- Memory widget
mymem = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", " ") .. mem_now.used .. ' MB' .. space2)
    end
})
memwidget = wibox.widget.background()
memwidget:set_widget(mymem)
memwidget:set_bgimage(beautiful.widget_bg)

memwidget_icon = wibox.widget.imagebox()
memwidget_icon:set_image(beautiful.mem)

-- Filesystem widget
fsmem = lain.widgets.fs({
    partition = '/',
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", " ") .. fs_now.available .. '%' .. space2)
    end
})
fswidget = wibox.widget.background()
fswidget:set_widget(fsmem)
fswidget:set_bgimage(beautiful.widget_bg)

fswidget_icon = wibox.widget.imagebox()
fswidget_icon:set_image(beautiful.disk)

-- Net
netdown_icon = wibox.widget.imagebox()
netdown_icon:set_image(beautiful.net_down)
netup_icon = wibox.widget.imagebox()
netup_icon:set_image(beautiful.net_up)
netwidget = lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", " ") .. net_now.received .. " - "
                          .. net_now.sent .. space2)
    end
})
networkwidget = wibox.widget.background()
networkwidget:set_widget(netwidget)
networkwidget:set_bgimage(beautiful.widget_bg)

-- Weather
yawn = lain.widgets.yawn(479616)

-- Separators
first = wibox.widget.textbox('<span font="Tamsyn 4"> </span>')
last = wibox.widget.imagebox()
last:set_image(beautiful.last)
spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr_small = wibox.widget.imagebox()
spr_small:set_image(beautiful.spr_small)
spr_very_small = wibox.widget.imagebox()
spr_very_small:set_image(beautiful.spr_very_small)
spr_right = wibox.widget.imagebox()
spr_right:set_image(beautiful.spr_right)
spr_bottom_right = wibox.widget.imagebox()
spr_bottom_right:set_image(beautiful.spr_bottom_right)
spr_left = wibox.widget.imagebox()
spr_left:set_image(beautiful.spr_left)
bar = wibox.widget.imagebox()
bar:set_image(beautiful.bar)
bottom_bar = wibox.widget.imagebox()
bottom_bar:set_image(beautiful.bottom_bar)

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 32 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mylayoutbox[s])
    left_layout:add(spr_small)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()

    if screen.count() == 2 and s == 1 then right_layout:add(spr_bottom_right) end
    if screen.count() == 2 and s == 1 then right_layout:add(tempwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(netdown_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(networkwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(netup_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(fswidget_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(fswidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(memwidget_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(memwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(loadwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(cpu_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(cpuwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(calendar_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(calendarwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bottom_bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(clock_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(clockwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(mpd_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(musicwidget) end
    if screen.count() == 2 and s == 1 then right_layout:add(bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(spr_right) end
    if screen.count() == 2 and s == 1 then right_layout:add(prev_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(next_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(stop_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(play_pause_icon) end
    if screen.count() == 2 and s == 1 then right_layout:add(bar) end
    if screen.count() == 2 and s == 1 then right_layout:add(spr_very_small) end
    if screen.count() == 2 and s == 1 then right_layout:add(volumewidget) end

    if (screen.count() == 2 and s == 2) or (screen.count() == 1) then right_layout:add(wibox.widget.systray()) end
    if (screen.count() == 2 and s == 2) or (screen.count() == 1) and custom_conf.imap_enabled then right_layout:add(mailwidget) end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 32 })

    -- Widgets that are aligned to the bottom left
    bottom_left_layout = wibox.layout.fixed.horizontal()
    bottom_left_layout:add(awesome_icon)

    -- Widgets that are aligned to the bottom right
    bottom_right_layout = wibox.layout.fixed.horizontal()

    -- Now bring it all together (with the tasklist in the middle)
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)

    -- Set proper backgrounds, instead of beautiful.bg_normal
    mybottomwibox[s]:set_bg("#242424")

    -- Create a borderbox above the bottomwibox
    lain.widgets.borderbox(mybottomwibox[s], s, { position = "top", color = "#0099CC" } )
    mywibox[s]:set_bg(beautiful.topbar_path .. "1920.png")

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    awful.key({ modkey }, "p", function() os.execute("scrot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),

    awful.key({ modkey }, "Tab",
    function ()
        awful.client.focus.byidx(1)
        if awful.client.ismarked() then
            awful.screen.focus_relative(-1)
            awful.client.getmarked()
        end
        if client.focus then
            client.focus:raise()
        end
        awful.client.togglemarked()
    end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.02)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.02)    end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Widgets popups
    awful.key({ modkey,           }, "w",      function () yawn.show(7) end),

    -- ALSA volume control
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " " .. myvolumebar.step .. "-") end),
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " " .. myvolumebar.step .. "+") end),
    awful.key({}, "XF86AudioMute",        function () awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " playback toggle") end),

    -- Music control
    awful.key({}, "XF86AudioPlay",        function () awful.util.spawn("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle") end),
    awful.key({}, "XF86AudioNext",        function () awful.util.spawn("mpc next || ncmpcpp next || ncmpc next || pms next" ) end),
    awful.key({}, "XF86AudioPrev",        function () awful.util.spawn("mpc prev || ncmpcpp prev || ncmpc prev || pms prev" ) end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift" }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift" }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Shift" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Shift" }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift" }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift" }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, "Shift" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     focus = true,
                     floating = false,
                     minimized = false,
                     maximized = false
                     } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { type = "dialog" },
          properties = { floating = true, border_width = 2 } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup
    then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    c:connect_signal("property::urgent", function(c)
        if c.urgent then
            run_once("beep -f 530 -l 30 -D 100; beep -f 530 -l 30 -D 100; beep -f 530 -l 30 -D 100")
            naughty.notify({text="Needs attention: " .. c.name})
        end
    end)
end)

-- }}}

-- {{{ Random desktop image

function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end


if string.len(custom_conf.random_photo_path) > 1
then
    -- configuration - edit to your liking
    wp_index = 1
    wp_timeout  = custom_conf.random_photo_timeout
    wp_path = custom_conf.random_photo_path
    wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
    wp_files = scandir(wp_path, wp_filter)

    -- setup the timer
    wp_timer = timer { timeout = wp_timeout }
    wp_timer:connect_signal("timeout", function()

      -- set wallpaper to current index for all screens
      for s = 1, screen.count() do
        gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
      end

      -- stop the timer (we don't need multiple instances running at the same time)
      wp_timer:stop()

      -- get next random index
      wp_index = math.random( 1, #wp_files)

      --restart the timer
      wp_timer.timeout = wp_timeout
      wp_timer:start()
    end)

    -- initial start when rc.lua is first run
    wp_timer:start()
end

-- }}}
