property __name__ : "IO"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

on writeFile(fileSpec, theData, asClass)
	try
		open for access (fileSpec as file specification) with write permission returning fileRef
		try
			set eof of fileRef to 0
			write theData to fileRef as asClass
		on error eMsg number eNum
			close access fileRef
			error eMsg number eNum
		end try
		close access fileRef
		return
	on error eMsg number eNum
		error "Can't writeFile: " & eMsg number eNum
	end try
end writeFile

on readFile(fileSpec, asClass)
	try
		set fileSpec to fileSpec as file specification
		if (get eof fileSpec) is 0 and asClass is string then
			return ""
		else
			return read fileSpec from 1 as asClass
		end if
	on error eMsg number eNum
		error "Can't readFile: " & eMsg number eNum
	end try
end readFile

-- TO DO: sniffFile(fileSpec) -- read first 4 bytes and guess class ?

(*
-- TEST

set f to "Macintosh HD:users:has:IOTest"
repeat with datRef in {true, 1, -198.01, 4.1E-50, "hello", "world" as Unicode text, {1, 2, "hello"}, {a:true, |b d|:{32, "%"}}}
	set dat to datRef's contents
	log dat
	writeFile(f, dat)
	if dat is not readFile(f, dat's class) then error datRef
end repeat
*)