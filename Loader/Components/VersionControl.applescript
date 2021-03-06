(*
VersionControl - parse and compare version numbers of form "version.subversion.patch", e.g. "2.10.4"
(c) 2003 HAS
*)

on versionToList(versionStr)
	-- convert version string to integer list; e.g. "3.12.0" -> {3, 12, 0}
	if versionStr's class is not in {string, Unicode text} then
		error "Invalid version string: not a string." number 1621
	end if
	try
		considering case, hyphens, punctuation and white space
			set lst to {""}
			repeat with charRef in versionStr
				set char to charRef's contents
				if char is in "0123456789" then
					set lst's last item to lst's last item & char
				else if char is "." then
					set lst's end to ""
				else
					error
				end if
			end repeat
			if (count of lst) is not 3 then error
			set {v, s, p} to lst
			if v is "" or s is "" or p is "" then error
		end considering
		return {v as integer, s as integer, p as integer}
	on error
		error "Malformed version string: \"" & versionStr & "\"." number 1622
	end try
end versionToList

on isGreaterOrEqual(vers1, vers2)
	-- is version equal to or above minimum version? e.g. isGreaterOrEqual("10.1.3", "10.1.4") -> false
	set {v1, s1, p1} to versionToList(vers1)
	set {v2, s2, p2} to versionToList(vers2)
	if v1 is less than v2 then
		return false
	else if v1 is greater than v2 then
		return true
	else if s1 is less than s2 then
		return false
	else if s1 is greater than s2 then
		return true
	else
		return p1 is greater than or equal to p2
	end if
end isGreaterOrEqual

-- TEST
-- isGreaterOrEqual("10.1.2", "10.1.4") --> false
--versionToList("12.a.4") -- error: invalid version no.