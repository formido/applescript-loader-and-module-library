property __name__ : "FinderExtras"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value

on __load__(loader)
	set _List to loader's loadLib("List")
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _SortOnFirstItem
	property reverseSort : false
	on eval(sublst)
		return sublst's first item
	end eval
end script

on _srt(sortVals, itemRefs) -- uses Schwartzian transform to sort one list against another
	_List's recomposeList({sortVals, itemRefs})
	_List's powerSort(result, {_SortOnFirstItem}, 0)
	return second item of _List's recomposeList(result)
end _srt

----------------------------------------------------------------------
--PUBLIC

on trashSize()
	return size of (info for (path to trash))
end trashSize

on asAliasList(finderItems)
	try
		tell application "Finder"
			if finderItems's class is list then
				set aliasList to {}
				repeat with anItem in finderItems
					set aliasList's end to anItem as alias
				end repeat
			else
				try
					set aliasList to finderItems as alias list
				on error number -1700 -- "Can't make alias into a �class alst�."
					set aliasList to {finderItems as alias}
				end try
			end if
		end tell
		return aliasList
	on error eMsg number eNum
		error "Can't get asAliasList: " & eMsg number eNum
	end try
end asAliasList

on sortByName(finderReference)
	tell application "Finder" to set {keysList, itemsList} to {name, contents} of finderReference
	return _srt(keysList, itemsList)
end sortByName

on sortByDateCreated(finderReference)
	tell application "Finder" to set {keysList, itemsList} to {creation date, contents} of finderReference
	return _srt(keysList, itemsList)
end sortByDateCreated

on sortByDateModified(finderReference)
	tell application "Finder" to set {keysList, itemsList} to {modification date, contents} of finderReference
	return _srt(keysList, itemsList)
end sortByDateModified

