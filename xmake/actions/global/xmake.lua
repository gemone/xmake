--!The Automatic Cross-platform Build Tool
-- 
-- XMake is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- 
-- XMake is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with XMake; 
-- If not, see <a href="http://www.gnu.org/licenses/"> http://www.gnu.org/licenses/</a>
-- 
-- Copyright (C) 2015 - 2016, ruki All rights reserved.
--
-- @author      ruki
-- @file        global.lua
--

-- define task
task("global")

    -- set category
    set_task_category("action")

    -- on run
    on_task_run(function ()

        -- imports
        import("core.base.option")
        import("core.project.global")

        -- load configure
        global.load()

        -- clean the cached configure?
        if option.get("clean") then
            
            -- clean it
            global.clean()
        end

        -- override the configure for the current options
        for name, value in pairs(option.options()) do
            if name ~= "verbose" and name ~= "clean" then
                global.set(name, value)
            end
        end

        -- merge the default options 
        for name, value in pairs(option.defaults()) do
            if name ~= "verbose" and name ~= "clean" and global.get(name) == nil then
                global.set(name, value)
            end
        end

        -- probe the configure with value: "auto"
        global.probe()
       
        -- save it
        global.save()

        -- dump it
        global.dump()

        -- trace
        print("configure ok!")
        
    end)

    -- set menu
    set_task_menu({
                    -- usage
                    usage = "xmake global|g [options] [target]"

                    -- description
                ,   description = "Configure the global options for xmake."

                    -- xmake g
                ,   shortname = 'g'

                    -- options
                ,   options = 
                    {
                        {'c', "clean",      "k",    nil,            "Clean the cached configure and configure all again."       }
                    ,   {nil, "make",       "kv",   "auto",         "Set the make path."                                        }
                    ,   {nil, "ccache",     "kv",   "auto",         "Enable or disable the c/c++ compiler cache." 
                                                                 ,  "    --ccache=[y|n]"                                        }

                    ,   {}

                        -- show platform menu options
                    ,   function () 

                            -- import platform menu
                            import("core.platform.menu")

                            -- get global menu options
                            return menu.options_global() 
                        end

                    }
                })



