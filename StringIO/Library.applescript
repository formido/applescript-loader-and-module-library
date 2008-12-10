property __name__ : "StringIO"
property __version__ : "0.1.0"
property __lv__ : 1.0

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

on writeFile(fileSpec, txt)
	try
		set txt to txt as string
		open for access (fileSpec as file specification) with write permission returning fileRef
		try
			set eof of fileRef to 0
			write txt to fileRef as string
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

on readFile(fileSpec)
	try
		set fileSpec to fileSpec as file specification
		if (get eof fileSpec) is 0 then
			set txt to ""
		else
			set txt to read fileSpec from 1 as string
		end if
		return txt
	on error eMsg number eNum
		error "Can't readFile: " & eMsg number eNum
	end try
end readFile


-- TEST
(*

set f to "Macintosh HD:Users:has:StringIOTest.txt" as file specification
writeFile(f, "") --Hello world.")

readFile(f)
*)