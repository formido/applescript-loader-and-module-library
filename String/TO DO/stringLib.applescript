property __name__ : "String"
property __version__ : "2.0.0"

property _EveryItem : missing value

on __load__(loader)
	tell loader
		set _EveryItem to loadLib("EveryItem")
	end tell
end __load__

(*
String -- basic ASCII string manipulation functions (change case, find & replace, etc)
Copyright (C) 2002 Hamish Sanderson [hhas@blueyonder.co.uk]

This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*)

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--mark PRIVATE STUFF<B

(*Note: Extra character sets can be added to this library to support machines using non-MacRoman (i.e. localised) character sets. Each must contain the following properties:

	¥ name -- name of character set
	¥ lowerCaseChars
	¥ upperCaseChars
	¥ accentedChars
	¥ unAccentedChars
	¥ unexpandedLig
	¥ expandedLig

You can use a copy of the MacRomanCharset script object as a model on which to base your own. Note, however, that the MacRomanCharset should not be changed or removed, and must remain the default charset (as found in the _currentCharset property). New charsets may also be submitted for inclusion in future releases of this library.

The object's name should also be added to the _supportedCharsets property so that it can be selected via the public selectCharset() call.*)

script MacRomanCharset
	property name : "MacRoman"
	property class : "charset"
	-------
	--A to Z
	property _lcAZ : "abcdefghijklmnopqrstuvwxyz"
	property _ucAZ : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	--diacriticals
	property _lcDia : "‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›¿œžŸØ"
	property _ucDia : "çËå€Ì‚ƒéæèêíëì„îñï…Í¯òôó†Ù"
	--diacriticals as plain chars
	property _lcDrm : "aaaaaaceeeeiiiinoooooouuuuy"
	property _ucDrm : "AAAAAACEEEEIIIINOOOOOOUUUUY"
	--ligatures
	property _lcLig : "¾Ï"
	property _ucLig : "®Î"
	-------
	property lowerCaseChars : _lcAZ & _lcDia & _lcLig
	property upperCaseChars : _ucAZ & _ucDia & _ucLig
	property accentedChars : _ucDia & _lcDia
	property unAccentedChars : _ucDrm & _lcDrm
	property unexpandedLig : "®¾ÎÏÞß"
	property expandedLig : {"AE", "ae", "OE", "oe", "fi", "fl"}
end script

--insert new charsets here

-------

property _supportedCharsets : {MacRomanCharset}

property _currentCharset : MacRomanCharset --default charset is MacRoman

--mark -
-------

on _throwError(handlerName, errorMessage, errorNumber)
	set AppleScript's text item delimiters to {""} --reset TIDs to default
	error "An error occurred in stringLib's " & handlerName & "() handler: " & errorMessage number errorNumber
end _throwError

--mark -
-------
--private find-and-replace routines

property _maxBlockLength : 3600
--
on _adjustMaxBlockLength()
	set _maxBlockLength to ((_maxBlockLength) div 4) * 3
	return
end _adjustMaxBlockLength
--
on _specialTextItems(theString)
	try
		set textItemCount to count theString's text items
		set theList to {}
		set endLen to textItemCount mod _maxBlockLength
		repeat with eachBlock from 1 to (textItemCount - endLen) by _maxBlockLength
			set theList's end to theString's text items eachBlock thru (eachBlock + _maxBlockLength - 1)
		end repeat
		if endLen is not 0 then set theList's end to theString's text items -endLen thru -1
		return theList
	on error number -2706
		_adjustMaxBlockLength()
		return _specialTextItems(theString)
	end try
end _specialTextItems
--
(*on _specialParagraphs(theString)
	try
		set textItemCount to count theString's paragraphs
		set theList to {}
		set endLen to textItemCount mod _maxBlockLength
		repeat with eachBlock from 1 to (textItemCount - endLen) by _maxBlockLength
			set theList's end to theString's paragraphs eachBlock thru (eachBlock + _maxBlockLength - 1)
		end repeat
		if endLen is not 0 then set theList's end to theString's paragraphs -endLen thru -1
		return theList
	on error number -2706
		_adjustMaxBlockLength()
		return _specialTextItems(theString)
	end try
end _specialParagraphs*)

-------

--(note: for uppercasing/lowercasing/case-desensitising on SHORT strings, scan convert is fastest)
on _scanConvert(theString, fromChars, toChars)
	set oldTID to AppleScript's text item delimiters
	considering case and diacriticals
		set theList to {}
		repeat with eachchar in theString
			set eachchar to eachchar's contents
			if eachchar is in fromChars then
				set AppleScript's text item delimiters to eachchar
				(fromChars's text item 1's length) + 1
				set theList's end to toChars's item result as string
			else
				set theList's end to eachchar as string
			end if
		end repeat
		set AppleScript's text item delimiters to ""
		set theString to theList as string
		set AppleScript's text item delimiters to oldTID
		theString
	end considering
end _scanConvert

--(note: for uppercasing/lowercasing/case-desensitising on LONG strings, tidConvert is fastest)
on _tidConvert(theString, fromList, toList)
	set oldTID to AppleScript's text item delimiters
	repeat with x from 1 to fromList's length
		set AppleScript's text item delimiters to get fromList's item x
		try
			set tempList to theString's text items
		on error number -2706
			set tempList to _specialTextItems(theString)
		end try
		set AppleScript's text item delimiters to get toList's item x
		set theString to tempList as string
	end repeat
	set AppleScript's text item delimiters to oldTID
	theString
end _tidConvert

-------
--"makesafe" handlers for "safe" find-and-replace routines

property _ascii1 : ASCII character 1
--
on _makeSafe(theString)
	if theString contains my _ascii1 then error "Cannot perform safeFindAndReplace() on a string containing ASCII#1 characters."
	set AppleScript's text item delimiters to ""
	set tempList to _specialTextItems(theString)
	set AppleScript's text item delimiters to _ascii1
	_ascii1 & tempList
end _makeSafe
--
on _removeSafe(theString)
	findAndReplace(theString, _ascii1, "", {})
end _removeSafe

--mark -
-------
--white space chars for trim routines

on _getWhiteSpace()
	set theString to ""
	repeat with eachchar in {9, 10, 11, 12, 13, 32, 202}
		set theString to theString & (ASCII character eachchar)
	end repeat
end _getWhiteSpace
--
property _whiteSpace : _getWhiteSpace()

-------
--for normalising line breaks

property _LF : ASCII character 10
property _CR : ASCII character 13
property _CRLF : _CR & _LF

--mark -
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--mark PUBLIC HANDLERS<B

--config
on selectCharset(charsetName)
	try
		ignoring case and diacriticals
			repeat with eachSet in _supportedCharsets
				if eachSet's name is charsetName then
					set _currentCharset to eachSet's contents
					return eachSet's name
				end if
			end repeat
			error "Charset not found."
		end ignoring
	on error eMsg number eNum
		_throwError("selectCharset", eMsg, eNum)
	end try
end selectCharset

on listCharsets()
	set theList to {}
	repeat with eachSet in _supportedCharsets
		set theList's end to eachSet's name
	end repeat
	theList
end listCharsets

--mark -
-------
--offsets

on getFirstOffset(theString, findString)
	try
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to findString
		theString's first text item's length
		if result is theString's length then
			set theOffset to 0
		else
			set theOffset to result + 1
		end if
		set AppleScript's text item delimiters to oldTID
		theOffset
	on error eMsg number eNum
		_throwError("getFirstOffset", eMsg, eNum)
	end try
end getFirstOffset

on getLastOffset(theString, findString)
	try
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to findString
		theString's last text item's length
		if result is theString's length then
			set theOffset to 0
		else
			set theOffset to -(findString's length) - result
		end if
		set AppleScript's text item delimiters to oldTID
		theOffset
	on error eMsg number eNum
		_throwError("getLastOffset", eMsg, eNum)
	end try
end getLastOffset

on listAllOffsets(theString, findString, theSettings)
	try
		set theSettings to theSettings & {iCase:false, iDiacriticals:false}
		set oldTID to AppleScript's text item delimiters
		if theSettings's iDiacriticals then
			set theString to removeDiacriticals(theString)
			set findString to removeDiacriticals(findString)
		end if
		if theSettings's iCase then
			set theString to lowercaseString(theString)
			set findString to lowercaseString(findString)
		end if
		set offsetList to {}
		set newOffset to 1
		set AppleScript's text item delimiters to findString
		repeat (count theString's text items) - 1 times
			set theOffset to newOffset + ((theString's text newOffset thru -1)'s text item 1's length)
			set newOffset to theOffset + (findString's length)
			set offsetList's end to {theOffset, newOffset - 1}
		end repeat
		set AppleScript's text item delimiters to oldTID
		offsetList
	on error eMsg number eNum
		_throwError("listAllOffsets", eMsg, eNum)
	end try
end listAllOffsets

--mark -
-------
--find and replace

on replaceText(theString, fromString, toString)
	return simpleFindAndReplace(theString, fromString, toString)
end replaceText

on simpleFindAndReplace(theString, fromString, toString)
	try
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to fromString
		try
			set tempList to theString's text items
		on error number -2706
			set tempList to _specialTextItems(theString)
		end try
		set AppleScript's text item delimiters to toString
		set theString to tempList as string
		set AppleScript's text item delimiters to oldTID
		theString
	on error eMsg number eNum
		_throwError("simpleFindAndReplace", eMsg, eNum)
	end try
end simpleFindAndReplace

on findAndReplace(theString, fromString, toString, theSettings) --TO DO: add support for whole-word matching
	try
		set theSettings to theSettings & {iCase:false, iDiacriticals:false}
		if not theSettings's iCase and not theSettings's iDiacriticals then return simpleFindAndReplace(theString, fromString, toString)
		--
		set oldTID to AppleScript's text item delimiters
		copy theString to tempString
		if theSettings's iDiacriticals then
			set tempString to removeDiacriticals(tempString)
			set fromString to removeDiacriticals(fromString)
		end if
		if theSettings's iCase then
			set tempString to lowercaseString(tempString)
			set fromString to lowercaseString(fromString)
		end if
		--
		set theList to {}
		set theOffset to 1
		set AppleScript's text item delimiters to fromString
		repeat with x from 1 to (count tempString's text items)
			set newOffset to theOffset + (tempString's text item x's length)
			if theOffset is less than or equal to (newOffset - 1) then
				set theList's end to theString's text theOffset thru (newOffset - 1)
			else
				set theList's end to ""
			end if
			set theOffset to newOffset + (fromString's length)
		end repeat
		set AppleScript's text item delimiters to toString
		set theString to theList as string
		set AppleScript's text item delimiters to oldTID
		theString
	on error eMsg number eNum
		_throwError("findAndReplace", eMsg, eNum)
	end try
end findAndReplace

on multiFindAndReplace(theString, fromList, toList, theSettings) --TO DO: add iCase support
	try
		set theSettings to theSettings & {doSafely:true}
		if not theSettings's doSafely then return _tidConvert(theString, fromList, toList)
		--
		if fromList's length is 1 then return findAndReplace(theString, fromList, toList, {})
		set oldTID to AppleScript's text item delimiters
		set theString to _makeSafe(theString)
		repeat with x from 1 to fromList's length
			set AppleScript's text item delimiters to _makeSafe(fromList's item x)
			set tempList to _specialTextItems(theString)
			set AppleScript's text item delimiters to get toList's item x
			set theString to tempList as string
		end repeat
		set theString to _removeSafe(theString)
		set AppleScript's text item delimiters to oldTID
		theString
	on error eMsg number eNum
		_throwError("multiFindAndReplace", eMsg, eNum)
	end try
end multiFindAndReplace

--mark -
-------
--case change

on uppercaseString(theString)
	try
		if theString's length is less than 130 then
			_scanConvert(theString, _currentCharset's lowerCaseChars, _currentCharset's upperCaseChars)
		else
			_tidConvert(theString, _currentCharset's lowerCaseChars, _currentCharset's upperCaseChars)
		end if
	on error eMsg number eNum
		_throwError("uppercaseString", eMsg, eNum)
	end try
end uppercaseString

on lowercaseString(theString)
	try
		if theString's length is less than 130 then
			_scanConvert(theString, _currentCharset's upperCaseChars, _currentCharset's lowerCaseChars)
		else
			_tidConvert(theString, _currentCharset's upperCaseChars, _currentCharset's lowerCaseChars)
		end if
	on error eMsg number eNum
		_throwError("lowercaseString", eMsg, eNum)
	end try
end lowercaseString

on capitaliseString(theString)
	try
		set tempList to {}
		set offsetPos to 1
		set wordCount to 1
		set oldTID to AppleScript's text item delimiters
		tell lowercaseString(theString)
			--get each word
			repeat with wordCount from 1 to count its words
				tell (its text offsetPos thru word wordCount)
					set wordLength to its first word's length
					try
						set tempList's end to its text 1 thru ((its length) - wordLength)
					on error number -1728
					end try
					tell its first word
						set AppleScript's text item delimiters to its first character
						tell _currentCharset
							(its lowerCaseChars's first text item's length) + 1
							set tempList's end to its upperCaseChars's character result
						end tell
						if wordLength is not 1 then set tempList's end to its text 2 thru -1
					end tell
					set offsetPos to offsetPos + (its length)
				end tell
			end repeat
			--get any text after last word
			((its text last word thru -1)'s length) - (its last word's length)
			if result is not 0 then set tempList's end to its text -result thru -1
		end tell
		set AppleScript's text item delimiters to ""
		set theString to tempList as string
		set AppleScript's text item delimiters to oldTID
		theString
	on error eMsg number eNum
		_throwError("capitaliseString", eMsg, eNum)
	end try
end capitaliseString

--mark -
-------

on removeDiacriticals(theString)
	try
		if theString's length is less than 130 then
			_scanConvert(theString, _currentCharset's accentedChars, _currentCharset's unAccentedChars)
		else
			_tidConvert(theString, _currentCharset's accentedChars, _currentCharset's unAccentedChars)
		end if
	on error eMsg number eNum
		_throwError("removeDiacriticals", eMsg, eNum)
	end try
end removeDiacriticals

on expandLigatures(theString)
	try
		_tidConvert(theString, _currentCharset's unexpandedLig, _currentCharset's expandedLig)
	on error eMsg number eNum
		_throwError("expandLigatures", eMsg, eNum)
	end try
end expandLigatures

--mark -
-------

on reverseString(theString)
	try
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ""
		set newString to _specialTextItems(theString)
		repeat with eachItem in newString
			set eachItem's contents to eachItem's reverse
		end repeat
		set newString to newString's reverse as string
		set AppleScript's text item delimiters to oldTID
		newString
	on error eMsg number eNum
		_throwError("reverseString", eMsg, eNum)
	end try
end reverseString

--mark -
-------
--trim

on trimStartOfString(theString)
	try
		try
			repeat while theString's first character is in _whiteSpace
				set theString to theString's text 2 thru -1
			end repeat
			return theString
		on error number -1728
			return ""
		end try
	on error eMsg number eNum
		_throwError("trimStartOfString", eMsg, eNum)
	end try
end trimStartOfString

on trimEndOfString(theString)
	try
		try
			repeat while theString's last character is in _whiteSpace
				set theString to theString's text 1 thru -2
			end repeat
			return theString
		on error number -1728
			return ""
		end try
	on error eMsg number eNum
		_throwError("trimEndOfString", eMsg, eNum)
	end try
end trimEndOfString

on trimString(theString)
	return trimStartOfString(trimEndOfString(theString))
end trimString

--mark -
-------

on normaliseLineBreaksForUnix(theString)
	return _tidConvert(theString, {_CRLF, _CR}, {_LF, _LF})
end normaliseLineBreaksForUnix

on normaliseLineBreaksForMac(theString)
	return _tidConvert(theString, {_CRLF, _LF}, {_CR, _CR})
end normaliseLineBreaksForMac

on normaliseLineBreaksForWindows(theString)
	return _tidConvert(theString, {_CRLF, _CR, _LF}, {_LF, _LF, _CRLF})
end normaliseLineBreaksForWindows

--mark -
-------

on compareStrings(string1, string2)
	try
		if string1's length is not string2's length then return false
		set y to 1
		repeat ((string1's length) - 1) div 30766 times
			if string1's text y thru (y + 30766) is not string2's text y thru (y + 30766) then return false
			set y to y + 30766
		end repeat
		if string1's text y thru -1 is not string2's text y thru -1 then return false
		return true
	on error eMsg number eNum
		_throwError("compareStrings", eMsg, eNum)
	end try
end compareStrings

--mark -
-------

on splitString(txt, delim)
	set oldTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	try
		set lst to txt's text items
	on error number -2706
		set lst to _EveryItem's everyTextItem(txt)
	end try
	set AppleScript's text item delimiters to oldTIDs
	return lst
end splitString

on joinList(lst, delim)
	set oldTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set txt to lst as string
	set AppleScript's text item delimiters to oldTIDs
	return txt
end joinList