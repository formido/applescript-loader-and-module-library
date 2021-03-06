property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _FinderLib : missing value

on __load__(loader)
	set _FinderLib to loader's loadLib("FinderLib")
end __load__

----------------------------------------------------------------------
-- MAIN

__load__(_Loader's makeLoader())

tell application "Finder" to set itemsRef to a reference to every item of home
_FinderLib's sortByName(itemsRef)
-- _FinderLib's sortByDateModified(itemsRef)