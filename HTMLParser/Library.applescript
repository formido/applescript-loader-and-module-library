property __name__ : "HTMLParser"
property __version__ : "0.1.0"
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _EveryItem : missing value

on __load__(loader)
	set _EveryItem to loader's loadLib("EveryItem")
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _ws : " " & tab & return & (ASCII character 10)
property _aZ : "eErRiIoOaAtTnNsSdDlLcCpPmMhHbBfFuUyYgGwWvVkKxXjJqQzZ"
property _09 : "0123456789"
property _aF : "aAbBcCdDeEfF"
property _pun : "-.:_"

--

property _entStart : _aZ -- {1}
property _entMid : _aZ & _09 & ".-" -- *
property _entEnd : ";" -- ?

property _charStart : "#"
property _char09 : _09 -- +
property _char0FMarker : "xX" -- {1}
property _char0F : _09 & _aF -- +
property _charEnd : ";" -- ?

property _startTagStart : _aZ -- {1}
property _startTagRest : _aZ & _09 & _pun -- *

property _keepSearching : _ws -- *
property _tagStop : ">" -- ^

property _attNameStart : _aZ & "_" -- {1}
property _attNameRest : _aZ & _09 & _pun -- *
property _attValueIndicator : "=" -- {1}
-- keep searching
property _attQuotedValueStart : "'\"" -- {1}
property _attEndBareValue : "'\">" & _ws -- ^*

property _endTagStart : "/"
-- keep searching
property _endTagNameStart : _aZ --{1}
property _endTagNameRest : _aZ & _09 & _pun -- *
-- keep searching

property _closeEmptyTag : "/"

property _declStart : "!"
property _piStart : "?"
property _piEnd : "?>"

property _Comment : "--"
-------

on _tokenise(txt, delim)
	set AppleScript's text item delimiters to delim
	try
		set lst to txt's text items
	on error number -2706 -- stack overflow (affects strings containing more than approx. 4000 text items)
		set lst to _EveryItem's everyTextItem(txt)
	end try
	return lst
end _tokenise

on _makeSource(txt)
	script
		script _k
			property l : rest of _tokenise(txt, "<")
		end script
		property _idx : 0
		property _len : count _k's l
		property _cont : 0
		
		on nextBlock()
			set _idx to _idx + 1
			return _k's l's item _idx
		end nextBlock
		
		on continueBlock()
			set _idx to _idx + 1
			set _cont to _cont + 1
			return _k's l's item _idx
		end continueBlock
		
		on isDone()
			return (_idx is _len)
		end isDone
		
		on tagNo()
			return _idx - _cont
		end tagNo
	end script
end _makeSource

-------

on _getToMarker(txt, src, len, i, j, marker)
	set AppleScript's text item delimiters to marker
	if j > len then
		set txt to txt & "<" & src's continueBlock() -- will raise error -1728 if unexpected EOF
		set len to txt's length
	end if
	repeat
		set j to j + (((txt's text j thru -1)'s text item 1)'s length)
		if j < len then exit repeat -- found char, else pull in next block
		set txt to txt & "<" & src's continueBlock() -- will raise error -1728 if unexpected EOF
		set len to txt's length
	end repeat
	return {txt's text i thru (j - 1), txt, len, j}
end _getToMarker

--

on _parseAtts(txt, src, len, i)
	set atts to {}
	repeat
		if txt's character i is not in _attNameStart then error number 8000 -- malformed tag
		set j to i + 1
		repeat while (get txt's character j) is in _attNameRest -- (error -1728 = premature end)
			set j to j + 1
		end repeat
		set attName to txt's text i thru (j - 1)
		repeat while (get txt's character j) is in _keepSearching -- (error -1728 = premature end)
			set j to j + 1
		end repeat
		if txt's character j is _attValueIndicator then -- get value
			set j to j + 1
			repeat while (get txt's character j) is in _keepSearching -- (error -1728 = premature end)
				set j to j + 1
			end repeat
			set char to txt's character j
			if char is in _attQuotedValueStart then
				set j to j + 1
				set i to j
				if txt's character i is char then
					set atts's end to {attName, ""}
				else
					set {attValue, txt, len, j} to _getToMarker(txt, src, len, i, j, char)
				end if
				set i to j + 1
			else if char is in _attEndBareValue then
				error number 8000 -- malformed tag
			else
				set i to j + 1
				repeat while (get txt's character i) is not in _attEndBareValue -- (error -1728 = premature end)
					set i to i + 1
				end repeat
				set attValue to txt's text j thru (i - 1)
			end if
			set atts's end to {attName, attValue}
		else
			set atts's end to {attName, attName}
		end if
		repeat while (get txt's character i) is in _keepSearching -- (error -1728 = premature end)
			set i to i + 1
		end repeat
		if txt's character i is in (_tagStop & _closeEmptyTag) then exit repeat
	end repeat
	return {atts, txt, i, len}
end _parseAtts

--

on _parseStartTag(txt, src, receiver)
	set len to txt's length
	set i to 2
	repeat while (get txt's character i) is in _startTagRest -- (error -1728 = premature end)
		set i to i + 1
	end repeat
	set tagName to txt's text 1 thru (i - 1)
	repeat while (get txt's character i) is in _keepSearching -- (error -1728 = premature end)
		set i to i + 1
	end repeat
	set atts to {}
	if txt's character i is _tagStop then
		set isEmptyElement to false
	else if txt's character i is _closeEmptyTag then
		set i to i + 1
		if txt's character i is not _tagStop then error number 8000 -- malformed tag
		set isEmptyElement to true
	else
		set {atts, txt, i, len} to _parseAtts(txt, src, len, i)
		if txt's character i is _closeEmptyTag then
			set i to i + 1
			if txt's character i is not _tagStop then error number 8000 -- malformed tag
			set isEmptyElement to true
		else
			set isEmptyElement to false
		end if
	end if
	if isEmptyElement then
		try
			receiver's handleStartEndTag(tagName, atts)
		on error eMsg number eNum
			error {"handleStartEndTag", eMsg, eNum} number 8010
		end try
	else
		try
			receiver's handleStartTag(tagName, atts)
		on error eMsg number eNum
			error {"handleStartTag", eMsg, eNum} number 8010
		end try
	end if
	return {i is len, txt, i + 1}
end _parseStartTag

on _parseEndTag(txt, src, receiver)
	set len to txt's length
	set i to 2
	repeat while (get txt's character i) is in _keepSearching -- (error -1728 = premature end)
		set i to i + 1
	end repeat
	if txt's character i is not in _endTagNameStart then error number 8000 -- malformed tag
	set j to i
	repeat while (get txt's character j) is in _endTagNameRest -- (error -1728 = premature end)
		set j to j + 1
	end repeat
	try
		receiver's handleEndTag(txt's text i thru (j - 1))
	on error eMsg number eNum
		error {"handleEndTag", eMsg, eNum} number 8010
	end try
	repeat while (get txt's character j) is in _keepSearching -- (error -1728 = premature end)
		set j to j + 1
	end repeat
	if txt's character j is not _tagStop then error number 8000 -- malformed tag
	return {j is len, txt, j + 1}
end _parseEndTag

--

on _parseComment(txt, src, receiver)
	set i to 4
	set j to 4
	set {val, txt, len, j} to _getToMarker(txt, src, txt's length, i, j, "--")
	if txt's text j thru -1 does not start with "-->" then error number 8003 -- malformed comment
	try
		receiver's handleComment(val)
	on error eMsg number eNum
		error {"handleComment", eMsg, eNum} number 8010
	end try
	return {j + 2 is len, txt, j + 3}
end _parseComment

on _parseDecl(txt, src, receiver)
	set len to txt's length
	set AppleScript's text item delimiters to ">"
	set closeOffset to txt's text item 1's length
	if closeOffset is len then
		error "Declaration parsing unimplemented." number 8009
	end if
	set AppleScript's text item delimiters to "--"
	set commentOffset to txt's text item 1's length
	set AppleScript's text item delimiters to "["
	set subsetOffset to txt's text item 1's length
	if closeOffset > commentOffset or closeOffset > subsetOffset then
		error "Declaration parsing unimplemented." number 8009
	end if
	try
		receiver's handleDecl(txt's text 2 thru closeOffset)
	on error eMsg number eNum
		error {"handleDecl", eMsg, eNum} number 8010
	end try
	return {closeOffset < len, txt, closeOffset + 1}
end _parseDecl

on _parsePI(txt, src, receiver)
	set i to 2
	set {val, txt, len, j} to _getToMarker(txt, src, txt's length, i, 2, _piEnd)
	try
		receiver's handlePI(val)
	on error eMsg number eNum
		error {"handleDecl", eMsg, eNum} number 8010
	end try
	return {j is len, txt, j + 2}
end _parsePI

--

on _parseContent(contentTxt, receiver)
	script k
		property l : _tokenise(contentTxt, "&")
	end script
	set txt to k's l's item 1
	try
		try
			if txt's length > 0 then receiver's handleData(txt)
		on error eMsg number eNum
			error {"handleData", eMsg, eNum} number 8010
		end try
		repeat with txtRef in rest of k's l
			set txt to txtRef's contents
			if (get txt's character 1) is _charStart then -- (error -1728 = malformed character/entity ref)
				_parseCharRef(txt, receiver) -- (error -1728 = malformed character/entity ref)
			else if txt's character 1 is in _entStart then
				_parseEntRef(txt, receiver)
			else
				error number 8001 -- malformed character/entity ref
			end if
		end repeat
	on error number -1728
		error number 8001
	end try
end _parseContent

--

on _parseEntRef(txt, receiver)
	set len to txt's length
	set i to 2
	try
		repeat while (get txt's character i) is in _entMid
			set i to i + 1
		end repeat
	on error number -1728 -- might occur with older HTML that doesn't close entities with ";", e.g. "<tag>&foo<tag>"
		try
			receiver's handleEntityRef(txt)
		on error eMsg number eNum
			error {"handleEntityRef", eMsg, eNum} number 8010
		end try
		return
	end try
	try
		receiver's handleEntityRef(txt's text 1 thru (i - 1))
	on error eMsg number eNum
		error {"handleEntityRef", eMsg, eNum} number 8010
	end try
	if txt's character i is _entEnd then set i to i + 1
	try
		if i < len then receiver's handleData(txt's text i thru -1)
	on error eMsg number eNum
		error {"handleData", eMsg, eNum} number 8010
	end try
	return
end _parseEntRef

on _parseCharRef(txt, receiver)
	set len to txt's length
	if (get txt's character 2) is in _char0FMarker then -- (error -1728 = malformed character/entity ref)
		set validChars to _char0F
		if (get txt's character 3) is not in validChars then error number 8001 -- (error -1728 = malformed character/entity ref)
		set i to 4
	else if txt's character 2 is in _char09 then
		set validChars to _char09
		set i to 3
	else
		error number 8001
	end if
	try
		repeat while (get txt's character i) is in validChars
			set i to i + 1
		end repeat
	on error number -1728 -- might occur with older HTML that doesn't close entities with ";", e.g. "<tag>&foo<tag>"
		try
			receiver's handleCharRef(txt's text 2 thru -1)
		on error eMsg number eNum
			error {"handleCharRef", eMsg, eNum} number 8010
		end try
		return
	end try
	try
		receiver's handleCharRef(txt's text 2 thru (i - 1))
	on error eMsg number eNum
		error {"handleCharRef", eMsg, eNum} number 8010
	end try
	if txt's character i is _charEnd then set i to i + 1
	try
		if i < len then receiver's handleData(txt's text i thru -1)
	on error eMsg number eNum
		error {"handleData", eMsg, eNum} number 8010
	end try
	return
end _parseCharRef

----------------------------------------------------------------------
-- PUBLIC

on makeEventReceiver()
	--EventReceiver receives HTMLParser processing events
	--subclass and override some or all methods to do useful work
	script
		property class : "EventReceiver"
		-------
		on handleStartEndTag(tagName, attributesList)
		end handleStartEndTag
		--
		on handleStartTag(tagName, attributesList)
		end handleStartTag
		--
		on handleEndTag(tagName)
		end handleEndTag
		--
		on handleData(txt)
		end handleData
		--
		on handleCharRef(txt)
		end handleCharRef
		--
		on handleEntityRef(txt)
		end handleEntityRef
		--
		on handlePI(txt)
		end handlePI
		--
		on handleDecl(txt)
		end handleDecl
		--
		on handleComment(txt)
		end handleComment
	end script
end makeEventReceiver


on parseHTML(html, receiver)
	try
		set src to _makeSource(html)
		repeat until src's isDone()
			set txt to src's nextBlock()
			try
				try
					try
						set char to txt's character 1 -- (error -1728 = malformed character/entity ref)
					on error number -1728
						error number 8000
					end try
					if char is "/" then -- read as end tag
						_parseEndTag(txt, src, receiver) returning {isNoData, txt, ptr}
					else if char is in _startTagStart then -- read as start tag
						_parseStartTag(txt, src, receiver) returning {isNoData, txt, ptr}
					else if char is _declStart then -- comment or declaration
						if txt starts with "!--" then
							_parseComment(txt, src, receiver) returning {isNoData, txt, ptr}
						else
							_parseDecl(txt, src, receiver) returning {isNoData, txt, ptr}
						end if
					else if char is _piStart then
						_parsePI(txt, src, receiver) returning {isNoData, txt, ptr}
					else
						error number 8000 -- malformed tag
					end if
				on error number -1728
					error number 8000
				end try
				if not isNoData then _parseContent(txt's text ptr thru -1, receiver)
			on error eMsg number eNum
				if eNum is 8000 then set eMsg to "malformed tag #" & src's tagNo()
				if eNum is 8001 then set eMsg to "malformed entity reference after tag #" & src's tagNo()
				if eNum is 8002 then set eMsg to "malformed character reference after tag #" & src's tagNo()
				if eNum is 8010 then -- user event handler error {"handleNAME", eMsg, eNum}
					set {handlerName, usreMsg, usreNum} to eMsg
					set eMsg to "Error " & usreNum & " in " & handlerName & " event handler: " & usreMsg
				end if
				error eMsg number eNum
			end try
		end repeat
		return
	on error eMsg number eNum
		error "Can't parseHTML: " & eMsg number eNum
	end try
end parseHTML
