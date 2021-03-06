property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Strftime : missing value

on __load__(loader)
	set _Strftime to loader's loadLib("Strftime")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


set d to date (get "1 3 05 7 43 1")

log {_Strftime's |strftime|(d, "%Y-%m-%d, %I:%M %p"), _Strftime's strftime2(d, "%Y-%m-%d, %I:%M %p")} = {"2005-03-01, 07:43 AM", "2005-3-1, 7:43 AM"}


log _Strftime's |strftime|(d, "
%a				locale's abbreviated weekday name
%A				locale's full weekday name
%b				locale's abbreviated month name
%B				locale's full month name
%c				locale's appropriate date and time representation
%C				first two digits of year (00-99)
%d				day of month (01�31)
%D				date as m/d/y
%e				day of month (1�31; single digits are preceded by a space)
%F				date as Y-m-d
%g				like G, but last 2 digits only (00-99)
%G				week-based year as number (see also V)
%h				locale's abbreviated month name
%H				hour (00�23)
%I				hour (01�12)
%j				day number of year (001�366)
%k				hour (0�23; single digits are preceded by a space)
%l				hour (1�12; single digits are preceded by a space)
%m				month as number (01�12)
%M				minute (00�59)
%n				return
%p				the meridian (AM/PM), in uppercase [see Notes]
%P				like p, but lowercase [see Notes]
%r				12-hour time as I:M:S p
%R				24-hour time as H:M
%s				number of seconds since 01/01/1970 00:00:00 GMT (unix epoch)
%S				seconds (00�59)
%t				tab
%T				24-hour time as H:M:S
%u				weekday as number (1�7), Monday=1
%U				week of year as number (00�53), Sunday is first day of week 1
%v				date as e-b-Y
%V				week of year as number (01 to 53), Monday is first day of week, week 1 is first week that has four or more days in the year
%w				weekday as number (0�6), Sunday=0
%W				week number of year (00�53), Monday is first day of week 1
%x				locale's appropriate date representation; here equivalent to theDate's date string
%X				locale's appropriate time representation; here equivalent to theDate's time string
%y				last two digits of year (00�99)
%Y				year as four-digit decimal number (e.g. 2002)
%z				time-zone offset from GMT (aka UTC, Z) [partial support only - see Notes]
%Z				time-zone name/abbreviation [partial support only - see Notes]
%%				
") = "
Tue				locale's abbreviated weekday name
Tuesday				locale's full weekday name
Mar				locale's abbreviated month name
March				locale's full month name
Tue 01 Mar 2005 07:43:01 AM +0000				locale's appropriate date and time representation
20				first two digits of year (00-99)
01				day of month (01�31)
03/01/05				date as m/d/y
 1				day of month (1�31; single digits are preceded by a space)
2005-03-01				date as Y-m-d
05				like G, but last 2 digits only (00-99)
2005				week-based year as number (see also V)
Mar				locale's abbreviated month name
07				hour (00�23)
07				hour (01�12)
060				day number of year (001�366)
 7				hour (0�23; single digits are preceded by a space)
 7				hour (1�12; single digits are preceded by a space)
03				month as number (01�12)
43				minute (00�59)

				return
AM				the meridian (AM/PM), in uppercase [see Notes]
am				like p, but lowercase [see Notes]
07:43:01 AM				12-hour time as I:M:S p
07:43				24-hour time as H:M
1.109662981E+9				number of seconds since 01/01/1970 00:00:00 GMT (unix epoch)
01				seconds (00�59)
					tab
07:43:01				24-hour time as H:M:S
2				weekday as number (1�7), Monday=1
09				week of year as number (00�53), Sunday is first day of week 1
 1-Mar-2005				date as e-b-Y
09				week of year as number (01 to 53), Monday is first day of week, week 1 is first week that has four or more days in the year
2				weekday as number (0�6), Sunday=0
09				week number of year (00�53), Monday is first day of week 1
Tuesday, March 1, 2005				locale's appropriate date representation; here equivalent to theDate's date string
7:43:01 am				locale's appropriate time representation; here equivalent to theDate's time string
05				last two digits of year (00�99)
2005				year as four-digit decimal number (e.g. 2002)
+0000				time-zone offset from GMT (aka UTC, Z) [partial support only - see Notes]
				time-zone name/abbreviation [partial support only - see Notes]
%			
"