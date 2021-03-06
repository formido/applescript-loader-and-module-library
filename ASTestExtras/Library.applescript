property __name__ : "ASTestExtras"
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

property _ASTest : missing value

on __load__(loader)
	set _ASTest to loader's loadLib("ASTest")
end __load__

----------------------------------------------------------------------
-- PUBLIC

on makeSimpleListener()
	try
		script
			property parent : _ASTest's makeListenerBase()
			property class : "SimpleListener"
			
			property _total : 0
			property _passed : 0
			property _failed : 0
			property _errored : 0
			property _startTime : 0
			property _result : missing value
			
			on startSuite(TestSuite)
				set _result to missing value
				set _startTime to current date
			end startSuite
			
			on stopSuite(TestSuite)
				set _result to {passed:(_total - _failed - _errored), failed:_failed, errored:_errored, total:_total, timeElapsed:(current date) - _startTime}
			end stopSuite
			
			on startTestCase(testCaseResult)
				set _total to _total + 1
			end startTestCase
			
			on stopTestCase(testCaseResult)
				if testCaseResult's failed then
					set _failed to _failed + 1
				else if testCaseResult's errored then
					set _errored to _errored + 1
				else --passed
					set _passed to _passed + 1
				end if
			end stopTestCase
			
			on getResult()
				return _result
			end getResult
		end script
	on error eMsg number eNum
		error "Can't makeSimpleListener: " & eMsg number eNum
	end try
end makeSimpleListener

--

on makeListenerCollection(listenersList)
	try
		if listenersList's class is not list then error "listenersList parameters isn't a list." number -1704
		script
			property class : "ListenerCollection"
			property parent : _ASTest's makeListenerBase()
			property _listeners : listenersList
			
			on startSuite(TestSuite)
				repeat with listenerRef in _listeners
					listenerRef's startSuite(TestSuite)
				end repeat
			end startSuite
			
			on stopSuite(TestSuite)
				repeat with listenerRef in _listeners
					listenerRef's stopSuite(TestSuite)
				end repeat
			end stopSuite
			
			on startTestCase(testCaseResult)
				repeat with listenerRef in _listeners
					listenerRef's startTestCase(testCaseResult)
				end repeat
			end startTestCase
			
			on stopTestCase(testCaseResult)
				repeat with listenerRef in _listeners
					listenerRef's stopTestCase(testCaseResult)
				end repeat
			end stopTestCase
			
			on getResult()
				return _listeners
			end getResult
		end script
	on error eMsg number eNum
		error "Can't makeListenerCollection: " & eMsg number eNum
	end try
end makeListenerCollection