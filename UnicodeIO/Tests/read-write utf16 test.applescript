property _Loader : run application "LoaderServer"
read r to 2
try
	set s to _UnicodeIO's readFile(f)
on error e
	display dialog e
end try
close access r
s*)