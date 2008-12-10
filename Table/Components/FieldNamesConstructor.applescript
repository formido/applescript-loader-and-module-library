property __name__ : "FieldNamesConstructor"
property __version__ : ""
property __lv__ : 1.0

on __load__(loader)
end __load__

----------------------------------------------------------------------

script basicProperties
	property ascii1 : ASCII character 1
	property ascii11 : ascii1 & ascii1
	--
	on _mainError(eMsg, eNum)
		set AppleScript's text item delimiters to {""}
		error "TableObj error: " & eMsg number eNum
	end _mainError
end script

--mark -

script fieldLookupHandlers
	property parent : basicProperties
	--
	on listFields()
		if my keyStore's length is less than 4 then error "No fields exist." number 100
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to my ascii11
		set tempList to my keyStore's text 3 thru -2's text items
		set AppleScript's text item delimiters to ", "
		set fieldsString to tempList as string
		set AppleScript's text item delimiters to oldTID
		fieldsString
	end listFields
	--
	on _fieldNotFound(theKey)
		--log "Field \"" & theKey & "\" does not exist in fields: " & listFields() --TEST
		error "Field \"" & theKey & "\" does not exist in fields: " & listFields() number 100
	end _fieldNotFound
	--
	on getIndex(theKey)
		try
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to ""
			(theKey as string)'s text beginning thru end --coerce to string (if necessary); throw error if theKey is ""
			set formattedField to my ascii1 & result & my ascii1
			set AppleScript's text item delimiters to formattedField
			set fieldChunk to my keyStore's first text item
			if result's length is my keyStore's length then _fieldNotFound(theKey)
			set AppleScript's text item delimiters to my ascii11
			set theIndex to count fieldChunk's text items
			set AppleScript's text item delimiters to oldTID
			theIndex
		on error eMsg number eNum
			if eNum is -1700 then _localError("Could not coerce a field to string.", 100)
			if eNum is -1728 then _localError("Empty strings cannot be used as fields.", 100)
			_localError(eMsg, eNum)
		end try
	end getIndex
end script

--mark -

on newFieldNamesObj(fieldNames)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to basicProperties's ascii11
	script fieldNamesObj
		property parent : fieldLookupHandlers
		property class : "fieldNamesObj"
		property keyStore : basicProperties's ascii11 & fieldNames & basicProperties's ascii1
		--
		on _localError(eMsg, eNum)
			_mainError("FieldNamesObj reports error: " & eMsg, eNum)
		end _localError
	end script
	set AppleScript's text item delimiters to oldTID
	fieldNamesObj
end newFieldNamesObj
