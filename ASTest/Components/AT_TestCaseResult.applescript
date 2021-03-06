property __name__ : "AT_TestCaseResult"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _AT_TESTCASEFAILED : "_AT_TESTCASEFAILED" -- standard break-out-of-test error message

----------------------------------------------------------------------
-- PUBLIC

on makeTestCaseResult(theFixtureName, theTestCaseName)
	(*	
		- records results for a _single_ test
		- automatically instantiate new TestCaseResult object for each test case created
		- TestCaseResult's properties may be examined [but NOT modified] by listeners at start and end of test
	*)
	script
		property class : "TestCaseResult"
		
		-------
		--PUBLIC
		
		property fixtureName : theFixtureName
		property testCaseName : theTestCaseName
		
		--basic flags
		
		property failed : false
		property errored : false
		
		--details
		
		property errorLocation : missing value --name of guilty assert/event handler
		
		property userFailed : false
		property assertGaveWrongResult : false
		property assertFailedToRaiseError : false
		
		property expected : missing value -- expectedResult, expectedErrorNum
		property actual : missing value -- assertGaveWrongResult, unexpected error
		
		property paramsAreAvailable : false
		property params : missing value -- if sandboxed
		
		property msg : "" -- additional message (e.g. from user), if any
		
		-------
		--RESTRICTED
		
		on AT_setParams(userParams) -- called by sandboxer
			set paramsAreAvailable to true
			set params to userParams
			return
		end AT_setParams
		
		on AT_failTest(eLocation, userMsg) -- called indirectly by decorators and other external agents
			set errorLocation to eLocation
			set msg to userMsg
			--
			set failed to true
			error _AT_TESTCASEFAILED
		end AT_failTest
		
		on AT_userFailed(userMsg)
			set msg to userMsg
			--
			set failed to true
			set userFailed to true
			error _AT_TESTCASEFAILED
		end AT_userFailed
		
		on AT_assertGaveWrongResult(assrType, expectedResult, actualResult, userMsg)
			set errorLocation to assrType
			set expected to expectedResult
			set actual to actualResult
			set msg to userMsg
			--
			set failed to true
			set assertGaveWrongResult to true
			error _AT_TESTCASEFAILED
		end AT_assertGaveWrongResult
		
		on AT_assertFailedToRaiseError(assrType, userParams, expectedErrorNumber, userMsg)
			set errorLocation to assrType
			set params to userParams
			set expected to expectedErrorNumber
			set msg to userMsg
			--
			set failed to true
			set assertFailedToRaiseError to true
			error _AT_TESTCASEFAILED
		end AT_assertFailedToRaiseError
		
		on AT_testRaisedUnexpectedError(eLocation, eMsg, eNum)
			set errorLocation to eLocation
			set actual to {class:"error", eMsg:eMsg, eNum:eNum}
			--
			set errored to true
			error _AT_TESTCASEFAILED
		end AT_testRaisedUnexpectedError
		
	end script
end makeTestCaseResult