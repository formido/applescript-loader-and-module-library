property __name__ : "AT_TestCase"
property __version__ : ""
property __lv__ : 1

-- TO DO: get rid of yucky convoluted code by instantiating TestCaseResult later

----------------------------------------------------------------------
-- DEPENDENCIES

property _AT_TestCaseResult : missing value

on __load__(loader)
	set _AT_TestCaseResult to loader's loadComponent("AT_TestCaseResult")
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _AT_TESTCASEFAILED : "_AT_TESTCASEFAILED" -- standard break-out-of-test error message

----------------------------------------------------------------------
-- PUBLIC

on makeTestCase(userFixture, userTestCaseName)
	script
		property class : "TestCase"
		
		-----------------------------------
		--PRIVATE/RESTRICTED
		
		property parent : userFixture
		property _AT_testCaseName : userTestCaseName
		property __AT_testCaseResult : _AT_TestCaseResult's makeTestCaseResult(userFixture's __AT_fixtureName, userTestCaseName)
		
		property _AT_targetScript : missing value
		
		property _AT_decoratorStack : missing value -- decorator object stack; events are sent through this before being passed to user's TestCase object, allowing extra checks, etc. to be inserted
		
		--used by asserts
		
		on _AT_compare(val1, val2) -- performs more precise check than AS 'equals' operator alone
			considering case, diacriticals, expansion, hyphens, punctuation and white space
				return (val1's class is val2's class) and (val1 is val2) -- [class check ensures that (e.g.) 1.0=1 will fail]
			end considering
		end _AT_compare
		
		-------
		--called from EndDecorator
		
		on AT_callTestCase(testCase, testCaseResult)
			copy testCase to testCaseCopy -- always run test using new instance of TestCase to avoid possible cross-contamination
			set testCaseCopy's __AT_testCaseResult to testCaseResult -- TO FIX: untidy
			try
				testCaseCopy's setUp()
			on error eMsg number eNum --eMsg/eNum are reused in main try block too
				testCaseResult's AT_testRaisedUnexpectedError("setUp", eMsg, eNum)
			end try
			--
			try
				set oldTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to {""}
				try
					_AT_decoratorStack's callRun(testCaseCopy)
				on error eMsg number eNum --eMsg/eNum are reused in main try block too
					set AppleScript's text item delimiters to oldTID
					if eMsg is not _AT_TESTCASEFAILED then testCaseResult's AT_testRaisedUnexpectedError("test", eMsg, eNum) -- (failure occurred in test case's 'run' handler; either the handler under test has failed, or there's a bug in the test code itself)
				end try
				set AppleScript's text item delimiters to oldTID
				--
				try
					testCaseCopy's cleanUp()
				on error eMsg number eNum --eMsg/eNum are reused in main try block too
					testCaseResult's AT_testRaisedUnexpectedError("cleanUp", eMsg, eNum)
				end try
			on error -- main trap; attempt cleanup and record if unexpected test error
				try
					testCaseCopy's cleanUp()
				end try
				if eNum is -128 then error eMsg number eNum -- user cancelled (re-throw so everything comes to a dead halt)
			end try
		end AT_callTestCase
		
		on AT_callRun()
			run
		end AT_callRun
		
		-------
		-- called from main library
		
		on AT_name()
			return my __AT_fixtureName & ": " & _AT_testCaseName
		end AT_name
		
		on AT_run(targetScript, resultListener, decoratorBuilder)
			try
				if _AT_decoratorStack is missing value then
					set _AT_decoratorStack to decoratorBuilder's makeDecoratorStack(my checkFor)
				end if
				set _AT_targetScript to targetScript
				copy __AT_testCaseResult to testCaseResultCopy
				resultListener's startTestCase(testCaseResultCopy) --allow listener to log test name, etc.
				_AT_decoratorStack's AT_setTestCaseResult(testCaseResultCopy) -- send result object on ahead to avoid cluttering callTestCase params
				_AT_decoratorStack's callTestCase(me) -- extend and call AT_callTestCase
				resultListener's stopTestCase(testCaseResultCopy) --allow listener to examine test results
				return --TO DO: user cancels must be reported to listener
			on error eMsg number eNum
				if eMsg is not _AT_TESTCASEFAILED then set eMsg to "Can't run TestCase \"" & AT_name() & "\": " & eMsg
				error eMsg number eNum
			end try
		end AT_run
		
		-----------------------------------
		--PUBLIC
		--general
		
		on targetScript()
			return _AT_targetScript
		end targetScript
		
		on failTest(userMsg) -- may be called by user
			__AT_testCaseResult's AT_failTest("user", userMsg)
		end failTest
		
		on AT_failTest(eLoc, userMsg) -- may be called by external agents such as decorators
			__AT_testCaseResult's AT_failTest(eLoc, userMsg)
		end AT_failTest
		
		--asserts	
		
		on assertTrue(actualResult, userMsg)
			if actualResult is not true then
				__AT_testCaseResult's AT_assertGaveWrongResult("assertTrue", true, actualResult, userMsg)
			end if
		end assertTrue
		
		on assertFalse(actualResult)
			if actualResult is not false then
				__AT_testCaseResult's AT_assertGaveWrongResult("assertFalse", false, actualResult, userMsg)
			end if
		end assertFalse
		
		on assertEqual(actualResult, expectedResult, userMsg)
			if not _AT_compare(actualResult, expectedResult) then
				__AT_testCaseResult's AT_assertGaveWrongResult("assertEqual", expectedResult, actualResult, userMsg)
			end if
		end assertEqual
		
		on assertNotEqual(actualResult, expectedResult, userMsg)
			if _AT_compare(actualResult, expectedResult) then
				__AT_testCaseResult's AT_assertGaveWrongResult("assertNotEqual", expectedResult, actualResult, userMsg)
			end if
		end assertNotEqual
		
		on assertError(userParams, expectedErrorNumber, userMsg)
			if expectedErrorNumber's class is not integer then error "Can't assertError: expectedErrorNumber wasn't an integer." number 200
			try
				|callhandler|(userParams)
			on error eMsg number eNumActual
				if (eMsg is not _AT_TESTCASEFAILED) and (_AT_compare(eNumActual, expectedErrorNumber)) then -- test passed
					return
				else -- unexpected error
					__AT_testCaseResult's AT_setParams(userParams)
					error eMsg number eNumActual
				end if
			end try
			--if we get this far, the handler being tested was asleep on the job
			__AT_testCaseResult's AT_setParams(userParams)
			__AT_testCaseResult's AT_assertFailedToRaiseError("assertError", userParams, expectedErrorNumber, userMsg)
		end assertError
		
		--events
		
		on run -- must be overridden in user's TestCase
			error "No test is defined." number 200
		end run
		
	end script
end makeTestCase