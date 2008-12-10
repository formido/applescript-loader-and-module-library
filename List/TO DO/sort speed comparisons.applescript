property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value
property _Random : missing value

on __load__(loader)
	set _List to loader's loadLib("List")
	set _Random to loader's loadLib("Random")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

on _downheap(k, i, n)
	set t to k's l's item i
	repeat while i ² n div 2
		set j to i + i
		if j < n and k's l's item j < k's l's item (j + 1) then
			set j to j + 1
		end if
		if t ³ k's l's item j then
			exit repeat
		else
			set k's l's item i to k's l's item j
			set i to j
		end if
	end repeat
	set k's l's item i to t
end _downheap

on heapsort(lst)
	script k
		property l : lst's items
	end script
	set n to count k's l
	repeat with i from n div 2 to 1 by -1
		_downheap(k, i, n)
	end repeat
	repeat while n > 1
		set t to k's l's first item
		set k's l's first item to k's l's item n
		set k's l's item n to t
		set n to n - 1
		_downheap(k, 1, n)
	end repeat
	return k's l
end heapsort

-------

on _ipSort(k, l, r) -- A. Knapp quicksort
	set i to l
	set j to r
	set v to k's lst's item ((l + r) div 2)
	repeat while (j > i)
		repeat while (k's lst's item i < v)
			set i to i + 1
		end repeat
		repeat while (k's lst's item j > v)
			set j to j - 1
		end repeat
		if (i ² j) then
			set tmp to k's lst's item i
			set k's lst's item i to k's lst's item j
			set k's lst's item j to tmp
			set i to i + 1
			set j to j - 1
		end if
	end repeat
	if (l < j) then _ipSort(k, l, j)
	if (r > i) then _ipSort(k, i, r)
	return
end _ipSort

on ipSort(theList)
	if theList's class is not list then error "not a list."
	script k
		property lst : theList's items
	end script
	_ipSort(k, 1, count k's lst)
	return k's lst
end ipSort


log "heapsort	ipsort	sortlist"

repeat with len in {10, 100, 1000, 10000}
	
	set lst to {}
	set g to _Random's makeIntegerGenerator(1, len * 1000)
	repeat len times
		set lst's end to g's rand()
	end repeat
	
	set n to 1000 / len
	if n < 1 then set n to 1
	
	
	set t to (GetMilliSec)
	repeat n times
		heapsort(lst)
	end repeat
	set a to ((GetMilliSec) - t) as integer
	set t to (GetMilliSec)
	repeat n times
		ipSort(lst)
	end repeat
	set b to ((GetMilliSec) - t) as integer
	set t to (GetMilliSec)
	repeat n times
		_List's sortList(lst)
	end repeat
	set c to ((GetMilliSec) - t) as integer
	
	
	set m to len div 1000
	if m < 1 then set m to 1
	log (a div m as string) & tab & b div m & tab & c div m & tab & "-- " & len
end repeat
(*
"heapsort	ipsort	sortlist"
"241	153	197	-- 10"
"481	248	347	-- 100"
"686	394	478	-- 1000"
"939	475	589	-- 10000"
*)