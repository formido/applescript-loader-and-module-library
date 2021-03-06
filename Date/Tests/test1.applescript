property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Date : missing value

on __load__(loader)
	set _Date to loader's loadLib("Date")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

log _Date's listLanguages()

set f1 to _Date's makeFormatterForLanguage("dddd, d mmmm yyyy, h:MM tt", "gaelic")
log f1's formatDate(date "Saturday, February 1, 2003 1:46:01 PM")

set f2 to _Date's makeFormatter("yyyy-mm-dd  HH:MM:SS")
log f2's formatDate(date "Saturday, February 1, 2003 1:46:01 PM")


log
set intlDateFormatter to _Date's makeFormatter("yyyy-mm-dd HH:MM:SS z")
set intlDateParser to _Date's makeParser("yyyy-mm-dd HH:MM:SS z")

log intlDateFormatter's formatDate(date "Saturday, February 1, 2003 1:46:01 PM")
set s to intlDateFormatter's formatDate(current date)
log s
log intlDateParser's parseText(s)

log
log _Date's makeParser("d/m/yy")'s parseText("3/10/03")
--> {date "Friday, October 3, 2003 12:00:00 am", missing value}

log _Date's makeFormatterForLanguage("dddd dd mmmm yyyy, hh:MM:SS tt (z)", "French")'s formatDate(date "Tuesday, May 30, 2000 12:00:00 AM")

log _Date's makeParserForLanguage("dddd dd mmmm yyyy, hh:MM:SS tt (z)", "French")'s parseText("Mardi 30 mai 2000, 03:30:00 am (-0200)")

log _Date's makeParser("d/m/yy")'s parseText("3/10/71")

(*
set rpt to 100
set t1 to GetMilliSec
repeat rpt times
	set f to _Date's makeFormatter("yyyy-mm-dd HH:MM:SS z", "English")
end repeat
set t1 to ((GetMilliSec) - t1) as integer
set t2 to GetMilliSec
repeat rpt times
	f's formatDate(current date)
end repeat
set t2 to ((GetMilliSec) - t2) as integer
set t3 to GetMilliSec
repeat rpt times
	do shell script "date +'%Y-%m-%d %H:%M:%S %z'"
end repeat
set t3 to ((GetMilliSec) - t3) as integer

log {t1, t2, t3} --> {480, 150, 1070} --(note that 'current date' = 0.4ms, 'formatDate' = 1.1ms)
*)


_Date's makeFormatter("dd `de mmmm `de yyyy", "Brazilian")'s formatDate(current date)