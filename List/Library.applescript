property __name__ : "List"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
--mark DEPENDENCIES<B<U

property _Sort : missing value

on __load__(loader)
	set _Sort to loader's loadComponent("Sort")
end __load__

-----------------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

(* note liberal use of list-access speed kludges throughout to get around crappy O(n) efficiency of AS lists au-naturelle *)

on _chkList(lst)
	if lst's class is not list then error "not a list." number -1704
end _chkList

-------
-- special-case optimisations for recomposeList

on _recomposeNarrow(lst, len)
	-- optimised transform for matrices 2-items wide
	script k
		property l1 : lst's item 1
		property l2 : lst's item 2
		property res : makeList(len, missing value)
	end script
	if k's l1's class is not list then error "item 1 isn't a list." number -1704
	if k's l2's class is not list then error "item 2 isn't a list." number -1704
	if (count of k's l2) is not len then error "item 2 is wrong length." number -1704
	repeat with i from 1 to len
		set k's res's item i to {get k's l1's item i, get k's l2's item i}
	end repeat
	return k's res
end _recomposeNarrow

on _recomposeWide(lst, len)
	-- optimised transform for matrices 2-items high
	set res1 to makeList(len, missing value)
	copy res1 to res2
	script k
		property l : lst
		property r1 : res1
		property r2 : res2
	end script
	if (count k's l each list) is not len then
		repeat with i from 1 to len
			if (class of k's l's item i) is not list then error "item " & i & " isn't a list." number -1704
		end repeat
	end if
	repeat with i from 1 to len
		set subl to k's l's item i
		if (count of subl) is not 2 then error "item " & i & " is wrong length." number -1704
		set {k's r1's item i, k's r2's item i} to subl
	end repeat
	return {k's r1, k's r2}
end _recomposeWide

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on isAllSameClass(lst)
	try
		_chkList(lst)
		set len to count lst
		if len > 0 then
			set itemsClass to class of item 1 of lst
			return (count lst each itemsClass) = len
		else
			return true
		end if
	on error eMsg number eNum
		error "Can't check isAllSameClass: " & eMsg number eNum
	end try
end isAllSameClass

on isAllOfClass(lst, theClass)
	try
		_chkList(lst)
		return (count lst each theClass) = (count lst)
	on error eMsg number eNum
		error "Can't check isAllOfClass: " & eMsg number eNum
	end try
end isAllOfClass

on isAllNumbers(lst)
	try
		_chkList(lst)
		return (count lst each number) = (count lst)
	on error eMsg number eNum
		error "Can't check isAllNumbers: " & eMsg number eNum
	end try
end isAllNumbers

on isAllText(lst)
	try
		_chkList(lst)
		return (count lst each string) + (count lst each Unicode text) = (count lst)
	on error eMsg number eNum
		error "Can't check isAllText: " & eMsg number eNum
	end try
end isAllText

--mark -

on makeList(len, val)
	-- acknowlegement: Arthur J Knapp, who severely performance-optimised the basic algorithm
	try
		set len to len as integer
		if len < 1 then error "length must be greater than 0." number -1704
		script k
			property lst : {val}
		end script
		if val's class is in {class, constant, boolean, integer, real, string, Unicode text} then
			-- duplicate using set instead of copy (faster)
			repeat while ((count of k's lst) < len)
				script
					property lst : k's lst & k's lst
				end script
				set k to result
			end repeat
		else
			-- duplicate using copy to prevent data sharing between list's items
			copy k to k
			repeat while ((count of k's lst) < len)
				copy k's lst to lstCpy
				script
					property lst : k's lst & lstCpy
				end script
				set k to result
			end repeat
		end if
		return k's lst's items 1 thru len
	on error eMsg number eNum
		error "Can't makeList: " & eMsg number eNum
	end try
end makeList

on insertItem(lst, val, idx)
	try
		_chkList(lst)
		set ndx to idx as integer
		script k
			property l : lst
		end script
		set len to count k's l
		if ndx < 0 then
			set ndx to len + ndx + 1
			if ndx < 0 then error "index " & idx & " is out of range."
		end if
		if ndx is 0 then
			return {val} & lst
		else if ndx is len then
			return lst & {val}
		else if ndx < len then
			return (lst's items 1 thru ndx) & {val} & (lst's items (ndx + 1) thru -1)
		else
			error "index " & idx & " is out of range."
		end if
	on error eMsg number eNum
		error "Can't insertItem: " & eMsg number eNum
	end try
end insertItem

on deleteItem(lst, idx)
	try
		_chkList(lst)
		script k
			property l : lst
		end script
		set len to count of k's l
		set ndx to idx as integer
		if ndx is 0 then
			error "index 0 is out of range." number -1728
		else if ndx < 0 then
			set ndx to len + 1 + ndx
			if ndx < 1 then error "index " & idx & " is out of range." number -1728
		else if ndx > len then
			error "index " & idx & " is out of range." number -1728
		end if
		if ndx is 1 then
			return rest of k's l
		else if ndx is len then
			return k's l's items 1 thru -2
		else
			return (k's l's items 1 thru (ndx - 1)) & (k's l's items (ndx + 1) thru -1)
		end if
	on error eMsg number eNum
		error "Can't deleteItem: " & eMsg number eNum
	end try
end deleteItem

on chopList(lst)
	try
		return reverse of rest of reverse of lst
	on error eMsg number eNum
		if lst's class is not list then set {eMsg, eNum} to {"not a list.", -1704}
		error "Can't chopList: " & eMsg number eNum
	end try
end chopList

on removeDuplicates(lst)
	try
		--	_chkList(lst)
		script k
			property l : lst
			property res : {}
		end script
		repeat with itemRef in k's l
			set itm to itemRef's contents
			-- note: minor speed optimisation when removing duplicates from ordered lists:
			-- assemble new list in reverse so 'contains' operator checks most recent item first
			if k's res does not contain {itm} then set k's res's beginning to itm
		end repeat
		return k's res's reverse
	on error eMsg number eNum
		error "Can't removeDuplicates: " & eMsg number eNum
	end try
end removeDuplicates

on multiplyList(lst, n)
	try
		if lst's class is not list then error "not a list." number -1704
		set n to n as integer
		if n < 1 then return {}
		set len to n * (count lst)
		set mk to 1
		repeat until mk is greater than or equal to n
			set lst to lst & lst
			set mk to mk * 2
		end repeat
		return lst's items 1 thru len
	on error eMsg number eNum
		error "Can't multiplyList: " & eMsg number eNum
	end try
end multiplyList

--mark -

on findFirst(lst, val)
	try
		_chkList(lst)
		if {val} is not in lst then return 0
		script k
			property l : lst
		end script
		repeat with i from 1 to count of k's l
			if k's l's item i is val then return i
		end repeat
	on error eMsg number eNum
		error "Can't findFirst: " & eMsg number eNum
	end try
end findFirst

on findLast(lst, val)
	try
		_chkList(lst)
		return -(findFirst(lst's reverse, val))
	on error eMsg number eNum
		error "Can't findLast: " & eMsg number eNum
	end try
end findLast

on FindAll(lst, val)
	try
		_chkList(lst)
		if {val} is not in lst then return {}
		set res to {}
		script k
			property l : lst
		end script
		repeat with i from 1 to count of k's l
			if k's l's item i is val then set res's end to i
		end repeat
		return res
	on error eMsg number eNum
		error "Can't findAll: " & eMsg number eNum
	end try
end FindAll

--mark -

on mapList(lst, evalObj)
	try
		if lst's class is not list then error "not a list." number -1704
		script k
			property l : lst's items
		end script
		repeat with i from 1 to count k's l
			set k's l's item i to evalObj's eval(k's l's item i)
		end repeat
		return k's l
	on error eMsg number eNum
		error "Can't mapList: " & eMsg number eNum
	end try
end mapList

on filterList(lst, evalObj)
	try
		if lst's class is not list then error "not a list." number -1704
		script k
			property l : lst's items
		end script
		set res to {}
		repeat with itemRef in k's l
			set val to itemRef's contents
			if evalObj's eval(val) then set res's end to val
		end repeat
		return res
	on error eMsg number eNum
		error "Can't mapList: " & eMsg number eNum
	end try
end filterList

on reduceList(lst, evalObj)
	try
		if lst's class is not list then error "not a list." number -1704
		script k
			property l : lst
		end script
		set res to k's l's item 1
		set k's l to rest of k's l
		repeat with valRef in k's l
			set res to evalObj's eval(res, valRef's contents)
		end repeat
		return res
	on error eMsg number eNum
		error "Can't reduceList: " & eMsg number eNum
	end try
end reduceList

--mark -

on recomposeList(lst)
	try
		_chkList(lst)
		script k1
			property l : lst
		end script
		set len to count k1's l
		set sublen to count k1's l's first item
		if len is 2 then return _recomposeNarrow(lst, sublen) -- performance-optimise special case
		if sublen is 2 then return _recomposeWide(lst, len) -- performance-optimise special case
		script k2
			property l : makeList(sublen, makeList(len, missing value))
		end script
		repeat with i from 1 to len
			set sublst to k1's l's item i
			if sublst's class is not list then error "item " & i & " isn't a list." number -1704
			script k3
				property l : sublst
			end script
			if (count of k3's l) is not sublen then error "item " & i & " is wrong length." number -1704
			repeat with j from 1 to sublen
				set k2's l's item j's item i to k3's l's item j
			end repeat
		end repeat
		return k2's l
	on error eMsg number eNum
		error "Can't recomposeList: " & eMsg number eNum
	end try
end recomposeList

on interlaceLists(list1, list2)
	try
		_chkList(list1)
		_chkList(list2)
		script k
			property l1 : list1
			property l2 : list2
			property res : {}
		end script
		if (count of k's l1) is not (count of k's l2) then error "lists are different lengths."
		repeat with i from 1 to count k's l1
			set k's res's end to k's l1's item i
			set k's res's end to k's l2's item i
		end repeat
		return k's res
	on error eMsg number eNum
		error "Can't interlaceLists: " & eMsg number eNum
	end try
end interlaceLists

on deinterlaceList(lst)
	try
		_chkList(lst)
		script k
			property l : lst
			property l1 : {}
			property l2 : {}
		end script
		if (count k's l) mod 2 is not 0 then error "list is not an even length."
		repeat with i from 1 to count of k's l by 2
			set k's l1's end to k's l's item i
			set k's l2's end to k's l's item (i + 1)
		end repeat
		return {k's l1, k's l2}
	on error eMsg number eNum
		error "Can't deinterlaceList: " & eMsg number eNum
	end try
end deinterlaceList

on groupList(lst, groupLen)
	try
		_chkList(lst)
		script k
			property l : lst
			property res : {}
		end script
		set tailLen to (count of k's l) mod groupLen
		repeat with idx from 1 to ((count of k's l) - tailLen) by groupLen
			set k's res's end to k's l's items idx thru (idx + groupLen - 1)
		end repeat
		if tailLen is not 0 then
			set k's res's end to k's l's items -tailLen thru -1
		end if
		return k's res
	on error eMsg number eNum
		error "Can't groupList: " & eMsg number eNum
	end try
end groupList

on ungroupList(lst)
	try
		_chkList(lst)
		script k
			property l : lst
		end script
		if (count k's l each list) is not (count k's l) then error "list contains non-list items." number -1704
		set res to {}
		repeat with itemRef in k's l
			set res to res & itemRef's contents
		end repeat
		return res
	on error eMsg number eNum
		error "Can't ungroupList: " & eMsg number eNum
	end try
end ungroupList

--mark -

on sortList(theList)
	return _Sort's sortList(theList)
end sortList

on sortListOfLists(theList, indexList)
	return _Sort's sortListOfLists(theList, indexList)
end sortListOfLists

on powerSort(theList, evaluatorsList, groupingToDepth)
	return _Sort's powerSort(theList, evaluatorsList, groupingToDepth)
end powerSort

on unsortList(lst)
	return _Sort's unsortList(lst)
end unsortList