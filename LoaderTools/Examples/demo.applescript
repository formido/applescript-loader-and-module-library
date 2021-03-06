property _Loader : run application "LoaderServer"

(*
	Trace the loading sequence for a chosen library.
*)

-- create a TraceLoader object
set loader to _Loader's makeLoader()
set LoaderTools to loader's loadLib("LoaderTools")
set traceLoader to LoaderTools's makeTraceLoader()

-- use TraceLoader to load a library
set libName to text returned of (display dialog "Enter library name (e.g. XTemplate):" default answer "")
traceLoader's loadLib(libName)

-- get trace result
return traceLoader's getResult()

(*
loadLib: XTemplate
	loadLib: XParser
		loadComponent: WhiteSpaceCleaner
		loadComponent: ElementParser
			loadComponent: TagAttributesParser
			loadComponent: WhiteSpaceCleaner
		loadLib: String
			loadLib: EveryItem
	loadComponent: ParserEventReceiver
		loadLib: Types
		loadComponent: TagAttributeParser
		loadComponent: TemplateAssembler
			loadComponent: TemplateConstructors
				loadComponent: Compiler
		loadComponent: ElementCollector
*)