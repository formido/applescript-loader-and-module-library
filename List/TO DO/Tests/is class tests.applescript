
set lst to {"a", 1.0, "b", 2.0, "c", 3, "d", 4.0}
set lst to {"a", "x", "b", "foo", "c", "d", "4"}


isEveryItemSameClass({"a", "x", "b", "foo", "c", "d", "4"}) --> true
isEveryItemNumeric({1, 1.0, -9, 2.0, 99, 3, 4.0}) --> true