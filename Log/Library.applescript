property __name__ : "Log"
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

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

on makeLog(fileSpec)
	script
		property class : "Log"
		
		-- PRIVATE
		
		property _fileSpec : fileSpec as file specification
		property _fileRef : missing value
		property _isOpen : false
		
		property _statusBreak : "*******"
		property _majorBreak : "============================================================" & return
		property _minorBreak : "------------------------------------------------------------" & return
		property _warningBreak : "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-" & return
		property _errorBreak : "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+" & return
		property _warningString : "WARNING:  "
		property _errorString : "ERROR:  "
		
		on _write(msg)
			try
				write msg to _fileRef
				return
			on error eMsg number eNum
				if not _isOpen then set {eMsg, eNum} to {"file is closed.", 898}
				error "Couldn't write to log " & _fileSpec & ": " & eMsg number eNum
			end try
		end _write
		
		on _logStatus(msg)
			_write(_statusBreak & space & msg & space & _statusBreak & return)
		end _logStatus
		
		on _timeStamp()
			tell (current date) to return time string & ", " & date string
		end _timeStamp
		
		-------
		-- PUBLIC
		
		on isOpen()
			return _isOpen
		end isOpen
		
		on openLog()
			try
				if not _isOpen then
					open for access _fileSpec with write permission returning _fileRef
					write "" to _fileRef starting at ((get eof of _fileRef) + 1)
					set _isOpen to true
					_logStatus("OPENED " & _timeStamp())
				end if
			on error eMsg number eNum
				error "Can't openLog: " & eMsg number eNum
			end try
			return
		end openLog
		
		on closeLog()
			try
				if _isOpen then
					_logStatus("CLOSED " & _timeStamp())
					close access _fileRef
					set _isOpen to false
				end if
				return
			on error eMsg number eNum
				error "Can't closeLog: " & eMsg number eNum
			end try
		end closeLog
		
		on clearLog()
			try
				if not _isOpen then error "file is closed." number 898
				set eof of _fileRef to 0
				_logStatus("CLEARED " & _timeStamp())
				return
			on error eMsg number eNum
				error "Can't clearLog: " & eMsg number eNum
			end try
		end clearLog
		
		--
		
		on logHeading(msg)
			_write(_majorBreak & "== " & msg & return & _majorBreak)
		end logHeading
		
		on logSubHeading(msg)
			_write(_minorBreak & "-- " & msg & return & _minorBreak)
		end logSubHeading
		
		--
		
		on logMsg(msg)
			_write(msg & return)
		end logMsg
		
		on logBreak()
			_write("..." & return)
		end logBreak
		
		on logTime()
			_write((current date)'s time string & return)
		end logTime
		
		--
		
		on logWarning(msg)
			_write(_warningBreak & _warningString & msg & return & _warningBreak)
		end logWarning
		
		on logError(eMsg, eNum)
			_write(_errorBreak & _errorString & eMsg & " [" & eNum & "]" & return & _errorBreak)
		end logError
		
	end script
end makeLog