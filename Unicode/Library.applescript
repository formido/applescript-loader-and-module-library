property __name__ : "Unicode"
property __version__ : "0.2.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _FormatStringParser : missing value

-------

on __load__(loader)
	set _FormatStringParser to loader's loadLib("FormatStringParser")
end __load__

----------------------------------------------------------------------
--mark _
--mark PRIVATE<B<U

-- compilation requires Standard Additions
-- load tables at compile-time

property _tableFile : alias (((path to scripts folder from local domain) as Unicode text) & "ASLibraries:Unicode:Data:CharacterTables")

-- uChar tables, 2048 * 32-character tables (this is much faster than one huge 65536-character table)
script _kCharTable
	property lst : read _tableFile as list
end script

property _charTableBlockSize : count first item of lst of _kCharTable

--

on _hexCharToNum(char)
	if char > "9" then
		if char is in "aAbBcC" then -- minor speed optimisation
			if char is in "aA" then
				return 10
			else if char is in "bB" then
				return 11
			else
				return 12
			end if
		else if char is in "dD" then
			return 13
		else if char is in "eE" then
			return 14
		else if char is in "fF" then
			return 15
		else
			error "invalid hex value" number -1704
		end if
	else if char ³ "0" then
		return char as integer
	else
		error "invalid hex value" number -1704
	end if
end _hexCharToNum

property _hexChars : "0123456789ABCDEF"

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on joinList(lst, delim)
	(*	Use this command in place of 'lst as Unicode text when joining lists.
		Note: this particular implementation provides a workaround for a bug in list-to-Unicode text 
		coercion that corrupts many characters. Performance will be relatively poor on large lists 
		and/or large strings compared to coercion, though it's been optimised as much as possible. *)
	try
		script k
			property l : lst's items
		end script
		if (count k's l each record) is not 0 then error "can't make a record into Unicode text." number -1704
		if (count k's l each list) is not 0 then
			repeat with i from 1 to (count k's l)
				get k's l's item i
				if class of result is list then set k's l's item i to joinList(result, delim)
			end repeat
		end if
		if delim's class is in {list, record} then error "delim is wrong type." number -1703
		set delim to delim as Unicode text
		if (count k's l) is 0 then
			set txt to "" as Unicode text
		else if (count k's l) is 1 then
			set txt to k's l's first item as Unicode text
		else
			repeat until (count of k's l) is 1
				set k's l's last item to k's l's last item as Unicode text
				repeat with i from 1 to ((count k's l) - 1) by 2
					set k's l's item i to ((k's l's item i) as Unicode text) & delim & k's l's item (i + 1)
					set k's l's item (i + 1) to missing value
				end repeat
				set k's l to every Unicode text of k's l
			end repeat
			set txt to k's l's first item
		end if
		return txt
	on error eMsg number eNum
		error "Can't joinList: " & eMsg number eNum
	end try
end joinList

on splitText(txt, delim)
	set oldTIDs to AppleScript's text item delimiters
	try
		if delim's class is in {list, record} then error "delim is wrong type." number -1703
		set txt to txt as Unicode text
		set AppleScript's text item delimiters to (get delim as Unicode text)
		set lst to txt's text items
		set AppleScript's text item delimiters to oldTIDs
		return lst
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't splitText: " & eMsg number eNum
	end try
end splitText

on replaceText(theText, fromTxt, toTxt)
	try
		return joinList(splitText(theText, fromTxt), toTxt)
	on error eMsg number eNum
		error "Can't replaceText: " & eMsg number eNum
	end try
end replaceText

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

-- uNum tables

on _joinTable(r1, r2)
	return joinList(_kCharTable's lst's items r1 thru r2, "")
end _joinTable

-- optimise search speed in low ranges (includes common ASCII characters)
property _uTable1 : _joinTable(1, 80)
-- further split added between 220 & 221 to avoid bizzare disappearing-character AS bug which
-- occurs if 220 and 221 are concatenated
property _uTable2 : _joinTable(81, 1760)
property _uTable3 : _joinTable(1761, 2048)

property _uTable1Len : _uTable1's length
property _uTable2Len : _uTable1Len + (_uTable2's length)
property _uTable3Len : _uTable2Len + (_uTable3's length)

on _verify() -- (just in case!)
	set {a, b, c} to {_uTable1's length, _uTable2's length, _uTable3's length}
	if a + b + c is not 65536 then
		error "uTables are corrupted: " & a & "+" & b & "+" & c & "=" & a + b + c
	end if
end _verify

property _ : _verify()

property _emptyUTxt : "" as Unicode text -- constant

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on uChar(num)
	try
		set num to num as integer
		if num < 0 or num > 65535 then
			error "character number " & num & " is out of range." number -1728
		end if
		return _kCharTable's lst's item (num div _charTableBlockSize + 1)'s character (num mod _charTableBlockSize + 1)
	on error eMsg number eNum
		error "Can't uChar: " & eMsg number eNum
	end try
end uChar

property _tableLen : count first item of _kCharTable's lst
property _tableCount : count _kCharTable's lst

on uNum(char)
	-- this doesn't work right either, as AS can't do comparisons correctly
	-- e.g. uChar(65300) = uChar(52) --> true !!!
	try
		set char to char as Unicode text
		if char's length is not 1 then error "not a single character." number -1704
		set oldTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to char
		set len to count first text item of _uTable1
		if len is _uTable1Len then
			set len to _uTable1Len + (count first text item of _uTable2)
			if len is _uTable2Len then
				set len to _uTable2Len + (count first text item of _uTable3)
				if len is _uTable3Len then
					error "not found." number -1728
				end if
			end if
		end if
		set AppleScript's text item delimiters to oldTIDs
		return len
	on error eMsg number eNum
		error "Can't uNum: " & eMsg number eNum
	end try
end uNum

(* -- Do not use! - Standard Additions offset command is buggy (ignores diacriticals, and maybe other stuff too)
 on uNum(char)
	try
		set char to char as Unicode text
		if char's length is not 1 then error "not a single character." number -1704
		set len to offset of char in _uTable1
		if len is 0 then
			set len to _uTable1Len + (offset of char in _uTable2)
			if len is _uTable1Len then
				set len to _uTable2Len + (offset of char in _uTable3)
				if len is _uTable2Len then
					error "not found." number -1728
				end if
			end if
		end if
		return len - 1
	on error eMsg number eNum
		error "Can't uNum: " & eMsg number eNum
	end try
end uNum *)

on uxChar(hexStr)
	try
		set txt to hexStr as string
		if txt's length is not 4 then error "invalid hex value" number -1704
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			return uChar(_hexCharToNum(txt's character 1) * 4096 + _hexCharToNum(txt's character 2) Â
				* 256 + _hexCharToNum(txt's character 3) * 16 + _hexCharToNum(txt's character 4))
		end considering
	on error eMsg number eNum
		error "Can't uxChar: " & eMsg number eNum
	end try
end uxChar

on uxNum(char)
	try
		set num to uNum(char)
		return _hexChars's item (num div 4096 + 1) & _hexChars's item (num div 256 mod 16 + 1) & _hexChars's item (num div 16 mod 16 + 1) & _hexChars's item (num mod 16 + 1)
	on error eMsg number eNum
		error "Can't uxNum: " & eMsg number eNum
	end try
end uxNum

--

on uText(theFormat) -- convert a string containing Unicode character codes, e.g. %x01AB, to Unicode text
	try
		set unicodeRef to a reference to me
		script receiver
			property parent : _FormatStringParser's makeEventReceiver()
			property _unicodeRef : unicodeRef
			--
			property uTxt : "" as Unicode text
			property _postProcess : false
			
			on processText(txt)
				if _postProcess then
					if txt's length < 4 then
						error "invalid hex value." number -1703
					else if txt's length is 4 then
						set uTxt to uTxt & _unicodeRef's uxChar(txt's text 1 thru 4)
					else
						set uTxt to uTxt & _unicodeRef's uxChar(txt's text 1 thru 4) & txt's text 5 thru -1
					end if
					set _postProcess to false
				else
					set uTxt to uTxt & txt
				end if
			end processText
			
			on processControlChar(char)
				if char is "x" then
					set _postProcess to true
				else
					error "invalid control character \"" & char & "\"." number -1703
				end if
			end processControlChar
		end script
		_FormatStringParser's parseFormatString(theFormat as Unicode text, "%", receiver)
		return receiver's uTxt
	on error eMsg number eNum
		error "Can't uText: " & eMsg number eNum
	end try
end uText

-- constants

property space : (ASCII character 32) as Unicode text
property tab : (ASCII character 9) as Unicode text
property linefeed : (ASCII character 10) as Unicode text
property return : (ASCII character 13) as Unicode text
property linesep : uChar(8232)
property parasep : uChar(8233)

--

on chompText(txt) -- remove trailing linefeed/return (if any) from string/unicode text
	try
		if (count txt each character) is greater than 0 then
			considering hyphens, punctuation and white space
				if txt's last character is in {linefeed, return} then
					if (count of txt) is 1 then
						set txt to _emptyUTxt
					else
						set txt to txt's text 1 thru -2
					end if
				end if
			end considering
		end if
		return txt
	on error eMsg number eNum
		error "Can't chompText: " & eMsg number eNum
	end try
end chompText