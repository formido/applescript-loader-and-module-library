property __name__ : "Dictionary"
property __version__ : ""
property __ldr__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

property _ascii0 : ASCII character 0
property _ascii1 : ASCII character 1

on makeDict()
	script
		property class : "Dictionary"
		-- PRIVATE
		property _sep : _ascii0 -- attached to keyStr for matching against/inserting into _keys
		property _esc : _ascii1 -- used to escape any reserved characters (_sep, _esc) found in keyStr
		--
		property _keys : _sep
		script _vals
			property l : {}
		end script
		--
		on _escapeKey(keyStr)
			set AppleScript's text item delimiters to _esc
			set lst to keyStr's text items
			set AppleScript's text item delimiters to _esc & "0"
			set keyStr to lst as string
			set AppleScript's text item delimiters to _sep
			set lst to keyStr's text items
			set AppleScript's text item delimiters to _esc & "1"
			return lst as string
		end _escapeKey
		--
		on _offset(keyStr) --returns position of value if key is found, or missing value if not found
			set oldTID to AppleScript's text item delimiters
			try
				--prep key
				set AppleScript's text item delimiters to ""
				set keyStr to keyStr as string
				if keyStr contains _sep or keyStr contains _esc then
					set keyStr to _escapeKey(keyStr)
				end if
				set formattedKey to keyStr & _sep
				--find key
				set AppleScript's text item delimiters to (_sep & formattedKey)
				set keyChunk to _keys's first text item
				if keyChunk's length is _keys's length then
					set AppleScript's text item delimiters to oldTID
					return {missing value, formattedKey}
				else
					set AppleScript's text item delimiters to _sep
					set keyIndex to count keyChunk each text item
					set AppleScript's text item delimiters to oldTID
					return {keyIndex, formattedKey}
				end if
			on error eMsg number eNum
				set AppleScript's text item delimiters to oldTID
				error eMsg number eNum
			end try
		end _offset
		------- 
		-- PUBLIC
		on itemExists(keyStr)
			try
				return _offset(keyStr)'s first item is not missing value
			on error eMsg number eNum
				error "Can't check if itemExists: " & eMsg number eNum
			end try
		end itemExists
		--
		on setItem(keyStr, val)
			try
				set {keyIndex, formattedKey} to _offset(keyStr)
				if keyIndex is missing value then --new value
					set _keys to _keys & formattedKey
					set _vals's l's end to val
				else
					set _vals's l's item (keyIndex) to val
				end if
				return
			on error eMsg number eNum
				error "Can't setItem: " & eMsg number eNum
			end try
		end setItem
		--
		on getItem(keyStr)
			try
				set {keyIndex, formattedKey} to _offset(keyStr)
				if keyIndex is missing value then
					error "key \"" & keyStr & "\" not found." number -1728
				else
					return _vals's l's item keyIndex
				end if
			on error eMsg number eNum
				error "Can't getItem: " & eMsg number eNum
			end try
		end getItem
		--
		on deleteItem(keyStr)
			try
				set {keyIndex, formattedKey} to _offset(keyStr)
				if keyIndex is missing value then
					error "key \"" & keyStr & "\" not found." number -1728
				else
					set oldTID to AppleScript's text item delimiters
					set AppleScript's text item delimiters to formattedKey
					set {keys1, keys2} to _keys's text items
					set _keys to keys1 & keys2
					set AppleScript's text item delimiters to oldTID
					set val to _vals's l's item keyIndex
					if keyIndex is 1 then
						set _vals's l to get rest of _vals's l
					else if keys2 is "" then
						set _vals's l to _vals's l's items 1 thru -2
					else
						set _vals's l to (_vals's l's items 1 thru (keyIndex - 1)) & (_vals's l's items (keyIndex + 1) thru -1)
					end if
					return val
				end if
			on error eMsg number eNum
				error "Can't deleteItem: " & eMsg number eNum
			end try
		end deleteItem
	end script
end makeDict


-- TEST

set x to makeDict()
tell x
	--log itemExists(1)
	setItem("a", "A")
	setItem("b", "B")
	setItem("c", "C")
	setItem("", 0)
	setItem("d", "D")
	--	log its _keys
	--	log
	getItem("")
end tell