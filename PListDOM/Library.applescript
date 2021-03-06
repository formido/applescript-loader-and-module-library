property __name__ : "PListDOM"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _SimpleTagParser : missing value
property _MainReceiver : missing value
property _EndReceivers : missing value

on __load__(loader)
	tell loader
		set _SimpleTagParser to loadComponent("SimpleTagParser")
		set _MainReceiver to loadComponent("MainReceiver")
		set _EndReceivers to loadComponent("EndReceivers")
	end tell
end __load__

----------------------------------------------------------------------
-- PRIVATE

on _makeParserReceiver()
	script
		property _current : _EndReceivers's makeHeader()
		property _todo : {_MainReceiver's makeReceiver(), _EndReceivers's makeFooter()}
		property _completed : {}
		-------
		on processTag(txt)
			_current's processTag(txt) returning isDone
			if isDone then
				set end of _completed to _current
				set _current to first item of _todo
				set _todo to rest of _todo
			end if
		end processTag
		--
		on processContent(txt)
			_current's processContent(txt)
		end processContent
		--
		on getResult()
			set headerTxt to _completed's first item's val()
			set bodyObj to _completed's second item's val()
			set footerTxt to _current's val()
			return {headerTxt, bodyObj, footerTxt}
		end getResult
	end script
end _makeParserReceiver

--

on _makePListCollector()
	script
		property _indent : "" as Unicode text
		script _k
			property l : {}
		end script
		property _newline : ASCII character 10
		--
		on addEmptyColl(typ)
			set _k's l's end to _indent & "<" & typ & "/>"
		end addEmptyColl
		--
		on startColl(typ)
			set _k's l's end to _indent & "<" & typ & ">"
			set _indent to _indent & tab
		end startColl
		--
		on endColl(typ)
			try
				set _indent to _indent's text 1 thru -2
			on error number -1728
				set _indent to "" as Unicode text
			end try
			set _k's l's end to _indent & "</" & typ & ">"
		end endColl
		--
		on addKey(txt)
			set _k's l's end to _indent & "<key>" & txt & "</key>"
		end addKey
		--
		on addEmptyVal(typ)
			set _k's l's end to _indent & "<" & typ & "/>"
		end addEmptyVal
		--
		on addVal(typ, txt)
			set _k's l's end to _indent & "<" & typ & ">" & txt & "</" & typ & ">"
		end addVal
		--
		on addTxt(txt)
			set _k's l's end to txt
		end addTxt
		--
		on getResult()
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to _newline
			set txt to _k's l as Unicode text
			set AppleScript's text item delimiters to oldTID
			return txt
		end getResult
	end script
end _makePListCollector

--

on _makeRecordCollector()
	script
		property _indent : "" as Unicode text
		script _k
			property l : {{class:"plist", contents:{}}}
		end script
		property _newline : ASCII character 10
		--
		on addEmptyColl(typ)
			set _k's l's first item's contents's end to {class:typ, contents:{}}
		end addEmptyColl
		--
		on startColl(typ)
			set beginning of _k's l to {class:typ, contents:{}}
		end startColl
		--
		on endColl(typ)
			set coll to first item of _k's l
			set _k's l to rest of _k's l
			set _k's l's first item's contents's end to coll
		end endColl
		--
		on addKey(txt)
			set _k's l's first item's contents's end to txt
		end addKey
		--
		on addEmptyVal(typ)
			set _k's l's first item's contents's end to {class:typ, contents:{}}
		end addEmptyVal
		--
		on addVal(typ, txt)
			set _k's l's first item's contents's end to {class:typ, contents:txt}
		end addVal
		--
		on addTxt(txt)
		end addTxt
		--
		on getResult()
			return _k's l's first item's contents's first item
		end getResult
	end script
end _makeRecordCollector

--

on _makeDOM(header, dom, footer)
	script
		property parent : dom
		property class : "plist"
		property _header : header
		property _footer : footer
		-------
		on ___collect(obj)
			obj's addTxt(_header)
			continue ___collect(obj)
			obj's addTxt(_footer)
		end ___collect
	end script
end _makeDOM

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on parsePList(txt)
	set receiver to _makeParserReceiver()
	_SimpleTagParser's parseTags(txt, receiver)
	set {header, dom, footer} to receiver's getResult()
	return _makeDOM(header, dom, footer)
end parsePList

on generatePList(obj)
	if obj's class is not "plist" then error "Not a plist object." number -1704
	set collector to _makePListCollector()
	obj's ___collect(collector)
	return collector's getResult()
end generatePList

on generateRecord(obj) -- diagnostic
	if obj's class is not "plist" then error "Not a plist object." number -1704
	set collector to _makeRecordCollector()
	obj's ___collect(collector)
	return collector's getResult()
end generateRecord