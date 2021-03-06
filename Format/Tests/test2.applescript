property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Format : missing value

on __load__(loader)
	set _Format to loader's loadLib("Format")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set tm to GetMilliSec
set formatter to _Format's makeFormatter("%x005f%x005f%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de%x005f%x31de" as Unicode text)
set t1 to ((GetMilliSec) - tm) as integer
set tm to GetMilliSec
repeat 1000 times
	formatter's formatData({1, 2})
end repeat
set t2 to ((GetMilliSec) - tm) as integer

log formatter's formatData({1, 2})

{t1, t2}
