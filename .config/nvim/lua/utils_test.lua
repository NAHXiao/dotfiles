local watchAssignKey = require("utils").watch_assign_key
local rand_str = function()
    return tostring(os.time())
end
local rand_int = function()
    return os.time()
end
local assert_eq = function(a, b)
    if a == b then
        print("test ok")
    else
        print(("test err: %s != %s"):format(tostring(a), tostring(b)))
    end
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("=== 1. 空表监控 ===")
    local t1 = {}
    watchAssignKey(t1, "name", function(v)
        return "wrapped" .. v
    end)
    s1 = rand_str()
    t1.name = s1
    assert_eq(t1.name, "wrapped" .. s1)
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 2. 空表多次监控 ===")
    local t2 = {}
    watchAssignKey(t2, "name", function(v)
        return "wrapped" .. v
    end)
    watchAssignKey(t2, "age", function(v)
        return v * 2
    end)
    s1 = rand_str()
    t2.name = s1
    assert_eq(t2.name, "wrapped" .. s1)
    i1 = rand_int()
    t2.age = i1
    assert_eq(t2.age, i1 * 2)
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 3. 非空表监控已有键 ===")
    local t3 = { name = "old" }
    watchAssignKey(t3, "name", function(v)
        return "wrapped" .. v
    end)
    s1 = rand_str()
    t3.name = s1
    assert_eq(t3.name, "wrapped" .. s1)
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 4. 非空表监控新键 ===")
    local t4 = { existing = "value" }
    watchAssignKey(t4, "new_key", function(v)
        return "wrapped" .. v
    end)
    s1 = rand_str()
    t4.new_key = s1
    assert_eq(t4.new_key, "wrapped" .. s1)
    assert_eq(t4.existing, "value")
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 5. 非空表多次监控已有键 ===")
    local t5 = { name = "old", age = 10 }
    watchAssignKey(t5, "name", function(v)
        return "wrapped1" .. v
    end)
    watchAssignKey(t5, "name", function(v)
        return "wrapped2" .. v
    end)
    s1 = rand_str()
    t5.name = s1
    assert_eq(t5.name, "wrapped2wrapped1" .. s1)
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 6. 非空表多次监控新键 ===")
    local t6 = { existing = "value" }
    watchAssignKey(t6, "newkey", function(v)
        return "wrap1" .. v
    end)
    watchAssignKey(t6, "newkey", function(v)
        return "wrap2" .. v
    end)
    s1 = rand_str()
    t6.newkey = s1
    assert_eq(t6.newkey, "wrap2wrap1" .. s1)
end
do
    local s1, s2, s3, s4, s5, i1, i2, i3, i4, i5
    print("\n=== 7. 非空表乱序测试 ===")
    local t7 = { existing1 = "value1" }
    local function t(tbl)
        watchAssignKey(tbl, "existing1", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrap" .. s1)

        watchAssignKey(tbl, "newkey", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrap" .. s1)
        s2 = rand_str()
        tbl.newkey = s2
        assert_eq(tbl.newkey, "wrap" .. s2)

        watchAssignKey(tbl, "existing1", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrapwrap" .. s1)
        s2 = rand_str()
        tbl.newkey = s2
        assert_eq(tbl.newkey, "wrap" .. s2)

        watchAssignKey(tbl, "newkey", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrapwrap" .. s1)
        s2 = rand_str()
        tbl.newkey = s2
        assert_eq(tbl.newkey, "wrapwrap" .. s2)

        watchAssignKey(tbl, "existing1", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrapwrapwrap" .. s1)
        s2 = rand_str()
        tbl.newkey = s2
        assert_eq(tbl.newkey, "wrapwrap" .. s2)

        watchAssignKey(tbl, "existing1", function(v)
            return "wrap" .. v
        end)
        s1 = rand_str()
        tbl.existing1 = s1
        assert_eq(tbl.existing1, "wrapwrapwrapwrap" .. s1)
        s2 = rand_str()
        tbl.newkey = s2
        assert_eq(tbl.newkey, "wrapwrap" .. s2)
    end
    t(t7)
end
