
on _toRoman(num)
	-- (based on PHP's toRoman function)
	set uConv to {"IXC", 0, 0, 0, "VLD", 0, 0, 0, 0, "XCM"}
	set lConv to {"ixc", 0, 0, 0, "vld", 0, 0, 0, 0, "xcm"}
	set uRoman to ""
	set lRoman to ""
	set digit to num div 1000
	set num to num - digit * 1000
	repeat while digit > 0
		set uRoman to uRoman & "M"
		set lRoman to lRoman & "m"
		set digit to digit - 1
	end repeat
	repeat with i from 3 to 1 by -1
		set power to 10 ^ (i - 1)
		set digit to num div power
		set num to num - digit * power
		if digit is in {9, 4} then
			set uRoman to uRoman & uConv's item 1's item i & uConv's item (digit + 1)'s item i
			set lRoman to lRoman & lConv's item 1's item i & lConv's item (digit + 1)'s item i
		else
			if digit ³ 5 then
				set uRoman to uRoman & uConv's item 5's item i
				set lRoman to lRoman & lConv's item 5's item i
				set digit to digit - 5
			end if
			repeat while digit > 0
				set uRoman to uRoman & uConv's item 1's item i
				set lRoman to lRoman & lConv's item 1's item i
				set digit to digit - 1
			end repeat
		end if
	end repeat
	return {uRoman, lRoman}
end _toRoman

on makeTables()
	set uIntToRom to {}
	set lIntToRom to {}
	set romToInt to {}
	repeat with i from 1 to 4999
		set {r1, r2} to _toRoman(i)
		set uIntToRom's end to r1
		set lIntToRom's end to r2
		set romToInt's end to tab & r1 & tab & r2 & tab
	end repeat
	set AppleScript's text item delimiters to return
	return {uIntToRom as string, lIntToRom as string, romToInt as string}
end makeTables

on writeListToFile(pth, txt)
	open for access POSIX file pth with write permission returning fileRef
	set eof of fileRef to 0
	write txt to fileRef
	close access fileRef
	return
end writeListToFile


set {uIntToRom, lIntToRom, romToInt} to makeTables()
set pth to "/Users/has/RomanLib/Support/"
writeListToFile(pth & "IntegerToUppercaseRoman1.txt", uIntToRom's text (paragraph 1) thru (paragraph 2999))
writeListToFile(pth & "IntegerToUppercaseRoman2.txt", uIntToRom's text (paragraph 3000) thru (paragraph 4999))
writeListToFile(pth & "IntegerToLowercaseRoman1.txt", lIntToRom's text (paragraph 1) thru (paragraph 2999))
writeListToFile(pth & "IntegerToLowercaseRoman2.txt", lIntToRom's text (paragraph 3000) thru (paragraph 4999))
writeListToFile(pth & "RomanToInteger.txt", romToInt)