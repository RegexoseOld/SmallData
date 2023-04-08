(
melo: (
    pr: Array.fill(~numSlots, {30}),
    ins: Array.fill(~numSlots, {42}),
    con: Array.fill(~numSlots, {48}),
    lec: Array.fill(~numSlots, {35}),
    dis: Array.fill(~numSlots, {66}),
	utt: ~numSlots.collect({|n| Buffer.new(s, 10000, 1)}), //  ändern in Buffer mit einen (leisen), Signal
    cad01: Pseq( [[60, 66, 42], [60, 48, 72], [60, 35, 42], [60, 66, 68]], inf),
    cad02: Pseq( [[60, 66, 42, 35], [35, 42, 66], [33, 35, 42], [60, 66, 68]], inf)

),

duras:(
    pr: Array.fill(~numSlots, {4}),
    ins: Array.fill(~numSlots, {4}),
    con: Array.fill(~numSlots, {4}),
    lec: Array.fill(~numSlots, {4}),
    dis: Array.fill(~numSlots, {4}),

),

amps:(
    pr: 0.3,
    ins: 0.3,
    con: 0.3,
    lec: 0.3,
    dis: 0.3,
    utt: 0.3,

),

pauses: (
    lecture: 2,
    dissent: 3,
    insinuation: 4,
    praise: 5,
    concession: 6
),

slots:(
	// sample Slots
	zahlen: ~numSlots.collect({|n| var i = n%8; ~buffers[\zahlen][i]}),
	utt: ~numSlots.collect({|n| var i = n+1; ~buffers[\lec01][i]}),
	//pattern slots
	a: Pbind(\instrument, \sampSt, \buf, Pxrand(~buffers[\bd], inf), \amp, 0.4, \dur, 0.5),
	b: Pbind(\instrument, \sampSt, \buf, Pxrand(~buffers[\Bells], inf), \amp, 0.9, \dur, 0.5, \cgain, 3),
	uttpr: Pbindef(\uttpr, \instrument, \sampMon, \buf, ~uttSample),
	uttdis: Pbindef(\uttdis, \instrument, \sampMon, \buf, ~uttSample),
	uttins: Pbindef(\uttins, \instrument, \sampMon, \buf, ~uttSample),
	uttcon: Pbindef(\uttcon, \instrument, \sampMon, \buf, ~uttSample),
	uttlec: Pbindef(\uttlec, \instrument, \sampMon, \buf, ~uttSample),
	pr: Pbindef(\pr),
	dis: Pbindef(\dis),
	ins: Pbindef(\ins),
	con: Pbindef(\con),
	lec: Pbindef(\lec),
)




)

