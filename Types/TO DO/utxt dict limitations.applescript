property _Loader : load script alias (((path to scripts folder from local domain) as Unicode text) & "ASLibraries:Loader:Library.scpt")

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value
property _Types : missing value

on __load__(loader)
	tell loader
		set _List to loadLib("List")
		set _Types to loadLib("Types")
	end tell
	return
end __load__
__load__(_Loader's makeLoader())
----------------------------------------------------------------------

(*set d to _Types's makeDict(false)
repeat with i from 0 to 127
	d's setItem(ASCII character i, 0)
end repeat
--return d's getLength()
set t to text of window 2
repeat with char in t
	set char to char's contents
	set n to d's getItem(char)
	d's setItem(char, n + 1)
end repeat

{d's _k's k, d's _k's v}
*)
tid("")
tell _List
	recomposeList(sortListOfLists(recomposeList({{"