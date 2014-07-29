-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- Widgets library
require("calendar2")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/david/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = function(file)
    return terminal .. " -e '" .. editor .. " " .. file .. "'"
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- Override awesome.quit when we're using GNOME
-- from: http://awesome.naquadah.org/wiki/Quickly_Setting_up_Awesome_with_Gnome
_awesome_quit = awesome.quit
awesome.quit = function()
    if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
       os.execute("/usr/bin/gnome-session-quit")
    else
        _awesome_quit()
    end
end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd(awesome.conffile) },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

myshutdownmenu = {
    { "suspend", "/home/david/bin/suspend" },
    { "logout", awesome.quit },
    { "reboot", "/home/david/bin/reboot" },
    { "win reboot", "/home/david/bin/win-reboot" },
    { "shutdown", "/home/david/bin/shutdown" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal },
                                    { "open program", "xboomx" },
                                    { "quit", myshutdownmenu }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %a %Y-%m-%d %H:%M:%S ", 1)
calendar2.addCalendarToWidget(mytextclock, "<span color='red'>%s</span>")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewprev),
                    awful.button({ }, 5, awful.tag.viewnext)
                    )

toggle_maximized = function (c)
    float = awful.client.floating.get(c)

    if float then
        -- clients are sometimes reported as floating when they are not
        -- hack around: delete the floating info
        awful.client.floating.delete(c)
    end

    set_maximized(c, not float)
end

set_maximized = function(c, val)
    c.maximized_horizontal = val
    c.maximized_vertical   = val
end

focus_by_id = function (idx)
    awful.client.focus.byidx(idx)
    if client.focus then client.focus:raise() end
end

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  -- c.minimized = true
                                                  toggle_maximized(c)
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                              end
                                              c:raise()
                                          end),
                     awful.button({ }, 2, function (c)
                                              c:kill()
                                          end),
                     awful.button({ }, 3, function (c)
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  -- instance = awful.menu.clients({ width=250 })
                                                  c.minimized = true
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              focus_by_id(-1)
                                          end),
                     awful.button({ }, 5, function ()
                                              focus_by_id(1)
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}

-- A minor hack to avoid screen switch focusing the wrong client
mouse_moved_by_screen_focus = false
focus_relative = function(offset)
    mouse_moved_by_screen_focus = true
    awful.screen.focus_relative(offset)
end

swapWindow = function (c, offset)
    client_maximized = c.maximized_vertical

    if client_maximized then
        set_maximized(c, false)
    end

    mouse_moved_by_screen_focus = true
    awful.client.movetoscreen(c,c.screen+offset)

    if client_maximized then
        set_maximized(c, true)
    end

    c:raise()
end


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Moving focus between clients, screens and tags
    awful.key({ modkey,           }, "j", function() focus_by_id(1) end),
    awful.key({ modkey,           }, "k", function() focus_by_id(-1) end),
    awful.key({ modkey,           }, "h", function () focus_relative(-1) end),
    awful.key({ modkey,           }, "l", function () focus_relative( 1) end),
    awful.key({ modkey,           }, "p", awful.tag.viewprev        ),
    awful.key({ modkey,           }, "n", awful.tag.viewnext        ),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab", function() focus_by_id(1) end),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Moving clients around
    awful.key({ modkey, "Control" }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "k", function () awful.client.swap.byidx( -1)    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey,           }, "i",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey,           }, "o",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "i",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "o",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Restore minimized clients
    awful.key({ modkey,           }, "v", awful.client.restore),
    
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "s",     function () awful.util.spawn( "bash -c 'sleep 1 && xset dpms force off'") end),
    awful.key({ modkey, "Shift"   }, "s",     function () awful.util.spawn( "/home/david/bin/suspend" ) end),

    -- Prompt
    -- Dmenu prompt using the awesome theme - from: http://awesome.naquadah.org/wiki/Using_dmenu (awesome theme moved to ~/.xboomx/config)
    -- install xboomx before using this https://bitbucket.org/dehun/xboomx/wiki/Home
    awful.key({ modkey            }, "d",     function () 
        -- HACK! dmenu does not want to spawn on empty screens if there is a focused client on another screen
        -- Spawn a dummy terminal that dies immediately, this is not visible on empty screens
        if mouse.screen ~= client.focus.screen then
            awful.util.spawn("urxvt -e 'echo'") 
        end
        awful.util.spawn("xboomx") 
    end),
    awful.key({ modkey            }, "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey, "Control" }, "r",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

sendClient = function(c, offset) 
    local tagindex = awful.tag.getidx(c:tags()[1]) + offset
    tagindex = (tagindex-1)%9+1 -- assuming 9 tags
    tag = screen[mouse.screen]:tags()[tagindex]
    c:tags({tag})
    return tag
end

clientkeys = awful.util.table.join(
    -- Moving clients around
    awful.key({ modkey, "Control"   }, "h",      function(c) swapWindow(c,-1) end ),
    awful.key({ modkey, "Control"   }, "l",      function(c) swapWindow(c,1) end ),
    -- http://awesome.naquadah.org/wiki/Move_Window_to_Workspace_Left/Right (should be updated for 3.5)
    awful.key({ modkey, "Shift"     }, "p", function (c) sendClient(c, -1) end),
    awful.key({ modkey, "Shift"     }, "n", function (c) sendClient(c, 1) end),
    awful.key({ modkey, "Control"   }, "p",
    function (c)
            tag = sendClient(c, -1)
            awful.tag.viewonly(tag)
        end),
    awful.key({ modkey, "Control"   }, "n",
    function (c)
            tag = sendClient(c, 1)
            awful.tag.viewonly(tag)
        end),
    awful.key({ modkey,           }, "m",      function (c) c:swap(awful.client.getmaster()) end),
    
    -- Client manipulation
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "b",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "g",      toggle_maximized) 
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
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
    awful.button({ modkey }, 1, function (c) 
        if c.maximized_horizontal or c.maximized_vertical then
            c.maximized_horizontal = false
            c.maximized_vertical = false
        end
        awful.mouse.client.move(c, nil)
    end),
    awful.button({ modkey }, 3, function(c) 
        if c.maximized_horizontal or c.maximized_vertical then
            c.maximized_horizontal = false
            c.maximized_vertical = false
            awful.client.floating.set(c, true)
        end
        awful.mouse.client.resize(c)
    end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    -- Pro tip: Find window classes using "xprop"
    { rule_any = { class = { "MPlayer" }},
      properties = { floating = true } },
    { rule_any = { class = { "feh", "Vlc", "Totem", "gimp", "Google-chrome" }, name =  {"Scala IDE" }},
      properties = { floating = true, maximized_vertical = true, maximized_horizontal = true } }
    -- { rule_any = { class = { "Google-chrome" }},
    --  properties = { floating = true, maximized_vertical = true, maximized_horizontal = true, tag = tags[2][1] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            if not mouse_moved_by_screen_focus then
                client.focus = c
            else
                mouse_moved_by_screen_focus = false
            end
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- Having maximized clients that are only half visibile is kind of useless
-- When one tiled window is in focus, all tiled windows should be shown (by lowering all maximized)
client.add_signal("focus", function(focused_client)
    if not awful.client.floating.get(focused_client) then

        all_clients = client.get(focused_client.screen)
        for key,other_client in pairs(all_clients) do 
            if other_client.maximized_vertical and other_client:isvisible() then

                -- Tricky edge case, placing an unfocused client under the mouse can steal focus
                mouse_client = awful.mouse.client_under_pointer()
                if mouse_client ~= nil and mouse_client.instance == other_client.instance then
                    mouse_moved_by_screen_focus = true
                end

                other_client:lower()
            end
        end
        
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
