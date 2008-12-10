property __name__ : "FormatterConstructors"
property __version__ : ""
property __lv__ : 1

on __load__(loader)
end __load__

--mark -
--mark PRIVATE<B<U

script _NodeBase -- used by s_Node, TextFormatter
	on ___addText(txt) -- append extra plain text during parsing
		set my __txt to my __txt & txt
		return
	end ___addText
	--
	on ___addNode(node)
		set my __nextNode to node
		return
	end ___addNode
end script

--

script _EndNode
	on render(lst, txt)
		return txt
	end render
end script

--mark -
--mark PUBLIC<B<U

on makeSNode(nullTxt)
	script
		property parent : _NodeBase
		property __txt : nullTxt
		property __nextNode : _EndNode
		-------
		on render(lst, txt)
			set txt to txt & (get lst's first item) & __txt -- error -1728 if lst is too short
			return __nextNode's render(rest of lst, txt)
		end render
	end script
end makeSNode

--

on makeFormatter(theFormat)
	if theFormat's class is string then
		set nullTxt to ""
	else
		set nullTxt to "" as Unicode text
	end if
	script
		property class : "TextFormatter"
		property parent : _NodeBase
		property __nullTxt : nullTxt
		property __txt : nullTxt
		property __nextNode : _EndNode
		property _theFormat : theFormat
		-------
		--PUBLIC
		on formatData(lst)
			try
				if lst's class is not list then
					error "parameter isn't a list." number -1704
				end if
				return __nextNode's render(lst, __txt)
			on error eMsg number eNum
				if eNum is -1728 then set eMsg to "list is too short."
				error "Can't formatData: " & eMsg number eNum
			end try
		end formatData
		--
		on getInfo()
			return {class:my class, formatString:_theFormat}
		end getInfo
	end script
end makeFormatter

(*
--TEST

set f to makeFormatter(" foo %s bar %% baz %s %s %%")
--
f's ___addText(" foo ")
--
set g to makeSNode()
f's ___addNode(g)
g's ___addText(" bar ")
g's ___addText("%")
g's ___addText(" baz ")
--
set h to makeSNode()
g's ___addNode(h)
h's ___addText(" ")
--
set i to makeSNode()
h's ___addNode(i)
i's ___addText(" ")
i's ___addText("%")
--
f's formatData({1, 2, 3, 4, 5}) --> " foo 1 bar % baz 2 3 %"
*)