property __name__ : "Dictionary"
property __version__ : ""
property __lv__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _UtxtConverter
	on _asText(txt)
		return txt as Unicode text
	end _asText
end script

script _StrConverter
	on _asText(txt)
		return txt as string
	end _asText
end script

on _makeDictBase()
	script
		property class : "Dictionary"
		
		property __textConverter : _UtxtConverter
		
		script _k
			property k : {} -- keys
			property v : {} -- values
		end script
		
		on _offset(keyTxt)
			set lo to 0
			set hi to (count _k's k)
			repeat while lo < hi
				set mid to (lo + hi) div 2
				if keyTxt < _k's k's item (mid + 1) then
					set hi to mid
				else
					set lo to mid + 1
				end if
			end repeat
			return lo
		end _offset
		
		-------
		
		on countItems()
			return count _k's k
		end countItems
		
		on keyExists(keyTxt)
			try
				set keyTxt to __textConverter's _asText(keyTxt)
				set idx to _offset(keyTxt)
				if idx is 0 then return false
				return (_k's k's item idx is keyTxt)
			on error eMsg number eNum
				error "Can't check keyExists: " & eMsg number eNum
			end try
		end keyExists
		
		on setItem(keyTxt, val)
			try
				set keyTxt to __textConverter's _asText(keyTxt)
				set idx to _offset(keyTxt)
				if idx is 0 then
					set _k's k's beginning to keyTxt
					set _k's v's beginning to val
				else if _k's k's item idx is keyTxt then
					set _k's v's item idx to val
				else if idx is (count _k's k) then
					set _k's k's end to keyTxt
					set _k's v's end to val
				else
					set _k's k to get ((_k's k's items 1 thru idx) & {keyTxt} & (_k's k's items (idx + 1) thru -1))
					set _k's v to get ((_k's v's items 1 thru idx) & {val} & (_k's v's items (idx + 1) thru -1))
				end if
				return
			on error eMsg number eNum
				error "Can't setItem: " & eMsg number eNum
			end try
		end setItem
		
		on getItem(keyTxt)
			try
				set keyTxt to __textConverter's _asText(keyTxt)
				set idx to _offset(keyTxt)
				if idx is 0 or _k's k's item idx is not keyTxt then error "key not found." number -1728
				return _k's v's item idx
			on error eMsg number eNum
				error "Can't getItem: " & eMsg number eNum
			end try
		end getItem
		
		on deleteItem(keyTxt)
			try
				set keyTxt to __textConverter's _asText(keyTxt)
				set idx to _offset(keyTxt)
				if idx is 0 or _k's k's item idx is not keyTxt then error "key not found." number -1728
				set val to _k's v's item idx
				if idx is 1 then
					set _k's k to get rest of _k's k
					set _k's v to get rest of _k's v
				else if idx is (count _k's k) then
					set _k's k to get _k's k's items 1 thru -2
					set _k's v to get _k's v's items 1 thru -2
				else
					set _k's k to get ((_k's k's items 1 thru (idx - 1)) & (_k's k's items (idx + 1) thru -1))
					set _k's v to get ((_k's v's items 1 thru (idx - 1)) & (_k's v's items (idx + 1) thru -1))
				end if
				return val
			on error eMsg number eNum
				error "Can't deleteItem: " & eMsg number eNum
			end try
		end deleteItem
		
		on getKeys()
			return _k's k's items
		end getKeys
		
		on getValues()
			return _k's v's items
		end getValues
	end script
end _makeDictBase

----------------------------------------------------------------------
-- PUBLIC

on makeDict()
	script
		property parent : _makeDictBase()
		on itemExists(keyTxt)
			considering diacriticals, hyphens, punctuation and white space but ignoring case and expansion
				continue itemExists(keyTxt)
			end considering
		end itemExists
		on setItem(keyTxt, val)
			considering diacriticals, hyphens, punctuation and white space but ignoring case and expansion
				continue setItem(keyTxt, val)
			end considering
		end setItem
		on getItem(keyTxt)
			considering diacriticals, hyphens, punctuation and white space but ignoring case and expansion
				continue getItem(keyTxt)
			end considering
		end getItem
		on deleteItem(keyTxt)
			considering diacriticals, hyphens, punctuation and white space but ignoring case and expansion
				continue deleteItem(keyTxt)
			end considering
		end deleteItem
	end script
end makeDict

on makeDictConsideringCase()
	script
		property parent : _makeDictBase()
		on itemExists(keyTxt)
			considering case, diacriticals, hyphens, punctuation and white space but ignoring expansion
				continue itemExists(keyTxt)
			end considering
		end itemExists
		on setItem(keyTxt, val)
			considering case, diacriticals, hyphens, punctuation and white space but ignoring expansion
				continue setItem(keyTxt, val)
			end considering
		end setItem
		on getItem(keyTxt)
			considering case, diacriticals, hyphens, punctuation and white space but ignoring expansion
				continue getItem(keyTxt)
			end considering
		end getItem
		on deleteItem(keyTxt)
			considering case, diacriticals, hyphens, punctuation and white space but ignoring expansion
				continue deleteItem(keyTxt)
			end considering
		end deleteItem
	end script
end makeDictConsideringCase

on makeSDict()
	set dict to makeDict()
	set dict's __textConverter to _StrConverter
	return dict
end makeSDict

on makeSDictConsideringCase()
	set dict to makeDictConsideringCase()
	set dict's __textConverter to _StrConverter
	return dict
end makeSDictConsideringCase