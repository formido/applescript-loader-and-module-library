property __name__ : "Date"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
--mark DEPENDENCIES<B<U

property _International : missing value
property _DateFormatters : missing value
property _DateParsers : missing value
property _FormatStringParser : missing value

on __load__(loader)
	tell loader
		set _International to loadComponent("International")
		set _DateFormatters to loadComponent("DateFormatters")
		set _DateParsers to loadComponent("DateParsers")
		set _FormatStringParser to loadComponent("FormatStringParser")
	end tell
	return
end __load__

-----------------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

property _weekdays : {Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday}
property _months : {January, February, March, April, May, June, July, August, September, October, November, December}

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeFormatter(formatString)
	-- e.g. set intlDateFormatter to makeFormatter("yyyy-mm-dd HH:MM:SS z")
	return makeFormatterForLanguage(formatString, "English")
end makeFormatter

on makeParser(formatString)
	-- e.g. set intlDateParser to makeParser("yyyy-mm-dd HH:MM:SS z")
	return makeParserForLanguage(formatString, "English")
end makeParser

--

on makeFormatterForLanguage(formatString, languageName)
	try
		set parsedFormat to _FormatStringParser's parseFormatString(formatString)
		set lang to _International's getLanguage(languageName)
		return _DateFormatters's makeFormatter(parsedFormat, formatString, lang, a reference to me)
	on error eMsg number eNum
		error "Can't makeFormatter: " & eMsg number eNum
	end try
end makeFormatterForLanguage

on makeParserForLanguage(formatString, languageName)
	try
		set parsedFormat to _FormatStringParser's parseFormatString(formatString)
		set lang to _International's getLanguage(languageName)
		return _DateParsers's makeParser(parsedFormat, formatString, lang, a reference to me)
	on error eMsg number eNum
		error "Can't makeParser: " & eMsg number eNum
	end try
end makeParserForLanguage

on listLanguages()
	return _International's listLanguages()
end listLanguages

-------
--mark -

-- TO DO: clean up code

on dateToRecord(theDate)
	try
		return {weekday:theDate's weekday, day:theDate's day, month:theDate's month, year:theDate's year, hours:�
			(theDate's time) div 3600, minutes:(theDate's time) div 60 mod 60, seconds:(theDate's time) mod 60}
	on error
		error "Error: not a date object."
	end try
end dateToRecord

on recordToDate(dateRec)
	try
		set theDate to (current date)
		set dateRec to dateRec & {weekday:missing value, day:theDate's day, month:theDate's month, year:theDate's year, hours:0, minutes:0, seconds:0}
		tell dateRec
			try
				set theDate's year to its year as integer
				if result is less than 1 or result is greater than 9999 then error
			on error
				error "Invalid year."
			end try
			--
			try
				if {its month} is in _months then
					set theDate's month to its month
				else
					set theDate's month to my integerToMonth(its month)
				end if
			on error
				error "Invalid month."
			end try
			--
			try
				set theDate's day to its day as integer
				if result is less than 1 or result is greater than my daysInMonth(theDate) then error
			on error
				error "Invalid day."
			end try
			--
			if its hours is less than 0 or its hours is greater than 23 then error "Invalid hours."
			if its minutes is less than 0 or its minutes is greater than 59 then error "Invalid minutes."
			if its seconds is less than 0 or its seconds is greater than 61 then error "Invalid seconds."
			set theDate's time to ((its hours) * 60 + (its minutes)) * 60 + (its seconds)
			--
			if its weekday is not missing value then
				if its weekday's class is in {integer, real} then set its weekday to my integerToWeekday(its weekday)
				if its weekday is not theDate's weekday then error "Invalid weekday."
			end if
		end tell
		theDate
	on error eMsg number eNum
		error "Error: couldn't convert record to date: " & eMsg number eNum
	end try
end recordToDate

-------
--mark -

on daysInMonth(theDate) -- modified from Nigel Garvey's Date Tips package
	copy theDate to d
	set d's day to 32
	set d's day to 1
	return day of (d - 1 * days)
end daysInMonth

--mark -

on weekdayToInteger(theWeekday)
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
	end if
	error "Can't convert weekdayToInteger: not a weekday." number -1704
end weekdayToInteger

on integerToWeekday(int)
	try
		set int to int as integer
		if int is less than 1 then error
		return item int of _weekdays
	on error
		error "Can't convert integerToWeekday: not an integer from 1 to 7."
	end try
end integerToWeekday

on monthToInteger(theMonth)
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
	end if
	error "Can't convert monthToInteger: not a month." number -1704
end monthToInteger

on integerToMonth(int)
	try
		set int to int as integer
		if int is less than 1 then error
		return item int of _months
	on error
		error "Can't convert integerToMonth: not an integer from 1 to 12."
	end try
end integerToMonth

-------
--mark -

on localTimeToGMT(theDate)
	return theDate - (time to GMT)
end localTimeToGMT

on GMTToLocalTime(theDate)
	return theDate - (-(time to GMT))
end GMTToLocalTime
