property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Format : missing value

on __load__(loader)
	set _Format to loader's loadLib("Format")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())


set theFormat to "foo%sbar%sbaz %t wibble%% buzz %s.%s %s"
_Format's makeFormatter(theFormat)'s formatData({1, 2, 3, 4, 5})
--> "foo1bar2baz 	 wibble% buzz 3.4 5" 