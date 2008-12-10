property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Calendar : missing value

on __load__(loader)
	set _Calendar to loader's loadLib("Calendar")
end __load__

----------------------------------------------------------------------
-- MAIN

__load__(_Loader's makeLoader())



log _Calendar's daysInMonth(date "Sunday, February 9, 2003 2:05:09 PM")
--> 28

log _Calendar's firstDayOfMonth(date "Sunday, February 9, 2003 2:05:09 PM")
--> Saturday

log _Calendar's daysByWeek(date "Sunday, February 9, 2003 2:05:09 PM", true)
--> {{1}, {2, 3, 4, 5, 6, 7, 8}, {9, 10, 11, 12, 13, 14, 15}, {16, 17, 18, 19, 20, 21, 22}, {23, 24, 25, 26, 27, 28}}

log _Calendar's daysByWeekWithPadding(date "Sunday, February 9, 2003 2:05:09 PM", false, "")
--> {{"", "", "", "", "", 1, 2}, {3, 4, 5, 6, 7, 8, 9}, {10, 11, 12, 13, 14, 15, 16}, {17, 18, 19, 20, 21, 22, 23}, {24, 25, 26, 27, 28, "", ""}, {"", "", "", "", "", "", ""}}

log _Calendar's tableForMonth(date "Sunday, February 9, 2003 2:05:09 PM", false)
(*
"Mo	Tu	We	Th	Fr	Sa	Su
  	  	  	  	  	 1	 2
 3	 4	 5	 6	 7	 8	 9
10	11	12	13	14	15	16
17	18	19	20	21	22	23
24	25	26	27	28	  	  
  	  	  	  	  	  	  "
*)