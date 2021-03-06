property __name__ : "EndReceivers"
property __version__ : ""
property __lv__ : 1

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeHeader()
	(* get everything up to and including <plist> tag *)
	script
		property _txt : "" as Unicode text
		--
		on processTag(txt)
			set _txt to _txt & ("<" as Unicode text) & txt & ">"
			set endOfHeader to false
			considering case, diacriticals, expansion, hyphens, punctuation and white space
				if txt begins with "plist" then
					ignoring white space
						set endOfHeader to (txt's first word is "plist")
					end ignoring
				end if
			end considering
			return endOfHeader -- true when start of body is reached
		end processTag
		--
		on processContent(txt)
			set _txt to _txt & txt
		end processContent
		--
		on val()
			return _txt
		end val
	end script
end makeHeader

--

on makeFooter()
	(* get everything after and including </plist> tag *)
	script
		property _txt : "" as Unicode text
		property _receive : false -- minor kludge; ignore first processContent message
		--
		on processTag(txt)
			set _receive to true
			set _txt to _txt & ("<" as Unicode text) & txt & ">"
			return false
		end processTag
		--
		on processContent(txt)
			if _receive then set _txt to _txt & txt
		end processContent
		--
		on val()
			return _txt
		end val
	end script
end makeFooter