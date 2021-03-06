property __name__ : "EventReceivers"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value
property _FormatStringParser : missing value
property _FormatterConstructors : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
	set _FormatStringParser to loader's loadLib("FormatStringParser")
	set _FormatterConstructors to loader's loadComponent("FormatterConstructors")
end __load__

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeEventReceiver()
	script
		property parent : _FormatStringParser's makeEventReceiver()
		property _linefeed : ASCII character 10 -- constant
		property _postProcess : false
		property _postProcessor : missing value
		
		-- post-processors
		
		script _UnicodeChar
			on processText(txt, compilerObj)
				if txt's class is not Unicode text then error "can't insert Unicode character: format string isn't Unicode text." number -1704
				if txt's length < 4 then
					error "invalid value for control character \"x\"." number -1703
				else if txt's length is 4 then
					compilerObj's __addText(_Unicode's uxChar(txt's text 1 thru 4))
				else
					compilerObj's __addText(_Unicode's uxChar(txt's text 1 thru 4) & txt's text 5 thru -1)
				end if
				return
			end processText
		end script
		
		--handle parsing events
		
		on processText(txt)
			if _postProcess then
				_postProcessor's processText(txt, me)
				set _postProcess to false
			else
				__addText(txt) -- (up-calls to Renderer/Formatter object)
			end if
		end processText
		
		on processControlChar(char)
			if char is "s" then
				__addSNode()
			else if char is "n" then
				__addText(_linefeed)
			else if char is "r" then
				__addText(return)
			else if char is "t" then
				__addText(tab)
			else if char is "x" then
				set _postProcess to true
				set _postProcessor to _UnicodeChar
			else if {char} is not in {_linefeed, return} then -- escaped LF/CR chars are removed
				error "invalid control character \"" & char & "\"." number -1703
			end if
		end processControlChar
	end script
end makeEventReceiver

--

on makeCompiler(theFormat) -- creates a new, reusable formatter object
	script
		property parent : makeEventReceiver()
		--
		property _formatter : _FormatterConstructors's makeFormatter(theFormat)
		property _lastNode : _formatter
		
		on __addSNode()
			set newNode to _FormatterConstructors's makeSNode(_formatter's __nullTxt)
			_lastNode's ___addNode(newNode)
			set _lastNode to newNode
			return
		end __addSNode
		
		on __addText(txt)
			_lastNode's ___addText(txt)
		end __addText
		
		-------
		
		on getResult() --get finished formatter object
			return _formatter
		end getResult
	end script
end makeCompiler