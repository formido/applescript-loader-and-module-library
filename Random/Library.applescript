property __name__ : "Random"
property __version__ : "0.1.0"
property __lv__ : 1.0

(*
Copyright (c) 2003 Michael Becht, HAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*)

----------------------------------------------------------------------
-- DEPENDENCIES

on __load__(loader)
end __load__

----------------------------------------------------------------------
-- PRIVATE

property _kBigPrime : 9.999999999971E+12 -- (largest prime under 1 trillion)
property _kPrime : 67128023 -- also prime

-------
-- zzzzzzzz

on _asInt(val)
	considering hyphens, punctuation and white space
		return val as integer
	end considering
end _asInt

on _asReal(val)
	considering hyphens, punctuation and white space
		return val as real
	end considering
end _asReal

on _asNum(val)
	considering hyphens, punctuation and white space
		return val as number
	end considering
end _asNum

-------

script _RandomBase
	property class : "RandomNumberGenerator"
	--
	on randomize()
		set my __last to random number from 1 to my __bigPrime
		return
	end randomize
	--
	on seed(num)
		try
			considering hyphens, punctuation and white space
				set num to num as number
			end considering
			if num < 1 then
				error "seed number can't be less than 1." number -1704
			end if
			set my __last to num
			return
		on error eMsg number eNum
			error "Can't seed: " & eMsg number eNum
		end try
	end seed
end script

----------------------------------------------------------------------
-- PUBLIC

on makeGenerator()
	try
		script RandomNumberGenerator
			-- private
			property parent : _RandomBase
			property __bigPrime : _kBigPrime
			property _prime : _kPrime
			property __last : missing value
			--public
			on rand()
				set __last to (__last * _prime) mod __bigPrime
				return __last / __bigPrime
			end rand
		end script
		RandomNumberGenerator's randomize()
		return RandomNumberGenerator
	on error eMsg number eNum
		error "Can't makeGenerator: " & eMsg number eNum
	end try
end makeGenerator

--

on makeGeneratorForRange(min, max, decPlaces)
	try
		set min to _asReal(min)
		set max to _asReal(max)
		if min > max then set {min, max} to {max, min}
		set decPlaces to _asInt(decPlaces)
		if decPlaces < 1 or decPlaces > 12 then
			error "decPlaces must be between 1 and 12." number -1704
		end if
		if min is 0.0 and max is 1.0 then -- special case (30% faster than arbitrary range)
			script
				-- private
				property parent : _RandomBase
				property __bigPrime : _kBigPrime
				property _prime : _kPrime
				property __last : missing value
				property _m : 10 ^ decPlaces
				--public
				on rand()
					set __last to (__last * _prime) mod __bigPrime
					return (((__last / __bigPrime) * _m) div 1) / _m
				end rand
			end script
		else
			script
				-- private
				property parent : _RandomBase
				property __bigPrime : _kBigPrime
				property _prime : _kPrime
				property __last : missing value
				property _m : 10 ^ decPlaces
				property _min : min
				property _mod : (max - min) * _m
				--public
				on rand()
					set __last to (__last * _prime) mod __bigPrime
					return ((((__last / __bigPrime) * _mod) div 1) / _m) + _min
				end rand
			end script
		end if
		set RandomNumberGenerator to result
		RandomNumberGenerator's randomize()
		return RandomNumberGenerator
	on error eMsg number eNum
		error "Can't makeGeneratorForRange: " & eMsg number eNum
	end try
end makeGeneratorForRange

--

on makeIntegerGenerator(min, max)
	try
		set min to _asInt(min)
		set max to _asInt(max)
		if min > max then set {min, max} to {max, min}
		script RandomNumberGenerator
			-- private
			property parent : _RandomBase
			property __bigPrime : _kBigPrime
			property _prime : _kPrime
			property __last : missing value
			property _min : min
			property _mod : max - min + 1
			--public
			on rand()
				set __last to (__last * _prime) mod __bigPrime
				return ((__last mod _mod) + _min) div 1
			end rand
		end script
		RandomNumberGenerator's randomize()
		return RandomNumberGenerator
	on error eMsg number eNum
		error "Can't makeIntegerGenerator: " & eMsg number eNum
	end try
end makeIntegerGenerator
