property __name__ : "iTunesToWebController"
property __version__ : ""
property __lv__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _delim : ASCII character 0
property _chars : "&<>\""
property _ents : {"&amp;", "&lt;", "&gt;", "&quot;"}

on _esc(lst) -- escape special chars in each text item of list
	set txt to _Unicode's joinList(lst, _delim)
	repeat with i from 1 to count _chars
		set txt to _Unicode's replaceText(txt, _chars's item i, _ents's item i)
	end repeat
	set res to _Unicode's splitText(txt, _delim)
	if (count res) is not (count lst) then
		error "A problem occurred while converting to HTML entities: invalid character."
	end if
	return res
end _esc

on _chk(txt)
	if txt is "" then set txt to "&nbsp;"
	return txt
end _chk

--

on _makeTrackIterator(nameList, artistList, albumList, timeList)
	script
		script _k
			property a : nameList
			property b : artistList
			property c : albumList
			property d : timeList
		end script
		
		property _cnt : count of _k's a
		property _idx : 1
		
		on gotoFirst()
			set _idx to 1
			return
		end gotoFirst
		
		on gotoNext()
			set _idx to _idx + 1
			return
		end gotoNext
		
		on isDone()
			return (_idx > _cnt)
		end isDone
		
		on currentItem()
			return {_idx, _k's a's item _idx, _k's b's item _idx, _k's c's item _idx, _k's d's item _idx}
		end currentItem
	end script
end _makeTrackIterator

----------------------------------------------------------------------
-- PUBLIC
-- Template Event Handlers

on render_template(xo, {})
	tell application "iTunes"
		tell view of front browser window
			set viewName to name
			set totalTime to time
			set {a, b, c, d} to {name, artist, album, time} of tracks
		end tell
	end tell
	xo's con_title()'s setContent(viewName)
	xo's rep_track()'s iterateWith(_makeTrackIterator(_esc(a), _esc(b), _esc(c), d), {})
	xo's con_totalTime()'s setContent(totalTime)
end render_template

on render_track(xo, {idx, nam, art, alb, tm}, {})
	xo's con_idx()'s setContent(idx)
	xo's con_title()'s setContent(nam)
	xo's con_artist()'s setContent(_chk(art))
	xo's con_album()'s setContent(_chk(alb))
	if tm is missing value then set tm to "-:--"
	xo's con_time()'s setContent(tm)
end render_track