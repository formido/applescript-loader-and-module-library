property __name__ : "ColumnClasses"
property __version__ : ""
property __lv__ : 1.0

on __load__(loader)
end __load__

----------------------------------------------------------------------

script _sharedClass
	on _mainError(className, eMsg, eNum)
		error className & " reported a problem: " & eMsg & " (" & eNum & ")" number eNum
	end _mainError
	--
	on _specialListCoerce(val)
		-- only allow lists containing 0 or 1 items to be coerced to something else (if item is also a list then look in that, etc.)
		if val's length is greater than 1 then
			_localError("Can't coerce multi-item lists.", -1700)
		else if val's length is 1 then
			classCoerce(val's first item)
		else
			""
		end if
	end _specialListCoerce
	-------
	on classCoerce(val)
		if val's class is list then _specialListCoerce(val)
		try
			coerceItem(val)
		on error eMsg number eNum
			_reportError(eMsg, eNum)
		end try
	end classCoerce
	--
	on coerceToString(val)
		val as string
	end coerceToString
end script

--mark -

script booleanClass
	property parent : _sharedClass
	--
	on _localError(eMsg, eNum)
		_mainError("booleanClass", eMsg, eNum)
	end _localError
	--
	on coerceItem(val) --this is called by classCoerce() in _sharedClass
		ignoring case
			if val is in {"false", "no", "0", "n"} then
				false
			else if val is in {"true", "yes", "1", "y"} then
				true
			else
				_localError("Can't make item into a boolean", -1700)
			end if
		end ignoring
	end coerceItem
	-------
	on classCheck(val, fieldName)
		if val's class is not boolean then _localError("Field \"" & fieldName & "\" expected a boolean but got " & val's class & ".", 100)
	end classCheck
	--
	--classCoerce() isn't included here as it's inherited from parent
	--
	on classDelete(val)
		val's booleans
	end classDelete
end script

--mark -

script integerClass
	property parent : _sharedClass
	--
	on _localError(eMsg, eNum)
		_mainError("integerClass", eMsg, eNum)
	end _localError
	--
	on coerceItem(val)
		val as integer
	end coerceItem
	-------
	on classCheck(val, fieldName)
		if val's class is not integer then _localError("Field \"" & fieldName & "\" expected an integer but got " & val's class & ".", 100)
	end classCheck
	--
	on classDelete(val)
		val's integers
	end classDelete
end script

--mark -

script realClass
	property parent : _sharedClass
	--
	on _localError(eMsg, eNum)
		_mainError("realClass", eMsg, eNum)
	end _localError
	--
	on coerceItem(val)
		val as real
	end coerceItem
	-------
	on classCheck(val, fieldName)
		if val's class is not real then _localError("Field \"" & fieldName & "\" expected a real but got " & val's class & ".", 100)
	end classCheck
	--
	on classDelete(val)
		val's reals
	end classDelete
end script

--mark -

script stringClass
	property parent : _sharedClass
	--
	on _localError(eMsg, eNum)
		_mainError("stringClass", eMsg, eNum)
	end _localError
	--
	on coerceItem(val)
		val as string
	end coerceItem
	-------
	on classCheck(val, fieldName)
		if val's class is not string then _localError("Field \"" & fieldName & "\" expected a string but got " & val's class & ".", 100)
	end classCheck
	--
	on classDelete(val)
		val's strings
	end classDelete
	--
	on coerceToString(val) -- override parent's cTS() handler for slightly improved speed
		val
	end coerceToString
end script

--mark -

script dateClass
	property parent : _sharedClass
	--
	on _localError(eMsg, eNum)
		_mainError("dateClass", eMsg, eNum)
	end _localError
	--
	on coerceItem(val)
		date val
	end coerceItem
	-------
	on classCheck(val, fieldName)
		if val's class is not date then _localError("Field \"" & fieldName & "\" expected a date but got " & val's class & ".", 100)
	end classCheck
	--
	on classDelete(val)
		val's dates
	end classDelete
end script

(*TO DO: dateClass, listClass, recordClass, scriptClass
	� dateClass will require dateLib for stringToDate() conversions; it'll also have to get the formatString and formatLanguage from somewhere
	� also need to work out stuff like unicode and other text classes
	� constantClass/classClass?
*)

property columnClassObjsKey : {"boolean", "integer", "real", "string", "date"}
property columnClassObjs : {booleanClass, integerClass, realClass, stringClass, dateClass}

-------
--mark -
--mark public handler<B

on getClassObj(columnClass)
	set columnClass to columnClass as string
	ignoring case
		repeat with x from 1 to columnClassObjs's length
			if columnClassObjsKey's item x is columnClass then return columnClassObjs's item x
		end repeat
	end ignoring
	error "Unsupported class." number 99
end getClassObj
