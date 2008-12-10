(*	ABOUT:

	- SampleLibrary contains an assortment of handlers - some well-designed, others intentionally awful - used to demonstrate the ASTest framework.

*)

-------------------------------------------------
-- CALCULATE SQUARES/SQUARE ROOTS

on squareOf(num) -- pretty solid stuff [unless you count the lack of protection against really-huge-number-problems]
	if num's class is not in {integer, real} then error "Can't get squareOf: wasn't integer/real." number 420
	return (num ^ 2)
end squareOf

--

on sloppySquareOf(num) -- no bad-parameter checking or error trapping... lazy, lazy, lazy
	return (num ^ 2)
end sloppySquareOf


-------------------------------------------------
-- CALCULATE SQUARE ROOTS

on squareroot(num) -- pretty solid stuff
	if num's class is not in {integer, real} then error "Can't get squareRoot: wasn't integer/real." number 430
	if num < 0 then error "Can't get squareRoot: number was negative." number 431
	return (num ^ 0.5)
end squareroot


-------------------------------------------------
-- IS INTEGER ODD OR EVEN?

on integerIsEven(num) -- a buggy routine; last line contains a typo 'nun'
	if num's class is not integer then error "Invalid parameter (not an integer)." number 519
	return ((nun mod 2) is 0)
end integerIsEven


-------------------------------------------------
--LIST CONCATENATIONS

on badConcat(theList) -- this handler's results will be affected by AS's current text item delimiters; also, there is no error handling to protect against bad params
	return theList as string
end badConcat

--

on sloppyConcat(theList) -- this handler's behaviour won't be harmed by current TIDs, but it fails to restore the previous value once done
	try
		set AppleScript's text item delimiters to {""}
		return theList as string
	on error eMsg number eNum
		error "Couldn't concatenate: " & eMsg number 600
	end try
end sloppyConcat

--

on goodConcat(theList) -- pretty solid stuff [unless Unicode/international text is involved; if it is, some better bad-type checking or smarter concat/coerce is needed]
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ""
	try
		set resultString to theList as string
	on error eMsg number eNum
		set AppleScript's text item delimiters to oldTID
		error "Couldn't concatenate: " & eMsg number 600
	end try
	set AppleScript's text item delimiters to oldTID
	return resultString
end goodConcat

-------