property __name__ : "Queue"
property __version__ : ""
property __lv__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

on makeQueue()
	script
		property class : "Queue"
		script _linkedList
			property nval : missing value
			property chain : missing value
		end script
		property _newestNode : _linkedList
		--
		on addItem(val)
			script node
				property nval : val
				property chain : missing value
			end script
			set _newestNode's chain to node
			set _newestNode to node
			return
		end addItem
		--
		on getItem()
			if _linkedList's chain is missing value then error "Can't getItem: queue is empty." number -1728
			return _linkedList's chain's nval
		end getItem
		--
		on removeItem()
			if _linkedList's chain is missing value then error "Can't get removeItem: queue is empty." number -1728
			set val to get _linkedList's chain's nval
			set _linkedList to get _linkedList's chain
			return val
		end removeItem
		--
		on isEmpty()
			return (_linkedList's chain is missing value)
		end isEmpty
	end script
end makeQueue