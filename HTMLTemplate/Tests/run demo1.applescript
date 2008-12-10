---------------------------------------------------------------
-- TEMPLATE CONTROLLER

script _TemplateController
	on render_template(xo, {pageTitle, namesList})
		xo's con_title()'s setContent(pageTitle) -- set page title
		if (count namesList) > 0 then -- render list items
			xo's con_list()'s rep_item()'s repeatWith(namesList, {})
		else -- remove entire <ol> element
			xo's con_list()'s dontRender()
		end if
	end render_template
	
	on render_item(xo, val, {}) -- render an item in list
		xo's con_link()'s att_href()'s setContent(val & ".html") -- set href attribute of <a> element
		xo's con_link()'s setContent(val) -- set content of <a> element
	end render_item
end script

---------------------------------------------------------------
-- MAIN

set |template| to load script (alias "/Library/Scripts/ASLibraries/XTemplate/Tests/demo1Template.scpt") -- path to "demo1Template.scpt" file

|template|'s installController(_TemplateController)
--
set theTitle to "Hello"
set theList to {}
log |template|'s renderTemplate({theTitle, theList})
--
set theTitle to "Names"
set theList to {"Frank", "Bob", "Jo", "Sam"}
log |template|'s renderTemplate({theTitle, theList})
