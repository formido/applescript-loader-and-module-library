on itemsMatching(lst, evaluator)
	script k
		property l : lst
	end script
	set res to {}
	repeat with itmRef in k's l
		set itm to itmRef's contents
		if evaluator's eval(itm) then set res's end to itm
	end repeat
	return res
end itemsMatching

on indexesMatching(lst, evaluator)
	script k
		property l : lst
	end script
	set res to {}
	repeat with i from 1 to count of k's l
		if evaluator's eval(k's l's item i) then set res's end to i
	end repeat
	return res
end indexesMatching

script evaluator
	on eval(val)
		val > 3
	end eval
end script

itemsMatching({1, 2, 3, 4, 5, 6, 7, 8, 6, 4, 2, 1}, evaluator) -- filterList