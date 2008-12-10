property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _XTemplate : missing value

on __load__(loader)
	set _XTemplate to loader's loadLib("XTemplate")
end __load__

----------------------------------------------------------------------

__load__(_Loader's makeLoader())

set pathToCompiledTemplate to alias "/Library/Scripts/ASLibraries/XTemplate/Tests/demo1Template.scpt"
_XTemplate's viewStructure(load script pathToCompiledTemplate)

(* Result:

tem_template
	con_title
	con_list
		rep_item
			con_link [att_href]

*)