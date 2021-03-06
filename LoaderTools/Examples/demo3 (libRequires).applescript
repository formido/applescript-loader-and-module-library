property _Loader : run application "LoaderServer"

(*
	List all libraries used by a chosen library. Any min version requirements will also be recorded.
*)

set loader to _Loader's makeLoader()
set LoaderTools to loader's loadLib("LoaderTools")

set libName to text returned of (display dialog "Enter library name (e.g. XTemplate):" default answer "")
LoaderTools's libRequires(libName)