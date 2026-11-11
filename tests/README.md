Run each test from the repository root with a standalone Lua 5.4 interpreter:

    lua tests/ranged_weapon.lua
    lua tests/ranged_binding.lua
    lua tests/bag_processing.lua
    lua tests/forever_bags.lua

Each test supplies mocked WoW APIs in its own interpreter. Tests check selection, protected-update guards, binding snippets, and macro contents. They do not validate actual WoW secure execution, mouse input timing, camera behavior, or game targeting. Those checks require the Forever client.
