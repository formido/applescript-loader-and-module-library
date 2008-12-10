set l to {}
repeat 4000 times
	set len to some item of {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
	set s to ""
	repeat len times
		set s to s & some item of "abcdefghijklmnopqrstuvwxy1234567890     !@£$%^&*()Œ§¶Ä©úÆûÂÏ·«¨ ´¬^¿¹½ÅÃº~µ"
	end repeat
	set l's end to s
end repeat
l