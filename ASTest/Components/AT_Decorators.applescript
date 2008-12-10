property __name__ : "AT_Decorators"
property __version__ : ""
property __lv__ : 1

(*	Test Decorators

Notes:

	- decorators are added to a TestCase during AT_run
	- AT_run then calls topmost decorator object's callTestCase method
	- each decorator delegates callTestCase to next in stack; additional decorator-specific code may be included before and/or after the 'continue callTestCase()' statement (e.g. the considering/ignoring decorator calls callTestCase multiple times to execute test case under different conditions)
	- once callTestCase message reaches bottom of stack, the TestCase's AT_callTestCase is called to perform the main test cycle (setUp, callRun and cleanUp)
	- callRun message is sent to the decorator stack, allowing decorators to extend it as necessary (e.g. the TIDs decorator extends this to check TIDs are being looked after)
	- once callRun message reaches bottom of stack, TestCase's AT_callRun() is called, which in turn calls user's run handler
	
This arrangement gives better granularity than simply wrapping TestCase in a standard decorator object which would only extend the AT_runTests, as overriding callRun lets you avoid potential contamination from user's setUp and cleanUp code.

Example:

	script DecoratorName
		property parent : makeDecorator(me)
		
		on callRun(testCase)
			[...]
			continue callRun(testCase)
			[...]
		end callRun
	end script
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

--mark -
----------------------------------------------------------------------
-- mark PRIVATE<B<U
--mark properties<B

property _defaultDecorators : {} -- built-in decorators stored here

on _makeDefaultDecorator(decoratorObj) -- called at compile-time by default decorators
	set _defaultDecorators's end to decoratorObj -- auto-register decorator
	set decoratorBase to makeDecorator()
	set decoratorBase's name to decoratorObj's name
	return decoratorBase
end _makeDefaultDecorator

--mark -
----------------------------------------------------------------------
-- mark PUBLIC<B<U
--mark constructors<B

on makeDecoratorBuilder(userDecorators)
	script
		script _EndDecorator
			property class : "EndDecorator"
			property _tempTestCaseResultStore : missing value
			--
			on AT_setTestCaseResult(testCaseResult) -- kludgy crap
				set _tempTestCaseResultStore to testCaseResult
				return
			end AT_setTestCaseResult
			--
			on callTestCase(testCase)
				set testCaseResult to _tempTestCaseResultStore
				set _tempTestCaseResultStore to missing value
				testCase's AT_callTestCase(testCase, testCaseResult)
			end callTestCase
			--
			on callRun(testCase)
				testCase's AT_callRun()
			end callRun
		end script
		
		property _decoratorsList : _defaultDecorators & userDecorators
		
		on _getDecorator(decoratorName)
			considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
				repeat with decoratorRef in _decoratorsList
					if decoratorRef's name is decoratorName then return decoratorRef's contents
				end repeat
			end considering
			error "decorator \"" & nameRef & "\" doesn't exist." number -1728
		end _getDecorator
		--
		on makeDecoratorStack(checkList) -- chain user-specified decorators together
			try
				if checkList's class is not list then error "checkList wasn't a list." number 200
				copy _EndDecorator to decoratorStack
				repeat with nameRef in checkList's reverse
					copy _getDecorator(nameRef's contents)'s AT_addStack(decoratorStack) to decoratorStack
				end repeat
				return decoratorStack
			on error eMsg number eNum
				error "Can't add decorators: " & eMsg number eNum
			end try
		end makeDecoratorStack
	end script
end makeDecoratorBuilder

--

(* A TestDecorator subclass may extend callTestCase and/or callRun, eg:

				on callRun(TestCase)
					considering case
						continue callRun(TestCase)
					end considering
				end callRun
				
		Note: if you want to run a test multiple times, extend callTestCase (not callRun) so that setUp and cleanUp are executed each time.
*)

on makeDecorator() --decorator base; called by _makeDefaultDecorator and main library's makeDecorator
	script
		property name : missing value
		property class : "TestDecorator"
		
		-------
		--private
		
		property _AT_next : missing value
		
		on AT_addStack(theStack)
			set _AT_next to theStack
			return me
		end AT_addStack
		
		on AT_setTestCaseResult(testCaseResult)
			_AT_next's AT_setTestCaseResult(testCaseResult)
		end AT_setTestCaseResult
		
		-------
		--public
		
		on callTestCase(testCase) --callTestCase() is called to execute test case (setUp, run, cleanUp)
			_AT_next's callTestCase(testCase)
		end callTestCase
		
		on callRun(testCase) --callRun() extends 'run' call
			_AT_next's callRun(testCase)
		end callRun
	end script
end makeDecorator

--mark -
----------------------------------------------------------------------
-- mark PRIVATE<B<U
--mark default decorators<B
-- add extra checking behaviour to test cases

script |considering/ignoring|
	property name : "considering/ignoring"
	property parent : _makeDefaultDecorator(me)
	on callTestCase(testCase)
		--AppleScript's default
		considering diacriticals, expansion, hyphens, punctuation and white space but ignoring case
			continue callTestCase(testCase)
		end considering
		--consider all
		considering case, diacriticals, expansion, hyphens, punctuation and white space
			continue callTestCase(testCase)
		end considering
		--ignore all
		ignoring case, diacriticals, expansion, hyphens, punctuation and white space
			continue callTestCase(testCase)
		end ignoring
	end callTestCase
end script

script |TIDs+|
	property name : "TIDs+"
	property parent : _makeDefaultDecorator(me)
	property _oldTIDs : missing value
	property _testTIDs : return & tab & "[%[TIDs CHECK STRING]%]" & tab & return
	
	on callRun(testCase)
		set _oldTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to _testTIDs
		try
			continue callRun(testCase)
		on error eMsg number eNum
			set AppleScript's text item delimiters to _oldTIDs
			error eMsg number eNum
		end try
		if AppleScript's text item delimiters is not _oldTIDs then
			testCase's AT_failTest("test case decorator", "TIDs weren't preserved.")
		end if
		set AppleScript's text item delimiters to _oldTIDs
	end callRun
end script

script |TIDs|
	property name : "TIDs"
	property parent : _makeDefaultDecorator(me)
	property _testTIDs : return & tab & "[%[TIDs CHECK STRING]%]" & tab & return
	
	on callRun(testCase)
		set oldTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to _testTIDs
		try
			continue callRun(testCase)
		on error eMsg number eNum
			set AppleScript's text item delimiters to oldTIDs
			error eMsg number eNum
		end try
		set AppleScript's text item delimiters to oldTIDs
	end callRun
end script
