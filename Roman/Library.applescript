property __name__ : "Roman"
property __version__ : "1.0.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

-- load tables at compile-time

property _support : "/Library/Scripts/ASLibraries/Roman/Data/"

on _read(f)
	return read ((_support & f) as POSIX file)
end _read

property _fromUpperTable : _read("UpperRomanToInteger.txt") & return
property _fromLowerTable : _read("LowerRomanToInteger.txt") & return
property _fromTableLen : count _fromUpperTable each paragraph
property _INVALID : 3179

-- have to split table lists into two else AS errors when saving as it can't linearize lists over approx 4000 items
script _toUC
	property lst1 : paragraphs of _read("IntegerToUppercaseRoman1.txt")
	property lst2 : paragraphs of _read("IntegerToUppercaseRoman2.txt")
end script
script _toLC
	property lst1 : paragraphs of _read("IntegerToLowercaseRoman1.txt")
	property lst2 : paragraphs of _read("IntegerToLowercaseRoman2.txt")
end script
property _toTable1Len : count _toUC's lst1

--

on _tableLookup(str, fromTable)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to (return & str & return)
	set int to count (fromTable's first text item) each paragraph
	set AppleScript's text item delimiters to oldTID
	if int is _fromTableLen then error number _INVALID
	return int
end _tableLookup

--

on _toRoman(int, tableObj)
	set int to int as integer
	if int < 1 or int > 4999 then error (int as string) & " is out of range (1-4999)." number -1720
	if int > _toTable1Len then
		return tableObj's lst2's item (int - _toTable1Len)
	else
		return tableObj's lst1's item int
	end if
end _toRoman


----------------------------------------------------------------------
-- PUBLIC

on toRoman(int)
	try
		return _toRoman(int, _toUC)
	on error eMsg number eNum
		error "Can't toRoman: " & eMsg number eNum
	end try
end toRoman

on toLowerRoman(int)
	try
		return _toRoman(int, _toLC)
	on error eMsg number eNum
		error "Can't toLowerRoman: " & eMsg number eNum
	end try
end toLowerRoman

on fromRoman(str)
	try
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			set str to str as string
			if str contains tab or str contains return then error number _INVALID
			set char1 to str's character 1
			if char1 is in "Mm" then
				if char1 is "M" then
					set tbl to _fromUpperTable
					set substr to "MMMM"
				else
					set tbl to _fromLowerTable
					set substr to "mmmm"
				end if
				repeat with i from 4 to 1 by -1
					if str begins with substr's text 1 thru i then
						if str's length is i then
							return i * 1000
						else
							return i * 1000 + _tableLookup(str's text (i + 1) thru -1, tbl)
						end if
					end if
				end repeat
			else if char1 is in "IVXLCD" then
				return _tableLookup(str, _fromUpperTable)
			else if char1 is in "ivxlcd" then
				return _tableLookup(str, _fromLowerTable)
			else
				error number _INVALID
			end if
		end considering
	on error eMsg number eNum
		if eNum is _INVALID then set {eMsg, eNum} to {"invalid value: \"" & str & "\"", -1704}
		error "Can't fromRoman: " & eMsg number eNum
	end try
end fromRoman

-------
--TESTS
--(*
toRoman(9) --499
{result, fromRoman(result)}
--*)

(*
repeat with i from 1 to 4999 -- sanity check
	if not i = fromRoman(toRoman(i)) then error i
	if not i = fromRoman(toLowerRoman(i)) then error i
end repeat
*)

--toRoman(1.0) --> "I"

--toRoman(0) -- error: out of range
--toRoman(5000) -- error: out of range
--fromRoman("") -- error: invalid value
--fromRoman("iI") -- error: invalid value
--fromRoman(tab & "i") -- error: invalid value
--fromRoman("mmmMi") -- error: invalid value
--fromRoman("mmmmmi") -- error: invalid value
--fromRoman("mmivx") -- error: invalid value
