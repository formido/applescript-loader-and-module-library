property __name__ : "Strftime"
property __version__ : "1.0.0"
property __lv__ : 1

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
--mark PRIVATE<B<U
--mark constants<B

property _unixEpoch : date "Thursday, January 1, 1970 12:00:00 AM"

--mark state<B
-- internal state in a library; oh, the naughtiness!!

property _standardTimeZoneCode : ""
property _summerTimeZoneCode : ""
property _standardTimeToGMTOffset : 0

property _addLeadingZeros : true

--mark -
--mark commands<B

on _monthToInteger(theMonth) -- (ugly but fast)
	if theMonth is January then
		return 1
	else if theMonth is February then
		return 2
	else if theMonth is March then
		return 3
	else if theMonth is April then
		return 4
	else if theMonth is May then
		return 5
	else if theMonth is June then
		return 6
	else if theMonth is July then
		return 7
	else if theMonth is August then
		return 8
	else if theMonth is September then
		return 9
	else if theMonth is October then
		return 10
	else if theMonth is November then
		return 11
	else if theMonth is December then
		return 12
	else
		error "Invalid value (not a month)."
	end if
end _monthToInteger

on _weekdayToIntegerMon(theWeekday)
	if theWeekday is Monday then
		return 1
	else if theWeekday is Tuesday then
		return 2
	else if theWeekday is Wednesday then
		return 3
	else if theWeekday is Thursday then
		return 4
	else if theWeekday is Friday then
		return 5
	else if theWeekday is Saturday then
		return 6
	else if theWeekday is Sunday then
		return 7
	else
		error "Invalid value (not a weekday)."
	end if
end _weekdayToIntegerMon

on _weekdayToIntegerSun(theWeekday)
	if theWeekday is Sunday then
		return 0
	else
		return _weekdayToIntegerMon(theWeekday)
	end if
end _weekdayToIntegerSun

on _addLeadingZerosOptional(theNumber, finalLength) -- (zeros only added if _addLeadingZeros is true)
	if _addLeadingZeros then
		return ("000" & theNumber)'s text -finalLength thru -1
	else
		return theNumber as string
	end if
end _addLeadingZerosOptional

on _addLeadingSpacesOptional(theNumber, finalLength) -- (spaces only added if _addLeadingZeros is true)
	if _addLeadingZeros then
		return ("   " & theNumber)'s text -finalLength thru -1
	else
		return theNumber as string
	end if
end _addLeadingSpacesOptional

on _addLeadingZerosAlways(theNumber, finalLength)
	return ("000" & theNumber)'s text -finalLength thru -1
end _addLeadingZerosAlways

--mark -
--mark converters<B

on |%a|(theDate)
	return |%A|(theDate)'s text 1 thru 3
end |%a|

on |%A|(theDate)
	try
		return theDate's weekday as string
	on error number -1700
		return {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}'s item |%u|(theDate)
	end try
end |%A|

on |%b|(theDate)
	return |%B|(theDate)'s text 1 thru 3
end |%b|

on |%B|(theDate)
	try
		return theDate's month as string
	on error number -1700
		return {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}'s item |%m|(theDate)
	end try
end |%B|

on |%c|(theDate)
	return |%a|(theDate) & " " & |%d|(theDate) & " " & |%b|(theDate) & " " & |%Y|(theDate) & " " & |%r|(theDate) & " " & |%z|(theDate) --e.g. "Wed 07 Nov 2001 11:07:02 PM +0000" - not quite standard, but pretty close to redhat linux (which uses %Z, not %z)
end |%c|

on |%C|(theDate)
	return _addLeadingZerosOptional((theDate's year as string)'s text 1 thru 2, 2) --TO CHECK!!
end |%C|

on |%d|(theDate)
	return _addLeadingZerosOptional(theDate's day, 2)
end |%d|

on |%D|(theDate)
	return |%m|(theDate) & "/" & |%d|(theDate) & "/" & |%y|(theDate)
end |%D|

on |%e|(theDate)
	return _addLeadingSpacesOptional(theDate's day, 2)
end |%e|

on |%F|(theDate)
	return |%Y|(theDate) & "-" & |%m|(theDate) & "-" & |%d|(theDate)
end |%F|

on |%g|(theDate) --ISO 8601 year (two digits, 00-99)  [see also %G]
	return |%G|(theDate)'s text -2 thru -1
end |%g|

on |%G|(theDate) --ISO 8601 year (four digits)
	copy theDate to b
	set b's month to January
	set b's day to 1
	set theDay to b's weekday
	set x to _weekdayToIntegerMon(theDay)
	if theDay is in {Monday, Tuesday, Wednesday, Thursday} then set x to x + 7
	((theDate - b) + ((x - 1) * 86400)) div 604800
	if result is 0 then
		(theDate's year) - 1
	else if result is 53 and theDay is in {Monday, Tuesday, Wednesday} then
		(theDate's year) + 1
	else
		theDate's year
	end if
	return _addLeadingZerosAlways(result, 4)
end |%G|

on |%h|(theDate)
	return |%b|(theDate)
end |%h|

on |%H|(theDate)
	return _addLeadingZerosOptional((theDate's time) div 3600, 2)
end |%H|

on |%I|(theDate)
	((theDate's time) div 3600) mod 12
	if result as integer = 0 then
		return "12"
	else
		return _addLeadingZerosOptional(result, 2)
	end if
end |%I|

on |%j|(theDate)
	copy theDate to b
	set b's month to January
	set b's day to 1
	return _addLeadingZerosOptional(1 + (theDate - b) div 86400, 3)
end |%j|

on |%k|(theDate)
	return _addLeadingSpacesOptional((theDate's time) div 3600, 2)
end |%k|

on |%l|(theDate)
	((theDate's time) div 3600) mod 12
	if result as integer = 0 then
		return "12"
	else
		return _addLeadingSpacesOptional(result, 2)
	end if
end |%l|

on |%m|(theDate)
	return _addLeadingZerosOptional(_monthToInteger(theDate's month), 2)
end |%m|

on |%M|(theDate)
	return _addLeadingZerosAlways(((theDate's time) div 60) mod 60, 2)
end |%M|

on |%n|(theDate)
	return return
end |%n|

on |%p|(theDate)
	if theDate's time is less than 43200 then
		return "AM"
	else
		return "PM"
	end if
end |%p|

on |%P|(theDate)
	if theDate's time is less than 43200 then
		return "am"
	else
		return "pm"
	end if
end |%P|

on |%r|(theDate)
	return |%I|(theDate) & ":" & |%M|(theDate) & ":" & |%S|(theDate) & " " & |%p|(theDate)
end |%r|

on |%R|(theDate)
	return |%H|(theDate) & ":" & |%M|(theDate)
end |%R|

on |%s|(theDate)
	return theDate - (_unixEpoch - (-(time to GMT)))
end |%s|

on |%S|(theDate)
	return _addLeadingZerosAlways((theDate's time) mod 60, 2)
end |%S|

on |%t|(theDate)
	return tab
end |%t|

on |%T|(theDate)
	return |%H|(theDate) & ":" & |%M|(theDate) & ":" & |%S|(theDate)
end |%T|

on |%u|(theDate)
	return _weekdayToIntegerMon(theDate's weekday)
end |%u|

on |%U|(theDate) --week of year as number (00Ð53), Sunday is first day of week 1
	copy theDate to b
	set b's month to January
	set b's day to 1
	_weekdayToIntegerSun(b's weekday)
	return _addLeadingZerosOptional(((theDate - b) + ((result - 1) * 86400)) div 604800, 2)
end |%U|

on |%v|(theDate)
	return |%e|(theDate) & "-" & |%b|(theDate) & "-" & |%Y|(theDate)
end |%v|

on |%V|(theDate) --ISO 8601 week number - week of year as number (01 to 53), Monday is first day of week, week 1 is first week that has 4 or more days in the year
	copy theDate to b
	set b's month to January
	set b's day to 1
	set theDay to b's weekday
	set x to _weekdayToIntegerMon(theDay)
	if theDay is in {Monday, Tuesday, Wednesday, Thursday} then set x to x + 7
	((theDate - b) + ((x - 1) * 86400)) div 604800
	if result is 0 then
		return "53"
	else if result is 53 and theDay is in {Monday, Tuesday, Wednesday} then
		return "01"
	else
		return _addLeadingZerosAlways(result, 2)
	end if
end |%V|

on |%w|(theDate)
	return _weekdayToIntegerSun(theDate's weekday)
end |%w|

on |%W|(theDate) --week number of year (00Ð53), Monday is first day of week 1
	copy theDate to b
	set b's month to January
	set b's day to 1
	_weekdayToIntegerMon(b's weekday)
	return _addLeadingZerosOptional(((theDate - b) + ((result - 1) * 86400)) div 604800, 2)
end |%W|

on |%x|(theDate)
	return theDate's date string
end |%x|

on |%X|(theDate)
	return theDate's time string
end |%X|

on |%y|(theDate)
	return _addLeadingZerosAlways(theDate's year, 2)
end |%y|

on |%Y|(theDate)
	return _addLeadingZerosOptional(theDate's year, 4)
end |%Y|

on |%z|(theDate)
	set timeToGMT to time to GMT
	(timeToGMT div 60) mod 60
	set mins to _addLeadingZerosAlways((timeToGMT div 60) mod 60, 2)
	timeToGMT div 3600
	if result < -9 then
		return (result as string) & mins
	else if result < 0 then
		return "-0" & ((result as string)'s item -1) & mins
	else if result > 9 then
		return "+" & result & mins
	else
		return "+0" & result & mins
	end if
end |%z|

on |%Z|(theDate) --NOT PROPERLY SUPPORTED
	if _standardTimeToGMTOffset is (time to GMT) then
		return _standardTimeZoneCode
	else
		return _summerTimeZoneCode
	end if
end |%Z|

--mark -
--mark format<B

--assemble all the 'converters' into a list so that they can be accessed by index value
property _strfList : {|%A|, |%B|, |%C|, |%D|, "%E", |%F|, |%G|, |%H|, |%I|, "%J", "%K", "%L", |%M|, "%N", "%O", |%P|, "%Q", |%R|, |%S|, |%T|, |%U|, |%V|, |%W|, |%X|, |%Y|, |%Z|, |%a|, |%b|, |%c|, |%d|, |%e|, "%f", |%g|, |%h|, "%i", |%j|, |%k|, |%l|, |%m|, |%n|, "%o", |%p|, "%q", |%r|, |%s|, |%t|, |%u|, |%v|, |%w|, |%x|, |%y|, |%z|, ""}
property _strfListKey : "%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
property _handler : {}


on _Strftime(theDate, formatString, leadingZeros)
	considering case, diacriticals, expansion, hyphens, punctuation and white space
		set theDate to theDate as date
		set formatString to formatString as string
		--setup
		set _addLeadingZeros to leadingZeros
		set oldTIDs to AppleScript's text item delimiters
		try
			set AppleScript's text item delimiters to "%"
			set formatChunks to formatString's text items
			set itemCount to 2
			--process each special character in turn
			repeat until itemCount is greater than formatChunks's length
				formatChunks's item itemCount
				if result is "" then --catch if character is % (i.e. escaped %)
					set replacedStr to "%"
					set itemCount to itemCount + 1
				else
					set conversionChar to result's first character
					set AppleScript's text item delimiters to conversionChar
					set _handler to _strfList's item (_strfListKey's text item 1's length) -- handler object assignment = HACK!!!
					try
						set replacedStr to _handler(theDate) --note: throws a -1708 error for invalid characters
					on error eMsg number -1708 --trap any invalid char and pass it unchanged
						set replacedStr to "%" & conversionChar
					end try
				end if
				--update formatString's item itemCount
				try
					formatChunks's item itemCount
					if result's length is less than 2 then
						set formatChunks's item itemCount to replacedStr
					else
						set formatChunks's item itemCount to replacedStr & result's text 2 thru -1
					end if
				on error eMsg number -1728 --trap error caused if last char in formatString is unescaped "%"
					exit repeat
				end try
				set itemCount to itemCount + 1
			end repeat
			--tidy up, return result
			set AppleScript's text item delimiters to ""
			set res to formatChunks as string
			set AppleScript's text item delimiters to oldTIDs
			return res
		on error eMsg number eNum
			set AppleScript's text item delimiters to oldTIDs
			error eMsg number eNum
		end try
	end considering
end _Strftime

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on |strftime|(theDate, formatString)
	try
		return _Strftime(theDate, formatString, true)
	on error eMsg number eNum
		error "Can't strftime: " & eMsg number eNum
	end try
end |strftime|

on strftime2(theDate, formatString)
	try
		return _Strftime(theDate, formatString, false)
	on error eMsg number eNum
		error "Can't strftime2: " & eMsg number eNum
	end try
end strftime2

--

on setTimeZoneCodes(standardTime, summerTime, standardTimeToGMTOffset)
	try
		set standardTime to standardTime as string
		set summerTime to summerTime as string
		set standardTimeToGMTOffset to standardTimeToGMTOffset as real
		if standardTime is "" and summerTime is not "" then error "mismatched parameters."
		if summerTime is "" then set summerTime to standardTime
		set _standardTimeZoneCode to standardTime
		set _summerTimeZoneCode to summerTime
		set _standardTimeToGMTOffset to standardTimeToGMTOffset
		return
	on error eMsg number eNum
		error "Can't setTimeZoneCodes: " & eMsg number eNum
	end try
end setTimeZoneCodes