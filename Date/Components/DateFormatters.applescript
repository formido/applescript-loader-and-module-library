property __name__ : "DateFormatters"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _FormatterBase
	property _next : missing value
	property _interTxt : missing value
	--
	on eval(dt, lang, res, lib)
		return _next's eval(dt, lang, res & _interTxt & __eval(dt, lang, lib), lib)
	end eval
end script

-- formatter nodes

script d
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return dt's day
	end __eval
end script
script dd
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((dt's day) + 100) as string)
	end __eval
end script
script ddd
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return item (lib's weekdayToInteger(dt's weekday)) of lang's shortWeekday
	end __eval
end script
script dddd
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return item (lib's weekdayToInteger(dt's weekday)) of lang's longWeekday
	end __eval
end script
--
script m
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return lib's monthToInteger(dt's month)
	end __eval
end script
script mm
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((lib's monthToInteger(dt's month)) + 100) as string)
	end __eval
end script
script mmm
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return item (lib's monthToInteger(dt's month)) of lang's shortMonth
	end __eval
end script
script mmmm
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return item (lib's monthToInteger(dt's month)) of lang's longMonth
	end __eval
end script
--
script y
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return dt's year
	end __eval
end script
script yy
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((dt's year) + 100) as string)
	end __eval
end script
script yyyy
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return text -4 thru -1 of (((dt's year) + 10000) as string)
	end __eval
end script
--
script h
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		set h to ((dt's time) div 3600) mod 12
		if h is 0 then
			return "12"
		else
			return h
		end if
	end __eval
end script
script hh
	property parent : h
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((continue __eval(dt, lang, lib)) + 100) as string)
	end __eval
end script
script |H|
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return (dt's time) div 3600
	end __eval
end script
script |HH|
	property parent : |H|
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((continue __eval(dt, lang, lib)) + 100) as string)
	end __eval
	--
end script
script |M|
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return ((dt's time) div 60) mod 60
	end __eval
end script
script |MM|
	property parent : |M|
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((continue __eval(dt, lang, lib)) + 100) as string)
	end __eval
	--
end script
script |S|
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		return (dt's time) mod 60
	end __eval
end script
script |SS|
	property parent : |S|
	on __eval(dt, lang, lib)
		return text -2 thru -1 of (((continue __eval(dt, lang, lib)) + 100) as string)
	end __eval
end script
--
script tt
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		if ((dt's time) div 43200) is 0 then
			return lang's am
		else
			return lang's pm
		end if
	end __eval
end script
script t
	property parent : tt
	on __eval(dt, lang, lib)
		return first character of (continue __eval(dt, lang, lib))
	end __eval
end script
--
script |TT|
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		if ((dt's time) div 43200) is 0 then
			return lang's |AM|
		else
			return lang's |PM|
		end if
	end __eval
end script
script |T|
	property parent : |TT|
	on __eval(dt, lang, lib)
		return first character of (continue __eval(dt, lang, lib))
	end __eval
end script
--
script z
	property parent : _FormatterBase
	on __eval(dt, lang, lib)
		set mins to text -2 thru -1 of ((((time to GMT) div 60) mod 60 + 100) as string)
		set hrs to (time to GMT) div 3600
		if hrs < -9 then
			return (hrs as string) & mins
		else if hrs < 0 then
			return "-0" & ((hrs as string)'s last character) & mins
		else if hrs > 9 then
			return "+" & hrs & mins
		else
			return "+0" & hrs & mins
		end if
	end __eval
end script

script _formatters
	property lst : {�
		d, dd, ddd, dddd, m, mm, mmm, mmmm, y, yy, missing value, yyyy, �
		h, hh, missing value, missing value, |H|, |HH|, missing value, missing value, �
		|M|, |MM|, missing value, missing value, |S|, |SS|, missing value, missing value, �
		t, tt, missing value, missing value, |T|, |TT|, missing value, missing value, �
		z, missing value, missing value, missing value} --use missing value for unsupported codes
end script

--

on _makeStartNode(lang, formatString, nextNode, DateRef) -- first node = start of formatString
	-- note: formatDate's results will be strings only when original format string is a string
	-- and language is English (all non-English languages use Unicode text)
	if formatString's class is Unicode text then
		set emptyString to "" as Unicode text
	else
		set emptyString to lang's ntxt
	end if
	script
		property class : "DateFormatter"
		property _next : nextNode
		property _lang : lang
		property _formatString : formatString
		property _interTxt : emptyString
		property _DateRef : DateRef -- a ref to Date library
		--
		on formatDate(theDate)
			try
				return _next's eval(theDate, _lang, _interTxt, _DateRef)
			on error eMsg number eNum
				error "Can't formatDate: " & eMsg number eNum
			end try
		end formatDate
		--
		on currentDate()
			return _next's eval(current date, _lang, _interTxt, _DateRef)
		end currentDate
		--
		on getProperties()
			return {class:my class, formatString:_formatString, languageName:_lang's name}
		end getProperties
	end script
end _makeStartNode

on _makeNode(idx, interTxt, nextNode)
	copy _formatters's lst's item idx to node
	if node is missing value then error "invalid format."
	set node's _interTxt to interTxt
	set node's _next to nextNode
	return node
end _makeNode

on _makeEndNode(interTxt) -- last node = end of formatString
	script
		property _interTxt : interTxt
		--
		on eval(dt, lang, res, lib)
			return res & _interTxt
		end eval
	end script
end _makeEndNode

----------------------------------------------------------------------
-- PUBLIC

on makeFormatter(parsedFormat, formatString, lang, DateRef)
	set node to _makeEndNode(parsedFormat's last item)
	repeat with i from ((count of parsedFormat) - 1) to 2 by -2
		set node to _makeNode(parsedFormat's item i, lang's ntxt & parsedFormat's item (i - 1), node)
	end repeat
	return _makeStartNode(lang, formatString, node, DateRef)
end makeFormatter


--(*-- TEST
script lang
	property ntxt : "" -- as Unicode text
end script
makeFormatter({"", 1, "B", 12, "~", 14, "D", 21, ""}, "dByyyy~hhDM", lang, missing value)'s formatDate(current date) --'s class
--*)