property __name__ : "MainReceiver"
property __version__ : ""
property __lv__ : 1

(*
Receives everything between <plist> and </plist> tags; dumps (XML) elements into objects.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _CollectorConstructors : missing value
property _NodeConstructors : missing value
property _Types : missing value

on __load__(loader)
	set _CollectorConstructors to loader's loadComponent("CollectorConstructors")
	set _NodeConstructors to loader's loadComponent("NodeConstructors")
	set _Types to loader's loadLib("Types")
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

property _nodeStack : missing value

--

on _startTag(tagTxt)
	if tagTxt is "dict" then
		_nodeStack's push(_CollectorConstructors's makeDictCollector())
	else if tagTxt is "array" then
		_nodeStack's push(_CollectorConstructors's makeArrayCollector())
	else
		_nodeStack's push(_CollectorConstructors's makePrimitiveCollector(tagTxt))
	end if
end _startTag

on _endTag(tagTxt)
	set collectorObj to _nodeStack's pop()
	if collectorObj's class is not tagTxt then -- token test for correctness
		error "Non-matching close tag (was \"" & tagTxt & "\" instead of \"" & collectorObj's class & "\")."
	end if
	if collectorObj's class is "key" then
		_nodeStack's top()'s addKey(collectorObj's val())
	else
		_nodeStack's top()'s addNode(collectorObj's finishedNode())
	end if
end _endTag

-------
--mark -
--mark PUBLIC<B<U
--mark parsing event handlers<U

on processTag(txt)
	considering case, diacriticals, expansion, hyphens, punctuation and white space
		if txt's first character is "/" then -- close tag
			_endTag(text 2 thru -1 of txt)
		else if txt's last character is "/" then -- empty element
			_startTag(text 1 thru -2 of txt)
			_nodeStack's top()'s addVal("")
			_endTag(text 1 thru -2 of txt)
		else -- open tag
			_startTag(txt)
		end if
	end considering
	return _nodeStack's top()'s isPList -- true when end of topmost <dict> element within <plist> element is reached
end processTag

on processContent(txt)
	_nodeStack's top()'s addVal(txt)
end processContent

on val()
	return _nodeStack's pop()'s val()
end val

--mark -
--mark constructor<U

on makeReceiver()
	copy me to meCpy
	set nodeStack to _Types's makeStack()
	nodeStack's push(_CollectorConstructors's makePListCollector())
	set meCpy's _nodeStack to nodeStack
	return meCpy
end makeReceiver