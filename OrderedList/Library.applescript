property __name__ : "OrderedList"
property __version__ : "0.1.0"
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value

on __load__(loader)
	set _List to loader's loadLib("List")
end __load__

----------------------------------------------------------------------
-- PUBLIC<B<U

--mark bisect|merge<B
-- based on Python's bisect module

on bisectLeft(lst, val)
	try
		if lst's class is not list then error "not a list." number -1704
		script k
			property l : lst
		end script
		set lo to 0
		set hi to (count k's l)
		repeat while lo < hi
			set mid to (lo + hi) div 2
			if k's l's item (mid + 1) < val then -- (remember to compensate for AS's 1-indexed lists)
				set lo to mid + 1
			else
				set hi to mid
			end if
		end repeat
		return lo
	on error eMsg number eNum
		error "Can't bisectLeft: " & eMsg number eNum
	end try
end bisectLeft

on bisectRight(lst, val)
	try
		if lst's class is not list then error "not a list." number -1704
		script k
			property l : lst
		end script
		set lo to 0
		set hi to (count k's l)
		repeat while lo < hi
			set mid to (lo + hi) div 2
			if val < k's l's item (mid + 1) then -- (remember to compensate for AS's 1-indexed lists)
				set hi to mid
			else
				set lo to mid + 1
			end if
		end repeat
		return lo
	on error eMsg number eNum
		error "Can't bisectRight: " & eMsg number eNum
	end try
end bisectRight

--

on insertLeft(lst, val)
	try
		return _List's insertItem(lst, val, bisectLeft(lst, val))
	on error eMsg number eNum
		error "Can't insertLeft: " & eMsg number eNum
	end try
end insertLeft

on insertRight(lst, val)
	try
		return _List's insertItem(lst, val, bisectRight(lst, val))
	on error eMsg number eNum
		error "Can't insertRight: " & eMsg number eNum
	end try
end insertRight

-------
--mark -
--mark merge<B

on mergeLists(lst1, lst2)
	try
		if lst1's class is not list then error "lst1 parameter isn't a list." number -1704
		if lst2's class is not list then error "lst2 parameter isn't a list." number -1704
		script k
			property l1 : lst1
			property l2 : lst2
		end script
		set len1 to count k's l1
		set len2 to count k's l2
		if len1 is 0 then return lst2
		if len2 is 0 then return lst1
		set itm1 to k's l1's item 1
		set itm2 to k's l2's item 1
		set i to 2
		set j to 2
		set res to {}
		repeat
			if itm2 is less than itm1 then
				set res's end to itm2
				if j > len2 then
					set res to res & k's l1's items (i - 1) thru -1
					exit repeat
				else
					set itm2 to k's l2's item j
					set j to j + 1
				end if
			else
				set res's end to itm1
				if i > len1 then
					set res to res & k's l2's items (j - 1) thru -1
					exit repeat
				else
					set itm1 to k's l1's item i
					set i to i + 1
				end if
			end if
		end repeat
		return res
	on error eMsg number eNum
		error "Can't mergeLists: " & eMsg number eNum
	end try
end mergeLists