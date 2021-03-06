property __name__ : "Loader"
property __version__ : "0.10.0"
property __lv__ : 1

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

-- bind Loader's modules at compile-time
property _srcFolder : "/Library/Scripts/ASLibraries/Loader/Components/"

property __DataStructures : load script POSIX file (_srcFolder & "DataStructures.scpt")
property __LibraryLocator : load script POSIX file (_srcFolder & "LibraryLocator.scpt")
property __VersionControl : load script POSIX file (_srcFolder & "VersionControl.scpt")
property __ScriptVerification : init(__VersionControl) of (load script POSIX file (_srcFolder & "ScriptVerification.scpt"))
property __DiskAccess : init(__ScriptVerification) of (load script POSIX file (_srcFolder & "DiskAccess.scpt"))

----------------------------------------------------------------------
-- PUBLIC

-- note: Loader mustn't contain a property/method named getResult, as this is reserved for LoaderTools' use

on makeLoader()
	script loader
		property class : "Loader"
		-- modules
		property _DataStructures : __DataStructures
		property _ScriptVerification : __ScriptVerification
		property _DiskAccess : __DiskAccess
		
		-- data
		property _libLocator : __LibraryLocator's makeLibraryLocator() -- returns aliases to named libraries
		property _libraryCache : _DataStructures's makeAssociative() -- stores all libs loaded by this loader object
		property _componentCacheStack : _DataStructures's makeStack() -- temporary store for component caches
		property _callerInfoStack : _DataStructures's makeStack() -- store info about current script/library for error reporting, additional services, etc.
		property _notFound : {} -- names of any libraries not found by tryToLoadLib
		
		-------
		
		on ___init()
			-- add main script's component cache (note that main script's Components folder is initially undefined)
			_componentCacheStack's push({scriptCache:_DataStructures's makeAssociative(), folderRef:missing value})
			_callerInfoStack's push({scriptName:"Script", scriptPath:missing value})
			return me
		end ___init
		
		-------
		
		on _load(theName, errorIfNotFound)
			try
				if _libraryCache's itemExists(theName) then
					return _libraryCache's getItem(theName) -- return cached library
				else
					-- load library
					set {libFound, pathToLib} to _libLocator's pathToLib(theName)
					if libFound then
						set scpt to _DiskAccess's loadLib(pathToLib, theName)
						-- and cache it
						_libraryCache's setItem(theName, scpt)
						-- then create a component cache for newly loaded library and add it to component cache stack
						_componentCacheStack's push({scriptCache:_DataStructures's makeAssociative(), folderRef:_locateLibraryComponentsFolder(pathToLib)})
						-- initialise library
						_callerInfoStack's push({scriptName:theName, scriptPath:pathToLib})
						__callLoad(scpt)
						_callerInfoStack's pop()
						-- and throw away its component cache when done
						_componentCacheStack's pop()
						return scpt -- return newly loaded library
					else
						if errorIfNotFound then
							error "Library doesn't exist." number 1610
						else
							if _notFound does not contain {theName} then set _notFound's end to theName
							return missing value
						end if
					end if
				end if
			on error eMsg number eNum
				error "Can't load " & theName & " library: " & return & eMsg number eNum
			end try
		end _load
		
		on _locateLibraryComponentsFolder(pathToLib)
			tell application "Finder"
				tell folder "Components" of (container of file pathToLib) -- Components folder is optional
					if it exists then
						return it
					else
						return missing value
					end if
				end tell
			end tell
		end _locateLibraryComponentsFolder
		
		-------
		
		on __callLoad(scpt) -- may be overridden in subclasses to provide additional behaviours
			scpt's __load__(me)
		end __callLoad
		
		-------
		-- PUBLIC
		
		on componentsFolder()
			try
				set folderRef to _componentCacheStack's top()'s folderRef
				if folderRef is missing value then error "Components folder isn't specified or doesn't exist." number 1630
				return folderRef as alias
			on error eMsg number eNum
				error "Can't get componentsFolder: " & eMsg number eNum
			end try
		end componentsFolder
		
		on setComponentsFolder(folderAlias)
			try
				tell application "Finder" to set folderRef to folder (folderAlias as alias)
				set _componentCacheStack's top()'s folderRef to folderRef
				return
			on error eMsg number eNum
				error "Can't setComponentsFolder: " & eMsg number eNum
			end try
		end setComponentsFolder
		
		on loadLib(theName)
			return _load(theName, true)
		end loadLib
		
		on tryToLoadLib(theName)
			return _load(theName, false)
		end tryToLoadLib
		
		on loadComponent(theName)
			try
				set {scriptCache, folderRef} to {scriptCache, folderRef} of _componentCacheStack's top()
				if folderRef is missing value then error "Components folder isn't specified or doesn't exist." number 1614
				if scriptCache's itemExists(theName) then
					return scriptCache's getItem(theName)
				else
					set scpt to _DiskAccess's loadComponent(theName, folderRef)
					scriptCache's setItem(theName, scpt)
					__callLoad(scpt)
					return scpt
				end if
			on error eMsg number eNum
				error "Can't load " & theName & " component: " & return & eMsg number eNum
			end try
		end loadComponent
		
		on loadTextComponent(theName)
			try
				set {scriptCache, folderRef} to {scriptCache, folderRef} of _componentCacheStack's top()
				if folderRef is missing value then error "Components folder isn't specified or doesn't exist." number 1614
				if scriptCache's itemExists(theName) then
					return scriptCache's getItem(theName)
				else
					set txt to _DiskAccess's loadTextComponent(theName, folderRef)
					scriptCache's setItem(theName, txt)
					return txt
				end if
			on error eMsg number eNum
				error "Can't load " & theName & " component: " & return & eMsg number eNum
			end try
		end loadTextComponent
		
		on minVersion(vers, scpt)
			if scpt is missing value then return scpt
			return _ScriptVerification's checkMinVersion(vers, scpt, _callerInfoStack's top()'s scriptName)
		end minVersion
		
		on addLibrariesFolder(folderRef)
			_libLocator's addLibsFolder(folderRef)
		end addLibrariesFolder
		
		on libFolder()
			try
				set pathToLib to _callerInfoStack's top()'s scriptPath
				if pathToLib is missing value then error "current context isn't a library or library component." number 1625
				tell application "Finder" to return (container of document file pathToLib) as alias
			on error eMsg number eNum
				error "Can't get libFolder: " & eMsg number eNum
			end try
		end libFolder
		
		on missingLibs()
			return _notFound's items
		end missingLibs
	end script
	--
	return loader's ___init()
end makeLoader
