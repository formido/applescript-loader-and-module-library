(*property _Loader : run application "LoaderServer"
property parent : _Loader's makeLoader()'s loadLib("ASTest")
property testCases : missing value
property suiteName : "RomanTest"

property _String : _Loader's makeLoader()'s loadLib("String")
--mark -
-------------------------------------------------
--mark MAIN<B

runTests(_Loader's makeLoader()'s loadLib("Roman"))

--mark -
-------------------------------------------------
--mark THE TESTS<B


script |known values|
	property parent : makeFixtureBase(me)
	
	--
	
	property knownValues : {Â
		{1, "I"}, Â
		{2, "II"}, Â
		{3, "III"}, Â
		{4, "IV"}, Â
		{5, "V"}, Â
		{6, "VI"}, Â
		{7, "VII"}, Â
		{8, "VIII"}, Â
		{9, "IX"}, Â
		{10, "X"}, Â
		{50, "L"}, Â
		{100, "C"}, Â
		{500, "D"}, Â
		{1000, "M"}, Â
		{31, "XXXI"}, Â
		{148, "CXLVIII"}, Â
		{294, "CCXCIV"}, Â
		{312, "CCCXII"}, Â
		{421, "CDXXI"}, Â
		{528, "DXXVIII"}, Â
		{621, "DCXXI"}, Â
		{782, "DCCLXXXII"}, Â
		{870, "DCCCLXX"}, Â
		{941, "CMXLI"}, Â
		{1043, "MXLIII"}, Â
		{1110, "MCX"}, Â
		{1226, "MCCXXVI"}, Â
		{1301, "MCCCI"}, Â
		{1485, "MCDLXXXV"}, Â
		{1509, "MDIX"}, Â
		{1607, "MDCVII"}, Â
		{1754, "MDCCLIV"}, Â
		{1832, "MDCCCXXXII"}, Â
		{1993, "MCMXCIII"}, Â
		{2074, "MMLXXIV"}, Â
		{2152, "MMCLII"}, Â
		{2212, "MMCCXII"}, Â
		{2343, "MMCCCXLIII"}, Â
		{2499, "MMCDXCIX"}, Â
		{2574, "MMDLXXIV"}, Â
		{2646, "MMDCXLVI"}, Â
		{2723, "MMDCCXXIII"}, Â
		{2892, "MMDCCCXCII"}, Â
		{2975, "MMCMLXXV"}, Â
		{3051, "MMMLI"}, Â
		{3185, "MMMCLXXXV"}, Â
		{3250, "MMMCCL"}, Â
		{3313, "MMMCCCXIII"}, Â
		{3408, "MMMCDVIII"}, Â
		{3501, "MMMDI"}, Â
		{3610, "MMMDCX"}, Â
		{3743, "MMMDCCXLIII"}, Â
		{3844, "MMMDCCCXLIV"}, Â
		{3888, "MMMDCCCLXXXVIII"}, Â
		{3940, "MMMCMXL"}, Â
		{3999, "MMMCMXCIX"}, Â
		{4000, "MMMM"}, Â
		{4999, "MMMMCMXCIX"}}
	
	--
	
	script |toRoman|
		property parent : makeTestCaseBase(me)
		repeat with val in my knownValues
			assertEqual(targetScript()'s toRoman(val's item 1), val's item 2, "")
		end repeat
	end script
	
	script |toLowerRoman|
		property parent : makeTestCaseBase(me)
		repeat with val in my knownValues
			assertEqual(targetScript()'s toRoman(_String's toLower(val's item 1)), val's item 2, "")
		end repeat
	end script
	
	script |fromRoman|
		property parent : makeTestCaseBase(me)
		repeat with val in my knownValues
			assertEqual(targetScript()'s fromRoman(val's item 2), val's item 1, "")
		end repeat
	end script
	
end script

---------------------

script |toRoman bad input|
	property parent : makeFixtureBase(me)
	
	on callHandler({param})
		targetScript()'s toRoman(param)
	end callHandler
	
	--
	
	script |bad value|
		property parent : makeTestCaseBase(me)
		repeat with valRef in {"one", "X", 0.5, {1, 2}}
			assertError({valRef's contents}, -1700, "")
		end repeat
	end script
	
	script |out of range|
		property parent : makeTestCaseBase(me)
		repeat with valRef in {5000, 0, -1}
			assertError({valRef's contents}, -1720, "")
		end repeat
	end script
	
end script

---------------------

script |fromRoman bad input|
	property parent : makeFixtureBase(me)
	
	on callHandler({param})
		targetScript()'s fromRoman(param)
	end callHandler
	
	--
	
	script |bad type|
		property parent : makeTestCaseBase(me)
		assertError({{a:"I", b:"II"}}, -1700, "")
	end script
	
	script |bad value|
		property parent : makeTestCaseBase(me)
		repeat with valRef in {true, 11, "hello", "XiV", "IIII", "MXM"}
			assertError({valRef's contents}, -1704, "")
		end repeat
	end script
	
end script

---------------------

script |sanity check|
	property parent : makeFixtureBase(me)
	
	--
	
	script sanity
		property parent : makeTestCaseBase(me)
		repeat with i from 1 to 4999
			targetScript()'s toRoman(i)
			targetScript()'s fromRoman(result)
			assertEqual(result, i, "")
		end repeat
	end script
	
end script

---------------------
*)