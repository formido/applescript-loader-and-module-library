property __name__ : "Strftime"
property __version__ : "1.0.0"
property __lv__ : 1

on __load__(loader)
end __load__

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
--mark PRIVATE<B<U

script _converters
	on monthToInteger(theMonth)
		--(note: it may be ugly, but it's fast)
		if theMonth is January then
			1
		else if theMonth is February then
			2
		else if theMonth is March then
			3
		else if theMonth is April then
			4
		else if theMonth is May then
			5
		else if theMonth is June then
			6
		else if theMonth is July then
			7
		else if theMonth is August then
			8
		else if theMonth is September then
			9
		else if theMonth is October then
			10
		else if theMonth is November then
			11
		else if theMonth is December then
			12
		else
			error "Invalid value (not a month)."
		end if
	end monthToInteger
	--
	on weekdayToIntegerMon(theWeekday)
		if theWeekday is Monday then
			1
		else if theWeekday is Tuesday then
			2
		else if theWeekday is Wednesday then
			3
		else if theWeekday is Thursday then
			4
		else if theWeekday is Friday then
			5
		else if theWeekday is Saturday then
			6
		else if theWeekday is Sunday then
			7
		else
			error "Invalid value (not a weekday)."
		end if
	end weekdayToIntegerMon
	--
	on weekdayToIntegerSun(theWeekday)
		if theWeekday is Sunday then return 0
		weekdayToIntegerMon(theWeekday)
	end weekdayToIntegerSun
	-------
	-------
	property upperAMMeridian : "AM"
	property lowerAMMeridian : "am"
	property upperPMMeridian : "PM"
	property lowerPMMeridian : "pm"
	--
	on setMeridianStrings(amUppercase, amLowercase, pmUppercase, pmLowercase)
		considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
			if amUppercase is "" or amLowercase is "" then error "parameters contained empty string(s)."
			if amUppercase is not amLowercase or pmUppercase is not pmLowercase then error "parameters contained mismatched upper/lowercase value(s)."
			if amUppercase is pmUppercase then error "parameters contained identical am/pm strings."
		end considering
		set upperAMMeridian to amUppercase
		set lowerAMMeridian to amLowercase
		set upperPMMeridian to pmUppercase
		set lowerPMMeridian to pmLowercase
		return
	end setMeridianStrings
	-------
	property standardTimeZoneCode : ""
	property summerTimeZoneCode : ""
	property standardTimeToGMTOffset : 0
	--
	on setTimeZoneCodes(standardTimeString, summerTimeString, standardTimeToGMTOffsetReal)
		if standardTimeString is "" and summerTimeString is not "" then error "mismatched parameters."
		if summerTimeString is "" then set summerTimeString to standardTimeString
		set standardTimeZoneCode to standardTimeString
		set summerTimeZoneCode to summerTimeString
		set standardTimeToGMTOffset to standardTimeToGMTOffsetReal
		return
	end setTimeZoneCodes
	-------
	-------
	property Jan1970 : date "Thursday, January 1, 1970 12:00:00 AM"
	-------
	--add leading zeros/spaces
	property addLeadingBool : true
	--
	on optionAddLeadingZeros(theNumber, finalLength) -- (zeros only added if addLeadingBool is true)
		if addLeadingBool then
			("000" & theNumber)'s text -finalLength thru -1
		else
			theNumber as string
		end if
	end optionAddLeadingZeros
	--
	on optionAddLeadingSpaces(theNumber, finalLength) -- (spaces only added if addLeadingBool is true)
		if addLeadingBool then
			("   " & theNumber)'s text -finalLength thru -1
		else
			theNumber as string
		end if
	end optionAddLeadingSpaces
	--
	on alwaysAddLeadingZeros(theNumber, finalLength)
		("000" & theNumber)'s text -finalLength thru -1
	end alwaysAddLeadingZeros
	----------------------
	----------------------
	--converters
	on |%a|(theDate)
		|%A|(theDate)'s text 1 thru 3
	end |%a|
	on |%A|(theDate)
		try
			theDate's weekday as string
		on error number -1700
			{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}'s item |%u|(theDate)
		end try
	end |%A|
	on |%b|(theDate)
		|%B|(theDate)'s text 1 thru 3
	end |%b|
	on |%B|(theDate)
		try
			theDate's month as string
		on error number -1700
			{"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}'s item |%m|(theDate)
		end try
	end |%B|
	on |%c|(theDate)
		|%a|(theDate) & " " & |%d|(theDate) & " " & |%b|(theDate) & " " & |%Y|(theDate) & " " & |%r|(theDate) & " " & |%z|(theDate) --e.g. "Wed 07 Nov 2001 11:07:02 PM +0000" - not quite standard, but pretty close to redhat linux (which uses %Z, not %z)
	end |%c|
	on |%C|(theDate)
		optionAddLeadingZeros((theDate's year as string)'s text 1 thru 2, 2) --TO CHECK!!
	end |%C|
	on |%d|(theDate)
		optionAddLeadingZeros(theDate's day, 2)
	end |%d|
	on |%D|(theDate)
		|%m|(theDate) & "/" & |%d|(theDate) & "/" & |%y|(theDate)
	end |%D|
	on |%e|(theDate)
		optionAddLeadingSpaces(theDate's day, 2)
	end |%e|
	on |%F|(theDate)
		|%Y|(theDate) & "-" & |%m|(theDate) & "-" & |%d|(theDate)
	end |%F|
	on |%g|(theDate) --ISO 8601 year (two digits, 00-99)  [see also %G]
		|%G|(theDate)'s text -2 thru -1
	end |%g|
	on |%G|(theDate) --ISO 8601 year (four digits)
		copy theDate to b
		set b's month to January
		set b's day to 1
		set theDay to b's weekday
		set x to weekdayToIntegerMon(theDay)
		if theDay is in {Monday, Tuesday, Wednesday, Thursday} then set x to x + 7
		((theDate - b) + ((x - 1) * 86400)) div 604800
		if result is 0 then
			(theDate's year) - 1
		else if result is 53 and theDay is in {Monday, Tuesday, Wednesday} then
			(theDate's year) + 1
		else
			theDate's year
		end if
		alwaysAddLeadingZeros(result, 4)
	end |%G|
	on |%h|(theDate)
		|%b|(theDate)
	end |%h|
	on |%H|(theDate)
		optionAddLeadingZeros((theDate's time) div 3600, 2)
	end |%H|
	on |%I|(theDate)
		((theDate's time) div 3600) mod 12
		if result as integer = 0 then
			"12"
		else
			optionAddLeadingZeros(result, 2)
		end if
	end |%I|
	on |%j|(theDate)
		copy theDate to b
		set b's month to January
		set b's day to 1
		optionAddLeadingZeros(1 + (theDate - b) div 86400, 3)
	end |%j|
	on |%k|(theDate)
		optionAddLeadingSpaces((theDate's time) div 3600, 2)
	end |%k|
	on |%l|(theDate)
		((theDate's time) div 3600) mod 12
		if result as integer = 0 then
			"12"
		else
			optionAddLeadingSpaces(result, 2)
		end if
	end |%l|
	on |%m|(theDate)
		optionAddLeadingZeros(monthToInteger(theDate's month), 2)
	end |%m|
	on |%M|(theDate)
		alwaysAddLeadingZeros(((theDate's time) div 60) mod 60, 2)
	end |%M|
	on |%n|(theDate)
		(return)
	end |%n|
	on |%p|(theDate)
		if theDate's time is less than 43200 then
			upperAMMeridian
		else
			upperPMMeridian
		end if
	end |%p|
	on |%P|(theDate)
		if theDate's time is less than 43200 then
			lowerAMMeridian
		else
			lowerPMMeridian
		end if
	end |%P|
	on |%r|(theDate)
		|%I|(theDate) & ":" & |%M|(theDate) & ":" & |%S|(theDate) & " " & |%p|(theDate)
	end |%r|
	on |%R|(theDate)
		|%H|(theDate) & ":" & |%M|(theDate)
	end |%R|
	on |%s|(theDate)
		theDate - ((my Jan1970) - (-(time to GMT)))
	end |%s|
	on |%S|(theDate)
		alwaysAddLeadingZeros((theDate's time) mod 60, 2)
	end |%S|
	on |%t|(theDate)
		tab
	end |%t|
	on |%T|(theDate)
		|%H|(theDate) & ":" & |%M|(theDate) & ":" & |%S|(theDate)
	end |%T|
	on |%u|(theDate)
		weekdayToIntegerMon(theDate's weekday)
	end |%u|
	on |%U|(theDate) --week of year as number (00�53), Sunday is first day of week 1
		copy theDate to b
		set b's month to January
		set b's day to 1
		weekdayToIntegerSun(b's weekday)
		optionAddLeadingZeros(((theDate - b) + ((result - 1) * 86400)) div 604800, 2)
	end |%U|
	on |%v|(theDate)
		|%e|(theDate) & "-" & |%b|(theDate) & "-" & |%Y|(theDate)
	end |%v|
	on |%V|(theDate) --ISO 8601 week number - week of year as number (01 to 53), Monday is first day of week, week 1 is first week that has 4 or more days in the year
		copy theDate to b
		set b's month to January
		set b's day to 1
		set theDay to b's weekday
		set x to weekdayToIntegerMon(theDay)
		if theDay is in {Monday, Tuesday, Wednesday, Thursday} then set x to x + 7
		((theDate - b) + ((x - 1) * 86400)) div 604800
		if result is 0 then
			"53"
		else if result is 53 and theDay is in {Monday, Tuesday, Wednesday} then
			"01"
		else
			alwaysAddLeadingZeros(result, 2)
		end if
	end |%V|
	on |%w|(theDate)
		weekdayToIntegerSun(theDate's weekday)
	end |%w|
	on |%W|(theDate) --week number of year (00�53), Monday is first day of week 1
		copy theDate to b
		set b's month to January
		set b's day to 1
		weekdayToIntegerMon(b's weekday)
		optionAddLeadingZeros(((theDate - b) + ((result - 1) * 86400)) div 604800, 2)
	end |%W|
	on |%x|(theDate)
		theDate's date string
	end |%x|
	on |%X|(theDate)
		theDate's time string
	end |%X|
	on |%y|(theDate)
		alwaysAddLeadingZeros(theDate's year, 2)
	end |%y|
	on |%Y|(theDate)
		optionAddLeadingZeros(theDate's year, 4)
	end |%Y|
	on |%z|(theDate)
		set timeToGMT to time to GMT
		(timeToGMT div 60) mod 60
		set mins to alwaysAddLeadingZeros((timeToGMT div 60) mod 60, 2)
		timeToGMT div 3600
		if result < -9 then
			(result as string) & mins
		else if result < 0 then
			"-0" & ((result as string)'s item -1) & mins
		else if result > 9 then
			"+" & result & mins
		else
			"+0" & result & mins
		end if
	end |%z|
	on |%Z|(theDate) --NOT PROPERLY SUPPORTED
		if standardTimeToGMTOffset is (time to GMT) then
			standardTimeZoneCode
		else
			summerTimeZoneCode
		end if
	end |%Z|
	--
	--assemble all the 'converters' into a list so that they can be accessed by index value
	property strfList : {|%A|, |%B|, |%C|, |%D|, "%E", |%F|, |%G|, |%H|, |%I|, "%J", "%K", "%L", |%M|, "%N", "%O", |%P|, "%Q", |%R|, |%S|, |%T|, |%U|, |%V|, |%W|, |%X|, |%Y|, |%Z|, |%a|, |%b|, |%c|, |%d|, |%e|, "%f", |%g|, |%h|, "%i", |%j|, |%k|, |%l|, |%m|, |%n|, "%o", |%p|, "%q", |%r|, |%s|, |%t|, |%u|, |%v|, |%w|, |%x|, |%y|, |%z|, ""}
	property strfListKey : "%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	property theHandler : {}
end script

on _Strftime(theDate, formatString, leadingZeros)
	tell _converters
		--throw error if parameters are incorrect classes
		if theDate's class is not date then error "Date parameter isn't a date object." number -1704
		if formatString's class is not string then error "FormatString parameter isn't a string." number -1704
		--setup
		set its addLeadingBool to leadingZeros
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "%"
		set formatString to formatString's text items
		set itemCount to 2
		--process each special character in turn
		repeat until itemCount is greater than formatString's length
			formatString's item itemCount
			if result is "" then --catch if character is % (i.e. escaped %)
				set replacementString to "%"
				set itemCount to itemCount + 1
			else
				set conversionChar to result's first character
				set AppleScript's text item delimiters to conversionChar
				set its theHandler to its strfList's item (its strfListKey's text item 1's length)
				try
					set replacementString to its theHandler(theDate) --note: throws a -1708 error for invalid characters
				on error eMsg number -1708 --trap any invalid char and pass it unchanged
					set replacementString to "%" & conversionChar
				end try
			end if
			--update formatString's item itemCount
			try
				formatString's item itemCount
				if result's length is less than 2 then
					set formatString's item itemCount to replacementString
				else
					set formatString's item itemCount to replacementString & result's text 2 thru -1
				end if
			on error eMsg number -1728 --trap error caused if last char in formatString is unescaped "%"
				exit repeat
			end try
			set itemCount to itemCount + 1
		end repeat
		--tidy up, return result
		set AppleScript's text item delimiters to ""
		set formatString to formatString as string
		set AppleScript's text item delimiters to oldTID
		set its addLeadingBool to true
		formatString
	end tell
end _Strftime

--mark -
-----------------------------------------------------------------------------
--mark PUBLIC<B<U

on |strftime|(theDate, formatString)
	_Strftime(theDate, formatString, true)
end |strftime|

on strftimeLite(theDate, formatString)
	_Strftime(theDate, formatString, false)
end strftimeLite

--

on setMeridians(amUppercase, amLowercase, pmUppercase, pmLowercase)
	try
		_converters's setMeridianStrings(amUppercase as string, amLowercase as string, pmUppercase as string, pmLowercase as string)
	on error eMsg number eNum
		error "Can't set meridian strings: " & eMsg number eNum
	end try
end setMeridians


on setTimeZoneCodes(standardTimeString, summerTimeString, standardTimeToGMTOffset)
	try
		_converters's setTimeZoneCodes(standardTimeString as string, summerTimeString as string, standardTimeToGMTOffset as real)
	on error eMsg number eNum
		error "Can't set time-zone codes: " & eMsg number eNum
	end try
end setTimeZoneCodes
