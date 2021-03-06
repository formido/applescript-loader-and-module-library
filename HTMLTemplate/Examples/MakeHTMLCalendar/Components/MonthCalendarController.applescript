property __name__ : "MonthCalendarController"
property __version__ : ""
property __lv__ : 1.0

-- (c) 2003 HAS

----------------------------------------------------------------------
--DEPENDENCIES

property _Calendar : missing value

on __load__(loader)
	set _Calendar to loader's loadLib("Calendar")
end __load__

----------------------------------------------------------------------
--PRIVATE

-- TO DO: multi-lingual support; get month and weekday names from Date library

property _monthStrings : {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
property _weekdaysFromSun : {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
property _weekdaysFromMon : ((_weekdaysFromSun's items 2 thru -1) & {_weekdaysFromSun's item 1})

--

script _NullLinkManager
	on linkForDay(dayNum)
		return {false, ""} -- {should link be shown, link path}
	end linkForDay
end script

on _makeWeekdayTracker(sundayIsFirst)
	script
		property _weekend : {sundayIsFirst, false, false, false, false, not sundayIsFirst, true}
		-------
		on isWeekend()
			return (_weekend's first item)
		end isWeekend
		--
		on nextDay()
			set _weekend to rest of _weekend
			return
		end nextDay
	end script
end _makeWeekdayTracker

on _makeDate(monthNum, yearNum)
	set dt to date "Saturday, January 1, 2000 12:00:00 AM"
	set dt's year to yearNum
	set dt's month to item monthNum of {January, February, March, April, May, June, July, August, September, October, November, December}
	return dt
end _makeDate

----------------------------------------------------------------------
--RENDERING EVENT HANDLERS

on render_template(xo, {monthNum, yearNum, sundayIsFirst, linkManager}) --a single month calendar
	try
		--check parameters
		try
			set yearNum to yearNum as integer
			if yearNum is less than 1 or yearNum is greater than 9999 then error
		on error
			error "bad value for year." number -1704
		end try
		try
			set monthNum to monthNum as integer
			if monthNum is less than 1 or monthNum is greater than 12 then error
		on error
			error "bad value for month." number -1704
		end try
		try
			set sundayIsFirst to sundayIsFirst as boolean
		on error
			error "bad value for sundayIsFirst." number -1704
		end try
		if linkManager is missing value then set linkManager to _NullLinkManager
		-- set table caption
		xo's con_caption()'s setContent(_monthStrings's item monthNum)
		-- render column labels
		if sundayIsFirst then
			set columnLabels to _weekdaysFromSun
		else
			set columnLabels to _weekdaysFromMon
		end if
		xo's rep_labels()'s repeatWith(columnLabels, {})
		-- render weekly rows
		set listOfDays to _Calendar's daysByWeekWithPadding(_makeDate(monthNum, yearNum), sundayIsFirst, "&nbsp;")
		xo's rep_week()'s repeatWith(listOfDays, {linkManager, sundayIsFirst})
	on error eMsg number eNum
		error "Can't render month calendar: " & eMsg number eNum
	end try
end render_template


on render_labels(xo, weekdayStr, {})
	xo's att_abbr()'s setContent(weekdayStr)
	xo's setContent(weekdayStr's first character)
end render_labels


on render_week(xo, theWeekList, {linkManager, sundayIsFirst})
	xo's rep_day()'s repeatWith(theWeekList, {linkManager, _makeWeekdayTracker(sundayIsFirst)})
end render_week


on render_day(xo, dayNum, {linkManager, weekdayTracker})
	xo's con_link()'s setContent(dayNum)
	if dayNum's class is integer then
		if weekdayTracker's isWeekend() then xo's att_class()'s setContent("wkend")
		set {showLink, linkTxt} to linkManager's linkForDay(dayNum)
		if showLink then
			xo's con_link()'s att_href()'s setContent(linkTxt)
		else
			xo's con_link()'s omitTags()
		end if
	else
		xo's att_class()'s dontRender()
		xo's con_link()'s omitTags()
	end if
	weekdayTracker's nextDay()
end render_day
