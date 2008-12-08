property _Loader : run application "LoaderServer"------------------------------------------------------------------------ DEPENDENCIESproperty _PListDOM : missing valueon __load__(loader)	set _PListDOM to loader's loadLib("PListDOM")end __load__----------------------------------------------------------------------__load__(_Loader's makeLoader())set txt to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>A</key>
	<string>foo</string>
	<key>B</key>
	<integer>0</integer>
	<key>C</key>
	<date>2003-02-01T05:43:21Z</date>
	<key>D</key>
	<array>
		<string>hello</string>
		<string>goodbye</string>
		<string>yesterday</string>
		<string>tomorrow</string>
	</array>
	<key>E</key>
	<dict>
		<key>x</key>
		<real>1.01E+15</real>
		<key>y</key>
		<real>20.01</real>
	</dict>
	<key>F</key>
	<true/>
	<key>foobar
&lt;&amp;&gt;©</key>
	<string>&lt;&amp;&gt;©</string>
</dict>
</plist>
"set obj to _PListDOM's parsePList(txt)log obj's allKeys()loglog obj's itemKey("A")'s classlog obj's itemKey("A")'s val()obj's itemKey("A")'s setVal("<bar>")log obj's itemKey("B")'s val()obj's itemKey("B")'s setVal("1")log obj's itemKey("C")'s val()obj's itemKey("C")'s setVal(date "Thursday, January 2, 2003 12:00:01 AM")log obj's itemKey("D")'s itemIndex(1)'s val()obj's itemKey("D")'s itemIndex(1)'s setVal("howdy!")log obj's itemKey("E")'s itemKey("x")'s val()obj's itemKey("E")'s itemKey("x")'s setVal(13)ignoring hyphens and punctuation -- test robustness	log obj's itemKey("E")'s itemKey("y") --'s setVal("-0.01")end ignoringlog obj's itemKey("F")'s val()obj's itemKey("F")'s setVal(0)log obj's itemKey("foobar
<&>©")'s val()obj's itemKey("foobar
<&>©")'s setVal("<&amp;")return _PListDOM's generatePList(obj)