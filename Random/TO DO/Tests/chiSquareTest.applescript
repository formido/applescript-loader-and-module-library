property _Loader : run application "LoaderServer"

----------------------------------------------------------------------
-- DEPENDENCIES

property _List : missing value
property _Random : missing value

on __load__(loader)
	set _List to loader's loadLib("List")
	set _Random to loader's loadLib("Random")
end __load__

----------------------------------------------------------------------
-- PUBLIC

on chiSquareTest(numOutcomes, testSize, numTests)
	(* this returns a list numTests long, with each item a chiSquare result that test *)
	set randGen to _Random's makeIntegerGenerator(1, numOutcomes)
	script TObj
		property theList : {}
		property chiSquare : _List's makeList(numTests, 0)
	end script
	repeat with j from 1 to numTests
		-- each entry in the following list represents a possible number the script will count each time it is hit:
		set TObj's theList to _List's makeList(numOutcomes, 0)
		-- this loop calls for many random numbers and enters a hit at the item in theList that the random call returns
		repeat with i from 1 to numOutcomes * testSize
			set k to randGen's rand()
			set item k of TObj's theList to (item k of TObj's theList) + 1
		end repeat
		-- this calculates chiSquare for the test just run
		repeat with i from 1 to numOutcomes
			set k to item i of TObj's theList
			set chiTemp to (k - testSize) ^ 2 / testSize
			set item j of TObj's chiSquare to (item j of TObj's chiSquare) + chiTemp
		end repeat
	end repeat
	return TObj's chiSquare
end chiSquareTest

-- TEST

__load__(_Loader's makeLoader())
chiSquareTest(100, 100, 10)