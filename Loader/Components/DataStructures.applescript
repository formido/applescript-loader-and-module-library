(*
DataStructures
(c) 2003 HAS
*)

on makeAssociative() -- simplified
	script
		script _k
			property keyStore : {}
			property valueStore : {}
		end script
		
		on _offset(theKey)
			considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
				repeat with idx from 1 to count of _k's keyStore
					if _k's keyStore's item idx is theKey then return idx
				end repeat
			end considering
			error "Key not found."
		end _offset
		
		on itemExists(theKey)
			considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
				return (_k's keyStore contains {theKey})
			end considering
		end itemExists
		
		on setItem(theKey, theValue)
			set _k's keyStore's beginning to theKey
			set _k's valueStore's beginning to theValue
			return
		end setItem
		
		on getItem(theKey)
			return _k's valueStore's item _offset(theKey)
		end getItem
		
		on listKeys()
			return _k's keyStore's items
		end listKeys
	end script
end makeAssociative

--

on makeStack()
	script
		script _k
			property l : {}
		end script
		
		on push(theValue)
			set _k's l's beginning to theValue
			return
		end push
		
		on pop()
			set res to _k's l's first item
			set _k's l to get rest of _k's l
			return res
		end pop
		
		on top()
			return _k's l's first item
		end top
	end script
end makeStack