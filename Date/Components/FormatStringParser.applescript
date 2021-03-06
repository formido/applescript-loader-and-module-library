property __name__ : "FormatStringParser"
property __version__ : ""
property __lv__ : 1

-----------------------------------------------------------------------------
--mark DEPENDENCIES<B<U

on __load__(loader)
end __load__

-----------------------------------------------------------------------------
--mark PRIVATE<B<U

property _escapeChar : "`"
property _breakChar : "|"
property _specialChars : "dmyhHMStTzDZ"

on _addEscapeChar(formatString, formatList, xPos)
	try
		set nextchar to formatString's item (xPos + 1)
	on error number -1728 --trap the error caused if "`" is last (unescaped) character in string
		error "formatString ended with an unescaped \"" & _escapeChar & "\"." number -1704
	end try
	set formatList's last item to formatList's last item & nextchar --as string
	return xPos + 2
end _addEscapeChar

on _addSpecialChar(eachchar, formatString, formatList, emptyString, xPos)
	set lenCount to 0
	repeat until xPos is greater than formatString's length or ((formatString's item xPos) as string) is not eachchar
		set lenCount to lenCount + 1
		set xPos to xPos + 1
	end repeat
	if lenCount is greater than 4 then
		set modString to ""
		repeat lenCount times
			set modString to modString & eachchar
		end repeat
		error "formatString contains an invalid code: \"" & modString & "\"." number -1704
	end if
	set AppleScript's text item delimiters to eachchar
	set formatList's end to (_specialChars's first text item's length) * 4 + lenCount
	set formatList's end to emptyString
	return xPos
end _addSpecialChar

-----------------------------------------------------------------------------
--mark PUBLIC<B<U

on parseFormatString(formatString)
	set oldTIDs to AppleScript's text item delimiters
	try
		if formatString's class is string then
			set emptyString to ""
		else if formatString's class is Unicode text then
			set emptyString to "" as Unicode text
		else
			error "formatString isn't a string or Unicode text." number -1704
		end if
		set formatList to {emptyString}
		set xPos to 1
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			repeat until xPos is greater than formatString's length
				set eachchar to formatString's item xPos
				if eachchar is _escapeChar then -- add the next character directly to the finished list
					_addEscapeChar(formatString, formatList, xPos) returning xPos
				else if eachchar is _breakChar then
					set xPos to xPos + 1
				else if eachchar is in _specialChars then --it's a special character, so process it
					_addSpecialChar(eachchar, formatString, formatList, emptyString, xPos) returning xPos
				else --it's an ordinary character, so add it to the finished list
					set formatList's last item to formatList's last item & eachchar --as string
					set xPos to xPos + 1
				end if
			end repeat
		end considering
		set AppleScript's text item delimiters to oldTIDs
		return formatList
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTIDs
		error "Can't parse formatString: " & eMsg number eNum
	end try
end parseFormatString

--TEST

--parseFormatString("xdd/mm/yyyyw" as Unicode text) --> {"x", 2, "/", 6, "/", 12, "w"}
--parseFormatString("ddd|d`ddddd") --> {"", 3, "", 1, "d", 4, ""}
