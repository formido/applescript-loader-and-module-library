property __name__ : "String"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

-----------------------------------------------------------------------------
-- DEPENDENCIES

property _EveryItem : missing value

on __load__(loader)
	set _EveryItem to loader's loadLib("EveryItem")
end __load__

-----------------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

property _lcChars : "abcdefghijklmnopqrstuvwxyz"
property _ucChars : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

-------
--mark -
-- find-and-replace

-- (note: for uppercasing/lowercasing/case-desensitising on SHORT strings, scan convert is fastest)
on _scanConvert(str, fromChars, toChars)
	set oldTIDs to AppleScript's text item delimiters
	try
		set lst to {}
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			repeat with eachchar in str
				set eachchar to eachchar's contents
				if eachchar is in fromChars then
					set AppleScript's text item delimiters to eachchar
					set lst's end to toChars's item ((fromChars's text item 1's length) + 1) as string
				else
					set lst's end to eachchar as string
				end if
			end repeat
		end considering
		set AppleScript's text item delimiters to ""
		set str to lst as string
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error eMsg number eNum
	end try
end _scanConvert

-- (note: for uppercasing/lowercasing/case-desensitising on LONG strings, tidConvert is fastest)
on _tidConvert(str, fromList, toList)
	set oldTIDs to AppleScript's text item delimiters
	try
		repeat with x from 1 to fromList's length
			set AppleScript's text item delimiters to get fromList's item x
			try
				set lst to str's text items
			on error number -2706
				set lst to _EveryItem's _specialTextItems(str)
			end try
			set AppleScript's text item delimiters to get toList's item x
			set str to lst as string
		end repeat
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error eMsg number eNum
	end try
end _tidConvert

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U
--mark constants<B

property linefeed : ASCII character 10
property crlf : return & linefeed
property _whiteSpace : space & tab & return & linefeed

--mark -
--mark commands<B

on findFirst(str, findString)
	set oldTIDs to AppleScript's text item delimiters
	try
		set str to str as string
		set AppleScript's text item delimiters to findString
		set len to str's first text item's length
		set AppleScript's text item delimiters to oldTIDs
		if len is str's length then
			return 0
		else
			return len + 1
		end if
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't findFirst: " & eMsg number eNum
	end try
end findFirst

on findLast(str, findString)
	set oldTIDs to AppleScript's text item delimiters
	try
		set str to str as string
		set AppleScript's text item delimiters to findString as string
		set len to str's last text item's length
		set AppleScript's text item delimiters to oldTIDs
		if len is str's length then
			return 0
		else
			return -(findString's length) - len
		end if
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't findLast: " & eMsg number eNum
	end try
end findLast

--mark -
-------
--find and replace

on replaceText(str, fromString, toString)
	set oldTIDs to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to fromString as string
		try
			set lst to (str as string)'s text items
		on error number -2706 -- handle AS stack overflow bug if more than approx. 4000 text items
			set lst to _EveryItem's _specialTextItems(str as string)
		end try
		set AppleScript's text item delimiters to toString as string
		set str to lst as string
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't replaceText: " & eMsg number eNum
	end try
end replaceText

--mark -
-------
--case change

on toUpper(str)
	try
		set str to str as string
		if str's length is less than 130 then
			_scanConvert(str, _lcChars, _ucChars)
		else
			_tidConvert(str, _lcChars, _ucChars)
		end if
	on error eMsg number eNum
		error "Can't toUpper: " & eMsg number eNum
	end try
end toUpper

on toLower(str)
	try
		set str to str as string
		if str's length is less than 130 then
			_scanConvert(str, _ucChars, _lcChars)
		else
			_tidConvert(str, _ucChars, _lcChars)
		end if
	on error eMsg number eNum
		error "Can't toLower: " & eMsg number eNum
	end try
end toLower

on toCaps(str)
	set oldTIDs to AppleScript's text item delimiters
	try
		set str to toLower(str)
		set lst to {}
		set len to (str's text 1 thru (word 1)'s length) - (str's word 1's length)
		if len is greater than 0 then
			set lst's end to str's text 1 thru len
			set str to str's text (len + 1) thru -1
		end if
		repeat (count str's words) - 1 times
			set len to (str's text 1 thru (word 2)'s length) - (str's word 2's length)
			set AppleScript's text item delimiters to (get str's character 1)
			set lst's end to (_ucChars's character ((_lcChars's text item 1's length) + 1)) & str's text 2 thru len
			set str to str's text (len + 1) thru -1
		end repeat
		set AppleScript's text item delimiters to (get str's character 1)
		set lst's end to (_ucChars's character ((_lcChars's text item 1's length) + 1))
		if str's length is greater than 1 then set lst's end to str's text 2 thru -1
		set AppleScript's text item delimiters to ""
		set str to lst as string
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't toCaps: " & eMsg number eNum
	end try
end toCaps

--mark -
-------

on toMac(str)
	try
		return _tidConvert(str as string, {crlf, linefeed}, {return, return})
	on error eMsg number eNum
		error "Can't toMac: " & eMsg number eNum
	end try
end toMac

on toUnix(str)
	try
		return _tidConvert(str as string, {crlf, return}, {linefeed, linefeed})
	on error eMsg number eNum
		error "Can't toUnix: " & eMsg number eNum
	end try
end toUnix

on toWin(str)
	try
		return _tidConvert(str as string, {crlf, return, linefeed}, {linefeed, linefeed, crlf})
	on error eMsg number eNum
		error "Can't toWin: " & eMsg number eNum
	end try
end toWin

--mark -
-------
--clean, trim

on normaliseWhiteSpace(str)
	set oldTIDs to AppleScript's text item delimiters
	try
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			repeat with charRef in tab & linefeed & return
				set AppleScript's text item delimiters to (get charRef's contents)
				try
					set lst to str's text items
				on error number -2706 -- stack overflow
					set lst to _EveryItem's specialTextItems(str)
				end try
				if (count of lst) is greater than 1 then
					set AppleScript's text item delimiters to space
					set str to lst as string
				end if
			end repeat
		end considering
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't normaliseWhiteSpace: " & eMsg number eNum
	end try
end normaliseWhiteSpace

on removeExtraSpaces(str)
	set oldTIDs to AppleScript's text item delimiters
	try
		repeat with removeStrRef in {"        ", "  "}
			set removeStr to removeStrRef's contents
			repeat
				set AppleScript's text item delimiters to removeStr
				try
					set lst to str's text items
				on error number -2706 -- stack overflow
					set lst to _EveryItem's specialTextItems(str)
				end try
				if (count of lst) is 1 then exit repeat
				set AppleScript's text item delimiters to " "
				set str to lst as string
			end repeat
		end repeat
		set AppleScript's text item delimiters to oldTIDs
		return str
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't removeDuplicateSpaces: " & eMsg number eNum
	end try
end removeExtraSpaces

on trimStart(str)
	try
		set str to str as string
		try
			repeat while str's first character is in _whiteSpace
				set str to str's text 2 thru -1
			end repeat
			return str
		on error number -1728
			return ""
		end try
	on error eMsg number eNum
		error "Can't trimStart: " & eMsg number eNum
	end try
end trimStart

on trimEnd(str)
	try
		set str to str as string
		try
			repeat while str's last character is in _whiteSpace
				set str to str's text 1 thru -2
			end repeat
			return str
		on error number -1728
			return ""
		end try
	on error eMsg number eNum
		error "Can't trimEnd: " & eMsg number eNum
	end try
end trimEnd

on trimBoth(str)
	try
		return trimStart(trimEnd(str))
	on error eMsg number eNum
		error "Can't trimBoth: " & eMsg number eNum
	end try
end trimBoth

--mark -
-------

on isEqual(str1, str2)
	try
		if str1's length is not str2's length then return false
		set idx to 1
		repeat ((str1's length) - 1) div 30766 times
			if str1's text idx thru (idx + 30766) is not str2's text idx thru (idx + 30766) then return false
			set idx to idx + 30766
		end repeat
		if str1's text idx thru -1 is not str2's text idx thru -1 then return false
		return true
	on error eMsg number eNum
		error "Can't isEqual: " & eMsg number eNum
	end try
end isEqual

--mark -
-------

on splitText(txt, delim)
	set oldTIDs to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to (delim as string)
		try
			set lst to (txt as string)'s text items
		on error number -2706
			set lst to _EveryItem's everyTextItem(txt)
		end try
		set AppleScript's text item delimiters to oldTIDs
		return lst
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't splitText: " & eMsg number eNum
	end try
end splitText

on joinList(lst, delim)
	set oldTIDs to AppleScript's text item delimiters
	try
		set AppleScript's text item delimiters to (delim as string)
		set txt to lst as string
		set AppleScript's text item delimiters to oldTIDs
		return txt
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't joinList: " & eMsg number eNum
	end try
end joinList

--mark -
-------

on multiplyText(str, n)
	try
		set n to n as integer
		if n < 1 then return {}
		set mk to 1
		set lst to {str as string}
		repeat until mk is greater than or equal to n
			set lst to lst & lst
			set mk to mk * 2
		end repeat
		return joinList(lst's items 1 thru n, "")
	on error eMsg number eNum
		error "Can't multiplyText: " & eMsg number eNum
	end try
end multiplyText

on quoteText(txt)
	try
		return "\"" & replaceText(replaceText(txt, "\\", "\\\\"), "\"", "\\\"") & "\""
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't quoteText: " & eMsg number eNum
	end try
end quoteText

on chompText(txt)
	try
		set txt to txt as string
		if txt's length is greater than 0 then
			considering hyphens, punctuation and white space
				if {txt's last character} is in {linefeed, return} then
					if txt's length is 1 then
						return ""
					else
						return txt's text 1 thru -2
					end if
				end if
			end considering
		end if
	on error eMsg number eNum
		error "Can't chompText: " & eMsg number eNum
	end try
end chompText