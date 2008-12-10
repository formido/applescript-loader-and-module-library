property __name__ : "Version"
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

on _cmp(vers1, vers2, callerName) --> {is equal, is greater than}
	try
		set {v1, s1, p1} to versionToList(vers1)
		set {v2, s2, p2} to versionToList(vers2)
		if {v1, s1, p1} is {v2, s2, p2} then
			return {true, false}
		else if v1 is less than v2 then
			return {false, false}
		else if v1 is greater than v2 then
			return {false, true}
		else if s1 is less than s2 then
			return {false, false}
		else if s1 is greater than s2 then
			return {false, true}
		else
			return {false, p1 is greater than p2}
		end if
	on error eMsg number eNum
		error "Can't get " & callerName & ": " & eMsg number eNum
	end try
end _cmp

----------------------------------------------------------------------
-- PUBLIC

on versionToList(versionTxt)
	if versionTxt's class is not in {string, Unicode text} then
		error "Can't convert versionToList: not a valid version number." number -1704
	end if
	try
		considering case, hyphens, punctuation and white space
			set lst to {""}
			repeat with charRef in versionTxt
				set char to charRef's contents
				if char is in "0123456789" then
					set lst's last item to lst's last item & char
				else if char is "." then
					set lst's end to ""
				else
					error
				end if
			end repeat
			if (count of lst) is not 3 then
				if (count of lst) is 2 then
					set end of lst to 0
				else
					error
				end if
			end if
			set {v, s, p} to lst
			if v is "" or s is "" or p is "" then error
		end considering
		return {v as integer, s as integer, p as integer}
	on error
		error "Can't convert versionToList: not a valid version number: " & versionStr number -1704
	end try
end versionToList

--

on isEqual(vers1, vers2)
	try
		return versionToList(vers1) is versionToList(vers2)
	on error eMsg number eNum
		error "Can't get isEqual: " & eMsg number eNum
	end try
end isEqual

on isLessThan(vers1, vers2)
	set {eq, gt} to _cmp(vers1, vers2, "isLessThan")
	return not (eq or gt)
end isLessThan

on isLessOrEqual(vers1, vers2)
	set {eq, gt} to _cmp(vers1, vers2, "isLessOrEqual")
	return eq or not gt
end isLessOrEqual

on isGreaterThan(vers1, vers2) -- is vers1 greater than vers2; e.g. isGreaterThan("10.1.3", "10.1.4") --> false
	set {eq, gt} to _cmp(vers1, vers2, "isGreaterThan")
	return gt
end isGreaterThan

on isGreaterOrEqual(vers1, vers2)
	set {eq, gt} to _cmp(vers1, vers2, "isGreaterOrEqual")
	return eq or gt
end isGreaterOrEqual

-------
--TEST

--versionToList("1.2")
--versionToList("1.2.1")