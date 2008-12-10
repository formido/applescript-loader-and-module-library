property __name__ : "Oyster"
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

property _IO : missing value

on __load__(loader)
	tell loader
		set _IO to loadLib("IO")
	end tell
	return
end __load__

----------------------------------------------------------------------
-- PRIVATE

on _rand()
	return some item of "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
end _rand

----------------------------------------------------------------------
-- PUBLIC

on makeTempFileSpec() -- TO DO: think up a smarter system?
	set tempFold to POSIX path of (path to temporary items)
	set tmpFiles to list folder POSIX file tempFold
	repeat 100 times
		set fileName to "Oyster_" & _rand() & _rand() & _rand() & _rand() & ".txt"
		if {fileName} is not in tmpFiles then return POSIX file (tempFold & fileName)
	end repeat
	error "Temp file overflow." -- this shouldn't happen unless you're generating tons of files and and never cleaning up
end makeTempFileSpec

--

on deleteFile(fileSpec)
	do shell script (("rm -f " as Unicode text) & quoted form of POSIX path of (fileSpec as file specification))
	return
end deleteFile

on deleteFiles(fileSpecList)
	set txt to "" as Unicode text
	repeat with fileSpec in fileSpecList
		set txt to txt & (quoted form of POSIX path of (fileSpec as file specification)) & space
	end repeat
	do shell script (("rm -f " as Unicode text) & txt)
	return
end deleteFiles

--

on isAlive()
	try
		do shell script "perl -e 'print q/hello world/'"
		return true
	on error
		return false
	end try
end isAlive

--

on transformFile(perlScript, srcAlias, destFileSpec)
	do shell script ("perl -e " as Unicode text) & (quoted form of perlScript) & Â
		space & (quoted form of POSIX path of srcAlias) & Â
		space & (quoted form of POSIX path of destFileSpec) returning msg
	if msg is not "" then
		try
			set eMsg to msg's paragraphs 1 thru -2
			set eNum to msg's last paragraph as integer
		on error
			set {eMsg, eNum} to {"Unknown error: " & msg, 200}
		end try
		error eMsg number eNum
	end if
	return
end transformFile

on transformData(perlScript, theData, resultClass)
	set srcFS to makeTempFileSpec()
	set destFS to makeTempFileSpec()
	try
		_IO's writeFile(srcFS, theData, theData's class)
		transformFile(perlScript, srcFS, destFS)
		set newData to _IO's readFile(destFS, resultClass)
		deleteFiles({srcFS, destFS})
	on error eMsg number eNum
		deleteFiles({srcFS, destFS})
		error eMsg number eNum
	end try
	return newData
end transformData