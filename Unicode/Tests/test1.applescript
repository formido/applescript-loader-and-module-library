property _Loader : run application "LoaderServer"------------------------------------------------------------------------ DEPENDENCIESproperty _Unicode : missing valueon __load__(loader)	set _Unicode to loader's loadLib("Unicode")end __load__----------------------------------------------------------------------__load__(_Loader's makeLoader())(*
set i to 5
tell application "Finder" to set s to name of folder 1 of folder "Žg ”" of home
return {character i of s, uNum(character i of s), uChar(uNum(character i of s))}
*)--(*set c to _Unicode's uChar(0) -- first char of first table--set c to _Unicode's uChar(10 * 256 - 1) -- last char of first table--set c to _Unicode's uChar(10 * 256) -- first char of second tableset c to _Unicode's uChar(256 * 256 - 3) -- 3rd last char of third tableset rpt to 1000set t1 to GetMilliSecrepeat rpt times	--_Unicode's uChar(150)	_Unicode's uNum(c)end repeatset t1 to ((GetMilliSec) - t1) as integerset t2 to GetMilliSecrepeat rpt times	--ASCII character 150	ASCII number "©"end repeatset t2 to ((GetMilliSec) - t2) as integerreturn {t1, t2}--*)(*
set n to 255 * 256 + 2
_Unicode's uChar(n)
{n, result, _Unicode's uNum(result)}
*)set l to {{}, Â	{1, 2, 3, 4, 5}, Â	{"a", "b", "c", {"d", "e"}, "f", "g"}, Â	{"a1", "b2", "c3", "d4", "e", "f", "g", "h", "i"}, Â	{{{{"a", "b"}}}}}repeat with iRef in l	set iRef's contents to _Unicode's uJoin(iRef's contents, "!")end repeatl--_Unicode's uJoin({1, {a:2}}, "!") -- error: can't make record into utxt0