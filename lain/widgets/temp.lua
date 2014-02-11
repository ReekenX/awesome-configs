
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    temp.widget = wibox.widget.textbox('')

    function update()
        local f = io.popen("sensors -A | grep 'Core 0' | sed 's!Core 0: *+\\([0-9\\.]*\\).*!\\1!' | xargs echo -n")
        coretemp_now = f:read("*all")
        f:close()
        widget = temp.widget
        settings()
    end

    newtimer("coretemp", timeout, update)
    return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
