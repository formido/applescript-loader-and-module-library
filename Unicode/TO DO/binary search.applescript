property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Types : missing value
property _Unicode : missing value

on __load__(loader)
	set _Types to loader's loadLib("Types")
	set _Unicode to loader's loadLib("Unicode")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set d to _Types's makeDictConsideringCase()

(*
repeat with i from 0 to 255
	d's setItem(_Unicode's uChar(i), i)
end repeat


set rpt to 10
set t1 to GetMilliSec
repeat rpt times
	repeat 2 times
		d's getItem("a")
	end repeat
end repeat
set t1 to ((GetMilliSec) - t1) as integer
set t2 to GetMilliSec
repeat rpt times
	_Unicode's uChar(81)
	--_unicode's uNum("a")
end repeat
set t2 to ((GetMilliSec) - t2) as integer

{t1, t2}
--_Unicode's uChar(81) < _Unicode's uChar(201)
-- "q" < "Ž"
*)

repeat with i from 0 to 65535 by 256
	d's setItem(_Unicode's uChar(i), i)
end repeat

set k to _Unicode's uChar(256 * 123)

log d's countItems()
log d's getItem(k)
d's _k's {k, v}