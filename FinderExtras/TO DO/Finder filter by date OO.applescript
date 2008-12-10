--library to filter a list of Finder items/files/folders/etc. by creation/modification date
--(workaround for buggy 'whose' clause in OS X Finder)

-------
--PRIVATE
--
--objects to get creation/modification date from Finder object

script _creationDate
	on getDate(itm)
		using terms from application "Finder"
			return (itm's creation date)
		end using terms from
	end getDate
end script

script _modificationDate
	on getDate(itm)
		using terms from application "Finder"
			return (itm's creation date)
		end using terms from
	end getDate
end script

-------
--verify user parameter is date object

on _verifyDate(theDate)
	if theDate's class is not date then error "not a date." number -1703
	return theDate
end _verifyDate

-------
--comparison objects (before date, after date, between dates)

script _AbstractBase
	on filterItems(itemList)
		script kludge
			property lst : itemList
			property resultList : {}
		end script
		tell kludge
			repeat with itm in its lst
				if my __cmp(itm's contents) then
					set its resultList's end to itm's contents
				end if
			end repeat
			return its resultList
		end tell
	end filterItems
end script

on _isBefore(theDate, usingDateType)
	script
		property parent : _AbstractBase
		property _usingDate : usingDateType
		property _toDate : _verifyDate(theDate)
		on __cmp(itm)
			set theDate to _usingDate's getDate(itm)
			return (theDate is less than _toDate)
		end __cmp
	end script
end _isBefore

on _isAfter(theDate, usingDateType)
	script
		property parent : _AbstractBase
		property _usingDate : usingDateType
		property _fromDate : _verifyDate(theDate)
		on __cmp(itm)
			set theDate to _usingDate's getDate(itm)
			return (theDate is greater than or equal to _fromDate)
		end __cmp
	end script
end _isAfter

on _isBetween(fromDate, toDate, usingDateType)
	script
		property parent : _AbstractBase
		property _usingDate : usingDateType
		property _fromDate : _verifyDate(fromDate)
		property _toDate : _verifyDate(toDate)
		on __cmp(itm)
			set theDate to _usingDate's getDate(itm)
			return (theDate is greater than or equal to _fromDate) and (theDate is less than _toDate)
		end __cmp
	end script
end _isBetween

-------
--PUBLIC

--
--filtering object constructors

on createdBefore(theDate)
	return _isBefore(theDate, _creationDate)
end createdBefore

on createdAfter(theDate)
	return _isAfter(theDate, _creationDate)
end createdAfter

on createdBetween(fromDate, toDate)
	return _isBetween(fromDate, toDate, _creationDate)
end createdBetween

--

on modifiedBefore(theDate)
	return _isBefore(theDate, _modificationDate)
end modifiedBefore

on modifiedAfter(theDate)
	return _isAfter(theDate, _modificationDate)
end modifiedAfter

on modifiedBetween(fromDate, toDate)
	return _isBetween(fromDate, toDate, _modificationDate)
end modifiedBetween

--
--miscellaneous (for convenience)

on midnightToday()
	set dat to current date
	set dat's time to 0
	return dat
end midnightToday

on createdToday()
	set fromDate to midnightToday()
	set toDate to fromDate + (1 * days)
	return _isBetween(fromDate, toDate, _creationDate)
end createdToday

on modifiedToday()
	set fromDate to midnightToday()
	set toDate to fromDate + (1 * days)
	return _isBetween(fromDate, toDate, _modificationDate)
end modifiedToday

-------
--TEST

tell application "Finder" to set filesList to files of disk "frank"
filterItems(filesList) of createdBetween(midnightToday() - (3 * days), midnightToday())