property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Log : missing value
property _StringIO : missing value
property _HTMLParser : missing value

on __load__(loader)
	set _Log to loader's loadLib("Log")
	set _StringIO to loader's loadLib("StringIO")
	set _HTMLParser to loader's loadLib("HTMLParser")
end __load__

----------------------------------------------------------------------
-- TEST

on makeTestRec(logObj)
	script
		property class : "EventReceiver"
		property _logObj : logObj
		on _Log(lst)
			set text item delimiters to " /// "
			_logObj's logMsg(lst as string)
		end _Log
		-------
		on handleStartEndTag(tagName, attributesList)
			_Log({"STARTEND", tagName, attributesList})
		end handleStartEndTag
		--
		on handleStartTag(tagName, attributesList)
			_Log({"START", tagName, attributesList})
		end handleStartTag
		--
		on handleEndTag(tagName)
			_Log({"END", tagName})
		end handleEndTag
		--
		on handleData(txt)
			_Log({"DATA", txt})
		end handleData
		--
		on handleCharRef(txt)
			_Log({"CHAR", txt})
		end handleCharRef
		--
		on handleEntityRef(txt)
			_Log({"ENT", txt})
		end handleEntityRef
		--
		on handlePI(txt)
			_Log({"PI", txt})
		end handlePI
		--
		on handleDecl(txt)
			_Log({"DECL", txt})
		end handleDecl
		--
		on handleComment(txt)
			_Log({"COMMENT", txt})
		end handleComment
	end script
end makeTestRec



property txt : "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"><head>

<title pxt=\"con_title\">calendar template</title>

<style type=\"text/css\" media=\"all\"><!--
body {padding:0; margin:0;}
h1, .footer {text-align:center; color:#bdb; background-color:#252; padding:4px;}
.calendar {font-weight:bold; color:black; background-color:#484; padding:0px; margin-bottom:12px;}
.calendar caption {font-size:small; font-weight:bold; text-align:center; color:#bdb; background-color:#252; padding:4px;}
.calendar th {text-align:center; color:white; background-color:#252; padding:2px;}
.calendar td {text-align:right; padding:2px;}
.calendar .wkday {color:black; background-color:#bdb;}
.calendar .wkend {color:black; background-color:#9c9;}
--></style>
</head><body>

<h1 pxt=\"con_heading\">2002</h1>

<!-- begin twelve-month table -->
<table class=\"yeartable\" summary=\"Year calendar from January to December.\" width=\"100%\">
<tr pxt=\"rep_row\">
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
</tr>
<tr pxt=\"rep_row\">
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
</tr>
<tr pxt=\"rep_row\">
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
<td pxt=\"rep_col\" align=\"center\">MONTH</td>
</tr>
</table>
<!-- end twelve-month table -->

<div class=\"footer\"><small>Made with XTemplate</small></div>

</body></html>"

on makeRec(logObj)
end makeRec

__load__(_Loader's makeLoader())

set txt to _StringIO's readFile(alias "/Library/Scripts/ASLibraries/XTemplate/Examples/MakeHTMLCalendar/SourceHTML/YearCalendar.html")

--set txt to _StringIO's readFile(alias "Macintosh HD:Users:has:2003.htm")

-- test output
set logObj to _Log's makeLog("Macintosh HD:users:has:HTMLParserLog1" as file specification)
logObj's openLog()
logObj's clearLog()
_HTMLParser's parseHTML(txt, makeTestRec(logObj))
logObj's closeLog()


-- test speed
set receiver to _HTMLParser's makeEventReceiver()
set rpt to 1
set tm to GetMilliSec
repeat rpt times
	_HTMLParser's parseHTML(txt, receiver)
end repeat
set t1 to ((GetMilliSec) - tm) as integer
set tm to GetMilliSec
repeat rpt times
	_HTMLParser's parseHTML(txt as Unicode text, receiver)
	--parse XML txt with preserving whitespace and including comments
end repeat
set t2 to ((GetMilliSec) - tm) as integer

{t1, t2}
