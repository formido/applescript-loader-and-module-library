property __name__ : "NodeConstructors"
property __version__ : ""
property __lv__ : 1

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

script _CharConverter
	property _chars : {"&", "<", ">"}
	property _ents : {"&amp;", "&lt;", "&gt;"}
	property _revChars : _chars's reverse
	property _revEnts : _ents's reverse
	--
	on _findAndReplace(uTxt, findLst, repLst) -- escape/unescape special chars
		set oldTID to AppleScript's text item delimiters
		repeat with i from 1 to count of findLst
			set AppleScript's text item delimiters to (get findLst's item i)
			try
				set lst to uTxt's text items
			on error number -2706 -- stack overflow is highly unlikely in this context
				error "Unexpected stack overflow while encoding/decoding key or string." number -2706
			end try
			set AppleScript's text item delimiters to (get repLst's item i)
			set uTxt to lst as Unicode text
		end repeat
		set AppleScript's text item delimiters to oldTID
		return uTxt
	end _findAndReplace
	-------
	on escapeChars(uTxt)
		considering case -- minimal speed tweak for faster 'contains' operation under typical circumstances
			if uTxt contains "&" or uTxt contains "<" or uTxt contains ">" then
				return _findAndReplace(uTxt, _chars, _ents)
			else
				return uTxt
			end if
		end considering
	end escapeChars
	--
	on unescapeChars(uTxt)
		considering case
			if uTxt contains "&" then
				return _findAndReplace(uTxt, _revEnts, _revChars)
			else
				return uTxt
			end if
		end considering
	end unescapeChars
end script

--

on _makeAbstractPrimitive(uTxt)
	script
		(*
			For best performance, each node stores data in one of/both of two forms: 
			- original (encoded/escaped UTF-8 as used in plist)
			- AS native (AppleScript type, without escapes)
			Original form is stored by default. AS form is only evaluated when required.
			If AS form is set, original form is only re-evaluated when required.
		*)
		property _orig : uTxt -- original text representation
		property _val : missing value -- AS value
		-------
		on ___collect(obj) -- used to rebuild plist
			obj's addVal(my class, txt())
		end ___collect
		-------
		on __setVal(val)
			set _orig to missing value
			set _val to val
			return
		end __setVal
		-------
		on txt()
			if _orig is missing value then set _orig to __asTxt(_val)
			return _orig
		end txt
		--
		on setTxt(uTxt)
			set _val to missing value
			set _orig to uTxt
			return
		end setTxt
		--
		on val()
			if _val is missing value then set _val to __asVal(_orig)
			return _val
		end val
		--
		(*
			subclasses should implement handlers:
				__asTxt(val) -- return val as formatted & escaped Unicode text
				__asVal(uTxt) -- return text representation as AppleScript type value
				setVal() -- set (AS type) value
		*)
	end script
end _makeAbstractPrimitive

--

script _AbstractCollection
	-------
	on len()
		return count of my _k's nList
	end len
	--
	on itemIndex(idx)
		try
			return item idx of my _k's nList
		on error eMsg number eNum
			error "Can't get itemIndex of " & my class & ": " & eMsg number eNum
		end try
	end itemIndex
end script

--

on _makeBool(typ, typStr)
	script |boolean|
		property parent : _makeAbstractPrimitive("" as Unicode text)
		property class : typStr -- note: booleans change type
		property _val : typ
		-------
		on ___collect(obj) -- used to rebuild plist
			obj's addEmptyVal(my class)
		end ___collect
		-------
		on ___asTag()
			return ("<" as Unicode text) & my class & "/>"
		end ___asTag
		-------
		on setTxt(val) -- squelch
		end setTxt
		-------
		on val()
			return _val
		end val
		--
		on setVal(val)
			set _val to val as boolean
			if _val then
				set class to "true"
			else
				set class to "false"
			end if
			return
		end setVal
	end script
end _makeBool

-------
--mark -
--mark PUBLIC<B<U
--mark primitive types<U

on makeTrue()
	_makeBool(true, "true")
end makeTrue

on makeFalse()
	_makeBool(false, "false")
end makeFalse

--

on makeInteger(uTxt)
	script |integer|
		property parent : _makeAbstractPrimitive(uTxt)
		property class : "integer"
		-------
		on __asTxt(val)
			return val as Unicode text
		end __asTxt
		--
		on __asVal(uTxt)
			considering punctuation, hyphens and white space
				return uTxt as integer -- TO DO: coercion may fail on big ints
			end considering
		end __asVal
		-------
		on setVal(val)
			__setVal(__asVal(val))
		end setVal
	end script
end makeInteger

on makeReal(uTxt)
	script |real|
		property parent : _makeAbstractPrimitive(uTxt)
		property class : "real"
		-------
		on __asTxt(val)
			return val as Unicode text
		end __asTxt
		--
		on __asVal(uTxt)
			considering punctuation, hyphens and white space
				return uTxt as real -- TO DO: coercion may fail on big nums
			end considering
		end __asVal
		-------
		on setVal(val)
			__setVal(__asVal(val))
		end setVal
	end script
end makeReal

--

on makeString(uTxt)
	script |string|
		property parent : _makeAbstractPrimitive(uTxt)
		property class : "string"
		-------
		on __asTxt(val) -- escape chars
			return _CharConverter's escapeChars(val)
		end __asTxt
		--
		on __asVal(uTxt) -- unescape chars
			return _CharConverter's unescapeChars(uTxt)
		end __asVal
		-------
		on setVal(val)
			__setVal(val as Unicode text)
		end setVal
	end script
end makeString

--

on makeDate(uTxt) -- YYYY-MM-DD T HH:MM:SS Z
	script |date|
		property parent : _makeAbstractPrimitive(uTxt)
		property class : "date"
		-------
		on _monthToStr(mnth)
			if mnth is January then
				return "01"
			else if mnth is February then
				return "02"
			else if mnth is March then
				return "03"
			else if mnth is April then
				return "04"
			else if mnth is May then
				return "05"
			else if mnth is June then
				return "06"
			else if mnth is July then
				return "07"
			else if mnth is August then
				return "08"
			else if mnth is September then
				return "09"
			else if mnth is October then
				return "10"
			else if mnth is November then
				return "11"
			else
				return "12"
			end if
		end _monthToStr
		--
		property _mnths : {January, February, March, April, May, June, July, August, September, October, November, December}
		-------
		on __asTxt(val)
			set {day:d, month:m, year:y, time:t} to val
			return ((text -4 thru -1 of ("000" & y)) as Unicode text) & "-" & _monthToStr(m) & "-" & Â
				(text -2 thru -1 of ("0" & d)) & "T" & (text -2 thru -1 of ("0" & (t div 3600))) & ":" & Â
				(text -2 thru -1 of ("0" & (t div 60 mod 60))) & ":" & (text -2 thru -1 of ("0" & (t mod 60))) & "Z"
		end __asTxt
		--
		on __asVal(uTxt)
			set dt to date (get "1")
			set dt's year to uTxt's text 1 thru 4 as integer
			set dt's month to _mnths's item (uTxt's text 6 thru 7 as integer)
			set dt's day to uTxt's text 9 thru 10 as integer
			set dt's time to (3600 * (uTxt's text 12 thru 13)) + (60 * (uTxt's text 15 thru 16)) + (uTxt's text 18 thru 19)
			return dt
		end __asVal
		-------
		on setVal(val)
			__setVal(val as date)
		end setVal
	end script
end makeDate

--

on makeData(uTxt)
	script |data|
		property parent : _makeAbstractPrimitive(uTxt)
		property class : "data"
		-------
		on __asTxt(val)
			return val -- TO DO?
		end __asTxt
		--
		on __asVal(uTxt)
			return uTxt -- TO DO?
		end __asVal
		-------
		on setVal(val)
			__setVal(val) -- TO DO?
		end setVal
	end script
end makeData

-------
--mark -
--mark collection types<U

on makeArray(nodeList)
	script array
		property parent : _AbstractCollection
		property class : "array"
		script _k
			property nList : nodeList
		end script
		-------
		on ___collect(obj) -- used to rebuild plist
			if _k's nList is {} then
				obj's addEmptyColl(my class)
			else
				obj's startColl(my class)
				repeat with aNode in _k's nList
					aNode's ___collect(obj)
				end repeat
				obj's endColl(my class)
			end if
		end ___collect
	end script
end makeArray

on makeDict(keyTable, keyList, nodeList, keyDelim)
	script dict
		property parent : _AbstractCollection
		property class : "dict"
		property _keyTable : keyTable
		script _k
			property kList : keyList
			property nList : nodeList
			property ukList : missing value
		end script
		property _keyDelim : keyDelim
		-------
		-- rebuild plist
		on ___collect(obj)
			if _k's nList is {} then
				obj's addEmptyColl(my class)
			else
				obj's startColl(my class)
				repeat with i from 1 to len()
					obj's addKey(_k's kList's item i)
					_k's nList's item i's ___collect(obj)
				end repeat
				obj's endColl(my class)
			end if
		end ___collect
		-------
		on allKeys()
			if _k's ukList is missing value then
				set _k's ukList to {}
				repeat with aKey in _k's kList
					set _k's ukList's end to _CharConverter's unescapeChars(aKey)
				end repeat
			end if
			return _k's ukList
		end allKeys
		--
		on keyExists(uTxt)
			considering case, diacriticals, expansion, hyphens, punctuation and white space
				return (_k's kList contains {_CharConverter's escapeChars(uTxt)})
			end considering
		end keyExists
		--
		on keyIndex(idx)
			try
				return _CharConverter's unescapeChars(_k's keyList)
			on error eMsg number eNum
				error "Can't get keyIndex of dict: " & eMsg number eNum
			end try
		end keyIndex
		--
		on itemKey(uTxt)
			try
				set oldTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to (get _keyDelim & _CharConverter's escapeChars(uTxt) & _keyDelim)
				set firstText to _keyTable's first text item
				set AppleScript's text item delimiters to _keyDelim
				set idx to count text items of firstText
				set AppleScript's text item delimiters to oldTID
				try
					return item idx of _k's nList
				on error number -1728
					error "key \"" & uTxt & "\" not found." number -1728
				end try
			on error eMsg number eNum
				error "Can't get itemKey of dict: " & eMsg number eNum
			end try
		end itemKey
	end script
end makeDict