property _epoch : (date "Monday, January 1, 2001 12:00:00 AM")

on dateToNum(theDate)
	return theDate - _epoch
end dateToNum

on numToDate(int)
	return _epoch + int
end numToDate

{dateToNum(date "Friday, January 1, 2100 12:00:01 AM"), numToDate(100)}
