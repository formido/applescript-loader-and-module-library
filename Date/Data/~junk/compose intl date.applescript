set d to date (get "1/1/1")
set sd to "" as Unicode text
set ld to "" as Unicode text
repeat with i from 1 to 7
	set d's day to i
	set s to (d as Unicode text)'s word 1
	set sd to sd & "|" & s's text 1 thru 3
	set ld to ld & "|" & s
end repeat
set sm to "" as Unicode text
set lm to "" as Unicode text
repeat with i from 1 to 12
	set d's month to item i of {January, February, March, April, May, June, July, August, September, October, November, December}
	set s to (d as Unicode text)'s word 3
	set sm to sm & "|" & s's text 1 thru 3
	set lm to lm & "|" & s
end repeat
set the clipboard to ((tab as Unicode text) & sd's text 2 thru -1 & tab & ld's text 2 thru -1 & tab & sm's text 2 thru -1 & tab & lm's text 2 thru -1)