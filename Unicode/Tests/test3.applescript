property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Unicode : missing value

on __load__(loader)
	set _Unicode to loader's loadLib("Unicode")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


on u(num)
	return _Unicode's uChar(num)
end u

set a to ("f" as Unicode text) & u(331) & u(28000) & u(45000) & u(380) & u(65510) & u(32222) & u(1574) & u(65509)
--return result
tell application "TextEdit" to set text of document 1 to result & return & return & return & return
return
_Unicode's uNum(u(1865))
("f" as Unicode text) & u(453) & "f"
tell application "TextEdit" to set paragraph 2 of document 1 to result
--return

set AppleScript's text item delimiters to "" as Unicode text
set b to {("f" as Unicode text), u(331), u(28000), u(45000), u(380), u(65510), u(32222), u(1574), u(65509)} as Unicode text

set b to ({u(1577), u(1577)} as Unicode text) & (u(1577) & u(1577))
tell application "TextEdit" to set paragraph 3 of document 1 to result
a = b -- u(1574) gets screwed up during list-to-utxt coercion