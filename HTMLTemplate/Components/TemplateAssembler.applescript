property __name__ : "TemplateAssembler"
property __version__ : ""
property __lv__ : 1

(*
used by ParserEventReceiver
converts generic element object into specific container/repeater/separator object and adds it to its container element
returns finished template object for top-level generic element
*)

----------------------------------------------------------------------
--Dependencies

property _TemplateConstructors : missing value

on __load__(loader)
	tell loader
		set _TemplateConstructors to loadComponent("TemplateConstructors")
	end tell
end __load__

----------------------------------------------------------------------
--mark PRIVATE<B<U

property _defaultSeparator : return

on _matchSeparatorToRepeater(emt, emtList)
	if (count of emt's eCont) is not 1 then error "separator " & emt's oName & " contained other elements." number 300
	-- insert separator string into repeater object of same name
	set repName to "rep_" & (emt's oName's text 5 thru -1)
	repeat with obj in emtList
		if obj's class is "Repeater" and obj's name is repName then
			set obj's ___sep to emt's eCont's first item
			return -- returns early if done...
		end if
	end repeat
	--...else falls through loop if no repeater of same name is found
	error "no repeater object was found for " & emt's oName & "." number 300
end _matchSeparatorToRepeater

-------
--mark PUBLIC<B<U
--mark event handlers<B<U

on completingElement(emt, emtCtr) -- {element, element's container element}
	try
		set objClass to emt's oName's text 1 thru 3
		if objClass is "con" then
			emtCtr's addItem(_TemplateConstructors's makeContainer(emt's oName, emt's tName, emt's tAtts, emt's tEnd, emt's tEmpty, emt's eCont, emt's ntxt))
		else if objClass is "rep" then
			emtCtr's addItem(_TemplateConstructors's makeRepeater(emt's oName, emt's tName, emt's tAtts, emt's tEnd, emt's tEmpty, emt's eCont, _defaultSeparator, emt's ntxt))
		else if objClass is "sep" then
			_matchSeparatorToRepeater(emt, emtCtr's eCont)
		else if objClass is not "del" then -- (del=delete=throw away finished element)
			error "unknown template class: " & objClass
		end if
		return
	on error eMsg number eNum
		error "TemplateAssembler error: Can't complete element: " & eMsg number eNum
	end try
end completingElement

on finishingTemplate(emt, templateObjName, XTVersion) --> finished Template object
	try
		if emt's oName is not templateObjName then
			error "one or more template elements were not closed correctly." number 200
		end if
		return _TemplateConstructors's makeTemplate(emt's oName, emt's eCont, XTVersion, emt's ntxt)
	on error eMsg number eNum
		error "TemplateAssembler error: Can't finish assembling Template: " & eMsg number eNum
	end try
end finishingTemplate