add_rules("mode.debug", "mode.release")
set_languages("cxx20")

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
    add_headerfiles("dylibsrc/dylibsrc.hpp", { install = true})
    add_packages("fmt")
end
target_end()
