property __name__ : "YearCalendarController"
property __version__ : ""
property __lv__ : 1.0

-- (c) 2003 HAS

----------------------------------------------------------------------
--DEPENDENCIES

property _MonthCalendar : missing value

on __load__(loader)
	set _MonthCalendar to loader's loadComponent("MonthCalendar")
end __load__

----------------------------------------------------------------------
--RENDERING EVENT HANDLERS

on render_template(xo, {yearNum, sundayIsFirst})
	--check parameters
	try
		set yearNum to yearNum as integer
		if yearNum is less than 1 or yearNum is greater than 9999 then error number -1700
	on error number -1703
		error "Invalid Year."
	end try
	--set page's <title>, <h1>
	xo's con_title()'s setContent((yearNum as string) & " calendar")
	xo's con_heading()'s setContent(yearNum)
	--build twelve-month table (4x3)
	set twelveMonthTable to {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}} -- Jan-Apr | May-Aug | Sep-Dec
	--render table
	xo's rep_row()'s repeatWith(twelveMonthTable, {yearNum, sundayIsFirst})
end render_template

--mark --
--mark year grid<B 

on render_row(xo, rowOfMonths, {yearNum, sundayIsFirst})
	xo's rep_col()'s repeatWith(rowOfMonths, {yearNum, sundayIsFirst})
end render_row

on render_col(xo, monthNum, {yearNum, sundayIsFirst}) --a single month cell
	--xo's setContent((monthNum as string) & "/" & yearNum) -- TEST
	xo's setContent(_MonthCalendar's renderTemplate({monthNum, yearNum, sundayIsFirst, missing value}))
end render_col
