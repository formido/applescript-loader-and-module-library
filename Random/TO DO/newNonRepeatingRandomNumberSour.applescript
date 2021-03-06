on _makeRange(fromNum, toNum, byStep)
	set lst to {}
	repeat with i from fromNum to toNum by byStep
		set lst's end to i
	end repeat
	return lst
end _makeRange

on makeUniqueIntegerGenerator(min, max)
	script
		script _k -- fast list-access hack
			property sourceNumbers : _makeRange(min, max, 1)
			property currentIdxs : {}
			property validIdxs : {}
		end script
		
		property _allIdxs : _makeRange(1, count of _k's sourceNumbers, 1)
		
		on rand()
			if _k's validIdxs is {} then
				copy _allIdxs to _k's currentIdxs
				set _k's validIdxs to _k's currentIdxs
			end if
			set idx to some item of _k's validIdxs
			set _k's currentIdxs's item idx to missing value
			set _k's validIdxs to get _k's currentIdxs's numbers
			return item idx of _k's sourceNumbers
		end rand
	end script
end makeUniqueIntegerGenerator


set x to makeUniqueIntegerGenerator(1, 4000, 1)
set t to GetMilliSec
set z to {}
repeat 20 times
	set y to x's rand()
	--if z contains y then error
	--set z's end to y
end repeat
z
(GetMilliSec) - t