property __name__ : "AT_Fixture"
property __version__ : ""
property __lv__ : 1

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------

on makeFixture(userFixtureName)
	script
		--RESTRICTED
		
		property __AT_fixtureName : userFixtureName
		
		-------
		--PUBLIC
		--user-overridable properties
		
		property checkFor : {} --{"considering/ignoring", "TIDs", "TIDs Preserved"}
		
		--user-overridable events
		
		on setUp()
		end setUp
		
		on |callhandler|(userParams)
			error "no callHandler handler was found for this test case." number 200
		end |callhandler|
		
		on cleanUp()
		end cleanUp
	end script
end makeFixture