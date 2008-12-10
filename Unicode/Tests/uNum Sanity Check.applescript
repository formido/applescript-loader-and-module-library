property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


on u(num)
	_Unicode's uChar(num)
end u

on n(char)
	_Unicode's uNum(char)
end n

--(*
set l to {}
repeat with i from 0 to 127 --0 to 655 --5
	--set o to n(u(i))
	--if o ­ i then set l's end to {i, u(i), o, u(o)}
	--set i to i + 128
	set c to u(i)
	set l's end to {i, c, n(c)}
end repeat
return l --*)

set c to u(65300)
--tell _Unicode to return {c, uNum(c), uChar(65300) = uChar(52), uChar(0) = uChar(128)}
--

set rpt to 100
set t1 to GetMilliSec
repeat rpt times
	u(65300)
end repeat
set t1 to ((GetMilliSec) - t1) as integer
set t2 to GetMilliSec
repeat rpt times
	n(c)
end repeat
set t2 to ((GetMilliSec) - t2) as integer

{t1, t2}
