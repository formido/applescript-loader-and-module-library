property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _ConvertToString : missing value

on __load__(loader)
	set _ConvertToString to loader's loadLib("ConvertToString")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

--toString

log _ConvertToString's toString({x:-9, y:3.004})
--> "{x:-9, y:3.004}"

log

--init + fastToString

_ConvertToString's init() -- remember: always call init before using fastToString
set bigList to {true, "Hello", Tuesday, {1, 2, 3}, {a:1}}
repeat with itemRef in bigList
	log _ConvertToString's fastToString(itemRef's contents)
end repeat
--> "true"
--> "\"Hello\""
--> "Tuesday"
--> "{1, 2, 3}"
--> "{a:1}"