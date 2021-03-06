
on removeRoundingError(num)
	considering hyphens, punctuation and white space but ignoring case
		set num to num as number
		set str to num as string
		if str contains "E" then return str
	end considering
	set m to num mod 1
	if (m * 10 as string)'s length is (m as string)'s length then -- has rounding error
		if num < 0 then
			set sign to "-"
			set num to -num
		else
			set sign to ""
		end if
		set str to sign & text 1 thru -2 of (num div 1 / 1 as string) & text 4 thru -1 of (((num mod 1) / 10) as string)
	end if
	return str
end removeRoundingError

set x to 8483.389999999999
log removeRoundingError(x)
set x to 0.123456789012
log removeRoundingError(x)
