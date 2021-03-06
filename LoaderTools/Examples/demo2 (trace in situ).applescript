property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _Date : missing value
property _EveryItem : missing value
property _String : missing value
property _Format : missing value

on __load__(loader)
	set _Date to loader's loadLib("Date")
	set _EveryItem to loader's loadLib("EveryItem")
	set _String to loader's loadLib("String")
	set _Format to loader's loadLib("Format")
end __load__

----------------------------------------------------------------------

(*
	Perform a trace on this script's existing __load__ handler. Notice how a trace can be inserted into an existing script without disrupting its normal behaviour.
*)

on run
	__load__(_Loader's makeLoader())
	
	-------begin temporary trace load code-------
	set traceLoader to _Loader's makeLoader()'s loadLib("LoaderTools")'s makeTimedLoader()
	__load__(traceLoader)
	log traceLoader's getResult()
	-------end temporary trace load code-------
	
	set s to _Date's makeFormatter("d/m/yy h:MM tt", "English")'s currentDate()
	_Format's makeFormatter("%s at %s.")'s formatData({"Hello World", s})
end run