property __name__ : "AT_Listeners"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

property _ConvertToString : missing value
property _Timer : missing value

on __load__(loader)
	set _ConvertToString to loader's loadLib("ConvertToString")
	set _Timer to loader's loadLib("Timer")
end __load__

----------------------------------------------------------------------
--mark -
-- PUBLIC

on makeListener() --implements listener interface; may be subclassed to create new listeners
	script
		--subclasses may override any of the following properties and/or handlers:
		
		property class : "Listener"
		
		--events
		
		on startSuite(TestSuite)
		end startSuite
		
		on stopSuite(TestSuite)
		end stopSuite
		
		on startTestCase(testCaseResult)
		end startTestCase
		
		on stopTestCase(testCaseResult)
		end stopTestCase
		
		--commands
		
		on getResult()
			return missing value
		end getResult
	end script
end makeListener

--

on makeDefaultListener()
	script
		property parent : makeListener()
		property class : "DefaultListener"
		
		-------
		--private
		property _CTS : a reference to _ConvertToString
		property _timerObj : _Timer's makeTimer()
		
		--
		
		property _total : 0
		
		property _failed : 0
		property _errored : 0
		property _summary : {}
		property _problems : {}
		
		property _result : missing value
		
		--
		
		property _titleDelim : "**********************************************************************"
		property _subDelim : "======================================================================"
		
		--
		
		on _concat(theList)
			set oldTID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to return
			try
				set resultString to theList as string
				set AppleScript's text item delimiters to oldTID
				return resultString
			on error eMsg number eNum
				set AppleScript's text item delimiters to oldTID
				error "Couldn't format DefaultListener's results: " & eMsg number eNum
			end try
		end _concat
		
		on _toString(theData)
			try
				if theData's class is list then -- hacking around the hack (otherwise a list of records will come back looking very weird); TO DO: this should really be recursive and in CoerceToString library, not here, but 'coerce to string' stuff stinks anyway so can't be bothered right now
					set dataString to "{"
					if theData's length > 0 then
						set dataString to dataString & _CTS's toString(theData's item 1)
						repeat with itemRef in rest of theData
							set dataString to return & dataString & _CTS's toString(itemRef's contents)
						end repeat
					end if
					set dataString to dataString & "}"
				else
					set dataString to _CTS's toString(theData)
				end if
			on error eMsg
				log eMsg
				set dataString to "[PARAMS UNAVAILABLE]"
			end try
			if (count of dataString) is greater than 256 then -- truncate for space
				set dataString to (dataString's text 1 thru 250) & "..." & dataString & (dataString's text -6 thru -1)
			end if
			return dataString
		end _toString
		
		--
		
		on _formatResult()
			set tally to (_total as string) & " tests were run in " & _timerObj's |duration|() & space & _timerObj's units() & ". "
			if (_failed is 0) and (_errored is 0) then
				set tally to tally & "All Passed."
			else if (_failed is not 0) and (_errored is not 0) then
				set tally to tally & _failed & " failed, " & _errored & " errored."
			else if (_failed is not 0) then
				set tally to tally & _failed & " failed."
			else
				set tally to tally & _errored & " errored."
			end if
			--
			if _problems is {} then
				set resultList to {_summary, _subDelim, tally, _subDelim}
			else
				set resultList to {_summary, _problems, _subDelim, tally, _subDelim}
			end if
			set _result to _concat(resultList)
			return
		end _formatResult
		
		--
		
		on _addToProblemsList(problemType, testCaseResult, reason, details)
			set theProblem to {_subDelim, "Testcase: " & testCaseResult's fixtureName & " - " & testCaseResult's testCaseName & " ... " & problemType, "Problem: " & reason}
			if details is not missing value then
				set theProblem's end to details
				if testCaseResult's paramsAreAvailable then set theProblem's end to "Parameters: " & _toString(testCaseResult's params)
			end if
			if testCaseResult's msg is not "" then set theProblem's end to "Message: " & testCaseResult's msg
			set _problems's end to theProblem
			return
		end _addToProblemsList
		
		--
		
		on _addFailMessage(testCaseResult)
			if testCaseResult's userFailed then
				set reason to "user failed test"
				set details to missing value
			else if testCaseResult's assertGaveWrongResult then
				set reason to testCaseResult's errorLocation & " gave wrong result"
				set details to "Expected result: " & _toString(testCaseResult's expected) & return & "Actual result: " & _toString(testCaseResult's actual)
			else if testCaseResult's assertFailedToRaiseError then
				set reason to testCaseResult's errorLocation & " failed to raise error"
				set details to "Expected error: " & testCaseResult's expected
			else
				set reason to testCaseResult's errorLocation & " failed" -- TO CHECK: why add "failed"?
				set details to missing value
			end if
			_addToProblemsList("FAIL", testCaseResult, reason, details)
		end _addFailMessage
		
		on _addErrorMessage(testCaseResult)
			set reason to testCaseResult's errorLocation & " raised unexpected error"
			set details to "Error: " & testCaseResult's actual's eMsg & " (" & testCaseResult's actual's eNum & ")"
			_addToProblemsList("ERROR", testCaseResult, reason, details)
		end _addErrorMessage
		
		-------
		--public
		
		on startSuite(TestSuite)
			set _summary to {_titleDelim, TestSuite's suiteName, _titleDelim}
			--set _problems to {}
			--set _result to missing value
			_timerObj's startTimer()
		end startSuite
		
		on stopSuite(TestSuite)
			_timerObj's stopTimer()
			_formatResult()
		end stopSuite
		
		on startTestCase(testCaseResult)
			set _total to _total + 1
			set _summary's end to testCaseResult's fixtureName & " - " & testCaseResult's testCaseName
		end startTestCase
		
		on stopTestCase(testCaseResult)
			if testCaseResult's failed then
				set _summary's last item to _summary's last item & " ... FAIL"
				set _failed to _failed + 1
				_addFailMessage(testCaseResult)
			else if testCaseResult's errored then
				set _summary's last item to _summary's last item & " ... ERROR"
				set _errored to _errored + 1
				_addErrorMessage(testCaseResult)
			else
				set _summary's last item to _summary's last item & " ... ok"
			end if
		end stopTestCase
		
		on getResult()
			return _result
		end getResult
	end script
end makeDefaultListener