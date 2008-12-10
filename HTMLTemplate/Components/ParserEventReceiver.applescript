property __name__ : "ParserEventReceiver"
property __version__ : ""
property __lv__ : 1

(* creates Receiver object for feeding to HTMLParser *)

----------------------------------------------------------------------
--Dependencies

property _Types : missing value
property _TemplateAssembler : missing value
property _ElementCollector : missing value

on __load__(loader)
	set _Types to loader's loadLib("Types")
	set _TemplateAssembler to loader's loadComponent("TemplateAssembler")
	set _ElementCollector to loader's loadComponent("ElementCollector")
end __load__

----------------------------------------------------------------------
--mark -
--mark Properties<B<U

--constants
property _validSpecifiers : {"con", "rep", "sep", "del"} -- used by _readTagAttributes
property _templateObjectName : "tem_template"
property _invalidObjectNames : {"template"} -- "template" is reserved for "tem_template" object; allows correct closure to be checked

--state
property _specialAttribute : missing value -- used by _readTagAttributes
property _removeSpecialAtt : missing value -- used by _readTagAttributes
property _libVersion : missing value
property _nullTxt : missing value
property _outputStack : missing value

--mark -
----------------------------------------------------------------------
--mark commands<B<U

on ___init(specialAttribute, removeSpecialAtt, libVersion, nullTxt)
	set _specialAttribute to specialAttribute
	set _removeSpecialAtt to removeSpecialAtt
	set _libVersion to libVersion
	set _nullTxt to nullTxt
	--
	set _outputStack to _Types's makeStack()
	_outputStack's push(_ElementCollector's makeElementCollector(_templateObjectName, _nullTxt, {}, _nullTxt, false, false, _nullTxt))
	return me
end ___init

on _readTagAttributes(attsList)
	set attsStr to _nullTxt
	set isSpecial to false
	considering case, diacriticals, expansion, punctuation, hyphens and white space
		repeat with attRef in attsList
			set {attName, attVal} to attRef
			set attsStr to attsStr & space & attName & "=\"" & attVal & "\""
			set attRef's contents to {_nullTxt & space & attName & "=\"", attVal, "\""}
			if attName is _specialAttribute and attVal's length > 3 and {attVal's text 1 thru 3} is in _validSpecifiers then
				if attVal begins with "del_" then return {true, "del__", {}}
				set isSpecial to true
				if _removeSpecialAtt then set attRef's contents to missing value
				set specifier to attVal
			end if
		end repeat
	end considering
	if isSpecial then
		return {true, specifier, attsList's lists}
	else
		return {false, missing value, attsStr}
	end if
end _readTagAttributes

--mark -
----------------------------------------------------------------------
--mark add to element stack<B<U

on _addOpenTag(tagName, attsList, isEmptyElement)
	if isEmptyElement then
		set endOfOpenTag to " /"
	else
		set endOfOpenTag to ""
	end if
	set thisNode to _outputStack's top()
	if thisNode's deleteThis then
		set {isSpecial, atts} to {false, ""} -- ignore special tags within deleted elements (faster)
	else
		set {isSpecial, specifier, atts} to _readTagAttributes(attsList)
	end if
	if isSpecial then
		if {specifier's text 5 thru -1} is in _invalidObjectNames then error "Invalid object name: " & specifier's text 5 thru -1
		set toDelete to ((specifier's text 1 thru 3 is "del") or ({specifier} is in thisNode's elementNames))
		_outputStack's push(_ElementCollector's makeElementCollector(specifier, tagName, atts, endOfOpenTag, isEmptyElement, toDelete, _nullTxt))
	else
		if thisNode's tName is tagName then thisNode's incDepth()
		thisNode's addItem(_nullTxt & "<" & tagName & atts & endOfOpenTag & ">")
	end if
	return
end _addOpenTag

on _addCloseTag(tagName, isEmptyElement)
	log "close " & tagName
	set thisNode to _outputStack's top()
	if thisNode's tName is tagName then thisNode's decDepth()
	if thisNode's isEndOfElement() then
		set thisNode to _outputStack's pop()
		if not thisNode's deleteThis then
			set parentNode to _outputStack's top()
			_TemplateAssembler's completingElement(thisNode, parentNode)
		end if
	else if not isEmptyElement then
		thisNode's addItem(_nullTxt & "</" & tagName & ">")
	end if
	return
end _addCloseTag

on _addContent(txt)
	_outputStack's top()'s addItem(txt)
	return
end _addContent

--mark -
-------
--mark HTMLParser event handlers<B<U

on handlePI(txt)
	_addContent(_nullTxt & "<?" & txt & "?>")
end handlePI

on handleDecl(txt)
	_addContent(_nullTxt & "<!" & txt & ">")
end handleDecl

on handleComment(txt)
	_addContent(_nullTxt & "<!--" & txt & "-->")
end handleComment

--

on handleStartEndTag(tagName, attributesList)
	_addOpenTag(tagName, attributesList, true)
	_addCloseTag(tagName, true)
end handleStartEndTag

on handleStartTag(tagName, attributesList)
	_addOpenTag(tagName, attributesList, false)
end handleStartTag

on handleEndTag(tagName)
	_addCloseTag(tagName, false)
end handleEndTag

on handleData(txt)
	_addContent(txt)
end handleData

on handleCharRef(txt)
	_addContent(_nullTxt & "&" & txt & ";")
end handleCharRef

on handleEntityRef(txt)
	_addContent(_nullTxt & "&#" & txt & ";")
end handleEntityRef

--mark -
----------------------------------------------------------------------
--mark main<B<U

on finishedTemplate() -- get compiled Template object once HTMLParser is done
	set thisNode to _outputStack's pop()
	return _TemplateAssembler's finishingTemplate(thisNode, _templateObjectName, _libVersion, _nullTxt)
end finishedTemplate

on makeReceiver(specialAttribute, removeSpecialAtt, libVersion, nullTxt)
	copy me to meCopy
	return meCopy's ___init(specialAttribute, removeSpecialAtt, libVersion, nullTxt)
end makeReceiver
