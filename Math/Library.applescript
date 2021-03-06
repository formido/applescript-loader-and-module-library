property __name__ : "Math"
property __version__ : "0.2.0"
property __lv__ : 1

(*
Copyright (c) 2003 HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
--mark -
--mark PRIVATE<B<U

(*
Handlers protect against worst-case errors where user calls from inside an ignoring hyphens/punctuation/whitespace block while passing string as parameter by enclosing any statements that perform an explicit or implicit string-to-number coercion in a considering block; eg:

	set x to "-3.14"
	considering hyphens, punctuation and white space
		set y to x as number -- example 1, explicit coercion
		set z to x *pi /180 -- example 2, implicit coercion
	end considering

*)

property _isEqualDelta : 1.0E-9

script _precalc -- pre-calculated values
	property sine : {0.0, 0.258819045103, 0.5, 0.707106781187, 0.866025403784, 0.965925826289, 1.0, 0.965925826289, 0.866025403784, 0.707106781187, 0.5, 0.258819045103, 0.0, -0.258819045103, -0.5, -0.707106781187, -0.866025403784, -0.965925826289, -1.0, -0.965925826289, -0.866025403784, -0.707106781187, -0.5, -0.258819045103}
	property tangent : {0.0, 0.267949192431, 0.57735026919, 1.0, 1.732050807569, 3.732050807569, missing value, -3.732050807569, -1.732050807569, -1.0, -0.57735026919, -0.267949192431, 0.0, 0.267949192431, 0.57735026919, 1.0, 1.732050807569, 3.732050807569, missing value, -3.732050807569, -1.732050807569, -1.0, -0.57735026919, -0.267949192431}
end script

on _frexp(x)
	try
		set m to x as real
		if m is 0 then return {0.0, 0}
		set isNeg to m < 0
		if isNeg then set m to -m
		set e to 0
		repeat until m � 0.5 and m < 1
			if m � 1 then
				set m to m / 2
				set e to e + 1
			else
				set m to m * 2
				set e to e - 1
			end if
		end repeat
		if isNeg then set m to -m
		return {m, e}
	on error eMsg number eNum
		error "Can't _frexp: " & eMsg number eNum
	end try
end _frexp

----------------------------------------------------------------------
--mark -
--mark PUBLIC<B<U
--mark properties<B

property e : 2.71828182846 -- The mathematical constant e

--mark -
--mark basic commands<B

on isEqual(x, y)
	try
		considering hyphens, punctuation and white space
			set x to x as number
			set y to y as number
			return (x - _isEqualDelta < y) and (x + _isEqualDelta > y)
		end considering
	on error eMsg number eNum
		error "Can't isEqual: " & eMsg number eNum
	end try
end isEqual

on toRadians(x)
	considering hyphens, punctuation and white space
		try
			return x * (pi / 180)
		on error eMsg number eNum
			error "Can't toRadians: " & eMsg number eNum
		end try
	end considering
end toRadians

on toDegrees(x)
	considering hyphens, punctuation and white space
		try
			return x / (pi / 180)
		on error eMsg number eNum
			error "Can't toDegrees: " & eMsg number eNum
		end try
	end considering
end toDegrees

on absolute(x)
	try
		considering hyphens, punctuation and white space
			set x to x as number
		end considering
		if x < 0 then
			return -x
		else
			return x
		end if
	on error eMsg number eNum
		error "Can't absolute: " & eMsg number eNum
	end try
end absolute

on divmod(x)
	considering hyphens, punctuation and white space
		try
			return {x div 1, x mod 1}
		on error eMsg number eNum
			error "Can't divmod: " & eMsg number eNum
		end try
	end considering
end divmod

on squareroot(x)
	considering hyphens, punctuation and white space
		try
			return x ^ 0.5
		on error eMsg number eNum
			try
				if x as number < 0 then set {eMsg, eNum} to {"parameter is out of range (0+).", 8901}
			on error eMsg number eNum
			end try
			error "Can't squareroot: " & eMsg number eNum
		end try
	end considering
end squareroot

on hypotenuse(x, y)
	considering hyphens, punctuation and white space
		try
			return (x * x + y * y) ^ 0.5
		on error eMsg number eNum
			error "Can't hypotenuse: " & eMsg number eNum
		end try
	end considering
end hypotenuse

on minnum(lst)
	considering hyphens, punctuation and white space
		try
			if lst's class is not list then error "not a list." number -1703
			script k
				property l : lst
			end script
			set res to k's l's item 1 as number
			repeat with i in k's l
				if res > i's contents then set res to i's contents as number
			end repeat
			return res
		on error eMsg number eNum
			error "Can't minnum: " & eMsg number eNum
		end try
	end considering
end minnum

on maxnum(lst)
	considering hyphens, punctuation and white space
		try
			if lst's class is not list then error "not a list." number -1703
			script k
				property l : lst
			end script
			set res to k's l's item 1 as number
			repeat with i in k's l
				if res < i's contents then set res to i's contents as number
			end repeat
			return res
		on error eMsg number eNum
			error "Can't maxnum: " & eMsg number eNum
		end try
	end considering
end maxnum

--mark -
--mark basic trig<B

on sine(x)
	try
		considering hyphens, punctuation and white space
			if x mod 15 is 0 then -- performance optimisation for common values
				if x < 0 then set x to -x
				return _precalc's sine's item (x mod 360 div 15 + 1)
			end if
			set x to x mod 360 * pi / 180 -- convert from degrees to radians
		end considering
		set isNeg to x < 0
		if isNeg then set x to -x
		set y to (x * (4 / pi)) div 1
		set z to y - (y * 0.0625 div 1) * 16
		if z mod 2 is 1 then
			set z to z + 1
			set y to y + 1
		end if
		set z to z mod 8
		if z > 3 then
			set isNeg to not isNeg
			set z to z - 4
		end if
		set z2 to ((x - y * 0.785398125648) - y * 3.77489470793E-8) - y * 2.695151429079E-15
		set zz to z2 * z2
		if z is 1 or z is 2 then
			set y to 1.0 - zz / 2 + zz * zz * (((((-1.13585365213877E-11 * zz + 2.08757008419747E-9) * zz - 2.75573141792967E-7) * zz + 2.48015872888517E-5) * zz - 0.001388888889) * zz + 0.041666666667)
		else
			set y to z2 + z2 * zz * (((((1.58962301576546E-10 * zz - 2.50507477628578E-8) * zz + 2.75573136213857E-6) * zz - 1.98412698295895E-4) * zz + 0.008333333333) * zz - 0.166666666667)
		end if
		if isNeg then set y to -y
		return y
	on error eMsg number eNum
		error "Can't sine: " & eMsg number eNum
	end try
end sine

on cosine(x)
	try
		considering hyphens, punctuation and white space
			return sine(x + 90)
		end considering
	on error eMsg number eNum
		error "Can't cosine: " & eMsg number eNum
	end try
end cosine

on tangent(x)
	try
		considering hyphens, punctuation and white space
			if x mod 15 is 0 then -- performance optimisation for common values
				if x < 0 then set x to -x
				if x is 90 or x is 270 then
					error "result is infinitely large." number 8900
				else
					return _precalc's tangent's item (x mod 360 div 15 + 1)
				end if
			end if
			set x to x mod 360 * pi / 180 -- convert from degrees to radians
		end considering
		set isNeg to x < 0
		if isNeg then set x to -x
		set y to (x / (pi / 4)) div 1
		set z to y - (y * 0.125 div 1) * 8
		if z mod 2 is 1 then
			set z to z + 1
			set y to y + 1
		end if
		set z2 to ((x - y * 0.785398155451) - y * 7.94662735614793E-9) - y * 3.06161699786838E-17
		set zz to z2 * z2
		if zz > 1.0E-14 then
			set y to z2 + z2 * zz * ((-1.30936939181384E+4 * zz + 1.15351664838587E+6) * zz - 1.79565251976485E+7) / ((((zz + 1.36812963470693E+4) * zz - 1.32089234440211E+6) * zz + 2.50083801823358E+7) * zz - 5.38695755929455E+7)
		else
			set y to z2
		end if
		if z is 2 or z is 6 then set y to -1 / y
		if isNeg then set y to -y
		return y
	on error eMsg number eNum
		error "Can't tangent: " & eMsg number eNum
	end try
end tangent

--mark -
--mark inverse trig<B

on arcsine(x)
	try
		considering hyphens, punctuation and white space
			set x to x as number
		end considering
		set isNeg to x < 0
		if isNeg then set x to -x
		if x > 1 then error "parameter is out of range (-1 to 1)." number 8901
		if x > 0.625 then
			set zz to 1 - x
			set p to zz * ((((0.002967721961 * zz - 0.563424278001) * zz + 6.968710824105) * zz - 25.569010496528) * zz + 28.536655482611) / ((((zz - 21.947795316429) * zz + 147.065635402681) * zz - 383.877095760369) * zz + 342.439865791308)
			set zz to (zz + zz) ^ 0.5
			set z to (pi / 4) - zz
			set zz to zz * p - 6.12323399573677E-17
			set z to z - zz + (pi / 4)
		else if x < 1.0E-8 then
			set z to x
		else
			set zz to x * x
			set z to zz * (((((0.004253011369 * zz - 0.601959800801) * zz + 5.444622390565) * zz - 16.26247967211) * zz + 19.56261983318) * zz - 8.198089802485) / (((((zz - 14.740913729889) * zz + 70.496102808568) * zz - 147.179129223273) * zz + 139.510561465749) * zz - 49.188538814909) * x + x
		end if
		if isNeg then set z to -z
		return z / (pi / 180)
	on error eMsg number eNum
		error "Can't arcsine: " & eMsg number eNum
	end try
end arcsine

on arccosine(x)
	try
		considering hyphens, punctuation and white space
			return 90 - arcsine(x)
		end considering
	on error eMsg number eNum
		error "Can't arccosine: " & eMsg number eNum
	end try
end arccosine

on arctangent(x)
	try
		considering hyphens, punctuation and white space
			return arcsine(x / ((x * x + 1) ^ 0.5))
		end considering
	on error eMsg number eNum
		error "Can't arccosine: " & eMsg number eNum
	end try
end arctangent

--mark -
--mark hyperbolic trig<B

on hypersine(x)
	try
		considering hyphens, punctuation and white space
			return 0.5 * (e ^ x - e ^ -x)
		end considering
	on error eMsg number eNum
		error "Can't arccosine: " & eMsg number eNum
	end try
end hypersine

on hypercosine(x)
	try
		considering hyphens, punctuation and white space
			return 0.5 * (e ^ x + e ^ -x)
		end considering
	on error eMsg number eNum
		error "Can't arccosine: " & eMsg number eNum
	end try
end hypercosine

on hypertangent(x)
	try
		considering hyphens, punctuation and white space
			return (e ^ x - e ^ -x) / (e ^ x + e ^ -x)
		end considering
	on error eMsg number eNum
		error "Can't arccosine: " & eMsg number eNum
	end try
end hypertangent

--mark -
--mark logarithms<B

on logn(x)
	try
		considering hyphens, punctuation and white space
			set x to x as number
		end considering
		if x � 0 then error "value must be greater than 0." number -1704
		set {x, e} to _frexp(x)
		if e < -2 or e > 2 then
			if x < 0.707106781187 then -- (2 ^ 0.5) / 2
				set e to e - 1
				set z to x - 0.5
				set y to 0.5 * z + 0.5
			else
				set z to x - 1
				set y to 0.5 * x + 0.5
			end if
			set x to z / y
			set z to x * x
			set z to x * z * ((-0.789580278885 * z + 16.386664569956) * z - 64.140995295872) / (((z - 35.672279825632) * z + 312.093766372244) * z - 769.69194355046)
			set y to e
			set z to z - y * 2.12194440054691E-4 + x + e * 0.693359375
		else
			if x < 0.707106781187 then -- (2 ^ 0.5) / 2
				set e to e - 1
				set x to 2 * x - 1
			else
				set x to x - 1
			end if
			set z to x * x
			set y to x * z * (((((1.01875663804581E-4 * x + 0.497494994977) * x + 4.705791198789) * x + 14.498922534161) * x + 17.936867850782) * x + 7.708387337559) / (((((x + 11.287358718917) * x + 45.227914583753) * x + 82.987526691278) * x + 71.154475061856) * x + 23.125162012677)
			if e � 0 then
				set y to y - e * 2.12194440054691E-4
			end if
			set y to y - (z / 2)
			set z to x + y
			if e � 0 then set z to z + e * 0.693359375
		end if
		return z
	on error eMsg number eNum
		error "Can't logn: " & eMsg number eNum
	end try
end logn

on logten(x)
	try
		return (logn(x) / 2.302585092994) * 300.0 / 300.000000000006 -- correct for minor drift
	on error eMsg number eNum
		error "Can't logten: " & eMsg number eNum
	end try
end logten

on logbase(x, base)
	try
		return logn(x) / (logn(base))
	on error eMsg number eNum
		error "Can't logbase: " & eMsg number eNum
	end try
end logbase