Run each test from the repository root with a standalone Lua 5.4 interpreter:

    lua tests/ranged_weapon.lua
    lua tests/ranged_binding.lua
    lua tests/bag_processing.lua
    lua tests/forever_bags.lua
    lua tests/eqol_bags.lua

Each test supplies mocked WoW APIs in its own interpreter. Tests check selection, protected-update guards, binding snippets, and macro contents. They do not validate actual WoW secure execution, mouse input timing, camera behavior, or game targeting. Those checks require the Forever client.

The Enhance QoL test models the published button tables and slot methods inspected in EnhanceQoL-13.20.1-forever.zip, CurseForge file 9563261. It contains no Enhance QoL source code.
