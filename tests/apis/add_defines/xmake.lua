add_rules("mode.debug", "mode.release")

target("add_defines")
    set_kind("binary")
    add_files("src/*.cpp")
    add_defines("TEST1=\"hello\"")
    add_defines("TEST2=\"hello xmake\"")
    add_defines("TEST3=3")
