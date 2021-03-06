property __name__ : "DateParsers"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _ParserBase
	property _next : missing value
	property _trailingLen : missing value -- no. of non-significant chars to skip after a token
	
	on __trimDateStr(dateRec, len)
		set dateRec's dateStr to dateRec's dateStr's text (len + _trailingLen + 1) thru -1
	end __trimDateStr
	
	on __compareStartOfString(dateRec, lookupList, tokenName)
		set dateStr to dateRec's dateStr
		ignoring case and diacriticals
			repeat with idx from 1 to count of lookupList
				if dateStr begins with lookupList's item idx then
					__trimDateStr(dateRec, lookupList's item idx's length)
					return idx
				end if
			end repeat
		end ignoring
		error "unrecognised value for " & tokenName & ": \"" & dateStr & "\"" number 200
	end __compareStartOfString
	
	on __oneToTwoDigit(dateRec, tokenName)
		set {txt, char2} to dateRec's dateStr
		if txt is not in "1234567890" then error "illegal value for " & tokenName & ": \"" & txt & "\"" number 200
		if char2 is in "1234567890" then set txt to txt & char2
		__trimDateStr(dateRec, txt's length)
		return txt
	end __oneToTwoDigit
	
	on __twoDigit(dateRec, tokenName)
		set txt to dateRec's dateStr's text 1 thru 2
		if txt's character 1 is not in "1234567890" or txt's character 2 is not in "1234567890" then
			error "illegal value for " & tokenName & ": \"" & txt & "\"" number 200
		end if
		__trimDateStr(dateRec, 2)
		return txt
	end __twoDigit
	
	on __oneToFourDigit(dateRec, tokenName)
		set {txt, char2, char3, char4} to dateRec's dateStr
		if txt is not in "1234567890" then error "illegal value for " & tokenName & ": \"" & txt & "\"" number 200
		if char2 is in "1234567890" then
			set txt to txt & char2
			if char3 is in "1234567890" then
				set txt to txt & char3
				if char4 is in "1234567890" then
					set txt to txt & char4
				end if
			end if
		end if
		__trimDateStr(dateRec, txt's length)
		return txt
	end __oneToFourDigit
	
	on __fourDigit(dateRec, tokenName)
		set txt to dateRec's dateStr's text 1 thru 4
		if txt's character 1 is not in "1234567890" or txt's character 2 is not in "1234567890" or �
			txt's character 3 is not in "1234567890" or txt's character 4 is not in "1234567890" then
			error "illegal value for " & tokenName & ": \"" & txt & "\"" number 200
		end if
		__trimDateStr(dateRec, 4)
		return txt
	end __fourDigit
	
	--
	
	on eval(dateRec, lang)
		__eval(dateRec, lang)
		return _next's eval(dateRec, lang)
	end eval
end script

-------

script d
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's day to __oneToTwoDigit(dateRec, "d")
	end __eval
end script
script dd
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's day to __twoDigit(dateRec, "dd")
	end __eval
end script
script ddd
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's weekday to __compareStartOfString(dateRec, lang's shortWeekday, "ddd")
	end __eval
end script
script dddd
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's weekday to __compareStartOfString(dateRec, lang's longWeekday, "dddd")
	end __eval
end script
--
script m
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's month to __oneToTwoDigit(dateRec, "m")
	end __eval
end script
script mm
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's month to __twoDigit(dateRec, "mm")
	end __eval
end script
script mmm
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's month to __compareStartOfString(dateRec, lang's shortMonth, "mmm")
	end __eval
end script
script mmmm
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's month to __compareStartOfString(dateRec, lang's longMonth, "mmmm")
	end __eval
end script
--
script y
	property parent : _ParserBase
	on __eval(dateRec, lang) -- 1�4 digits
		set dateRec's year to __oneToFourDigit(dateRec, "y")
	end __eval
end script
script yy
	property parent : _ParserBase
	--
	on _calcYYYYFromYY(yy, centuryCutoff)
		set yy to yy as integer
		set thisCentury to ((current date)'s year) div 100 * 100
		if yy is less than or equal to centuryCutoff then
			return thisCentury + yy
		else
			return thisCentury - 100 + yy
		end if
	end _calcYYYYFromYY
	--
	on __eval(dateRec, lang) -- 2-digit
		set dateRec's year to _calcYYYYFromYY(__twoDigit(dateRec, "yy"), dateRec's centuryCutoff)
	end __eval
end script
script yyyy
	property parent : _ParserBase
	on __eval(dateRec, lang) -- 4-digit
		set dateRec's year to __fourDigit(dateRec, "yyyy")
	end __eval
end script
--
script h
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's hours to __oneToTwoDigit(dateRec, "h")
	end __eval
end script
script hh
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's hours to __twoDigit(dateRec, "hh")
	end __eval
end script
script |H|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's hours to __oneToTwoDigit(dateRec, "H")
	end __eval
end script
script |HH|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's hours to __twoDigit(dateRec, "HH")
	end __eval
end script
--
script |M|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's minutes to __oneToTwoDigit(dateRec, "M")
	end __eval
end script
script |MM|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's minutes to __twoDigit(dateRec, "MM")
	end __eval
end script
--
script |S|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's seconds to __oneToTwoDigit(dateRec, "S")
	end __eval
end script
script |SS|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateRec's seconds to __twoDigit(dateRec, "SS")
	end __eval
end script
--
script t
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateStr to dateRec's dateStr
		if dateStr begins with lang's pm's first character then
			set dateRec's isPM to true
		else if dateStr does not start with lang's am's first character then
			error "Invalid \"t\"."
		end if
		__trimDateStr(dateRec, 1)
	end __eval
end script
script tt
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateStr to dateRec's dateStr
		if dateStr begins with lang's pm then
			set dateRec's isPM to true
			__trimDateStr(dateRec, lang's pm's length)
		else if dateStr begins with lang's am then
			__trimDateStr(dateRec, lang's am's length)
		else
			error "Invalid \"tt\"."
		end if
	end __eval
end script
--
script |T|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateStr to dateRec's dateStr
		if dateStr begins with lang's |PM|'s first character then
			set dateRec's isPM to true
		else if dateStr does not start with lang's |AM|'s first character then
			error "Invalid \"T\"."
		end if
		__trimDateStr(dateRec, 1)
	end __eval
end script
script |TT|
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateStr to dateRec's dateStr
		if dateStr begins with lang's |PM| then
			set dateRec's isPM to true
			__trimDateStr(dateRec, lang's |PM|'s length)
		else if dateStr begins with lang's |AM| then
			__trimDateStr(dateRec, lang's |AM|'s length)
		else
			error "Invalid \"TT\"."
		end if
	end __eval
end script
--
script z
	property parent : _ParserBase
	on __eval(dateRec, lang)
		set dateStr to dateRec's dateStr
		set num to ((dateStr's text 2 thru 3) as integer) * 3600 + ((dateStr's text 4 thru 5) as integer) * 60
		if dateStr's first character is "+" then
			set dateRec's gmtOffset to num
		else if dateStr's first character is "-" then
			set dateRec's gmtOffset to -num
		else
			error "Invalid \"z\"."
		end if
		__trimDateStr(dateRec, 5)
	end __eval
end script

script _parsers
	property lst : {�
		d, dd, ddd, dddd, �
		m, mm, mmm, mmmm, �
		y, yy, missing value, yyyy, �
		h, hh, missing value, missing value, �
		|H|, |HH|, missing value, missing value, �
		|M|, |MM|, missing value, missing value, �
		|S|, |SS|, missing value, missing value, �
		t, tt, missing value, missing value, �
		|T|, |TT|, missing value, missing value, �
		z, missing value, missing value, missing value} -- (note: use missing value for unsupported codes)
end script

--

on _makeStartNode(lang, formatString, nextNode, leadingLen, DateRef) -- first node = start of string
	script
		property class : "DateParser"
		property _lang : lang
		property _formatString : formatString
		property _centuryCutoff : 49
		--
		property _next : nextNode
		property _leadingLen : leadingLen -- number of non-significant characters to skip at start of text being parsed
		property _DateRef : DateRef -- a ref to Date library
		-------
		on setCenturyCutoff(int)
			try
				set int to int as integer
				if int < 0 or int > 99 then
					error "out of range (0-99): " & int number -1704
				end if
				set _centuryCutoff to int
				return
			on error eMsg number eNum
				error "invalid centuryCutoff: " & eMsg number eNum
			end try
		end setCenturyCutoff
		-------
		on parseText(txt)
			try
				set baseDate to current date
				set txt to (txt's text (_leadingLen + 1) thru -1) & "    "
				set dateRec to {weekday:missing value, day:baseDate's day, month:�
					baseDate's month, year:baseDate's year, hours:0, minutes:0, seconds:�
					0, isPM:false, gmtOffset:missing value, dateStr:txt, centuryCutoff:_centuryCutoff}
				considering expansion, hyphens, punctuation and white space but ignoring case and diacriticals
					_next's eval(dateRec, _lang)
				end considering
				-- combine hours and meridian values; note that meridian has precedence over H/HH in determining morning or afternoon
				set hrs to dateRec's hours as integer
				if hrs < 0 or hrs > 23 then error "Hours is out of range."
				if dateRec's isPM then set dateRec's hours to (hrs mod 12) + 12
				return {_DateRef's recordToDate(dateRec), dateRec's gmtOffset}
			on error eMsg number eNum
				error "Can't parseText: " & eMsg number eNum
			end try
		end parseText
		-------
		on getProperties()
			return {class:my class, formatString:_formatString, languageName:_lang's name, centuryCutoff:_centuryCutoff}
		end getProperties
	end script
end _makeStartNode

on _makeNode(idx, trailingLen, nextNode)
	copy _parsers's lst's item idx to node
	if node is missing value then error "invalid format."
	set node's _trailingLen to trailingLen
	set node's _next to nextNode
	return node
end _makeNode

on _makeEndNode() -- last node = end of string
	script
		on eval(dateRec, lang)
			return dateRec
		end eval
	end script
end _makeEndNode

----------------------------------------------------------------------
-- PUBLIC

on makeParser(parsedFormat, formatString, lang, DateRef)
	
	set node to _makeEndNode()
	repeat with i from (count of parsedFormat) to 3 by -2
		set node to _makeNode(parsedFormat's item (i - 1), parsedFormat's item i's length, node)
	end repeat
	return _makeStartNode(lang, formatString, node, parsedFormat's first item's length, DateRef)
end makeParser

(*
-- TEST
script lang
	property am : "am"
	property pm : "pm"
	property |AM| : "AM"
	property |PM| : "PM"
end script
script _Date
	on recordToDate(rec)
		return rec
	end recordToDate
end script
log makeParser({"", 1, ".", 5, ".", 12, ".", 14, ".", 21, ""}, "d-m-yyyy hh:M", lang, _Date)'s parseText("3-4-1980 11:02.")
log makeParser({"", 18, ":", 22, ""}, "HH:MM", lang, _Date)'s parseText("13:02")'s item 1's hours --> "13"
log makeParser({"", 18, ":", 22, ""}, "HH:MM", lang, _Date)'s parseText("01:02")'s item 1's hours --> "01"
log makeParser({"", 18, ":", 22, " ", 29, ""}, "h:MM t", lang, _Date)'s parseText("01:02 a")'s item 1's hours --> "01"
log makeParser({"", 18, ":", 22, " ", 29, ""}, "h:MM t", lang, _Date)'s parseText("01:02 p")'s item 1's hours --> 13
log makeParser({"", 18, ":", 22, " ", 29, ""}, "h:MM t", lang, _Date)'s parseText("13:02 p")'s item 1's hours -->13
*)