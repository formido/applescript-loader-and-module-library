property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value
property _String : missing value
property _Number : missing value
property _Date : missing value
property _List : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
	set _String to loader's minVersion("0.1.0", loader's loadLib("String"))
	set _Number to loader's loadLib("Number")
	set _Date to loader's loadLib("Date")
	set _List to loader's loadLib("List")
end __load__

----------------------------------------------------------------------
-- MAIN

__load__(_Loader's makeLoader())
log _Unicode's joinList({1, 2, 3, 4, _Unicode's uChar(300), 5}, "-")
log _String's trimBoth("    foo   ")
log _Number's trimToNearest(pi, 6)
log _Date's makeFormatter("d/m/yy", "English")'s formatDate(date "Thursday, January 2, 2003 12:00:00 AM")
log _List's sortList({4, 17, 1, 33, 6, 9, 2, 1, 0})