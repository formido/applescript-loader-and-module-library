property _Loader : run application "LoaderServer"------------------------------------------------------------------------ DEPENDENCIESproperty _UnicodeIO : missing valueon __load__(loader)	set _UnicodeIO to loader's loadLib("UnicodeIO")end __load__------------------------------------------------------------------------ TEST__load__(_Loader's makeLoader())set f to "Macintosh HD:Users:has:UIOtest_utf16.txt" as file specification_UnicodeIO's writeFile(f, "abcå∫çé")(*open for access f returning r
read r to 2
try
	set s to _UnicodeIO's readFile(f)
on error e
	display dialog e
end try
close access r
s*)_UnicodeIO's readFile(f)