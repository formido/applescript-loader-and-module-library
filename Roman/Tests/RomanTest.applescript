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
	
	property knownValues : {�
		{1, "I"}, �
		{2, "II"}, �
		{3, "III"}, �
		{4, "IV"}, �
		{5, "V"}, �
		{6, "VI"}, �
		{7, "VII"}, �
		{8, "VIII"}, �
		{9, "IX"}, �
		{10, "X"}, �
		{50, "L"}, �
		{100, "C"}, �
		{500, "D"}, �
		{1000, "M"}, �
		{31, "XXXI"}, �
		{148, "CXLVIII"}, �
		{294, "CCXCIV"}, �
		{312, "CCCXII"}, �
		{421, "CDXXI"}, �
		{528, "DXXVIII"}, �
		{621, "DCXXI"}, �
		{782, "DCCLXXXII"}, �
		{870, "DCCCLXX"}, �
		{941, "CMXLI"}, �
		{1043, "MXLIII"}, �
		{1110, "MCX"}, �
		{1226, "MCCXXVI"}, �
		{1301, "MCCCI"}, �
		{1485, "MCDLXXXV"}, �
		{1509, "MDIX"}, �
		{1607, "MDCVII"}, �
		{1754, "MDCCLIV"}, �
		{1832, "MDCCCXXXII"}, �
		{1993, "MCMXCIII"}, �
		{2074, "MMLXXIV"}, �
		{2152, "MMCLII"}, �
		{2212, "MMCCXII"}, �
		{2343, "MMCCCXLIII"}, �
		{2499, "MMCDXCIX"}, �
		{2574, "MMDLXXIV"}, �
		{2646, "MMDCXLVI"}, �
		{2723, "MMDCCXXIII"}, �
		{2892, "MMDCCCXCII"}, �
		{2975, "MMCMLXXV"}, �
		{3051, "MMMLI"}, �
		{3185, "MMMCLXXXV"}, �
		{3250, "MMMCCL"}, �
		{3313, "MMMCCCXIII"}, �
		{3408, "MMMCDVIII"}, �
		{3501, "MMMDI"}, �
		{3610, "MMMDCX"}, �
		{3743, "MMMDCCXLIII"}, �
		{3844, "MMMDCCCXLIV"}, �
		{3888, "MMMDCCCLXXXVIII"}, �
		{3940, "MMMCMXL"}, �
		{3999, "MMMCMXCIX"}, �
		{4000, "MMMM"}, �
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