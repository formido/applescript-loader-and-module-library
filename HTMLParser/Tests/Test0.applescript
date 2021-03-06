property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _HTMLParser : missing value

on __load__(loader)
	set _HTMLParser to loader's loadLib("HTMLParser")
end __load__

----------------------------------------------------------------------
-- TEST

on makeEventReceiver()
	script
		property class : "EventReceiver"
		-------
		on handleStartEndTag(tagName, attributesList)
			log ({"STARTEND", tagName, attributesList})
		end handleStartEndTag
		--
		on handleStartTag(tagName, attributesList)
			log ({"START", tagName, attributesList})
		end handleStartTag
		--
		on handleEndTag(tagName)
			log ({"END", tagName})
		end handleEndTag
		--
		on handleData(txt)
			log ({"DATA", txt})
		end handleData
		--
		on handleCharRef(txt)
			log ({"CHAR", txt})
		end handleCharRef
		--
		on handleEntityRef(txt)
			log ({"ENT", txt})
		end handleEntityRef
		--
		on handlePI(txt)
			log ({"PI", txt})
		end handlePI
		--
		on handleDecl(txt)
			log ({"DECL", txt})
		end handleDecl
		--
		on handleComment(txt)
			log ({"COMMENT", txt})
		end handleComment
	end script
end makeEventReceiver



property txt : "
<?xml version=\"1.0\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" 
	\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">
    <head> <!--< funny >--> <title pxt='con_pageTitle' class=red   id = \"a'
<1> \">Page Title</title><style type=\"text/css\" media=\"all\"><!--
body {padding:0; margin:0;}
.calendar {color:black; background-color:#9c9;}
--></style></head>
    <body><? HELLO<> ?>
		<!--<em>this is a comment</em>-->
		<br />
        <h1 pxt='con_h1Title'>Page Title</h1>
<p>Hello World! <img src = images/world.gif alt=\"the world\" /></p>
        <p pxt='con_quote'>&quot;Some Text&quot;</p>
		<div class=\"footer\">&copy; 2003 &#90</div>
		<p>&lt;&#91&#xfE01;</p>
    </body>
</html>"



__load__(_Loader's makeLoader())
set receiver to makeEventReceiver()
_HTMLParser's parseHTML(txt, receiver)
