property __name__ : "Compiler"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
--Dependencies

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on compileScript(txt)
	try
		return run script ("script" & return & txt & return & "end script")
		--tell application "Smile"
		--return do script ("script" & return & str & return & "end script")
		--end tell
	on error eMsg number eNum
		error "Couldn't compile: " & eMsg & " (" & eNum & ")" & return & "
******* BEGIN SCRIPT *******
" & return & txt & return & "
******* END SCRIPT *******" number eNum
	end try
end compileScript