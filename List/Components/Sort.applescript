property __name__ : "Sort"
property __version__ : ""
property __lv__ : 1

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

-- TO DO: see how sorting a parallel list of indexes to original list's items a-la Table's sort routine compares,
-- It might be a better approach to use, giving greater flexibility over how values may be sorted, especially
-- when sorting application object references (the values to sort on can be gotten _much_ more quickly by property - e.g. {name, version, size} of every item - than by item).
-- Also, take another look at possibility of using an in-place sorting algorithm for better performance (note: not sure how an in-place algorithm would cope with groupToDepth).

on _doEval(theList, evalObj)
	-- convert each item of list to a {val, item} sublist, where
	--  val is the value from item to be compared in _psrt()
	script k -- speed kludge
		property lst : theList's items
	end script
	repeat with i from 1 to count of theList
		set val to k's lst's item i
		set k's lst's item i to {evalObj's eval(val), val}
	end repeat
	return k's lst
end _doEval

--

on _psrt(lst, evalList, doGroups, groupThis)
	if ((count of lst) is 1) then
		-- apply any remaining grouping levels and return early
		set val to {last item of first item of lst}
		repeat while groupThis
			set val to {val}
			set groupThis to first item of doGroups
			set doGroups to rest of doGroups
		end repeat
		return val
	end if
	script k -- speed kludge
		property sourceList : lst
		property lessList : {}
		property sameList : {}
		property moreList : {}
	end script
	set listLength to count of k's sourceList
	-- take list's middle item as pivot
	set midpoint to (listLength + 1) div 2
	set {pivotVal, k's sameList's end} to k's sourceList's item midpoint
	-- process items on either side of pivot (stable sorting)
	if listLength mod 2 is 0 then
		set itm to k's sourceList's item -midpoint
		set val to itm's first item
		if val = pivotVal then
			set k's sameList's end to itm's last item
		else if val < pivotVal then
			set k's lessList's end to itm
		else
			set k's moreList's end to itm
		end if
	end if
	--
	repeat with idx from (midpoint - 1) to 1 by -1
		set itm to k's sourceList's item idx
		set val to itm's first item
		if val = pivotVal then
			set k's sameList's beginning to itm's last item
		else if val < pivotVal then
			set k's lessList's beginning to itm
		else
			set k's moreList's beginning to itm
		end if
		set itm to k's sourceList's item -idx
		set val to itm's first item
		if val = pivotVal then
			set k's sameList's end to itm's last item
		else if val < pivotVal then
			set k's lessList's end to itm
		else
			set k's moreList's end to itm
		end if
	end repeat
	-- get lists from kludge object
	set lessList to k's lessList
	set sameList to k's sameList
	set moreList to k's moreList
	-- recursively sort lesser/greater values
	if lessList is not {} then set lessList to _psrt(lessList, evalList, doGroups, groupThis)
	if moreList is not {} then set moreList to _psrt(moreList, evalList, doGroups, groupThis)
	-- optionally sort items of sameList on a different attribute
	if ((count of sameList) = 1) then
		-- apply any remaining grouping levels
		repeat while groupThis
			set sameList to {sameList}
			set groupThis to first item of doGroups
			set doGroups to rest of doGroups
		end repeat
	else if ((count of sameList) > 1) then
		-- sort using next evaluator, if any
		if ((count of evalList) > 0) then
			set evalObj to evalList's first item
			set sameList to _psrt(_doEval(sameList, evalObj), rest of evalList, rest of doGroups, first item of doGroups)
			if evalObj's reverseSort then set sameList to reverse of sameList
		end if
		if groupThis then set sameList to {sameList}
	end if
	-- rejoin sorted sublists
	return lessList & sameList & moreList
end _psrt

--

on _powerSort(theList, evaluatorsList, groupingToDepth)
	if theList's class is not list then error "Not a list." number -1704
	if groupingToDepth's class is not integer then error "groupingToDepth parameter isn't an integer." number -1704
	if evaluatorsList's class is not list then set evaluatorsList to {evaluatorsList}
	set doGroups to {}
	repeat (count of evaluatorsList) times
		set doGroups's end to (groupingToDepth > 0)
		set groupingToDepth to groupingToDepth - 1
	end repeat
	if ((count of theList) > 1) then
		set firstEvaluator to evaluatorsList's first item
		set theList to _psrt(_doEval(theList, firstEvaluator), rest of evaluatorsList, rest of doGroups & {false}, first item of doGroups)
		if firstEvaluator's reverseSort then set theList to reverse of theList
	end if
	return theList
end _powerSort

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on sortList(theList) -- a stack-based, non-recursive quicksort 
	-- your basic list sort, e.g. sortList({1, 3, 8, 2}) --> {1, 2, 3, 8}
	try
		if theList's class is not list then error "not a list." number -1704
		if (count theList each number) > 0 and ((count theList each string) + (count theList each Unicode text) > 0) then
			error "can't sort a list containing both number and text values." number -1704
		end if
		script k -- list access speed kludge
			property lst : theList's items
		end script
		if k's lst's length < 2 then return k's lst
		set s to {a:1, b:count k's lst, c:missing value} -- unsorted slices stack
		repeat until s is missing value
			set l to s's a
			set r to s's b
			set s to get s's c
			set i to l
			set j to r
			set v to k's lst's item ((l + r) div 2)
			repeat while (j > i)
				repeat while (k's lst's item i < v)
					set i to i + 1
				end repeat
				repeat while (k's lst's item j > v)
					set j to j - 1
				end repeat
				if (i � j) then
					set tmp to k's lst's item i
					set k's lst's item i to k's lst's item j
					set k's lst's item j to tmp
					set i to i + 1
					set j to j - 1
				end if
			end repeat
			if (l < j) then set s to {a:l, b:j, c:s}
			if (r > i) then set s to {a:i, b:r, c:s}
		end repeat
		return k's lst
	on error eMsg number eNum
		error "Can't sortList: " & eMsg number eNum
	end try
end sortList

on sortListOfLists(theList, indexList)
	-- sort a list of sublists, given a list of sublist indexes to sort on;
	-- e.g. sortListOfLists(lst, {3, 2}) will sort lst's sublists first by their
	-- third item and then by their second
	try
		if (count theList each list) < (count theList) then error "not a list of lists." number -1704
		if indexList's class is not list then set indexList to {indexList}
		if indexList is {} then return theList
		set evaluatorsList to {}
		repeat with itm in indexList
			script EvalIndex
				property reverseSort : false
				property _idx : itm's contents
				on eval(sublst)
					return sublst's item _idx
				end eval
			end script
			set evaluatorsList's end to EvalIndex
		end repeat
		return _powerSort(theList, evaluatorsList, 0)
	on error eMsg number eNum
		error "Can't sortListOfLists: " & eMsg number eNum
	end try
end sortListOfLists

on powerSort(theList, evaluatorsList, groupingToDepth)
	-- sort a list of complex items (e.g. lists or records)
	-- evaluatorsList is a list of evaluator objects;
	-- each evaluator object is a script object containing an eval(itm) handler
	-- that returns the value to be compared (number, text, date; basically
	-- anything that responds to =<> operators)
	try
		return _powerSort(theList, evaluatorsList, groupingToDepth)
	on error eMsg number eNum
		error "Can't powerSort: " & eMsg number eNum
	end try
end powerSort

--

on unsortList(lst)
	-- randomise list items
	try
		if lst's class is not list then error "Not a list." number -1704
		script k
			property l : lst's items
		end script
		set len to count k's l
		set lastNum to random number from 1 to 9.999999999971E+12 -- calling osax only once improves overall performance approx 40%
		repeat with idx1 from 1 to len
			set lastNum to (lastNum * 67128023) mod 9.999999999971E+12
			set idx2 to (lastNum mod len) + 1
			set tmp to k's l's item idx1
			set k's l's item idx1 to (get k's l's item idx2)
			set k's l's item idx2 to tmp
		end repeat
		return k's l
	on error eMsg number eNum
		error "Can't unsortList: " & eMsg number eNum
	end try
end unsortList