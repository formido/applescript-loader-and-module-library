property _Loader : load script alias (((path to scripts folder from local domain) as Unicode text) & "ASLibraries:Loader:Library.scpt")

----------------------------------------------------------------------
-- DEPENDENCIES

property _String : missing value
property _Types : missing value

on __load__(loader)
	tell loader
		set _String to loadLib("String")
		set _Types to loadLib("Types")
	end tell
	return
end __load__

----------------------------------------------------------------------


on randStr()
	set s to ""
	repeat some item of {4, 5, 6, 7, 8, 9, 10} times
		set s to s & some item of "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	end repeat
	return s
end randStr


on run
	__load__(_Loader's makeLoader())
	
	set p to _String's toUnix("import random


a = {}
l = []
g = random.Random()
h = random.Random()


def randstr():
	chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	s = ''
	for i in range(1, h.randint(4, 10)):
		s = s + chars[h.randint(0,51)]
	return s

print randstr()

for i in range(1,1000):
	s = randstr()
	a[s] = i
#	l = l + [s]
	
#for i in range(0, 999):
#	print a[l[i]]")
	
	--set p to "print 'hello'"
	
	set d to _Types's makeDict(false)
	set l to {}
	repeat with i from 1 to 1000
		set s to randStr()
		set l's end to s
	end repeat
	script k
		property ls : l
	end script
	
	
	set rpt to 1
	set t1 to GetMilliSec
	repeat rpt times
		do shell script "python -c " & quoted form of p
	end repeat
	set t1 to ((GetMilliSec) - t1) as integer
	set t2 to GetMilliSec
	repeat rpt times
		
		
		repeat with i in k's ls
			d's setItem(i's contents, 0)
			d's getItem(i's contents)
		end repeat
		--	repeat with i in k's ls
		
		--	end repeat
	end repeat
	set t2 to ((GetMilliSec) - t2) as integer
	
	{t1, t2}
end run
