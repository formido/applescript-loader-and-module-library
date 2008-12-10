property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _LoaderHeaderGenerator : missing value

on __load__(loader)
	set _LoaderHeaderGenerator to loader's loadLib("LoaderHeaderGenerator")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

_LoaderHeaderGenerator's generateSimpleHeader()