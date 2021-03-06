property _Loader : load script alias (((path to scripts folder from local domain) as Unicode text) & "ASLibraries:Loader:Library.scpt")

----------------------------------------------------------------------
-- DEPENDENCIES

property _Types : missing value

on __load__(loader)
	tell loader
		set _Types to loadLib("Types")
	end tell
	return
end __load__

----------------------------------------------------------------------

on randTxt(len)
	set l to {}
	repeat len times
		set len to some item of {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		set s to ""
		repeat len times
			set s to s & some item of "abcdefghijklmnopqrstuvwxy1234567890     !@�$%^&*()���ĩ����Ϸ�����^���ōú~�"
		end repeat
		set l's end to s
	end repeat
	return l
end randTxt
script k
	property l : {}
end script

on tst(d)
	repeat with i from 1 to count k's l
		d's setItem(k's l's item i, i)
	end repeat
end tst

on tst2(d)
	repeat with s in k's l
		d's getItem(s's contents)
	end repeat
end tst2



on run
	__load__(_Loader's makeLoader())
	set k's l to randTxt(1000)
	
	set dict to (load script ("/Library/Scripts/ASLibraries/Types/TO DO/StringDictionary.scpt" as POSIX file))'s makeDict()
	set udict to _Types's makeDict(false)
	
	set res to {len:count k's l}
	
	set t1 to GetMilliSec
	tst(dict)
	set t1 to ((GetMilliSec) - t1) as integer
	set t2 to GetMilliSec
	tst(udict)
	set t2 to ((GetMilliSec) - t2) as integer
	set res to res & {addItems:{t1, t2}}
	
	--
	
	set t1 to GetMilliSec
	tst2(dict)
	set t1 to ((GetMilliSec) - t1) as integer
	set t2 to GetMilliSec
	tst2(udict)
	set t2 to ((GetMilliSec) - t2) as integer
	set res to res & {getAllItems:{t1, t2}}
	
	--
	
	set x to get k's l's item ((k's l's length) div 10 * 9)
	set x to "efessg adfaehʫ��AGF"
	
	set rpt to 1000
	set t1 to GetMilliSec
	repeat rpt times
		dict's setItem(x, 0)
	end repeat
	set t1 to ((GetMilliSec) - t1) as integer
	set t2 to GetMilliSec
	repeat rpt times
		udict's setItem(x, 0)
	end repeat
	set t2 to ((GetMilliSec) - t2) as integer
	set res to res & {setItem:{t1, t2}}
	
	--
	
	set x to get k's l's item ((k's l's length) div 10 * 9)
	
	set rpt to 1000
	set t1 to GetMilliSec
	repeat rpt times
		dict's getItem(x)
	end repeat
	set t1 to ((GetMilliSec) - t1) as integer
	set t2 to GetMilliSec
	repeat rpt times
		udict's getItem(x)
	end repeat
	set t2 to ((GetMilliSec) - t2) as integer
	set res to res & {getItem:{t1, t2}}
	
end run
(*
{len:10, addItems:{4, 2}, getAllItems:{3, 3}, setItem:{330, 221}, getItem:{358, 193}}
{len:100, addItems:{35, 45}, getAllItems:{34, 31}, setItem:{355, 298}, getItem:{383, 290}}
{len:1000, addItems:{564, 1898}, getAllItems:{544, 379}, setItem:{732, 374}, getItem:{685, 367}}
*)