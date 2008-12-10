on daysInMonth(theDate) -- modified from Nigel Garvey's Date Tips package
	copy theDate to d
	set d's day to 32
	set d's day to 1
	set d to d - (1 * days)
	return d's day
end daysInMonth

property _mnths : {January, February, March, April, May, June, July, August, September, October, November, December}

on makeDate(y, m, d, t) -- makeDate(y, mo, d, h, m, s)
	try
		considering hyphens, punctuation and white space --ensure robust string-to-integer conversion
			set theDate to date (get "1")
			--set year
			set y to y as integer
			if (y < 1) or (y > 9999) then error "year is out of range." number -1703
			set theDate's year to y
			--set month
			if m is in _mnths then
				set theDate's month to m
			else
				set m to m as integer
				if (m < -12) or (m = 0) or (m > 12) then error "month is out of range." number -1703
				set theDate's month to _mnths's item m
			end if
			--set day
			set d to d as integer
			set noOfDays to daysInMonth(theDate)
			if (d < 1) then
				if (d = 0) or (d < -noOfDays) then error "day is out of range." number -1703
				set d to noOfDays + 1 + d
			end if
			if (d > noOfDays) then error "day is out of range." number -1703
			set theDate's day to d
			--set time
			set t to t as integer
			if (t < 0) or (t > 86399) then error "time is out of range." number -1703
			set theDate's time to t
		end considering
		return theDate
	on error eMsg number eNum
		error "Can't make makeDate: " & eMsg number eNum
	end try
end makeDate

on HMSToSecs(h, m, s)
	try
		considering hyphens, punctuation and white space --ensure robust string-to-integer conversion
			set h to h as integer
			set m to m as integer
			set s to s as integer
		end considering
		if (h < 0) or (h > 23) then error "hour is out of range." number -1703
		if (m < 0) or (m > 59) then error "minute is out of range." number -1703
		if (s < 0) or (s > 59) then error "second is out of range." number -1703
		return ((h * 3600) + (m * 60) + s)
	on error eMsg number eNum
		error "Can't get asSeconds: " & eMsg number eNum
	end try
end HMSToSecs

on SecsToHMS(secs)
	try
		considering hyphens, punctuation and white space --ensure robust string-to-integer conversion
			set secs to secs as integer
		end considering
		if (secs < 0) or (secs > 86399) then error "time is out of range." number -1703
		return {secs div 3600, secs div 60 mod 60, secs mod 60}
	on error eMsg number eNum
		error "Can't get asTime: " & eMsg number eNum
	end try
end SecsToHMS

on DHMSToSecs(d, h, m, s)
	try
		considering hyphens, punctuation and white space
			set d to d as integer
			set h to h as integer
			set m to m as integer
			set s to s as integer
		end considering
		if (d < 0) then error "day is out of range." number -1704
		if (h < 0) or (h > 23) then error "hour is out of range." number -1704
		if (m < 0) or (m > 59) then error "minute is out of range." number -1704
		if (s < 0) or (s > 59) then error "second is out of range." number -1704
		return ((d * 86400) + (h * 3600) + (m * 60) + s)
	on error eMsg number eNum
		error "Can't convert DHMSToSeconds: " & eMsg number eNum
	end try
end DHMSToSecs

on secsToDHMS(secs) --> {days, hours, mins, secs}
	try
		considering hyphens, punctuation and white space
			set secs to secs as integer
		end considering
		if (secs < 0) then error "secs is out of range." number -1704
		return {secs div 86400, secs div 3600 mod 24, secs div 60 mod 60, secs mod 60}
	on error eMsg number eNum
		error "Can't convert secondsToDHMS: " & eMsg number eNum
	end try
end secsToDHMS

makeDate(2001, -9, -30, 0)
--asTime(12000)
--asSeconds(3, 20, 0)