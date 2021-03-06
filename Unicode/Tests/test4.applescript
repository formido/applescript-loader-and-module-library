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

set a to ("f" as Unicode text) & u(331) & u(28000) & u(45000) & u(380) & u(65510) & u(32222) & u(1574) & u(65509) & u(65510)
--return result

{a, _Unicode's splitText(a, u(65510)), _Unicode's replaceText(a, u(65510), u(280))}