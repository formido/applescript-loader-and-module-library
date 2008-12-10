property __name__ : "ElementCollector"
property __version__ : ""
property __lv__ : 1

(* builds list of form text-element-text-... for each template element found *)

----------------------------------------------------------------------
--Dependencies

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeElementCollector(objectName, tagName, attributesList, endOfOpenTag, isEmptyTag, toDelete, nullTxt)
	script
		property _depth : 1
		--
		property oName : objectName
		property tName : tagName
		property tAtts : attributesList
		property tEnd : endOfOpenTag
		property tEmpty : isEmptyTag
		property eCont : {nullTxt}
		property deleteThis : toDelete
		property elementNames : {}
		property ntxt : nullTxt
		-------
		on incDepth()
			set _depth to _depth + 1
			return
		end incDepth
		--
		on decDepth()
			set _depth to _depth - 1
			return
		end decDepth
		--
		on isEndOfElement()
			return (_depth is less than 1)
		end isEndOfElement
		-------
		on addItem(val) -- add nodes and strings
			if val's class is in {string, Unicode text} then
				set eCont's last item to eCont's last item & val
			else
				set elementNames's end to val's name
				set eCont's end to val
				set eCont's end to ntxt
			end if
			return
		end addItem
	end script
end makeElementCollector