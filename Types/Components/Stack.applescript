property __name__ : "Stack"
property __version__ : ""
property __lv__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

on makeStack()
	script
		property class : "Stack"
		property _linkedList : missing value
		-------
		on push(val)
			script node
				property nval : val
				property chain : _linkedList
			end script
			set _linkedList to node
			return
		end push
		--
		on top()
			if _linkedList is missing value then error "Can't get top: stack is empty." number -1728
			return _linkedList's nval
		end top
		--
		on pop()
			if _linkedList is missing value then error "Can't pop: stack is empty." number -1728
			set val to get _linkedList's nval
			set _linkedList to get _linkedList's chain
			return val
		end pop
		--
		on isEmpty()
			return (_linkedList is missing value)
		end isEmpty
	end script
end makeStack