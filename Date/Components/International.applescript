property __name__ : "International"
property __version__ : ""
property __lv__ : 1.0

(* provides multiple language support for Date library *)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

(* NOTES
- loads languages at compile-time for speed
- English is default language, and is supplied as string
- all other languages should be specified in ../Data/International.txt table as UTF-16
- when adding additional languages to International.txt table:
	- list one language per paragraph
	- use tab as column separator and "|" as item separator
	- order: language name[TAB]short weekdays[TAB]long weekdays[TAB]short months[TAB]long Months
	- language name should use characters [A-Za-z] only for compatibility
	- recompile this script after making changes to International.txt (adjust _langFile path as necessary)
*)

property _langFile : "/Library/Scripts/ASLibraries/Date/Data/International.txt" as POSIX file

property _english : "English" & tab & �
	"Mon|Tue|Wed|Thu|Fri|Sat|Sun" & tab & �
	"Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday" & tab & �
	"Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec" & tab & �
	"January|February|March|April|May|June|July|August|September|October|November|December"

on _parseDefinition(txt)
	set oldTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to tab
	set {langName, b, c, d, e} to text items of txt
	set AppleScript's text item delimiters to "|"
	script lang
		property name : langName
		property ntxt : missing value -- in date-to-text conversions, concat strings onto this value to ensure correct class
		property shortWeekday : b's text items
		property longWeekday : c's text items
		property shortMonth : d's text items
		property longMonth : e's text items
		property am : "am"
		property pm : "pm"
		property |AM| : "AM"
		property |PM| : "PM"
	end script
	set AppleScript's text item delimiters to oldTIDs
	if txt's class is string then
		set lang's ntxt to ""
	else
		set lang's ntxt to "" as Unicode text
	end if
	return lang
end _parseDefinition

on _loadLangs()
	set lst to {_parseDefinition(_english)}
	repeat with txtRef in paragraphs of (read _langFile as Unicode text)
		set lst's end to _parseDefinition(txtRef's contents)
	end repeat
	return lst
end _loadLangs

-------

script _intl
	property lst : _loadLangs()
end script

on _findLang(theLang)
	repeat with eachPara in _langString's paragraphs
		if eachPara's first text item is theLang then return eachPara
	end repeat
	error "Language not found: " & theLang number -1728
end _findLang

----------------------------------------------------------------------
-- PUBLIC

on getLanguage(languageName)
	ignoring case
		repeat with lang in _intl's lst
			if lang's name is languageName then return lang's contents
		end repeat
	end ignoring
	error "Language not found: " & languageName number 200
end getLanguage

on listLanguages()
	set lst to {}
	repeat with lang in _intl's lst
		set lst's end to lang's name
	end repeat
	return lst
end listLanguages


--TEST

log _parseDefinition(_english)'s {name, ntxt's class, shortWeekday, longWeekday, shortMonth, longMonth}
log
log listLanguages()
log
log getLanguage("french")'s {name, ntxt's class, shortWeekday, longWeekday, shortMonth, longMonth}
getLanguage("sponish") -- should error