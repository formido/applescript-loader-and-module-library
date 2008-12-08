property _Loader : run application "LoaderServer"------------------------------------------------------------------------ DEPENDENCIESproperty _Conversion : missing valueproperty _String : missing valueproperty _Unicode : missing valueon __load__(loader)	set _Conversion to loader's loadLib("Conversion")	set _String to loader's loadLib("String")	set _Unicode to loader's loadLib("Unicode")end __load__----------------------------------------------------------------------__load__(_Loader's makeLoader())----------------------------------------------------------------------set t to "0080 00c4
0081 00b9
0082 00b2
0083 00c9
0084 00b3
0085 00d6
0086 00dc
0087 0385
0088 00e0
0089 00e2
008a 00e4
008b 0384
008c 00a8
008d 00e7
008e 00e9
008f 00e8
0090 00ea
0091 00eb
0092 00a3
0093 2122
0094 00ee
0095 00ef
0096 2022
0097 00bd
0098 2030
0099 00f4
009a 00f6
009b 00a6
009c 00ad
009d 00f9
009e 00fb
009f 00fc
00a0 2020
00a1 0393
00a2 0394
00a3 0398
00a4 039b
00a5 039e
00a6 03a0
00a7 00df
00a8 00ae
00aa 03a3
00ab 03aa
00ac 00a7
00ad 2260
00ae 00b0
00af 0387
00b0 0391
00b2 2264
00b3 2265
00b4 00a5
00b5 0392
00b6 0395
00b7 0396
00b8 0397
00b9 0399
00ba 039a
00bb 039c
00bc 03a6
00bd 03ab
00be 03a8
00bf 03a9
00c0 03ac
00c1 039d
00c2 00ac
00c3 039f
00c4 03a1
00c5 2248
00c6 03a4
00c7 00ab
00c8 00bb
00c9 2026
00ca 00a0
00cb 03a5
00cc 03a7
00cd 0386
00ce 0388
00cf 0153
00d0 2013
00d1 2015
00d2 201c
00d3 201d
00d4 2018
00d5 2019
00d6 00f7
00d7 0389
00d8 038a
00d9 038c
00da 038e
00db 03ad
00dc 03ae
00dd 03af
00de 03cc
00df 038f
00e0 03cd
00e1 03b1
00e2 03b2
00e3 03c8
00e4 03b4
00e5 03b5
00e6 03c6
00e7 03b3
00e8 03b7
00e9 03b9
00ea 03be
00eb 03ba
00ec 03bb
00ed 03bc
00ee 03bd
00ef 03bf
00f0 03c0
00f1 03ce
00f2 03c1
00f3 03c3
00f4 03c4
00f5 03b8
00f6 03c9
00f7 03c2
00f8 03c7
00f9 03c5
00fa 03b6
00fb 03ca
00fc 03cb
00fd 0390
00fe 03b0"set t to _String's toUpper(t)set ol to ""set nl to "" as Unicode textrepeat with p in t's paragraphs	set oe to _Conversion's shortHexToInteger(text 3 thru 4 of p)	set ne1 to _Conversion's shortHexToInteger(text 6 thru 7 of p)	set ne2 to _Conversion's shortHexToInteger(text 8 thru 9 of p)	set ol to ol & (ASCII character oe)	set nl to nl & _Unicode's uChar(ne1 * 256 + ne2)end repeatreturn {ol, nl}set s to "Turkish|Turkish|Ptesi/Sal›/Çarﬂamba/Perﬂembe/Cuma/Ctesi/Pazar|Pte/Sal/Çar/Per/Cum/Cte/Paz|Ocak/ﬁubat/Mart/Nisan/May›s/Haziran/Temmuz/A€ustos/Eylül/Ekim/Kas›m/Aral›k|Oca/ﬁub/Mar/Nis/May/Haz/Tem/A€u/Eyl/Eki/Kas/Ara"set r to "" as Unicode textrepeat with c in s	set c to c's contents	set off to _String's getFirstOffset(ol, c)	if off ≠ 0 then		set r to r & nl's item off	else		set r to r & c	end ifend repeatr