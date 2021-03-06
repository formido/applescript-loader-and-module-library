property __name__ : "ConvertToString"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
--DEPENDENCIES

on __load__(loader)
end __load__

-----------------------------------------------------------------------------
--PRIVATE

property _CTSTextFrom : missing value
property _CTSTextTo : missing value

on _init()
	try
		get Monday as weekday
		error "Can't initialise ConvertToString library." number 200
	on error eMsg number -1700
	end try
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "Monday"
	set _CTSTextFrom to ((eMsg's text item 1)'s length) + 1
	set _CTSTextTo to -((eMsg's text item 2)'s length) - 1
	set AppleScript's text item delimiters to oldTID
	return
end _init

-----------------------------------------------------------------------------
--PUBLIC

on toString(val) --the 'polite' method, guaranteed safe
	init()
	set str to fastToString(val)
	init()
	return str
end toString

on fastToString(val) --faster when doing many conversions as doesn't initialise library's properties each time; for good housekeeping, remember to call init at beginning of any script which uses fastToString
	try
		get val as weekday
		error "Can't fastToString." number 200
	on error eMsg number -1700
		if _CTSTextFrom is missing value then _init()
		return eMsg's text (_CTSTextFrom) thru (_CTSTextTo)
	end try
end fastToString

on init() --clears persistent properties; avoids problems if system's language changes
	set _CTSTextFrom to missing value
	set _CTSTextTo to missing value
	return
end init
