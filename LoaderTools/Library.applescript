property __name__ : "LoaderTools"
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

property _Loader : missing value
property _String : missing value
property _Version : missing value

property _ModuleLocator : missing value

on __load__(loader)
	tell loader
		set _Loader to loadLib("Loader")
		set _String to loadLib("String")
		set _Version to loadLib("Version")
		set _ModuleLocator to loadComponent("ModuleLocator")
	end tell
	return
end __load__

----------------------------------------------------------------------


on makeTraceLoader()
	script
		-- TraceLoader stuff (note identifier extension, "TL_", to avoid potential namespace conflicts with Loader
		property parent : _Loader's makeLoader()
		property _TL_abort : false
		property _TL_indent : tab
		property _TL_res : {}
		
		on _TL_add(s)
			set _TL_res's end to text 2 thru -1 of (_TL_indent & s)
		end _TL_add
		
		on _TL_up()
			set _TL_indent to _TL_indent & tab
		end _TL_up
		
		on _TL_down()
			set _TL_indent to _TL_indent's text 2 thru -1
		end _TL_down
		
		-------
		-- overridden Loader methods
		
		on __callLoad(scpt)
			try
				scpt's __load__(me)
			on error eMsg number eNum
				set _TL_abort to true
				set _TL_res's end to "ERROR: " & eNum & return & eMsg
			end try
		end __callLoad
		
		on loadLib(theName)
			if _TL_abort then return missing value
			_TL_add("loadLib: " & theName)
			_TL_up()
			continue loadLib(theName) returning scpt
			_TL_down()
			return scpt
		end loadLib
		
		on tryToLoadLib(theName)
			if _TL_abort then return missing value
			_TL_add("tryToLoadLib: " & theName)
			_TL_up()
			continue tryToLoadLib(theName) returning scpt
			if scpt is missing value then _TL_add("[not loaded]")
			_TL_down()
			return scpt
		end tryToLoadLib
		
		on loadComponent(theName)
			if _TL_abort then return missing value
			_TL_add("loadComponent: " & theName)
			_TL_up()
			continue loadComponent(theName) returning scpt
			_TL_down()
			return scpt
		end loadComponent
		
		on getResult()
			if _TL_res is {} then return "NO TRACE RECORDED"
			return _String's joinList(_TL_res, return)
		end getResult
	end script
end makeTraceLoader

-------

on makeTimedLoader()
	script
		property parent : makeTraceLoader()
		-------
		-- overridden Loader methods
		
		on loadLib(theName)
			set t to GetMilliSec
			continue loadLib(theName) returning scpt
			_TL_add("(" & (((GetMilliSec) - t) / 1000) & ")")
			return scpt
		end loadLib
		
		on tryToLoadLib(theName)
			set t to GetMilliSec
			continue tryToLoadLib(theName) returning scpt
			_TL_add("(" & (((GetMilliSec) - t) / 1000) & ")")
			return scpt
		end tryToLoadLib
		
		on loadComponent(theName)
			set t to GetMilliSec
			continue loadComponent(theName) returning scpt
			_TL_add("(" & (((GetMilliSec) - t) / 1000) & ")")
			return scpt
		end loadComponent
	end script
end makeTimedLoader

-------

on libRequires(libName)
	script loader
		property parent : _Loader's makeLoader()
		property _TL_names : {}
		property _TL_res : {}
		property _TL_continue : true
		
		on _TL_add(libName, isOptional)
			if _TL_names does not contain {libName} then
				set _TL_names's end to libName
				set _TL_res's end to {name:libName, version:"", optional:isOptional}
			end if
		end _TL_add
		
		on _TL_req()
			_TL_add("Loader", false)
		end _TL_req
		-------
		-- overridden Loader methods
		
		on loadLib(theName)
			if _TL_continue then
				set _TL_continue to false
				continue loadLib(theName)
			else
				_TL_req()
				_TL_add(theName, false)
			end if
			script
				property __name__ : theName
			end script
		end loadLib
		
		on tryToLoadLib(theName)
			if _TL_continue then
				set _TL_continue to false
				continue tryToLoadLib(theName)
			else
				_TL_req()
				_TL_add(theName, true)
			end if
			script
				property __name__ : theName
			end script
		end tryToLoadLib
		
		on loadComponent(theName)
			_TL_req()
			return continue loadComponent(theName)
		end loadComponent
		
		on minVersion(vers, scpt)
			_TL_req()
			set theName to scpt's __name__
			if theName is in _TL_names then -- TO DO: is there any way to differentiate between a library and a component here?
				repeat with recRef in _TL_res
					if recRef's name is theName then
						if recRef's version is "" or _Version's isGreaterThan(vers, recRef's version) then
							set recRef's version to minVers
						end if
						exit repeat
					end if
				end repeat
				return scpt
			else -- it's a component
				return continue minVersion(vers, scpt)
			end if
		end minVersion
		
		on setComponentsFolder(folderAlias)
			_TL_req()
			continue setComponentsFolder(folderAlias)
		end setComponentsFolder
		
		on componentsFolder()
			_TL_req()
			return continue componentsFolder()
		end componentsFolder
		
		on addLibsFolder(folderAlias)
			_TL_req()
			continue addLibsFolder(folderAlias)
		end addLibsFolder
		
		on libPath()
			_TL_req()
			continue libPath()
		end libPath
		
		
		on getResult()
			return _TL_res
		end getResult
	end script
	loader's loadLib(libName)
	return loader's getResult()
end libRequires

on allLibsRequire()
	set res to {}
	repeat with nameRef in _ModuleLocator's listLibraries()
		set res's end to {name:nameRef's contents, requires:libRequires(nameRef's contents)}
	end repeat
	return res
end allLibsRequire

--

(*on listLoadedLibs(loader)
	return loader's _libraryCache's listKeys()'s reverse
end listLoadedLibs*)