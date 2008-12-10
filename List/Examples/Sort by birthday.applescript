property _Loader : run application "LoaderServer"

-- This example demonstrates how to sort a list of people according to the days on which their birthdays fall.

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value

on __load__(loader)
	set _List to loader's loadLib("List")
end __load__

----------------------------------------------------------------------
-- Sort Evaluators

script SortOnMonth
	property reverseSort : false
	on eval(rec)
		set mnth to rec's date's month
		repeat with idx from 1 to 12
			if item idx of {January, February, March, April, May, June, July, August, September, October, November, December} is mnth then exit repeat
		end repeat
		return idx
	end eval
end script

script SortOnDay
	property reverseSort : false
	on eval(rec)
		return rec's date's day
	end eval
end script

script SortOnYear
	property reverseSort : false
	on eval(sublst)
		return sublst's date's year
	end eval
end script

script SortOnName
	property reverseSort : false
	on eval(rec)
		return rec's name
	end eval
end script

----------------------------------------------------------------------
-- Main

__load__(_Loader's makeLoader())

set lst to {Â
	{name:"Jo", date:date "Wednesday, February 19, 1975 12:00:00 AM"}, Â
	{name:"John", date:date "Tuesday, December 1, 1970 12:00:00 AM"}, Â
	{name:"Bob", date:date "Tuesday, February 4, 1975 12:00:00 AM"}, Â
	{name:"Jane", date:date "Tuesday, June 16, 1970 12:00:00 AM"}, Â
	{name:"Mary", date:date "Monday, December 1, 1975 12:00:00 AM"}, Â
	{name:"Ray", date:date "Saturday, December 1, 1973 12:00:00 AM"}}

_List's powerSort(lst, {SortOnMonth, SortOnDay, SortOnYear, SortOnName}, 0)
(* Result:
	{
		{name:"Bob", date:date "Tuesday, February 4, 1975 12:00:00 am"}, 
		{name:"Jo", date:date "Wednesday, February 19, 1975 12:00:00 am"}, 
		{name:"Jane", date:date "Tuesday, June 16, 1970 12:00:00 am"}, 
		{name:"John", date:date "Tuesday, December 1, 1970 12:00:00 am"}, 
		{name:"Ray", date:date "Saturday, December 1, 1973 12:00:00 am"}, 
		{name:"Mary", date:date "Monday, December 1, 1975 12:00:00 am"}
	}
*)