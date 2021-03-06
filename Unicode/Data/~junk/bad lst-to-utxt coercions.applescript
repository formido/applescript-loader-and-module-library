property ASLoader : load script ((((path to scripts folder from local domain) as Unicode text) & "ASLibraries:ASLoader.scpt") as alias)

-- other libraries
property _UnicodeLib : missing value

--

on __load__(loader) -- call this at every run/open/etc. for dynamic loading
	set _UnicodeLib to loader's loadLib("UnicodeLib")
end __load__

----------------------------------------------------------------------

on u(num)
	return _UnicodeLib's uChar(num)
end u

__load__(ASLoader's makeLoader())

-- 'lst as Unicode text' is buggy. Oh joy!
set badLst to {}
set AppleScript's text item delimiters to "" as Unicode text
repeat with i from 0 to 512 -- 65535
	set a to (("" as Unicode text) & u(i))
	set b to {"" as Unicode text, u(i)} as Unicode text
	if a is not b then set badLst's end to {i, a, b}
end repeat
{count badLst, badLst}