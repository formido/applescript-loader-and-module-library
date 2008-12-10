property __name__ : "ASTest"
property __version__ : "0.6.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

property _AT_TestCase : missing value
property _AT_Fixture : missing value
property _AT_Listeners : missing value
property _AT_Decorators : missing value

on __load__(loader)
	set _AT_TestCase to loader's loadComponent("AT_TestCase")
	set _AT_Fixture to loader's loadComponent("AT_Fixture")
	set _AT_Listeners to loader's loadComponent("AT_Listeners")
	set _AT_Decorators to loader's loadComponent("AT_Decorators")
end __load__

-----------------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U
--mark constants|properties<B

property class : "ASTest"
property _AT_UNDEFINEDTESTCASESPROPERTY : "UndefinedTestCasesProperty"
property _AT_COMPILEDTESTCASES : "CompiledTestCases"

property _AT_isInitialised : false
property _AT_oldTID : missing value
property _AT_targetScript : missing value
property _AT_userDecorators : {}
property _AT_resultListener : missing value

-------------------------------------------------
--mark -
--mark miscellaneous commands<B

on _AT_initTestCasesProperty()
	-- initialisation is carried out as a side-effect to the first makeFixture call made by user's unit test script
	--initialise testCases property
	if my testCases is _AT_UNDEFINEDTESTCASESPROPERTY then error "Compilation error: testCases property is undefined." number 200 -- user forgot to include testCases property in their script
	set my testCases to {class:_AT_COMPILEDTESTCASES, currentFixture:missing value, testCaseList:{}}
	set _AT_isInitialised to true
end _AT_initTestCasesProperty

on _AT_isScript(obj)
	return ((count of ({obj}'s scripts)) is 1)
end _AT_isScript

-----------------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U
--mark properties<B

property suiteName : "Untitled" -- user should override this property
property testCases : _AT_UNDEFINEDTESTCASESPROPERTY -- user must override this property [used to store compiled test cases in original context; would be better to store them out of sight here, but AS is stupid and will bloat saved files]

-------------------------------------------------
--mark -
--mark test sequence<B

on AT_runTests(targetScript, resultListener, userDecorators)
	set _AT_oldTID to AppleScript's text item delimiters
	set _AT_resultListener to resultListener
	try
		if my testCases's class is not _AT_COMPILEDTESTCASES then error "Couldn't get test cases." number -1728
		set _AT_targetScript to targetScript
		set _AT_decoratorBuilder to _AT_Decorators's makeDecoratorBuilder(userDecorators)
		_AT_resultListener's startSuite(me)
		try
			repeat with aTestCase in my testCases's testCaseList
				aTestCase's AT_run(_AT_targetScript, _AT_resultListener, _AT_decoratorBuilder)
			end repeat
			_AT_resultListener's stopSuite(me)
		on error eMsg number eNum
			try
				_AT_resultListener's stopSuite(me)
			end try
			error eMsg number eNum
		end try
		set AppleScript's text item delimiters to _AT_oldTID
		return
	on error eMsg number eNum
		set AppleScript's text item delimiters to _AT_oldTID
		error "An unexpected error occurred while running the test cases: " & eMsg number eNum
	end try
end AT_runTests

-------------------------------------------------
--mark -
--mark constructors<B

on makeFixture(userFixture) -- auto-registers the user's Fixture object, then returns new Fixture base object
	if not _AT_isInitialised then _AT_initTestCasesProperty()
	set my testCases's currentFixture to userFixture
	return _AT_Fixture's makeFixture(userFixture's name)
end makeFixture

on makeTestCase(userTestCase) -- auto-registers user's TestCase object, then returns new TestCase base object 
	try
		if my testCases's class is not _AT_COMPILEDTESTCASES then error "fixture hasn't been defined yet." number 200
		set my testCases's testCaseList's end to userTestCase
		return _AT_TestCase's makeTestCase(my testCases's currentFixture, userTestCase's name)
	on error eMsg number eNum
		error "Can't makeTestCase: " & eMsg number eNum
	end try
end makeTestCase

on makeDecorator()
	return _AT_Decorators's makeDecorator()
end makeDecorator

on makeListener()
	return _AT_Listeners's makeListener()
end makeListener

on makeDefaultListener()
	return _AT_Listeners's makeDefaultListener()
end makeDefaultListener

-------------------------------------------------
--mark -
--mark accessors<B	

on addTestDecorator(testDecorator)
	try
		if not _AT_isScript(testDecorator) then error "testDecorator parameter isn't a script object." number -1704
		if testDecorator's name is missing value then error "test decorator's name property isn't defined." number -1728
		set _AT_userDecorators's end to testDecorator
		return
	on error eMsg number eNum
		error "Can't addTestDecorator: " & eMsg number eNum
	end try
end addTestDecorator

on setResultListener(resultListener)
	if not _AT_isScript(resultListener) then error "Can't setResultListener: resultListener parameter isn't a script object." number -1704
	set _AT_resultListener to resultListener
	return
end setResultListener

-------------------------------------------------
--mark -
--mark main commands<B	

on countTests()
	return count my testCases's testCaseList
end countTests

on listTests()
	set resultList to {}
	repeat with aTestCase in my testCases's testCaseList
		set resultList's end to aTestCase's AT_name()
	end repeat
	return resultList
end listTests

on targetScript()
	return _AT_targetScript
end targetScript

on runTests(targetScript)
	try
		if not _AT_isScript(targetScript) then error "Can't runTests: targetScript parameter isn't a script object." number -1704
		if _AT_resultListener is missing value then
			set resultListener to _AT_Listeners's makeDefaultListener() -- use default listener if user hasn't specified their own
		else
			set resultListener to _AT_resultListener
			set _AT_resultListener to missing value --kludgy way to avoid file bloat when saving test script after running tests
		end if
		set userDecorators to _AT_userDecorators
		set _AT_userDecorators to {} --kludgy way to avoid file bloat when saving test script after running tests
		copy me to meCopy --kludgy way to avoid file bloat when saving test script after running tests
		meCopy's AT_runTests(targetScript, resultListener, userDecorators)
		return resultListener's getResult()
	on error eMsg number eNum
		error "ASTest couldn't complete tests for \"" & (my suiteName) & "\": " & eMsg number eNum
	end try
end runTests