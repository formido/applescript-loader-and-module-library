property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _FormatStringParser : missing value

on __load__(loader)
	set _FormatStringParser to loader's loadLib("FormatStringParser")
end __load__

----------------------------------------------------------------------


on _makeTestReceiver()
	script
		--private
		
		property _res : ""
		
		on rec(txt)
			set _res to _res & return & txt
		end rec
		
		--public
		
		on processStart()
			rec("*******START*******")
		end processStart
		
		on processText(txt) -- plain text block: "blah"
			rec("TEXT: '" & txt & "'")
		end processText
		
		on processControlChar(char) -- formatter character, e.g. "s", "t"
			rec("SPECIAL: " & char)
		end processControlChar
		
		on processEnd()
			rec("*******END*******")
		end processEnd
		
		on getResult()
			return _res
		end getResult
	end script
end _makeTestReceiver


__load__(_Loader's makeLoader())
set receiver to _makeTestReceiver()
_FormatStringParser's parseFormatString("foo%sbar%tbaz%%surf%sbuzz", "%", receiver)
receiver's getResult()

(* Result:
"
*******START*******
TEXT: 'foo'
SPECIAL: s
TEXT: 'bar'
SPECIAL: t
TEXT: 'baz'
TEXT: '%'
TEXT: 'surf'
SPECIAL: s
TEXT: 'buzz'
*******END*******"
*)