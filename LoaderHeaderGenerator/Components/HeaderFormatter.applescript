property __name__ : "HeaderFormatter"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

script _FormatterModule
	-- private
	on _escapeString(str)
		if str contains "\"" or str contains "\\" then
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "\\"
			set lst to str's text items
			set AppleScript's text item delimiters to "\\\\"
			set str to lst as string
			set AppleScript's text item delimiters to "\""
			set lst to str's text items
			set AppleScript's text item delimiters to "\\\""
			set str to lst as string
			set AppleScript's text item delimiters to oldTID
		end if
		return str
	end _escapeString
	
	on _makeLoadStrings(moduleNames, loadCmd)
		set propStr to ""
		set loadStr to ""
		set flushStr to ""
		repeat with nameRef in moduleNames
			set propStr to propStr & "property _" & nameRef & " : missing value" & return
			set loadStr to loadStr & tab & tab & "set _" & nameRef & " to loader's " & loadCmd & "(\"" & nameRef & "\")" & return
			set flushStr to flushStr & tab & "set _" & nameRef & " to missing value" & return
		end repeat
		return {propStr, loadStr, flushStr}
	end _makeLoadStrings
	
	-- public
	
	on bindLoader()
		return "property _Loader : run application \"LoaderServer\"" & return
	end bindLoader
	
	--
	
	on lineRule()
		return return & "----------------------------------------------------------------------" & return
	end lineRule
	
	on blockTitle()
		return "-- DEPENDENCIES" & return & return
	end blockTitle
	
	--
	
	on nameProperty(modName)
		return "property __name__ : \"" & modName & "\"" & return
	end nameProperty
	
	on versionProperty(modVersion)
		return "property __version__ : \"" & modVersion & "\"" & return
	end versionProperty
	
	on ldrProperty()
		return "property __lv__ : 1" & return
	end ldrProperty
	
	--
	
	on componentsFolder(pathToFolder)
		return tab & tab & "loader's setComponentsFolder(alias \"" & _escapeString(pathToFolder as string) & "\")" & return
	end componentsFolder
	
	on loadLibs(libNames)
		return _makeLoadStrings(libNames, "loadLib")
	end loadLibs
	
	on loadComponents(scriptNames)
		return _makeLoadStrings(scriptNames, "loadComponent")
	end loadComponents
	
	on loadHandler(contentStr)
		return "on __load__(loader)" & return & contentStr & "end __load__" & return
	end loadHandler
	
	on flushHandler(contentStr)
		return "on __flush__()" & return & contentStr & "end __flush__" & return
	end flushHandler
end script

-------

on _makeFormatterBase()
	script
		-- public
		property modName : "" -- "Date"
		property modVersion : "" -- "0.1.0"
		
		property libNames : {} -- {"Date", "String", "UnicodeIO"}
		property componentNames : {} -- {"Foo", "Bar"}
		
		property componentsFolderPath : missing value -- "Macintosh HD:Users:has:foo\\bar:"
		
		-- private
		
		property _Fmtr : _FormatterModule
		
		on _loaderBlock(includeFlush, footerTxt)
			tell _Fmtr
				set txt to lineRule() & blockTitle()
				set {libProps, loadLibs, flushLibs} to loadLibs(libNames)
				set {suppProps, loadSupp, flushSupp} to loadComponents(componentNames)
				if suppProps is not "" then set suppProps to return & suppProps
				if libProps & suppProps is not "" then
					set txt to txt & libProps & suppProps & return
				end if
				set loadMods to loadLibs & loadSupp
				if componentsFolderPath is not missing value then
					set loadMods to componentsFolder(componentsFolderPath) & loadMods
				end if
				set txt to txt & loadHandler(loadMods)
				if includeFlush then set txt to txt & return & flushHandler(flushLibs & flushSupp)
				return txt & lineRule() & footerTxt
			end tell
		end _loaderBlock
	end script
end _makeFormatterBase

----------------------------------------------------------------------
-- PUBLIC

on makeMainHeaderFormatter()
	script
		property class : "MainHeaderFormatter"
		property parent : _makeFormatterBase()
		--
		on renderHeader()
			--return my _Fmtr's bindLoader() & _loaderBlock(true, return & "__load__(_Loader's makeLoader())" & return)
			return my _Fmtr's bindLoader() & _loaderBlock(false, return & "__load__(_Loader's makeLoader())" & return)
		end renderHeader
	end script
end makeMainHeaderFormatter

on makeModuleHeaderFormatter()
	script
		property class : "ModuleHeaderFormatter"
		property parent : _makeFormatterBase()
		--
		on renderHeader()
			set headerTxt to my _Fmtr's nameProperty(my modName)
			set headerTxt to headerTxt & my _Fmtr's versionProperty(my modVersion)
			set headerTxt to headerTxt & my _Fmtr's ldrProperty()
			return headerTxt & _loaderBlock(false, "")
		end renderHeader
	end script
end makeModuleHeaderFormatter

-------
-- TEST

(*
set f to makeModuleHeaderFormatter()
set f to makeMainHeaderFormatter()
set f's modName to "Hello"
set f's modVersion to "0.0.1"
set f's libNames to {"Date", "String", "UnicodeIO"}
set f's componentNames to {"Foo", "Bar"}
set f's componentsFolderPath to "Macintosh HD:Users:has:foo\\bar:"

f's renderHeader()
*)