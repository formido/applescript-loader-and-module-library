property __name__ : "Filter"
property __version__ : ""
property __lv__ : 1.0

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark FILTER<B

on _filterColumn(valuesList, rowIndexes, filterObj)
	script k
		property idxs : rowIndexes
		property vals : valuesList
		property idxMatches : {}
	end script
	repeat with idxRef in k's idxs
		if filterObj's eval(k's vals's item idxRef) then
			set k's idxMatches's end to idxRef's contents
		end if
	end repeat
	return k's idxMatches
end _filterColumn

on filterRows(theDB, indexList, filterRequestsList)
	repeat with newRequest in filterRequestsList
		tell theDB to getColumn(newRequest's fieldName)
		set indexList to _filterColumn(result, indexList, newRequest)
		if indexList is {} then return {}
	end repeat
	indexList
end filterRows