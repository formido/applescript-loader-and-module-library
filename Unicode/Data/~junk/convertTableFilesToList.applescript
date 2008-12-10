on writeListToFile(fileSpec, lst)
	open for access fileSpec with write permission returning fileRef
	set eof of fileRef to 0
	write lst to fileRef as list
	close access fileRef
	return
end writeListToFile

set lst to {}
repeat with i from 1 to 256
	set fs to "/Users/has/Library/Scripts/ASLibraries/UnicodeLib/Support/Tables/" & i & ".txt" as POSIX file
	set txt to read fs as Unicode text
	repeat with i from 1 to 256 by 32
		set lst's end to txt's text i thru (i + 31)
	end repeat
end repeat
set fs to "/Users/has/Library/Scripts/ASLibraries/UnicodeLib/Support/characterTables" as POSIX file
writeListToFile(fs, lst)
read fs as list
{count result, count result's item 1}