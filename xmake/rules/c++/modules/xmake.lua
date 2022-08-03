--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        xmake.lua
--

-- define rule: c++.build.modules
rule("c++.build.modules")
    set_extensions(".mpp", ".mxx", ".cppm", ".ixx")

    add_deps("c++.build.modules.dependencies")
    add_deps("c++.build.modules.builder")
    add_deps("c++.build.modules.install")

    on_config(function (target)
        import("modules_support.common")

        -- we disable to build across targets in parallel, because the source files may depend on other target modules
        -- @see https://github.com/xmake-io/xmake/issues/1858
        if common.contains_modules(target) then
            -- @note this will cause cross-parallel builds to be disabled for all sub-dependent targets,
            -- even if some sub-targets do not contain C++ modules.
            --
            -- maybe we will have a more fine-grained configuration strategy to disable it in the future.
            target:set("policy", "build.across_targets_in_parallel", false)

            -- get modules support
            local modules_support = common.modules_support(target)

            -- check C++20 module support
            modules_support.check_module_support(target)

            -- mark this target with modules
            target:data_set("cxx.has_modules", true)

            -- load parent
            modules_support.load_parent(target, opt)
        end
    end)

-- build dependencies
rule("c++.build.modules.dependencies")
    before_build(function(target, opt)
        if not target:data("cxx.has_modules") then
            return
        end

        -- patch sourcebatch
        import("modules_support.common")
        local sourcebatch = target:sourcebatches()["c++.build.modules.builder"]
        common.patch_sourcebatch(target, sourcebatch, opt)

        -- generate dependencies
        local modules_support = common.modules_support(target)
        modules_support.generate_dependencies(target, sourcebatch, opt)

        -- load and parse module dependencies
        local moduleinfos = common.load(target, sourcebatch, opt)
        local modules = common.parse_dependency_data(target, moduleinfos, opt)
        target:data_set("cxx.modules", modules)
    end)

-- build modules
rule("c++.build.modules.builder")
    set_sourcekinds("cxx")
    set_extensions(".mpp", ".mxx", ".cppm", ".ixx")

    before_buildcmd_files(function(target, batchcmds, sourcebatch, opt)
        if not target:data("cxx.has_modules") then
            sourcebatch.objectfiles = {}
            return
        end

        -- patch sourcebatch
        import("modules_support.common")
        sourcebatch.objectfiles = {}
        sourcebatch.dependfiles = {}
        common.patch_sourcebatch(target, sourcebatch, opt)

        -- get headerunits info, TODO maybe need optimize it
        local headerunits
        local modules = target:data("cxx.modules")
        for _, objectfile in ipairs(sourcebatch.objectfiles) do
            for obj, m in pairs(modules) do
                if obj == objectfile then
                    for name, r in pairs(m.requires) do
                        if r.method ~= "by-name" then
                            headerunits = headerunits or {}
                            local unittype = r.method == "include-angle" and ":angle" or ":quote"
                            table.append(headerunits, {name = name, path = r.path, type = unittype, stl = common.is_stl_header(name)})
                        end
                    end
                    break
                end
            end
        end

        -- generate headerunits
        local headerunits_flags
        local private_headerunits_flags
        local modules_support = common.modules_support(target)
        if headerunits then
            headerunits_flags, private_headerunits_flags = modules_support.generate_headerunits(target, batchcmds, headerunits, opt)
        end
        if headerunits_flags then
            target:add("cxxflags", headerunits_flags, {force = true, expand = false})
        end
        if private_headerunits_flags then
            target:add("cxxflags", private_headerunits_flags, {force = true, expand = false})
        end

        -- topological sort
        local objectfiles = common.sort_modules_by_dependencies(sourcebatch.objectfiles, modules)
        modules_support.build_modules(target, batchcmds, objectfiles, modules, opt)
    end)

-- install modules
rule("c++.build.modules.install")
    set_extensions(".mpp", ".mxx", ".cppm", ".ixx")

    before_install(function (target)
        import("modules_support.common")
        if common.contains_modules(target) then
            local sourcebatch = target:sourcebatches()["c++.build.modules.install"]
            if sourcebatch then
                target:add("installfiles", sourcebatch.sourcefiles, {prefixdir = "include"})
            end
        end
    end)
