property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


on charToHTML(char)
	return "&#" & _Unicode's uNum(char) & ";"
end charToHTML

set string_ to "Æ¶¸¹·½ð"

set {ls, my text item delimiters, htm} to {{}, "", "/tmp/temp.html"}
repeat with c in characters in string_
	set end of ls to "" & charToHTML(c)
end repeat
set f to POSIX file htm
set fref to open for access f with write permission
set eof f to 0
write "<font face='lucida grande'>" to f
write "" & ls to f
write "</font>" to f
close access f
do shell script "open -a safari " & htm