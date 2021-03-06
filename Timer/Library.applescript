property __name__ : "Timer"
property __version__ : "0.1.0"
property __lv__ : 1.0

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PUBLIC

on makeTimer()
	try
		GetMilliSec -- test for GetMilliSec OSAX's presence
		script
			property class : "Timer"
			property _startTime : 0
			property _stopTime : 0
			
			on startTimer()
				set _startTime to GetMilliSec
				return me
			end startTimer
			
			on stopTimer()
				set _stopTime to GetMilliSec
				return me
			end stopTimer
			
			on |duration|()
				return (_stopTime - _startTime) / 1000
			end |duration|
			
			on units()
				return "sec"
			end units
		end script
	on error -- return alternative timer object if GetMilliSec isn't available
		script
			property class : "Timer"
			property _startTime : 0
			property _stopTime : 0
			
			on startTimer()
				set _startTime to current date
				return me
			end startTimer
			
			on stopTimer()
				set _stopTime to current date
				return me
			end stopTimer
			
			on |duration|()
				return (_stopTime - _startTime)
			end |duration|
			
			on units()
				return "sec"
			end units
		end script
	end try
end makeTimer