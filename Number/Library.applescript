property __name__ : "Number"
property __version__ : "0.1.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
--mark DEPENDENCIES<B<U

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

--textToNum precision limits
property _dLen : 16 -- safe max=~16
property _mLen : 12 -- safe max=~12

property _zeroStr : "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" -- used by numToStr

script _precalc
	property range1000 : {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 660, 661, 662, 663, 664, 665, 666, 667, 668, 669, 670, 671, 672, 673, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 698, 699, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716, 717, 718, 719, 720, 721, 722, 723, 724, 725, 726, 727, 728, 729, 730, 731, 732, 733, 734, 735, 736, 737, 738, 739, 740, 741, 742, 743, 744, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 761, 762, 763, 764, 765, 766, 767, 768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831, 832, 833, 834, 835, 836, 837, 838, 839, 840, 841, 842, 843, 844, 845, 846, 847, 848, 849, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860, 861, 862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 896, 897, 898, 899, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000}
end script

--mark -

on _round(num, roundObj)
	try
		return roundObj's fn(asNum(num))
	on error eMsg number eNum
		error "Can't round" & roundObj's name & ": " & eMsg number eNum
	end try
end _round

on _trim(num, decPl, roundObj)
	-- note: negative values are allowed for decPl; eg trimAndRoundDown(399, -2) --> 300
	try
		set multiplier to 10 ^ (asInt(decPl))
		(* note: the extra *10 & /10 below is intended to avoid a rounding bug 
				identified by Emmanuel Levy; e.g. 324.21 * 100 div 1 / 100 --> 324.2, but
				should be 324.21 
				whether it works as intended for ALL possible values is another question entirely...
			*)
		set num to roundObj's fn(((asNum(num) * 10) * multiplier) / 10) -- calling up
		if multiplier is less than 1 then
			-- return integers when rounding to -ve decimal places; e.g. 321 --> 300, not 300.0
			return (num div multiplier)
		else
			return (num / multiplier)
		end if
	on error eMsg number eNum
		error "Can't trim" & roundObj's name & ": " & eMsg number eNum
	end try
end _trim

--

script _RoundUp
	property name : "Up"
	on fn(num)
		if num is less than 0 or num mod 1 is 0 then
			return (num div 1)
		else
			return ((num + 1) div 1)
		end if
	end fn
end script

script _RoundDown
	property name : "Down"
	on fn(num)
		if num is greater than 0 or num mod 1 is 0 then
			return (num div 1)
		else
			return ((num - 1) div 1)
		end if
	end fn
end script

script _RoundToNearest
	property name : "ToNearest"
	on fn(num)
		if (num / 2) mod 1 is in {-0.25, 0.25} then -- if num ends in .5 and its div is even then round toward zero so it stays even
			return (num div 1)
		else if num is greater than 0 then -- else round to nearest whole digit [note that .5 will round up to give an even result]
			return ((num + 0.5) div 1)
		else
			return ((num - 0.5) div 1)
		end if
	end fn
end script

script _RoundTowardZero
	property name : "TowardZero"
	on fn(num)
		return (num div 1)
	end fn
end script

script _RoundAsInSchool
	property name : "AsInSchool"
	on fn(num)
		if num mod 1 is in {-0.5, 0.5} then -- if num ends in .5 then round towards zero
			return (num div 1)
		else if num is greater than 0 then -- else round to nearest whole digit
			return ((num + 0.5) div 1)
		else
			return ((num - 0.5) div 1)
		end if
	end fn
end script

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U

on decPt()
	return character 2 of (0.0 as string)
end decPt

-------
--mark -

on asInt(val)
	considering punctuation, hyphens and white space
		return val as integer
	end considering
end asInt

on asReal(val)
	considering punctuation, hyphens and white space
		return val as real
	end considering
end asReal

on asNum(val)
	considering punctuation, hyphens and white space
		return val as number
	end considering
end asNum

on textToNum(txt)
	try
		considering case, hyphens, punctuation and white space
			if txt contains "E" or txt contains "e" then
				error "Sci-notation not supported."
			end if
			if txt's first character is "-" then
				set mlt to -1
				set txt to txt's text 2 thru -1
			else
				set mlt to 1
			end if
			if txt contains "." then -- TO DO: make dec pt a parameter?
				if txt contains "," then error "Found both \".\" and \",\" decimal points."
				set AppleScript's text item delimiters to "."
				set {d, m} to (txt & ".0")'s text items
			else if txt contains "," then
				set AppleScript's text item delimiters to ","
				set {d, m} to (txt & ".0")'s text items
			else
				set d to txt
				set m to "0"
			end if
			if d's length is greater than _dLen then
				return (d's text 1 thru _dLen) * (10 ^ ((d's length) - _dLen)) * mlt
			else
				if m's length is greater than _mLen then set m to m's text 1 thru _mLen
				return ((d + ("0." & m)) * mlt)
			end if
		end considering
	on error eMsg number eNum
		error "Can't convert textToNum: " & eMsg number eNum
	end try
end textToNum

--

on numToText(num, decimalPoint)
	try
		considering case, hyphens, punctuation and white space
			set num to num as number -- must consider hyph, punct, ws to avoid bugs if called inside ignoring blocks
			set decimalPoint to decimalPoint as string
			if decimalPoint's length is not 1 then error "bad value for decimal point (not a single character)." number -1704
			set str to num as string
			if str does not contain "E" and str does not contain "e" then
				if num mod 1 is 0 then
					return str
				else
					return (num div 1 as string) & decimalPoint & (text 3 thru -1 of (num mod 10 as string))
				end if
			end if
			if num < 0 then
				set startAtChar to 4
				set sign to "-"
				set res to str's character 2
			else
				set startAtChar to 3
				set sign to ""
				set res to str's character 1
			end if
			repeat with i from ((str's length) - 2) to 1 by -1
				if str's character i is in "eE" then exit repeat -- must consider hyph, punct, ws
			end repeat
			set res to res & str's text startAtChar thru (i - 1)
			set expt to (str's text (i + 1) thru -1) as integer
			set len to res's length
			if expt is (len - 1) then -- e.g. 1.2345e4 --> "12345"
				return (sign & res)
			else if expt < 0 then -- e.g. 1.1e-10 --> "0.00000000011"
				repeat with i from len to 1 by -1
					if res's character i is not "0" then exit repeat
				end repeat
				return sign & "0." & _zeroStr's text 1 thru (-expt - 1) & (res's text 1 thru i)
			else if expt > len then -- e.g. 1.1e10 --> "11000000000"
				return sign & res & _zeroStr's text 1 thru (expt - len + 1)
			else -- e.g. 1.2345e2 --> "123.45"
				return sign & res's text 1 thru (expt + 1) & "." & res's text (expt + 2) thru -1
			end if
		end considering
	on error eMsg number eNum
		error "Can't convert numToText: " & eMsg number eNum
	end try
end numToText

on padNum(num, len)
	try
		set num to num as integer
		set len to len as integer
		if num < 0 then error "number is negative." number -1704
		if len < 2 or len > 8 then error "pad length is out of range (2-8)." number -1704
		set num to num as string
		if num's length > len then error "number is longer than pad length." number -1704
		return text -len thru -1 of ("00000000" & num)
	on error eMsg number eNum
		error "Can't padNum: " & eMsg number eNum
	end try
end padNum

-------
--mark -

on roundUp(num)
	return _round(num, _RoundUp)
end roundUp

on roundDown(num)
	return _round(num, _RoundDown)
end roundDown

on roundTowardZero(num)
	return _round(num, _RoundTowardZero)
end roundTowardZero

on roundToNearest(num) -- default for Standard Additions' round command
	return _round(num, _RoundToNearest)
end roundToNearest

on roundAsInSchool(num)
	return _round(num, _RoundAsInSchool)
end roundAsInSchool

--mark -

on trimUp(num, toDecimalPlaces)
	return _trim(num, toDecimalPlaces, _RoundUp)
end trimUp

on trimDown(num, toDecimalPlaces)
	return _trim(num, toDecimalPlaces, _RoundDown)
end trimDown

on trimTowardZero(num, toDecimalPlaces)
	return _trim(num, toDecimalPlaces, _RoundTowardZero)
end trimTowardZero

on trimToNearest(num, toDecimalPlaces)
	return _trim(num, toDecimalPlaces, _RoundToNearest)
end trimToNearest

on trimAsInSchool(num, toDecimalPlaces)
	return _trim(num, toDecimalPlaces, _RoundAsInSchool)
end trimAsInSchool

-------
--mark -

on makeRange(fromNum, toNum, byNum)
	try
		set fromNum to asInt(fromNum)
		set toNum to asInt(toNum)
		set byNum to asInt(byNum)
		if byNum is 0 then error "invalid value for byNum (0)." number -1704
		-- optimised special case, where fromNum and toNum are within range 0-1000, and byNum is 1 or -1
		if fromNum � 0 and toNum � 1000 and byNum is 1 or byNum is -1 then
			if fromNum � toNum and byNum is 1 then
				set lst to _precalc's range1000's items (fromNum + 1) thru (toNum + 1)
			else if fromNum � toNum and byNum is -1 then
				set lst to _precalc's range1000's items (toNum + 1) thru (fromNum + 1)'s reverse
			else
				set lst to {}
			end if
		else
			set lst to {}
			repeat with i from fromNum to toNum by byNum
				set lst's end to i
			end repeat
		end if
		return lst
	on error eMsg number eNum
		error "Can't makeRange: " & eMsg number eNum
	end try
end makeRange

on makeRealRange(fromNum, toNum, byNum)
	try
		set num to asReal(fromNum)
		set toNum to asReal(toNum)
		set byNum to asReal(byNum)
		if byNum is 0 then error "invalid value for byNum (0)." number -1704
		if (toNum - fromNum) * byNum < 0 then
			set lst to {}
		else
			set lst to {num}
			repeat (toNum - num) div byNum times
				set num to num + byNum
				set lst's end to num
			end repeat
		end if
		return lst
	on error eMsg number eNum
		error "Can't makeRealRange: " & eMsg number eNum
	end try
end makeRealRange