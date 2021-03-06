property __name__ : "Sort"
property __version__ : ""
property __lv__ : 1.0

on __load__(loader)
end __load__

----------------------------------------------------------------------

(*other stuff still to do: 
	� remove duplicates? - this would required that at the end of sub-sorting, only the first index in the sub-sorted list would be returned
*)

--mark groupObjects<B

script groupObj
	on equalItems(theList)
		{theList}
	end equalItems
	on unequalItems(item1, item2, groupDepth)
		repeat groupDepth times
			set item1 to {item1}
			set item2 to {item2}
		end repeat
		{{item1}, {item2}}
	end unequalItems
	on wrapItem(theList, groupDepth)
		repeat groupDepth times
			set theList to {theList}
		end repeat
		{theList}
	end wrapItem
end script

script nogroupObj
	on equalItems(theList)
		theList
	end equalItems
	on unequalItems(item1, item2, groupDepth)
		{item1, item2}
	end unequalItems
	on wrapItem(theList, groupDepth)
		theList
	end wrapItem
end script

on _getGroupObj(groupDepth)
	if groupDepth is less than 0 then
		nogroupObj
	else
		groupObj
	end if
end _getGroupObj

--mark -
-------
--mark sortObjects parent<B

script sortParent
	on sortColumn(theDB, indexList, columnList, groupObj, sortRequestsList, groupDepth)
		--log {indexList, columnList}
		-- sort lists of one or two items
		if indexList's length is 1 then
			return groupObj's wrapItem(indexList, groupDepth)
		else if indexList's length is 2 then
			tell columnList
				set item1 to its item (indexList's beginning)
				set item2 to its item (indexList's end)
				if item1 is item2 then
					my _listOrder(indexList)
					if sortRequestsList is {} then
						result
					else
						my _sortRows(theDB, result, sortRequestsList, groupDepth) -- subsort here
					end if
					return groupObj's equalItems(result)
				else if item1 is less than item2 then
					return groupObj's unequalItems(indexList's beginning, indexList's end, groupDepth)
				else
					return groupObj's unequalItems(indexList's end, indexList's beginning, groupDepth)
				end if
			end tell
		end if
		-- sort lists of more than two items
		set startPos to 1
		set endPos to indexList's length
		set midpoint to endPos div 2
		script
			property _columnList : columnList -- the list of values (doesn't change)
			property _indexList : indexList -- the list of indices left to sort
			-- next three properties store indices for items in the above list
			property _lesserList : {}
			property _equalList : {}
			property _greaterList : {}
		end script
		tell result
			set midPointItem to its _columnList's item (its _indexList's item midpoint)
			--get sorting stuff into the 3 result lists...
			-- first sort items below the midPoint, then items above the midPoint
			repeat with eachItem in {{startPos, midpoint - 1}, {midpoint + 1, endPos}}
				repeat with x from eachItem's item 1 to eachItem's item 2
					set indexNumber to its _indexList's item x
					its _columnList's item result -- get the value for that index and do comparisons on it
					if my _isEqual(result, midPointItem) then
						set its _equalList's end to indexNumber
					else if my _isLess(result, midPointItem) then
						set its _lesserList's end to indexNumber
					else
						set its _greaterList's end to indexNumber
					end if
				end repeat
				set its _equalList's end to its _indexList's item midpoint
			end repeat
			--concat the 3 result lists together
			if sortRequestsList is {} then
				its _equalList's items 1 thru -2
			else
				my _sortRows(theDB, its _equalList's items 1 thru -2, sortRequestsList, groupDepth) -- subsort here
			end if
			my _listOrder(result)
			set resultList to groupObj's equalItems(result)
			if its _lesserList's length is not 0 then set resultList to my sortColumn(theDB, its _lesserList, columnList, groupObj, sortRequestsList, groupDepth) & resultList
			if its _greaterList's length is not 0 then set resultList to resultList & my sortColumn(theDB, its _greaterList, columnList, groupObj, sortRequestsList, groupDepth)
			resultList
		end tell
	end sortColumn
end script

--mark -
-------
--mark sortObjects<B

script normalSortObj
	property parent : sortParent
	on _isEqual(theItem, midPointItem)
		theItem = midPointItem
	end _isEqual
	on _isLess(theItem, midPointItem)
		theItem < midPointItem
	end _isLess
	on _listOrder(theList)
		theList
	end _listOrder
end script

script reverseSortObj
	property parent : sortParent
	on _isEqual(theItem, midPointItem)
		theItem = midPointItem
	end _isEqual
	on _isLess(theItem, midPointItem)
		theItem > midPointItem --note: uses ">" to do a reverse-order sort
	end _isLess
	on _listOrder(theList)
		theList's reverse
	end _listOrder
end script

--mark -
-------
--mark PUBLIC CALL<B

on _sortRows(theDB, indexList, sortRequestsList, groupDepth)
	--if sortRequestsList is {} then return indexList
	--
	set newRequest to sortRequestsList's first item
	set sortRequestsList to sortRequestsList's rest
	set groupDepth to groupDepth - 1
	--
	(*if newRequest's dontSort then -- don't sort
		if sortRequestsList is {} then
			indexList
		else
			_sortRows(theDB, indexList, sortRequestsList, groupDepth)
		end if
		tell _getGroupObj(groupDepth) to return equalItems(result)
	end if*)
	--
	tell theDB to set theList to getColumn(newRequest's fieldName)
	--
	if newRequest's reverseOrder then
		reverseSortObj
	else
		normalSortObj
	end if
	tell result to sortColumn(theDB, indexList, theList, _getGroupObj(groupDepth), sortRequestsList, groupDepth)
end _sortRows

--

on sortRows(theDB, indexList, sortRequestsList)
	if indexList is {} then return {}
	set groupDepth to 0
	repeat with eachRequest in sortRequestsList
		if not eachRequest's groupResults then exit repeat
		set groupDepth to groupDepth + 1
	end repeat
	_sortRows(theDB, indexList, sortRequestsList, groupDepth)
end sortRows

