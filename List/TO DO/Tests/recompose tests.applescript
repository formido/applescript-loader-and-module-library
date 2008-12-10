
on makeWide()
	set l to {}
	repeat 2000 times
		set l's end to {1, 2}
	end repeat
	return l
end makeWide

set lst to makeWide()
set len to count lst

on makeNarrow()
	set l to {}
	set m to {}
	repeat 2000 times
		set l's end to 1
		set m's end to 2
	end repeat
	return {l, m}
end makeNarrow



set rpt to 10
set t1 to GetMilliSec
repeat rpt times
	--_recomposeNarrow(lst, len)
	_recomposeWide(lst, len)
end repeat
set t1 to ((GetMilliSec) - t1) as integer
set t2 to GetMilliSec
repeat rpt times
	recomposeList(lst)
end repeat
set t2 to ((GetMilliSec) - t2) as integer

{t1, t2}
