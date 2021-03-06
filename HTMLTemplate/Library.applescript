property __name__ : "HTMLTemplate"
property __version__ : "0.8.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _HTMLParser : missing value
property _ParserEventReceiver : missing value
--
on __load__(loader)
	tell loader
		set _HTMLParser to loadLib("HTMLParser")
		set _ParserEventReceiver to loadComponent("ParserEventReceiver")
	end tell
end __load__

----------------------------------------------------------------------
-- PRIVATE

on _checkTxt(val, paramName)
	if val's class is not in {string, Unicode text} then
		error paramName & " isn't a string or Unicode text." number -1704
	end if
end _checkTxt

----------------------------------------------------------------------
-- PUBLIC

on makeTemplate(sourceText, specialAttribute, removeSpecialAtt)
	try
		_checkTxt(sourceText, "sourceText")
		_checkTxt(specialAttribute, "specialAttribute")
		if sourceText's class is string then
			set nullTxt to ""
		else
			set nullTxt to "" as Unicode text
		end if
		set theReceiver to _ParserEventReceiver's makeReceiver(specialAttribute, removeSpecialAtt, __version__, nullTxt)
		_HTMLParser's parseHTML(sourceText, theReceiver)
		return theReceiver's finishedTemplate()
	on error eMsg number eNum
		error "Can't makeTemplate: " & eMsg number eNum
	end try
end makeTemplate

-- configure a template object

on setLoaderInfo(templateObj, nameStr, versionStr)
	set templateObj's __name__ to nameStr as string
	set templateObj's __version__ to versionStr as string
	return
end setLoaderInfo

on setControllerInfo(templateObj, controllerName)
	set templateObj's ___controllerName to controllerName as string
	set templateObj's ___autoLoad to true
	return
end setControllerInfo

on setUserInfo(templateObj, infoRec)
	set templateObj's ___userInfo to infoRec as record
	return
end setUserInfo

-- view object model

on viewStructure(templateObj)
	script infoCollector -- visitor object
		property _indent : tab
		property ___str : ""
		--
		on startNode(xo)
			set ___str to ___str & text 2 thru -1 of (_indent & xo's name)
			set attNames to xo's attributeNames()
			if attNames is not {} then
				set ___str to ___str & " [" & attNames's first item
				repeat with attName in rest of attNames
					set ___str to ___str & ", " & attName
				end repeat
				set ___str to ___str & "]"
			end if
			set ___str to ___str & return
			set _indent to _indent & tab
		end startNode
		--
		on endNode(xo)
			set _indent to _indent's text 1 thru -2
		end endNode
	end script
	templateObj's ___traverse(infoCollector)
	return infoCollector's ___str's text 1 thru -2
end viewStructure