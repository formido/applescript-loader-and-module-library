property __name__ : "Breadcrumb"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _EndNode
	property ___isEndNode : true
	property ___linksToSelf : ""
	
	on rebuildLinks(lev)
		return ""
	end rebuildLinks
end script

on _makeLevelNode(topNode, titleTxt, defaultFile)
	script node
		--PRIVATE
		-- constants
		property _link1 : "<a href=\""
		property _link2 : "\">"
		property _link3 : "</a>"
		property _div : space & "&gt;" & space
		--state (note that these values don't change once set)
		property _defaultFile : defaultFile -- e.g. "index.html"
		property _nextNode : topNode
		property _title : titleTxt
		-------
		-- RESTRICTED (used by the node's container)
		property ___isEndNode : false --constant
		property ___linksToSelf : "" -- this is rebuilt every time the breadcrumb changes level
		-------
		-- PUBLIC
		--methods
		on nextNode()
			if _nextNode's ___isEndNode then error number 1460
			return _nextNode
		end nextNode
		--
		on startRender()
			return _nextNode's ___linksToSelf & _title
		end startRender
		--
		on continueRender(pageTitle)
			return ___linksToSelf & pageTitle
		end continueRender
		
		on rebuildLinks(lev)
			set ___linksToSelf to _nextNode's rebuildLinks("../" & lev) & _link1 & (lev & _defaultFile) & _link2 & _title & _link3 & _div
			return ___linksToSelf
		end rebuildLinks
	end script
end _makeLevelNode

----------------------------------------------------------------------
-- PUBLIC

on makeBreadcrumb(homeName, defaultFile)
	set firstNode to _makeLevelNode(_EndNode, homeName, defaultFile)
	firstNode's rebuildLinks("")
	script
		property class : "Breadcrumb"
		--PRIVATE
		-- constants
		property _isPage : false
		--state
		property _defaultFile : defaultFile
		property _topLevelNode : firstNode
		property _pageName : ""
		-------
		--PUBLIC
		on addLevel(titleTxt)
			set _topLevelNode to _makeLevelNode(_topLevelNode, titleTxt, _defaultFile)
			_topLevelNode's rebuildLinks("")
			removePage()
			return
		end addLevel
		--
		on removeLevel()
			try
				set _topLevelNode to _topLevelNode's nextNode()
			on error number 1460
				error "Can't removeLevel: already at Home level." number -1728
			end try
			_topLevelNode's rebuildLinks("")
			removePage()
			return
		end removeLevel
		-------
		on addPage(pageName)
			set _isPage to true
			set _pageName to pageName
			return
		end addPage
		--
		on removePage()
			set _isPage to false
			set _pageName to ""
			return
		end removePage
		-------
		on renderHTML()
			if _isPage then
				return _topLevelNode's continueRender(_pageName)
			else
				return _topLevelNode's startRender()
			end if
		end renderHTML
	end script
end makeBreadcrumb

----------------------------------------------------------------------
-- TEST

(*
tell makeBreadcrumb("Home", "index.html")
	log renderHTML() --> "Home"
	addPage("dandy")
	log renderHTML() --> "<a href=\"index.html\">Home</a> &gt; dandy"
	addLevel("Level 1")
	log renderHTML() --> "<a href=\"../index.html\">Home</a> &gt; Level 1"
	addLevel("Level 2")
	log renderHTML() --> "<a href=\"../../index.html\">Home</a> &gt; <a href=\"../folder1/index.html\">Level 1</a> &gt; Level 2"
	addLevel("Level 3")
	log renderHTML() --> "<a href=\"../../../index.html\">Home</a> &gt; <a href=\"../../folder1/index.html\">Level 1</a> &gt; <a href=\"../folder1/folder2/index.html\">Level 2</a> &gt; Level 3"
	addPage("heady")
	log renderHTML() --> "<a href=\"../../../index.html\">Home</a> &gt; <a href=\"../../folder1/index.html\">Level 1</a> &gt; <a href=\"../folder1/folder2/index.html\">Level 2</a> &gt; <a href=\"folder1/folder2/folder3/index.html\">Level 3</a> &gt; heady"
	removeLevel()
	addPage("comfy")
	log renderHTML() --> "<a href=\"../../index.html\">Home</a> &gt; <a href=\"../folder1/index.html\">Level 1</a> &gt; <a href=\"folder1/folder2/index.html\">Level 2</a> &gt; comfy"
	removePage()
	log renderHTML() --> "<a href=\"../../index.html\">Home</a> &gt; <a href=\"../folder1/index.html\">Level 1</a> &gt; Level 2"
end tell
*)