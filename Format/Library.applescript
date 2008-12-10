property __name__ : "Format"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _FormatStringParser : missing value
property _EventReceivers : missing value

on __load__(loader)
	set _FormatStringParser to loader's loadLib("FormatStringParser")
	set _EventReceivers to loader's loadComponent("EventReceivers")
end __load__

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on makeFormatter(theFormat)
	try
		set receiver to _EventReceivers's makeCompiler(theFormat)
		_FormatStringParser's parseFormatString(theFormat, "%", receiver)
		return receiver's getResult()
	on error eMsg number eNum
		error "Can't makeFormatter: " & eMsg number eNum
	end try
end makeFormatter