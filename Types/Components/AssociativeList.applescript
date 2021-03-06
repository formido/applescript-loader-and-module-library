property __name__ : "AssociativeList"
property __version__ : ""
property __lv__ : 1.0

----------------------------------------------------------------------
--DEPENDENCIES

on __load__()
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

script _ConsiderCase
	on do(obj, params)
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			return obj's do(params)
		end considering
	end do
end script

script _IgnoreCase
	on do(obj, params)
		considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
			return obj's do(params)
		end considering
	end do
end script

--

on _makeAssoc(caseObj)
	script
		property class : "AssociativeList"
		
		script _k
			property k : {} -- keys
			property v : {} -- values
		end script
		
		property _caseObj : caseObj
		
		--
		
		script _doOffset
			on do({theKey, kludge})
				if kludge's k does not contain {theKey} then error "key not found." number -1728
				repeat with idx from 1 to count of kludge's k
					if kludge's k's item idx is theKey then return idx
				end repeat
			end do
		end script
		
		script _doExists
			on do({theKey, kludge})
				return (kludge's k contains {theKey})
			end do
		end script
		
		--
		
		on _findOffset(theKey)
			_caseObj's do(_doOffset, {theKey, _k})
		end _findOffset
		
		-------
		
		on countItems()
			return count _k's k
		end countItems
		
		on itemExists(theKey)
			_caseObj's do(_doExists, {theKey, _k})
		end itemExists
		
		on setItem(theKey, theValue)
			try
				if itemExists(theKey) then
					set _k's v's item _findOffset(theKey) to theValue
				else
					set _k's k's beginning to theKey
					set _k's v's beginning to theValue
				end if
				return
			on error eMsg number eNum
				error "Can't setItem: " & eMsg number eNum
			end try
		end setItem
		
		on getItem(theKey)
			try
				return _k's v's item _findOffset(theKey)
			on error eMsg number eNum
				error "Can't getItem: " & eMsg number eNum
			end try
		end getItem
		
		on deleteItem(theKey)
			try
				set keyOffset to _findOffset(theKey)
				set theValue to _k's v's item keyOffset
				if keyOffset is 1 then
					set _k's k to get rest of _k's k
					set _k's v to get rest of _k's v
				else if keyOffset is (count of _k's k) then
					set _k's k to get items 1 thru -2 of _k's k
					set _k's v to get items 1 thru -2 of _k's v
				else
					set _k's k to get ((items 1 thru (keyOffset - 1) of _k's k) & �
						(items (keyOffset + 1) thru -1 of _k's k))
					set _k's v to get ((items 1 thru (keyOffset - 1) of _k's v) & �
						(items (keyOffset + 1) thru -1 of _k's v))
				end if
				return theValue
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
end _makeAssoc

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeAssociativeList()
	return _makeAssoc(_IgnoreCase)
end makeAssociativeList

on makeAssociativeListConsideringCase()
	return _makeAssoc(_ConsiderCase)
end makeAssociativeListConsideringCase

(*
--TEST

set x to makeAssoc()
x's setItem("yyyy-mm-dd H:MM:SS", 1)
x's setItem("H.MM P, ddd, d mmmm yy", 2)

log x's getItem("H.MM P, ddd, d mmmm yy") --> 2
log x's getItem("yyyy-mm-dd H:MM:SS") --> 1
*)