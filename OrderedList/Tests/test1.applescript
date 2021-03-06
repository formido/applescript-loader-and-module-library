property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _OrderedList : missing value

on __load__(loader)
	set _OrderedList to loader's loadLib("OrderedList")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

--TEST

tell _OrderedList
	log insertLeft({1, 2, 3, 4, 4, 5, 5, 5, 5, 6, 7}, 4.0)
	
	set lst1 to {0, 1, 2, 3, 5, 5, 7}
	set lst2 to {2.0, 3.0, 4.0, 6.0, 8.0}
	log mergeLists(lst1, lst2)
	
	set l to {1, 2, 3, 4, 5}
	repeat with v from -1 to 7
		log {bisectLeft(l, v), bisectRight(l, v)}
	end repeat
end tell
(*
	{1, 2, 3, 4.0, 4, 4, 5, 5, 5, 5, 6, 7}
	{0, 1, 2, 2.0, 3, 3.0, 4.0, 5, 5, 6.0, 7, 8.0}
	{0, 0}
	{0, 0}
	{0, 1}
	{1, 2}
	{2, 3}
	{3, 4}
	{4, 5}
	{5, 5}
	{5, 5}
*)