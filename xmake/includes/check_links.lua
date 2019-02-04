--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        check_links.lua
--

-- check links and add macro definition 
--
-- e.g.
--
-- check_links("HAS_PTHREAD", "pthread")
-- check_links("HAS_PTHREAD", {"pthread", "m", "dl"})
--
function check_links(definition, links)
    option(opt.name or definition)
        add_links(links)
        add_defines(definition)
    option_end()
    add_options(opt.name or definition)
end

-- check links and add macro definition to the configuration files 
--
-- e.g.
--
-- configvar_check_links("HAS_PTHREAD", "pthread")
-- configvar_check_links("HAS_PTHREAD", {"pthread", "m", "dl"})
--
function configvar_check_links(definition, links)
    option(opt.name or definition)
        add_links(links)
        set_configvar(definition, 1)
    option_end()
    add_options(opt.name or definition)
end
