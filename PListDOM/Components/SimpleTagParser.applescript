property __name__ : "SimpleTagParser"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
--Dependencies

property _EveryItem : missing value

on __load__(loader)
	set _EveryItem to loader's loadLib("EveryItem")
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

on _tokenise(txt, delim)
	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	try
		set lst to txt's text items
	on error number -2706 -- stack overflow (affects strings containing more than approx. 4000 text items)
		set lst to _EveryItem's everyTextItem(txt)
	end try
	set AppleScript's text item delimiters to oldTID
	return lst
end _tokenise

-------
--PUBLIC

on parseTags(txt, receiverScript)
	try
		script kludge
			property lst : _tokenise(txt, "<")
		end script
		set contentTxt to kludge's lst's first item
		if contentTxt contains ">" then error "invalid \">\" character." number 1600
		set kludge's lst to rest of kludge's lst
		receiverScript's processContent(contentTxt)
		repeat with chunkRef in kludge's lst
			set txtChunks to _tokenise(chunkRef's contents, ">")
			if (count of txtChunks) is not 2 then
				if (count of txtChunks) is 1 then
					error "missing \">\" character." number 1600
				else
					error "invalid \">\" character." number 1600
				end if
			end if
			receiverScript's processTag(txtChunks's first item)
			receiverScript's processContent(txtChunks's second item)
		end repeat
		return
	on error eMsg number eNum
		error "parseTags error: " & eMsg number eNum
	end try
end parseTags

(*
--TEST

on makeReceiver()
	script
		script _kludge
			property l : {}
		end script
		
		on processTag(txt)
			set _kludge's l's end to {class:"tag", contents:txt}
		end processTag
		
		on processContent(txt)
			set _kludge's l's end to {class:"val", contents:txt}
		end processContent
		
		on getResult()
			return _kludge's l
		end getResult
	end script
end makeReceiver

set txt to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>foo</key>
	<true/>
</dict>
</plist>"

set receiver to makeReceiver()
parseTags(txt, receiver)
return receiver's getResult()
*)