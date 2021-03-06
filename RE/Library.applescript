property __name__ : "RE"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

--property _Oyster : missing value
property _utf8match : missing value
property _utf8replace : missing value

-------

on __load__(loader)
	tell loader
		--set _Oyster to loadLib("Oyster")
		set _utf8match to loadTextComponent("utf8match")
		set _utf8replace to loadTextComponent("utf8replace")
	end tell
end __load__

----------------------------------------------------------------------
-- PRIVATE

on _reMatch(theText, matchPattern, formattingAs, flags)
	set shellScript to ("perl -e " as Unicode text) & quoted form of _utf8match & space & �
		quoted form of flags & space & quoted form of theText & space & �
		quoted form of matchPattern & space & quoted form of formattingAs
	return do shell script shellScript
end _reMatch

on _reReplace(theText, patternsList, flags)
	if patternsList's class is not list then error "patternsList isn't a list." number -1704
	set shellScript to ("perl -e " as Unicode text) & quoted form of _utf8replace & space & �
		quoted form of flags & space & quoted form of theText
	repeat with i from 1 to count patternsList by 2
		set shellScript to shellScript & space & �
			quoted form of (patternsList's item i) & space & �
			quoted form of (patternsList's item (i + 1))
	end repeat
	return do shell script shellScript
end _reReplace

----------------------------------------------------------------------
-- PUBLIC

on reMatch(theText, matchPattern, formattingAs)
	try
		_reMatch(theText, matchPattern, formattingAs, "gi")
	on error eMsg number eNum
		error "Can't reMatch: " & eMsg number eNum
	end try
end reMatch

on reMatchConsideringCase(theText, patternsList)
	try
		_reMatch(theText, patternsList, "g")
	on error eMsg number eNum
		error "Can't reMatchConsideringCase: " & eMsg number eNum
	end try
end reMatchConsideringCase

on reReplace(theText, patternsList)
	try
		_reReplace(theText, patternsList, "gi")
	on error eMsg number eNum
		error "Can't reReplace: " & eMsg number eNum
	end try
end reReplace

on reReplaceConsideringCase(theText, patternsList)
	try
		_reReplace(theText, patternsList, "g")
	on error eMsg number eNum
		error "Can't reReplaceConsideringCase: " & eMsg number eNum
	end try
end reReplaceConsideringCase