property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Types : missing value

on __load__(loader)
	set _Types to loader's loadLib("Types")
end __load__

----------------------------------------------------------------------


property _converters : missing value



on addConverter(ident, scpt)
	if _converters's keyExists(ident) then error "Duplicate ident."
	_converters's setItem(ident, scpt)
	return
end addConverter

on addTextConverter(ident, val)
	script scpt
		property _ctxt : val
		on eval(ident, txt, fsp)
			return _ctxt & txt
		end eval
	end script
	addConverter(ident, scpt)
end addTextConverter


__load__(_Loader's makeLoader())
set _converters to _Types's makeDictConsideringCase()

addTextConverter("n", ASCII character 10)
addTextConverter("r", return)
addTextConverter("t", tab)
addTextConverter(ASCII character 10, "")
addTextConverter(return, "")

_converters's getItem("t")'s eval("t", "hello world", {})