(*
LibraryLocator -- locate ASLibraries folders and libraries within
(c) 2003 HAS

Note: ASLibraries folders must be stored in:
	- OS 8-9: "STARTUP DISK:System Folder:Scripts:"
	- OS X: "/Library/Scripts/" and/or "~/Library/Scripts/"

TO DO: add support 'path to scripts folder from network domain'?
*)

-------
-- PRIVATE

on _listScriptsFolders()
	set pathsList to {}
	try
		set end of pathsList to path to scripts folder -- works on OS8/9; breaks on OS10.1.x; equiv. to 'user domain' on OS10.2.x
	on error
		try
			set end of pathsList to path to scripts folder from user domain -- breaks on OS8; works on OS10.x
		end try
	end try
	try
		set end of pathsList to path to scripts folder from local domain -- breaks on OS8/9; works on OS10.x
	end try
	return pathsList --> {user, local} on OS X, {local} on OS 9
end _listScriptsFolders

--

on _listAllLibraries()
	set foundLibs to {}
	tell application "Finder"
		repeat with scriptsFolder in my _listScriptsFolders()
			tell folder "ASLibraries" of folder scriptsFolder
				if it exists then set foundLibs's end to {get it, get name of every folder of it}
			end tell
		end repeat
	end tell
	return foundLibs
end _listAllLibraries

-------
-- PUBLIC

on makeLibraryLocator()
	script
		property _installedLibraries : _listAllLibraries()
		--
		on pathToLib(libName)
			considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
				repeat with aFolder in _installedLibraries
					set {folderRef, libNames} to aFolder
					if libNames contains {libName} then
						try
							tell application "Finder"
								return {true, (get document file "Library.scpt" of folder libName of folderRef) as alias} -- return if found
							end tell
						on error number -1728
							error "File Library.scpt not found." number 1611
						end try
					end if
				end repeat
			end considering
			return {false, missing value} -- library not found (let caller decide what to do)
		end pathToLib
		
		on addLibsFolder(folderRef)
			try
				tell application "Finder"
					if folderRef's class is not folder then set folderRef to folder folderRef
					set beginning of _installedLibraries to {folderRef, name of every folder of folderRef}
				end tell
				return
			on error eMsg number eNum
				error "Can't addLibsFolder:" & eMsg number eNum
			end try
		end addLibsFolder
	end script
end makeLibraryLocator

-------
-- TEST

--return _listAllLibraries()

set rpt to 10
set t1 to GetMilliSec
repeat rpt times
	_listAllLibraries()
end repeat
set t1 to ((GetMilliSec) - t1) as integer
set loc to makeLibraryLocator()
set t2 to GetMilliSec
repeat rpt times
	loc's pathToLib("string")
end repeat
set t2 to ((GetMilliSec) - t2) as integer

{t1, t2}
