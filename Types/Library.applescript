property __name__ : "Types"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _AssociativeList : missing value
property _Dictionary : missing value
property _Queue : missing value
property _Stack : missing value

on __load__(loader)
end __load__

-- note: uses static bindings to reduce loading time

on _load(cName)
	return load script POSIX file ("/Library/Scripts/ASLibraries/Types/Components/" & cName & ".scpt")
end _load

on _static()
	set _AssociativeList to _load("AssociativeList")
	set _Dictionary to _load("Dictionary")
	set _Queue to _load("Queue")
	set _Stack to _load("Stack")
	return
end _static

property _ : _static()

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeAssociativeList()
	return _AssociativeList's makeAssociativeList()
end makeAssociativeList

on makeAssociativeListConsideringCase()
	return _AssociativeList's makeAssociativeListConsideringCase()
end makeAssociativeListConsideringCase

--

on makeDict()
	return _Dictionary's makeDict()
end makeDict

on makeDictConsideringCase()
	return _Dictionary's makeDictConsideringCase()
end makeDictConsideringCase

on makeSDict()
	return _Dictionary's makeSDict()
end makeSDict

on makeSDictConsideringCase()
	return _Dictionary's makeSDictConsideringCase()
end makeSDictConsideringCase

--

on makeQueue()
	return _Queue's makeQueue()
end makeQueue

on makeStack()
	return _Stack's makeStack()
end makeStack