property __name__ : "LoaderHeaderGenerator"
property __version__ : "0.2.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _ModuleLocator : missing value
property _HeaderFormatter : missing value

on __load__(loader)
	tell loader
		set _ModuleLocator to loadComponent("ModuleLocator")
		set _HeaderFormatter to loadComponent("HeaderFormatter")
	end tell
end __load__

----------------------------------------------------------------------
-- PRIVATE

-- GUI interaction

on buttonInput(promptStr, buttonNames)
	return button returned of (display dialog promptStr buttons buttonNames)
end buttonInput

on textInput(promptStr)
	return text returned of (display dialog promptStr default answer "")
end textInput

on chooseItem(itemNames, promptStr, selectedItem)
	set useItems to choose from list itemNames with prompt promptStr default items {selectedItem}
	result
	if useItems is false then error "User cancelled." number -128
	return useItems's first item
end chooseItem

on chooseItems(itemNames, promptStr)
	if itemNames is not {} then
		set useItems to choose from list itemNames with prompt promptStr with multiple selections allowed and empty selection allowed
		if useItems is false then error "User cancelled." number -128
		return useItems
	else
		return {}
	end if
end chooseItems

on locateFolder(promptStr)
	return choose folder with prompt promptStr
end locateFolder

-------

property _domains : {"local", "user", "OS 9"}
property _defaultDomain : _domains's item 1

----------------------------------------------------------------------
-- PUBLIC

on generateHeader()
	try
		-- target
		if buttonInput("Generate header for:", {"Cancel", "Main Script", "Module"}) is "Main Script" then
			set formatter to _HeaderFormatter's makeMainHeaderFormatter()
		else
			set formatter to _HeaderFormatter's makeModuleHeaderFormatter()
			set formatter's modName to textInput("Enter __name__ (e.g. FinderExtras):")
			set formatter's modVersion to textInput("Enter __version__ (e.g. 1.0.0):")
		end if
		-- library bindings
		if buttonInput("Load libraries?", {"Cancel", "No", "Yes"}) is "Yes" then
			set formatter's libNames to chooseItems(_ModuleLocator's listLibraries(), "Choose libraries to load:")
		end if
		-- component bindings
		if buttonInput("Load components?", {"Cancel", "No", "Yes"}) is "Yes" then
			set pathToComponentsFolder to locateFolder("Please locate the Components folder:")
			if formatter's class is "MainHeaderFormatter" then set formatter's componentsFolderPath to pathToComponentsFolder
			set formatter's componentNames to chooseItems(_ModuleLocator's listComponents(pathToComponentsFolder), "Choose components to load:")
		end if
		--
		return formatter's renderHeader()
	on error eMsg number eNum
		error "Couldn't generateHeader: " & eMsg number eNum
	end try
end generateHeader

on generateSimpleHeader()
	try
		set formatter to _HeaderFormatter's makeMainHeaderFormatter()
		set formatter's libNames to chooseItems(_ModuleLocator's listLibraries(), "Choose libraries to load:" & return & "(command-click to select multiple items)")
		return formatter's renderHeader()
	on error eMsg number eNum
		error "Couldn't generateHeader: " & eMsg number eNum
	end try
end generateSimpleHeader

-------
-- TEST

(*
set loader to makeLoader() of (load script ("/Library/Scripts/ASLibraries:Loader:Library.scpt" as POSIX file))
loader's setComponentsFolder(("/Library/Scripts/ASLibraries/LoaderHeaderGenerator/Components/" as POSIX file as Unicode text as alias))
__load__(loader)
generateHeader()
*)