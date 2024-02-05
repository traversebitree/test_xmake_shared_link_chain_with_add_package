add_rules("mode.debug", "mode.release")
set_languages("cxx20")
add_rules("set_export_all_symbols")
add_rules("add_pkgenv_when_linking")

rule("set_export_all_symbols")
do
	on_load(function(target)
		if target:kind() == "static" then
			target:set("kind", "static")
		elseif target:kind() == "shared" then
			target:set("kind", "shared")
			if is_plat("windows") and target:toolchains()[1]:config("vs") then
				import("core.project.rule")
				local rule = rule.rule("utils.symbols.export_all")
				target:rule_add(rule)
				target:extraconf_set("rules", "utils.symbols.export_all", { export_classes = true })
			end
		end
	end)
end
rule_end()

rule("add_pkgenv_when_linking")
do
	before_link(function(target)
		os.addenvs(target:pkgenvs())
	end)
  after_link(function(target)
    print(os.getenvs())
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
end
target_end()
