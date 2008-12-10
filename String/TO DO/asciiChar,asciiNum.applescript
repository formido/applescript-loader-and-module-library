on _makeASCIITable()
	set str to ""
	repeat with i from 0 to 255
		set str to str & (ASCII character i)
	end repeat
	return str
end _makeASCIITable

property _asciiTable : _makeASCIITable()

--

on asciiChar(int)
	try
		set int to int as integer
		if int < 0 or int > 255 then error "out of range." number -1728
		return _asciiTable's item (int + 1)
	on error eMsg number eNum
		error "Can't get asciiChar: " & eMsg number eNum
	end try
end asciiChar

on asciiNum(str)
	try
		set str to str as string
		if str's length is not 1 then error "not a single character." number -1703
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to str
		set int to count of _asciiTable's first text item
		set AppleScript's text item delimiters to oldTID
		return int
	on error eMsg number eNum
		error "Can't get asciiNum: " & eMsg number eNum
	end try
end asciiNum

set str to "®"
set int to 200
set rpt to 10000

set t to GetMilliSec
repeat rpt times
	asciiChar(int) -- {322, 690} (only 2x faster on OS 10.2)
end repeat
set t1 to ((GetMilliSec) - t) as integer
set t2 to GetMilliSec
repeat rpt times
	ASCII character int
end repeat
set t2 to ((GetMilliSec) - t2) as integer
set rpt to 1000
set tm to GetMilliSec
repeat rpt times
	asciiNum(str) -- {962, 570} (2x slower on OS 10.2!)
end repeat
set t3 to ((GetMilliSec) - tm) as integer
set tm to GetMilliSec
repeat rpt times
	ASCII number str
end repeat
set t4 to ((GetMilliSec) - tm) as integer

{t1, t2, t3, t4}
