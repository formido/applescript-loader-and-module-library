property __name__ : "CollectorConstructors"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _NodeConstructors : missing value

on __load__(loader)
	set _NodeConstructors to loader's loadComponent("NodeConstructors")
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

script _CollectorBase
	property isPList : false
	--
	on addVal(txt)
		-- squelch
	end addVal
	--
	on addKey(txt)
		error "Can't add key to " & my class
	end addKey
	--
	on addNode(node)
		error "Can't add node to " & my class
	end addNode
end script

-------
--mark -
--mark PUBLIC<B<U
--mark constructors<U

on makeArrayCollector()
	script
		property parent : _CollectorBase
		property class : "array"
		script _k
			property nList : {}
		end script
		-------
		on addNode(node)
			set end of _k's nList to node
		end addNode
		--
		on finishedNode()
			return _NodeConstructors's makeArray(_k's nList)
		end finishedNode
	end script
end makeArrayCollector

--

on makeDictCollector()
	script
		property parent : _CollectorBase
		property class : "dict"
		script _k
			property kList : {}
			property nList : {}
		end script
		--
		property _keyDelim : "<" as Unicode text
		property _nextIsKey : true
		-------
		on addKey(txt)
			if not _nextIsKey then error "Key can't follow key."
			set _nextIsKey to false
			set _k's kList's end to txt
		end addKey
		--
		on addNode(node)
			if _nextIsKey then error "Value is missing key."
			set _nextIsKey to true
			set end of _k's nList to node
		end addNode
		--
		on finishedNode()
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to _keyDelim
			set keyTable to ("null" as Unicode text) & _keyDelim & _k's kList & _keyDelim
			set AppleScript's text item delimiters to oldTID
			return _NodeConstructors's makeDict(keyTable, _k's kList, _k's nList, _keyDelim)
		end finishedNode
	end script
end makeDictCollector

--

on makePrimitiveCollector(nodeType)
	--log "makePrimitiveCollector: " & nodeType
	script
		property parent : _CollectorBase
		property class : nodeType
		property _val : missing value
		-------
		on addVal(txt)
			if _val is not missing value then error "A value already exists."
			set _val to txt
			return
		end addVal
		--
		on val()
			return _val
		end val
		--
		on finishedNode()
			if _val is missing value then error "No value."
			tell _NodeConstructors
				if my class is "string" then
					return makeString(_val)
				else if my class is "true" then
					return makeTrue()
				else if my class is "false" then
					return makeFalse()
				else if my class is "integer" then
					return makeInteger(_val)
				else if my class is "real" then
					return makeReal(_val)
				else if my class is "date" then
					return makeDate(_val)
				else if my class is "data" then
					return makeData(_val)
				else
					error "Can't make node for \"" & my class & "\" (type unknown)."
				end if
			end tell
		end finishedNode
	end script
end makePrimitiveCollector

--

on makePListCollector()
	script
		property isPList : true
		--
		property parent : _CollectorBase
		property class : "plist"
		property _node : missing value
		-------
		on addNode(node)
			set _node to node
		end addNode
		--
		on val()
			return _node
		end val
	end script
end makePListCollector