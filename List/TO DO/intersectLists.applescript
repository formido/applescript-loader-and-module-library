set mainList to {1, 2, 3, 4, 5, 6, 8, 9}
set filterList to {1, 3, 7, 9, 0}
set invertMatch to false

set a to «event Timµinsµ»
repeat 1000 times
	intersectLists(mainList, filterList, invertMatch)
end repeat
set a to «event Timµstop» a

{a, intersectLists(mainList, filterList, invertMatch)}


on intersectLists(mainList, filterList, invertMatch)
	script
		property _mainList : mainList
		property _filterList : filterList
		property _intersectList : {}
	end script
	tell result
		if invertMatch then
			repeat with x from 1 to mainList's length
				if its _filterList does not contain its _mainList's item x then set its _intersectList's end to its _mainList's item x
			end repeat
		else
			repeat with x from 1 to mainList's length
				if its _filterList contains its mainList's item x then set its _intersectList's end to its _mainList's item x
			end repeat
		end if
		its _intersectList
	end tell
end intersectLists