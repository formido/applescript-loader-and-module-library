
----------------------------------------------------------------------
--mark -
--mark TESTS<B
-- TEST 1
(*
log sortList({1, 3, 8, 2})

-- TEST 2

set lst to {{4, 1}, {3, 2}, {4, 0}, {4, 2}, {0, 5}, {4, 1}, {3, 0}, {1, 7}}
log sortListOfLists(lst, {1, 2})

-- TEST 3

script EvalMyDateOfRecord
	property reverseSort : false
	on eval(theRecord)
		return myDate of theRecord -- your code here
	end eval
end script

set lst to {{myDate:date "Tuesday, February 4, 2003 12:00:00 am"}, {myDate:date "Monday, February 3, 2003 12:00:00 am"}, {myDate:date "Saturday, February 1, 2003 12:00:00 am"}, {myDate:date "Sunday, February 2, 2003 12:00:00 am"}}
log powerSort(lst, EvalMyDateOfRecord, 0)

-- TEST 4

script EvalA
	property reverseSort : false
	on eval(rec)
		return rec's a -- your code here
	end eval
end script

script EvalB
	property reverseSort : false
	on eval(rec)
		return rec's b -- your code here
	end eval
end script

set lst to {{a:1, b:3}, {a:5, b:2}, {a:5, b:1}}
log powerSort(lst, {EvalA, EvalB}, 0)
*)

(*-- TEST 5 (long-duration)

script
	property l : {}
end script
set x to result

repeat with i from 1 to 40000
	set x's l's end to i
end repeat

set l to reverse of x's l

beep
sortList(x's l)
beep*)


-- TEST 6
(*
script Eval1
	property reverseSort : false
	on eval(val)
		return 10 * (val's a) -- your code here
	end eval
end script

script Eval2
	property reverseSort : false
	on eval(val)
		return 10 * (val's b) -- your code here
	end eval
end script

set lst to {{a:4, b:1}, {a:3, b:2}, {a:4, b:0}, {a:4, b:2}, {a:0, b:5}, {a:4, b:1}, {a:4, b:1}, {a:4, b:1}, {a:3, b:0}, {a:1, b:7}}
log powerSort(lst, {Eval1, Eval2}, 2)
*)

-- TEST 7
(*
script Eval3
	property reverseSort : false
	on eval(val)
		return (val) -- your code here
	end eval
end script
set lst to {7, 1, 3, 4, 5, 2, 2, 4, 2, 4, 7, 8, 9, 1, 0, 4, 4, 4}

log powerSort(lst, {Eval3}, 1)*)


-- TEST 8
script randList
	on mkEval(n, r)
		script
			property reverseSort : r
			property _n : n
			on eval(val)
				return val's item _n
			end eval
		end script
	end mkEval
	
	on rand(n)
		some item of items 1 thru n of {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	end rand
	
	on swap(lst, idx1, idx2)
		tell lst to set {item idx1, item idx2} to {item idx2, item idx1}
		return
	end swap
	
	on mk()
		-- make a list of sublists of form {x,y,z,cnt}, where x,y,z are random
		set cnt to 0 -- unique 4th number for checking sorts are stable
		set m to {}
		repeat 40 times
			set l to {}
			repeat with i from 1 to 10
				set l's end to (i - 1) div 2
			end repeat
			
			repeat 10 times
				swap(l, rand(10), rand(10))
			end repeat
			set m's end to l's items 1 thru 3 & {cnt}
			set cnt to cnt + 1
		end repeat
		
		set O to {1, 2, 3}
		repeat 3 times
			swap(O, rand(3), rand(3))
		end repeat
		
		set e to {}
		repeat with i from 1 to 3
			set s to false --some item of {true, false}
			set e's end to mkEval(i, s) --o's item
			--	log {i, s} --o's item
		end repeat
		return {m, e}
	end mk
	
	--
	
	on dive(lst, depth, indt, res)
		if depth is less than 0 then
			set text item delimiters to ", "
			set res's end to indt & "{" & lst & "}"
			--log indt & "{" & lst & "}"
		else
			--log indt & "{"
			set res's end to indt & "{"
			repeat with itm in lst
				dive(itm's contents, depth - 1, indt & tab, res)
			end repeat
			set res's end to indt & "}"
			--log indt & "}"
		end if
	end dive
	
	on fmt(lst, dpth)
		set res to {}
		dive(lst, dpth, "", res)
		set text item delimiters to return
		set txt to res as string
		set text item delimiters to ""
		return txt
	end fmt
end script

(*

set {lst, evals} to randList's mk()
set evals to evals --'s reverse's items 1 thru -3
set dpth to (count evals)

log lst
set lst to powerSort(lst & {{5, 5, 5}}, evals, dpth)
log lst
log randList's fmt(lst, dpth)
*)


-- TEST 9

script SortOnMonth
	property reverseSort : false
	on eval(sublst)
		set mnth to sublst's last item's month
		repeat with idx from 1 to 12
			if item idx of {January, February, March, April, May, June, July, August, September, October, November, December} is mnth then exit repeat
		end repeat
		return idx
	end eval
end script

script SortOnDay
	property reverseSort : false
	on eval(sublst)
		return sublst's last item's day
	end eval
end script

script SortOnYear
	property reverseSort : false
	on eval(sublst)
		return sublst's last item's year
	end eval
end script

script SortOnName
	property reverseSort : false
	on eval(sublst)
		return sublst's first item
	end eval
end script

set lst to {{"Jo", date (get "19/2/1975")}, {"John", date (get "1/12/1970")}, {"Bob", date (get "4/2/1975")}, {"Jane", date (get "16/6/1970")}, {"Mary", date (get "1/12/1975")}, {"Ray", date (get "1/12/1973")}}

powerSort(lst, {SortOnMonth, SortOnDay, SortOnName}, 1)
