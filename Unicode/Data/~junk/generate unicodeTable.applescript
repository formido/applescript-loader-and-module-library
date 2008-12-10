on writeToFile(fileSpec, txt)
	open for access fileSpec with write permission returning fileRef
	set eof of fileRef to 0
	write txt to fileRef
	close access fileRef
	return
end writeToFile

on makeASCIITable()
	set str to ""
	repeat with i from 0 to 255
		set str to str & (ASCII character i)
	end repeat
	return str
end makeASCIITable

property _asciiTable : makeASCIITable()
property _magicNumber : (ASCII character 254) & (ASCII character 255)

set lst to {}
repeat with i from 1 to 256
	set txt to ""
	repeat with j from 1 to 256
		set txt to txt & (_asciiTable's item i) & (_asciiTable's item j)
	end repeat
	set fs to "/Users/has/Library/Scripts/ASLibraries/UnicodeLib/Support/Tables/" & i & ".txt" as POSIX file
	writeToFile(fs, _magicNumber & txt)
end repeat