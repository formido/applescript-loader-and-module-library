property __name__ : "FormatStringParser"
property __version__ : "1.0.0"
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

on _tokenise(str, delim)
	try
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to delim
		set lst to str's text items
		set AppleScript's text item delimiters to oldTID
		return lst
	on error eMsg number eNum
		error "Can't tokenise: " & eMsg number eNum
	end try
end _tokenise

on _restOf(str, nullTxt)
	if str's length is 1 then
		return nullTxt
	else
		return str's text 2 thru -1
	end if
end _restOf

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeEventReceiver()
	script
		property class : "EventReceiver"
		
		on processText(txt)
		end processText
		
		on processControlChar(char)
		end processControlChar
	end script
end makeEventReceiver

--

on parseFormatString(formatTxt, escapeChar, eventReceiver)
	try
		if formatTxt's class is not in {string, Unicode text} then error "formatTxt isn't a string/Unicode text." number -1704
		if escapeChar's class is not in {string, Unicode text} then error "escapeChar isn't a string/Unicode text." number -1704
		if escapeChar's length is not 1 then error "escapeChar isn't a single character." number -1704
		if formatTxt's class is string then
			set nullTxt to ""
		else
			set nullTxt to "" as Unicode text
		end if
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			set tokensList to _tokenise(formatTxt, escapeChar)
			eventReceiver's processText(tokensList's first item)
			set idx to 2
			repeat until idx is greater than (count of tokensList)
				set str to tokensList's item idx
				if str is "" then -- next character is escaped escape char
					eventReceiver's processText(escapeChar)
					set idx to idx + 1
					eventReceiver's processText(tokensList's item idx)
				else -- next character is control character
					eventReceiver's processControlChar(str's first character)
					eventReceiver's processText(_restOf(str, nullTxt))
				end if
				set idx to idx + 1
			end repeat
			return
		end considering
	on error eMsg number eNum
		error "Can't parseFormatString: " & eMsg number eNum
	end try
end parseFormatString