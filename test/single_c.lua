local a = 1
a = 2
a = a + 4
assert(#____LUAWATCHER.history.a >= 2, "Doesnt contain INIT and SET events")