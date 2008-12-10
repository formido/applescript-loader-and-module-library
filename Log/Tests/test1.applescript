property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Log : missing value

on __load__(loader)
	set _Log to loader's loadLib("Log")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set logFile to _Log's makeLog("Macintosh HD:Users:has:logfile.txt" as file specification)

logFile's openLog()
logFile's logMsg("Hello World")
logFile's closeLog()