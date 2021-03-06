(*
DiskAccess - load library/component scripts
(c) 2003 HAS
*)

property _ScriptVerification : missing value

on init(ScriptVerification)
	set _ScriptVerification to ScriptVerification
	return me
end init

--

on _loadScript(theAlias, theName)
	try
		set scpt to load script theAlias
	on error eMsg number eNum
		error "Can't load script " & theAlias & ": " & return & eMsg number eNum
	end try
	_ScriptVerification's checkScriptName(theName, scpt)
	return scpt
end _loadScript

--

on loadLib(pathToLib, theName)
	return _loadScript(pathToLib, theName)
end loadLib

on loadComponent(theName, componentsFolderRef)
	try
		tell application "Finder"
			set theAlias to (get document file (theName & ".scpt") of componentsFolderRef) as alias
		end tell
	on error number -1728
		error "File " & theName & ".scpt not found." number 1615
	end try
	return _loadScript(theAlias, theName)
end loadComponent

on loadTextComponent(theName, componentsFolderRef)
	try
		tell application "Finder"
			set theAlias to (get first document file of componentsFolderRef whose name begins with (theName & ".")) as alias
		end tell
	on error number -1728
		error "File " & theName & ".[suffix] not found." number 1615
	end try
	try
		return read theAlias
	on error eMsg number eNum
		error "Can't load component " & theAlias & ": " & return & eMsg number eNum
	end try
end loadTextComponent