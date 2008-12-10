property __name__ : "UnicodeIO"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 John Delacour, HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _Oyster : missing value
property _UTF8To16 : missing value
property _UTF16To8 : missing value

-------

on __load__(loader)
	tell loader
		set _Oyster to tryToLoadLib("Oyster")
		set _UTF8To16 to loadTextComponent("UTF8To16")
		set _UTF16To8 to loadTextComponent("UTF16To8")
	end tell
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _magic : (ASCII character 254) & (ASCII character 255)

----------------------------------------------------------------------
-- PUBLIC
on writeFile(fileSpec, txt)
	writeUTF16(fileSpec, txt)
end writeFile

on readFile(fileSpec)
	readUTF16(fileSpec)
end readFile

--

on writeUTF16(fileSpec, txt)
	try
		set txt to txt as Unicode text
		open for access (fileSpec as file specification) with write permission returning fileRef
		try
			set eof of fileRef to 0
			write _magic to fileRef as string
			write txt to fileRef as Unicode text
		on error eMsg number eNum
			close access fileRef
			error eMsg number eNum
		end try
		close access fileRef
		return
	on error eMsg number eNum
		error "Can't writeFile: " & eMsg number eNum
	end try
end writeUTF16

on readUTF16(fileSpec)
	try
		set fileSpec to fileSpec as file specification
		if ((get eof fileSpec) is less than 2) or ((read fileSpec from 1 to 2 as string) is not _magic) then
			error "not a UTF-16 text file." number 1702
		end if
		return read fileSpec from 1 as Unicode text
	on error eMsg number eNum
		error "Can't readFile: " & eMsg number eNum
	end try
end readUTF16

--

on writeUTF8(fileSpec, txt)
	try
		set tempFile to _Oyster's makeTempFile()
		writeFile(tempFile, txt)
		utf16To8(tempFile, fileSpec)
		_Oyster's deleteFile(tempFile)
		return
	on error eMsg number eNum
		if _Oyster is missing value then set {eMsg, eNum} to {"Oyster library isn't loaded.", 1650}
		error "Can't writeUTF8: " & eMsg number eNum
	end try
end writeUTF8

on readUTF8(fileSpec)
	try
		set tempFile to _Oyster's makeTempFile()
		utf8To16(fileSpec, tempFile)
		set txt to readFile(tempFile)
		_Oyster's deleteFile(tempFile)
		return txt
	on error eMsg number eNum
		if _Oyster is missing value then set {eMsg, eNum} to {"Oyster library isn't loaded.", 1650}
		error "Can't readUTF8: " & eMsg number eNum
	end try
end readUTF8

--

on utf8To16(srcFile, destFile)
	try
		_Oyster's transformFile(_UTF8To16, srcFile as alias, destFile as file specification)
		return
	on error eMsg number eNum
		if _Oyster is missing value then set {eMsg, eNum} to {"Oyster library isn't loaded.", 1650}
		error "Can't convert utf8To16: " & eMsg number eNum
	end try
end utf8To16

on utf16To8(srcFile, destFile)
	try
		_Oyster's transformFile(_UTF16To8, srcFile as alias, destFile as file specification)
		return
	on error eMsg number eNum
		if _Oyster is missing value then set {eMsg, eNum} to {"Oyster library isn't loaded.", 1650}
		error "Can't convert utf16To8: " & eMsg number eNum
	end try
end utf16To8