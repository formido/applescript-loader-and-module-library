property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _RE : missing value
property _UnicodeIO : missing value

on __load__(loader)
	set _RE to loader's loadLib("RE")
	set _UnicodeIO to loader's loadLib("UnicodeIO")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set txt to _UnicodeIO's readUTF8("/Users/has/AppleMods/Website/index.html" as POSIX file)
paragraphs of _RE's reMatch(txt, "<a\\s[^>]*href=(\"([^\"]*)|'([^']*))", "$2$3\\n")
--paragraphs of _RE's reMatch(txt, "<img\\s[^>]*src=(\"([^\"]*)|'([^']*))", "$2$3\\n")

