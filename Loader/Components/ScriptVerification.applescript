(*
ScriptVerification - check scripts' special properties
(c) 2003 HAS

-- TO DO: version control to use Version library, loaded on demand by Loader
*)

property _versionControl : missing value

on init(VersionControl)
	set _versionControl to VersionControl
	return me
end init

--

on _getScriptName(scpt)
	try
		return scpt's __name__
	on error
		error "Can't get __name__ property." number 1618
	end try
end _getScriptName

on _getScriptVersion(scpt)
	try
		return scpt's __version__
	on error
		error "Can't get __version__ property." number 1620
	end try
end _getScriptVersion

--

on checkScriptName(theName, scpt) -- called by _loadScript
	considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
		if _getScriptName(scpt) is not theName then
			error "__name__ property doesn't match expected name." number 1619
		end if
	end considering
	return scpt
end checkScriptName

on checkMinVersion(versionStr, scpt, callerName) -- optionally called by user
	try
		if _versionControl's isGreaterOrEqual(_getScriptVersion(scpt), versionStr) then return scpt -- return if passed
	on error eMsg number eNum
		error "Can't check minVersion for " & _getScriptName(scpt) & ": " & return & eMsg number eNum
	end try
	error callerName & " requires a newer version of " & _getScriptName(scpt) & " (" & versionStr & " or later)." number 1600 -- raise error if failed
end checkMinVersion