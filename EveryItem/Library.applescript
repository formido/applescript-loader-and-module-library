property __name__ : "EveryItem"
property __version__ : "1.0.0"
property __lv__ : 1

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
--mark -
--mark PRIVATE<B

property _blockLen : 3600

on _reduceBlockLen()
	set _blockLen to ((_blockLen) div 4) * 3
	return
end _reduceBlockLen

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B

on everyCharacter(str)
	try
		set tokenCount to count str's characters
		if tokenCount is less than _blockLen then
			set lst to str's characters
		else
			set lst to {}
			set endLen to tokenCount mod _blockLen
			repeat with eachBlock from 1 to (tokenCount - endLen) by _blockLen
				set lst to lst & str's characters eachBlock thru (eachBlock + _blockLen - 1)
			end repeat
			if endLen is greater than 0 then set lst to lst & str's characters -endLen thru -1
		end if
		return lst
	on error number -2706
		_reduceBlockLen()
		return everyCharacter(str)
	end try
end everyCharacter

on everyWord(str)
	try
		set tokenCount to count str's words
		if tokenCount is less than _blockLen then
			set lst to str's words
		else
			set lst to {}
			set endLen to tokenCount mod _blockLen
			repeat with eachBlock from 1 to (tokenCount - endLen) by _blockLen
				set lst to lst & str's words eachBlock thru (eachBlock + _blockLen - 1)
			end repeat
			if endLen is greater than 0 then set lst to lst & str's words -endLen thru -1
		end if
		return lst
	on error number -2706
		_reduceBlockLen()
		return everyWord(str)
	end try
end everyWord

on everyParagraph(str)
	try
		set tokenCount to count str's paragraphs
		if tokenCount is less than _blockLen then
			set lst to str's paragraphs
		else
			set lst to {}
			set endLen to tokenCount mod _blockLen
			repeat with eachBlock from 1 to (tokenCount - endLen) by _blockLen
				set lst to lst & str's paragraphs eachBlock thru (eachBlock + _blockLen - 1)
			end repeat
			if endLen is greater than 0 then set lst to lst & str's paragraphs -endLen thru -1
		end if
		return lst
	on error number -2706
		_reduceBlockLen()
		return everyParagraph(str)
	end try
end everyParagraph

on everyTextItem(str)
	try
		set tokenCount to count str's text items
		if tokenCount is less than _blockLen then
			set lst to str's text items
		else
			set lst to {}
			set endLen to tokenCount mod _blockLen
			repeat with eachBlock from 1 to (tokenCount - endLen) by _blockLen
				set lst to lst & str's text items eachBlock thru (eachBlock + _blockLen - 1)
			end repeat
			if endLen is greater than 0 then set lst to lst & str's text items -endLen thru -1
		end if
		return lst
	on error number -2706
		_reduceBlockLen()
		return everyTextItem(str)
	end try
end everyTextItem

on specialTextItems(str)
	try
		set tokenCount to count str's text items
		if tokenCount is less than _blockLen then
			set lst to str's text items
		else
			set lst to {}
			set endLen to tokenCount mod _blockLen
			repeat with eachBlock from 1 to (tokenCount - endLen) by _blockLen
				set lst's end to str's text items eachBlock thru (eachBlock + _blockLen - 1)
			end repeat
			if endLen is greater than 0 then set lst's end to str's text items -endLen thru -1
		end if
		return lst
	on error number -2706
		_reduceBlockLen()
		return specialTextItems(str)
	end try
end specialTextItems
