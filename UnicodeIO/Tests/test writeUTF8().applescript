property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value
property _UnicodeIO : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
	set _UnicodeIO to loader's loadLib("UnicodeIO")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set l to {65, 66, 67, 68, 69, 10, 945, 946, 947, 948, 949, 10, 1040, 1041, 1042, 1043, 1044, 10, 3665, 3666, 3667, 3668, 3669, 10, 3840, 3841, 3842, 3843, 3844}

set s to "" as Unicode text
repeat with num in l
	set s to s & _Unicode's uChar(num)
end repeat
--set s to ""

set f to "/Users/has/UIOtest_utf8.txt" as POSIX file
_UnicodeIO's writeUTF8(f, s)
set t to _UnicodeIO's readUTF8(f)


--_UnicodeIO's readUTF8("/Users/has/Library/Preferences/com.apple.internetconfig.plist" as POSIX file)
{t = s, t}