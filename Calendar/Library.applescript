property __name__ : "Calendar"
property __version__ : "2.0.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

-----------------------------------------------------------------------------
--mark -
--mark PRIVATE<B

on _padList(daysList, theDate, sundayFirst, padValue) --changes daysList in-place
	if (sundayFirst is true) then
		set weekdaysList to {Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday}
	else
		set weekdaysList to {Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday}
	end if
	set firstDayOfMonth to firstDayOfMonth(theDate)
	repeat with x from 1 to 7
		if weekdaysList's item x is firstDayOfMonth then exit repeat
		set daysList's beginning to padValue
	end repeat
	repeat (42 - (count daysList)) times
		set daysList's end to padValue
	end repeat
	return
end _padList

on _groupByWeek(theList)
	set newList to {}
	repeat with x from 1 to (count theList) by 7
		set newList's end to theList's items x thru (x + 6)
	end repeat
	return newList
end _groupByWeek

--

on _concatList(theList, theDelimiter)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimiter as string
	set resultString to theList as string
	set AppleScript's text item delimiters to oldTID
	return resultString
end _concatList

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B

on daysInMonth(theDate)
	try
		copy theDate to d
		set d's day to 32
		set d's day to 1
		return day of (d - 86400)
	on error eMsg number eNum
		error "Can't get daysInMonth: " & eMsg number eNum
	end try
end daysInMonth

on firstDayOfMonth(theDate)
	try
		copy theDate to newDate
		set newDate's day to 1
		return newDate's weekday
	on error eMsg number eNum
		error "Can't get firstDayOfMonth: " & eMsg number eNum
	end try
end firstDayOfMonth

--

on daysByWeek(theDate, sundayFirst)
	set weeksList to daysByWeekWithPadding(theDate, sundayFirst, missing value)
	repeat with eachWeek in weeksList
		set eachWeek's contents to eachWeek's integers
	end repeat
	if weeksList's last item is {} then set weeksList to weeksList's items 1 thru -2
	return weeksList
end daysByWeek

on daysByWeekWithPadding(theDate, sundayFirst, padValue)
	try
		if theDate's class is not date then error "bad theDate parameter (not a date)." number -1703
		if (padValue's class is not in {integer, string}) and (padValue is not missing value) then error "Invalid blank value." number -1703
		set daysList to {}
		repeat with x from 1 to daysInMonth(theDate)
			set daysList's end to x
		end repeat
		_padList(daysList, theDate, sundayFirst, padValue)
		return _groupByWeek(daysList)
	on error eMsg number eNum
		error "Couldn't build list of days: " & eMsg number eNum
	end try
end daysByWeekWithPadding

--

on tableForMonth(theDate, sundayFirst)
	try
		if theDate's class is not date then error "bad theDate parameter (not a date)." number -1703
		set daysList to {}
		repeat with x from 1 to daysInMonth(theDate)
			set daysList's end to (" " & x)'s text -2 thru -1
		end repeat
		_padList(daysList, theDate, sundayFirst, "  ")
		set weeksList to _groupByWeek(daysList)
		--
		repeat with eachWeek in weeksList
			set eachWeek's contents to _concatList(eachWeek, tab)
		end repeat
		if (sundayFirst is true) then
			set weeksList's beginning to "Su	Mo	Tu	We	Th	Fr	Sa"
		else
			set weeksList's beginning to "Mo	Tu	We	Th	Fr	Sa	Su"
		end if
		return _concatList(weeksList, return)
	on error eMsg number eNum
		error "Couldn't build month table: " & eMsg number eNum
	end try
end tableForMonth