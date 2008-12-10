property __name__ : "ModuleLocator"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value

on __load__(loader)
	tell loader
		set _List to loadLib("List")
	end tell
end __load__

----------------------------------------------------------------------
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

----------------------------------------------------------------------
-- PUBLIC

on listLibraries() -- name of every installed library
	set foundLibs to {}
	tell application "Finder"
		repeat with scriptsFolder in my _listScriptsFolders()
			tell folder "ASLibraries" of folder scriptsFolder
				if it exists then
					tell (every folder whose name does not start with "~" and name is not in foundLibs)
						if its (count) is greater than 0 then set foundLibs to foundLibs & name
					end tell
				end if
			end tell
		end repeat
	end tell
	return _List's sortList(foundLibs)
end listLibraries

on listComponents(pathToComponentsFolder) -- name of every script within given folder
	set namesList to {}
	tell application "Finder"
		set scriptsList to every file of folder pathToComponentsFolder whose name ends with ".scpt"
	end tell
	repeat with fileRef in scriptsList
		set namesList's end to text 1 thru -6 of (get fileRef's name)
	end repeat
	return namesList
end listComponents

----------------------------------------------------------------------
--TEST

(*
property _Loader : load script alias (((path to scripts folder from local domain) as Unicode text) & "ASLibraries:Loader:Library.scpt")
__load__(_Loader's makeLoader())
installedLibraryNames()
*)