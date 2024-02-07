add_rules("mode.debug", "mode.release")
set_languages("cxx20")
add_rules("set_export_all_symbols")
-- add_rules("copy_dll_when_build")
add_rules("set_rpath_origin")

rule("set_rpath_origin")
do
	on_load(function(target)
		if target:kind() == "shared" or target:kind() == "binary" then
			if target:is_plat("linux") then
				target:add("rpathdirs", "$ORIGIN")
				target:add("rpathdirs", "$ORIGIN/../lib")
			elseif target:is_plat("macosx") then
				target:add("rpathdirs", "@loader_path")
				target:add("rpathdirs", "@loader_path/../lib")
			end
		end
	end)
end
rule_end()

rule("set_export_all_symbols")
do
	on_load(function(target)
		if target:kind() == "shared" and is_plat("windows") then
      print("123")
			import("core.project.rule")
			local rule = rule.rule("utils.symbols.export_all")
			target:rule_add(rule)
			target:extraconf_set("rules", "utils.symbols.export_all", { export_classes = true })
		end
	end)
end
rule_end()

rule("copy_dll_when_build")
do
	after_link(function(target)
		installed_libfiles = installed_libfiles or {}
		for _, pkg in ipairs(target:orderpkgs()) do
			local target_build_dir = target:targetdir()
			if pkg:enabled() and pkg:get("libfiles") then
				for _, dll_path in ipairs(table.wrap(pkg:get("libfiles"))) do
					if
						(target:is_plat("windows", "mingw") and dll_path:endswith(".dll"))
						or (
							(not target:is_plat("windows", "mingw"))
							and (
								dll_path:endswith(".so")
								or dll_path:match(".+%.so%..+$")
								or dll_path:endswith(".dylib")
							)
						)
					then
						if not installed_libfiles[dll_path] then
							local dll_name = path.filename(dll_path)
							local targe_dll_path = path.join(target_build_dir, dll_name)
							if os.isfile(targe_dll_path) then
								os.rm(targe_dll_path)
							end
							os.vcp(dll_path, target_build_dir, { symlink = true, force = true })
							installed_libfiles[dll_path] = true
						end
					end
				end
			end
		end
	end)
end
rule_end()

add_requires("fmt 10.x", {
	debug = is_mode("debug"),
	configs = {
		shared = true,
	},
})

target("main")
do
	set_kind("binary")
	add_files("src/main.cpp")
	add_deps("mydylib")
end
target_end()

target("mydylib")
do
	set_kind("shared")
	add_files("dylibsrc/dylibsrc.cpp")
	add_includedirs("dylibsrc/", { public = true })
	add_headerfiles("dylibsrc/dylibsrc.hpp", { install = true })
	add_packages("fmt", { public = false })
	on_load(function (target)
        for _, pkg in ipairs(target:orderpkgs()) do
            for _, linkdir in ipairs(pkg:get("linkdirs")) do
                target:add("ldflags", "-Wl,-rpath-link=" .. linkdir, {public = true, force = true})
            end
        end
    end)
end
target_end()
