property __name__ : "TemplateConstructors"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
--Dependencies

property _String : missing value
property _compiler : missing value

on __load__(loader)
	set _compiler to loader's loadComponent("Compiler")
	set _String to loader's loadLib("String")
end __load__

----------------------------------------------------------------------

(*
	makeContainer(objectName, tagName, attributesList, endOfOpenTag, elementIsEmpty,contentList, nullTxt)
	makeRepeater(objectName, tagName, attributesList, endOfOpenTag, elementIsEmpty,contentList, defaultSeparator, nullTxt)
	makeTemplate(objectName, contentList, libVersion, nullTxt)
	
		objectName : string -- e.g. "con_foobar"
		tagName : string/Unicode text -- e.g. "h1"
		endOfOpenTag : string/Unicode text -- e.g. " /"
		attributesList : list -- list of form: {{" name=\"", "value", "\""}, {" name=\"", "value", "\""}, ...}
		contentList : list -- list of form: {text, obj, text, obj, ..., text}		
		defaultSeparator : string/Unicode text -- e.g. "<br />"
	
		libVersion : string -- version of HTMLTemplate library used to compile this template
		nullTxt : string/Unicode text -- a zero-length string/Unicode text; used for (ick) list-to-text conversion
		
		Result : script -- container/repeater/template object
		
	Note: inheritance tree shown in manual is simplified for end user
*)

--mark -
--mark TAG AND CONTENT OBJECTS<B<U

on _makeTag(tagName, attributesList, endOfOpenTag, elementIsEmpty, nullTxt)
	if elementIsEmpty then
		set endOfOpenTag to endOfOpenTag & "/"
		set closeTag to nullTxt
	else
		set closeTag to nullTxt & "</" & tagName & ">"
	end if
	--
	script
		property _nullTxt : nullTxt
		property _startOfOpenTag : nullTxt & "<" & tagName
		property _endOfOpenTag : endOfOpenTag & ">"
		property _closeTag : closeTag
		property _atts : attributesList -- {{" id=\"", "val", "\""}, {" class=\"", "val", "\""}}
		-------
		on ___renderElement(tagContent)
			return {_startOfOpenTag} & _atts & {_endOfOpenTag} & tagContent & {_closeTag}
		end ___renderElement
		-------
		-- pretend to be a TagAttribute object when user gets/sets attributes
		property _idx : missing value
		property class : "TagAttribute"
		--
		on ___getAttribute(idx)
			set _idx to idx
			return me
		end ___getAttribute
		-- 
		on setContent(val)
			try
				set _atts's item _idx's second item to (_nullTxt & val) -- blam blam blam
				return
			on error eMsg number eNum -- ignore error raised if attribute's dontRender() method has been called previously
				if _atts's item _idx is _nullTxt then return
				error eMsg number eNum
			end try
		end setContent
		--
		on getContent()
			try
				return _atts's item _idx's second item
			on error eMsg number eNum -- ignore error raised if attribute's dontRender() method has been called previously
				if _atts's item _idx is _nullTxt then return _nullTxt
				error eMsg number eNum
			end try
		end getContent
		--
		on dontRender()
			set _atts's item _idx to _nullTxt
			return
		end dontRender
	end script
end _makeTag

--

on _makeContent(contentList, nullTxt) -- used by all; called by makeNodeBase()
	if (count of contentList) is 1 then -- node has plain content
		script
			property _content : contentList's first item
			on setContent(val)
				set _content to val
				return
			end setContent
			on getContent()
				return _content
			end getContent
			on renderContent()
				return _content
			end renderContent
		end script
	else -- node has elements/node has no content
		script
			property _content : (contentList & {nullTxt})'s first item
			on setContent(val)
				error "Can't setContent (access not allowed)." number -1708
			end setContent
			on getContent()
				error "Can't getContent (access not allowed)." number -1708
			end getContent
			on renderContent()
				return _content
			end renderContent
		end script
	end if
end _makeContent

--mark -
----------------------------------------------------------------------
----------------------------------------------------------------------
--mark BASE OBJECTS<B<U

on _makeNodeBase(objectName, tagObj, contentList, attributeNames, elementNames, nullTxt) -- called by _makeNodeElements()
	script
		property name : objectName -- e.g. "con_fubar"
		--
		property _content : _makeContent(contentList, nullTxt)
		property _tag : tagObj
		property _renderMe : true
		property _ctrlScript : missing value
		property _nullTxt : nullTxt
		property _attributeNames : attributeNames
		property _elementNames : elementNames
		-------
		script _TagStub
			property _nullTxt : nullTxt
			property class : "TagAttribute"
			on ___renderElement(tagContent)
				return tagContent
			end ___renderElement
			on ___getAttribute(idx)
				return me
			end ___getAttribute
			on setContent(val)
			end setContent
			on getContent()
				return _nullTxt
			end getContent
			on dontRender()
			end dontRender
		end script
		-------
		on ___setCtrlScript(ctrlScriptRef) -- called during setControllerScript()
			set _ctrlScript to ctrlScriptRef
		end ___setCtrlScript
		-------
		on __ctrlScript()
			return _ctrlScript
		end __ctrlScript
		--
		on __content()
			return _content
		end __content
		--
		on __tag()
			return _tag
		end __tag
		--
		on __renderMe()
			return _renderMe
		end __renderMe
		-------
		on setContent(val)
			_content's setContent(_nullTxt & val) -- ick-ptui
		end setContent
		--
		on getContent()
			_content's getContent()
		end getContent
		--
		on omitTags()
			set _tag to _TagStub
			return
		end omitTags
		--
		on dontRender()
			set _renderMe to false
			return
		end dontRender
		--
		on attributeNames()
			return _attributeNames's items
		end attributeNames
		--
		on attributeExists(nameTxt)
			return _attributeNames contains {nameTxt}
		end attributeExists
		--
		on elementNames()
			return _elementNames's items
		end elementNames
		--
		on elementExists(nameTxt)
			return _elementNames contains {nameTxt}
		end elementExists
		-------
		on asText()
			try
				set oldTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to _nullTxt
				set renderedText to _nullTxt & ___render() -- wham wham wham
				set AppleScript's text item delimiters to oldTID
			on error eMsg number eNum
				error "Couldn't renderElement: " & eMsg number eNum
			end try
			return renderedText
		end asText
	end script
end _makeNodeBase

--mark -
--mark CUSTOM ELEMENT OBJECTS<B<U
(*
	AS-based hashing/associative rountines are slow, so each template object has its
	elements baked directly into its structure for better rendering performance.
*)

on _hasInvalidChars(str)
	set res to ""
	considering case, diacriticals, expansion, hyphens, punctuation and white space
		repeat with charRef in str
			if charRef's contents is not in "eErRiIoOaAtTnNsSdDlLcCpPmMhHbBfFuUyYgGwWvVkKxXjJqQzZ_0123456789" then return true
		end repeat
	end considering
	return false
end _hasInvalidChars

on _customAttributes(attributesList)
	set attributeAccessors to ""
	set attributeNames to {}
	repeat with idx from 1 to count of attributesList
		set attName to attributesList's item idx's first item's text 2 thru -3
		if _hasInvalidChars(attName) then
			set accessorName to "|att_" & _String's replaceText(_String's replaceText(attName, "\\", "\\\\"), "|", "\\|") & "|"
		else
			set accessorName to "att_" & attName
		end if
		set attributeAccessors to attributeAccessors & "
 on " & accessorName & "()
return __tag()'s ___getAttribute(" & idx & ")
end"
		set attributeNames's end to accessorName
	end repeat
	return {attributeAccessors, attributeNames}
end _customAttributes

on _customContent(contentList)
	set contentAccessors to ""
	set renderItems to "  "
	set traverseElements to ""
	set elementNames to {}
	repeat with idx from 2 to count of contentList by 2
		set objectName to contentList's item idx's name
		set contentAccessors to contentAccessors & "
property _" & objectName & " : contentList's item " & idx & "
 on " & objectName & "()
return _" & objectName & "
end
 on set_" & objectName & "(obj)
if {obj's class} isn't in {\"Container\", \"Repeater\"} then error \"Can't set_" & objectName & ": not a Container/Repeater object.\" number -1704
set _" & objectName & " to obj
return
end
property _htm" & (idx + 1) & " : contentList's item " & (idx + 1)
		set renderItems to renderItems & "_" & objectName & "'s ___render(), _htm" & (idx + 1) & ","
		set traverseElements to traverseElements & "
_" & objectName & "'s ___traverse(obj)"
		set elementNames's end to objectName as string
	end repeat
	return {contentAccessors, renderItems's text 1 thru -2, traverseElements, elementNames}
end _customContent

--

on _makeNodeElements(tagObj, objectName, attributesList, contentList, nullTxt)
	set {attributeAccessors, attributeNames} to _customAttributes(attributesList)
	set {contentAccessors, renderItems, traverseElements, elementNames} to _customContent(contentList)
	set constructorCode to "on makeObject(baseObj, contentList)
script
property parent : baseObj
-------
--attribute accessors" & attributeAccessors & "
-------
--element accessors" & contentAccessors & "
-------
 on ___traverse(obj) -- traverse object tree
obj's startNode(__getSelf())" & traverseElements & "
obj's endNode(__getSelf())
end ___traverse
--
 on __renderElements()
return {" & renderItems & "}
end __renderElements
--
 on ___callCtrlScript(val, params) -- (used by rep and tem)
try
__ctrlScript()'s render_" & (objectName's text 5 thru -1) & "(__getSelf(), val, params)
on error eMsg number eNum
error \"An error occurred while calling controllerScript's render_" & (objectName's text 5 thru -1) & " handler: \" & eMsg number eNum
end try
return
end ___callCtrlScript
end script
end makeObject"
	set baseObj to _makeNodeBase(objectName, tagObj, contentList, attributeNames, elementNames, nullTxt)
	return makeObject(baseObj, contentList) of _compiler's compileScript(constructorCode)
end _makeNodeElements

----------------------------------------------------------------------
--mark -
--mark PUBLIC CONSTRUCTORS<B<U

on makeContainer(objectName, tagName, attributesList, endOfOpenTag, elementIsEmpty, contentList, nullTxt)
	set tagObj to _makeTag(tagName, attributesList, endOfOpenTag, elementIsEmpty, nullTxt)
	script
		property class : "Container"
		property parent : _makeNodeElements(tagObj, objectName, attributesList, contentList, nullTxt)
		property _nullTxt : nullTxt
		-------
		on __getSelf()
			return me
		end __getSelf
		--
		on ___render()
			if __renderMe() then
				return __tag()'s ___renderElement({__content()'s renderContent(), __renderElements()})
			else
				return _nullTxt
			end if
		end ___render
	end script
end makeContainer

--

on makeRepeater(objectName, tagName, attributesList, endOfOpenTag, elementIsEmpty, contentList, defaultSeparator, nullTxt)
	set tagObj to _makeTag(tagName, attributesList, endOfOpenTag, elementIsEmpty, nullTxt)
	script
		property class : "Repeater"
		property parent : _makeNodeElements(tagObj, objectName, attributesList, contentList, nullTxt)
		property _nullTxt : nullTxt
		-------
		property ___sep : nullTxt & defaultSeparator -- may be changed by template assembler
		property _renderedContent : {} -- first item is extra separator string
		-------
		on __getSelf()
			return me
		end __getSelf
		--
		on ___render() -- return all instances of this rep
			if _renderedContent is {} then
				return _nullTxt
			else
				return rest of _renderedContent
			end if
		end ___render
		--
		on ___renderInstance(val, params, collectorObj) -- render single instance of tem/rep object
			___callCtrlScript(val, params)
			if __renderMe() then
				set collectorObj's lst's end to ___sep
				set collectorObj's lst's end to __tag()'s ___renderElement({__content()'s renderContent(), __renderElements()})
			end if
			return
		end ___renderInstance
		-------
		on repeatWith(lst, params)
			script kludge
				property l : lst
			end script
			script collectorObj
				property lst : _renderedContent
			end script
			copy me to b
			repeat with valRef in kludge's l
				(*
					1.	Repeater clones self, then calls clone's ___renderInstance() method, 
						passing val, params and its _renderedContent list (collectorObj).
					2.	The clone calls its ctrl_script's render_foo() method, passing 
						itself, val and params to relevant event handler in user's controllerScript.
					3.	Clone appends rendered item (if any) to collectorObj.
				*)
				copy b to repCpy
				repCpy's ___renderInstance(valRef's contents, params, collectorObj)
			end repeat
			set _renderedContent to collectorObj's lst
			return
		end repeatWith
		--
		on iterateWith(Iterator, params)
			script collectorObj
				property lst : _renderedContent
			end script
			copy me to b
			Iterator's gotoFirst()
			repeat until Iterator's isDone()
				copy b to repCpy
				repCpy's ___renderInstance(Iterator's currentItem(), params, collectorObj)
				Iterator's gotoNext()
			end repeat
			set _renderedContent to collectorObj's lst
			return
		end iterateWith
	end script
end makeRepeater

--

on makeTemplate(objectName, contentList, libVersion, nullTxt)
	script
		(* Template object; generated by HTMLTemplate library. Do not edit. *)
		-------
		-- Loader compatibility
		property __name__ : ""
		property __version__ : ""
		property __lv__ : 1
		--
		property ___controllerName : ""
		property ___autoLoad : false
		--
		on __load__(loader)
			if ___autoLoad then installController(loader's loadComponent(___controllerName))
		end __load__
		-------
		property class : "Template"
		property parent : _makeNodeElements(missing value, objectName, {}, contentList, nullTxt)
		--
		property ___userInfo : {}
		property _libVersion : libVersion
		property _nullTxt : nullTxt -- used to concatenate list to string/Unicode text 
		-- (note: 'lst as Unicode text' appears to be buggy in some or all versions of AS)
		-------
		on __getSelf()
			return me
		end __getSelf
		--
		on ___render()
			if __renderMe() then
				return {__content()'s renderContent(), __renderElements()}
			else
				return _nullTxt
			end if
		end ___render
		-------
		on userInfo()
			return ___userInfo
		end userInfo
		--
		on libVersion()
			return _libVersion
		end libVersion
		-------
		on installController(ctrlScript)
			script controllerInstaller -- visitor object
				property _controllerScript : ctrlScript
				--
				on startNode(xo)
					xo's ___setCtrlScript(a reference to _controllerScript)
				end startNode
				--
				on endNode(xo)
				end endNode
			end script
			___traverse(controllerInstaller)
			return
		end installController
		-------
		on renderTemplate(params)
			try
				copy me to templateCopy
				templateCopy's ___callCtrlScript(params, missing value)
				set oldTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to _nullTxt
				set txt to _nullTxt & templateCopy's ___render() -- thuggish concatenation
				set AppleScript's text item delimiters to oldTID
				return txt
			on error eMsg number eNum
				error "Couldn't renderTemplate: " & eMsg number eNum
			end try
		end renderTemplate
	end script
end makeTemplate
