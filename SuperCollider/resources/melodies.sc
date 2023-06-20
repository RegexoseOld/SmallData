(
melo: (
    pr: Pseq([Pn(60, 8), Pn(58, 7), \], inf),
	ins: Pseq([Pn(71, 8), Pn(68, 7), \], inf),
    con:  Pseq([Pn (64, 8), Pn(63, 6), 62, \], inf),
    lec: Pseq([Pn(68, 8), Pn(70, 7), \], inf),
    dis: Pseq([Pn(65, 8), Pn(65, 7), \], inf),
    pr05: Pseq([Pn(60, 4), Pn(63, 4), Pn(63, 4), 60, \, \, \], inf),
    ins05: Pseq([Pn(63, 4), Pn( 66, 4), Pn( 66, 4), 65, \, \, \], inf),
    con05:  Pseq([Pn( 65, 4), Pn(70, 4), Pn(69, 4), 65, \, \, \], inf),
    lec05: Pseq([Pn(72, 4), Pn(75, 4), Pn(75, 4), 72, \, \, \], inf),
    dis05: Pseq([Pn(77, 4), Pn(76, 4), Pn(77, 4), 76, \, \, \], inf),
    pr10: Pseq([60, 63, 63, 60], inf),
    ins10: Pseq([63, 66, 66, 65], inf),
    con10: Pseq([65, 70, 69, 65], inf),
    lec10: Pseq([72, 75, 75,72], inf),
    dis10: Pseq([77, 76, 77, 76], inf),
    pr20:  Pseq([Pn(60, 16)], inf),
    ins20: Pseq([Pn(71, 16)], inf),
    con20: Pseq([Pn(64, 16)], inf),
    lec20: Pseq([Pn(68, 16)], inf),
    dis20: Pseq([Pn(65, 16)], inf),
    cad01: Pseq( [[60, 66, 42], [60, 48, 72], [60, 35, 42], [60, 66, 68]], inf),
    cad02: Pseq( [[60, 66, 42, 35], [35, 42, 66], [33, 35, 42], [60, 66, 68]], inf),
	kik01: Pseq([60, Pn(\, 7), 60, Pn(\, 7), 60, Pn(\, 6), 60, 60, Pn(\, 7) ], inf),
	kik02: Pseq([Pn(60, 3), \, 60, \, \, Pn([60, \, \], 2)], inf),
	kik03: Pseq([Pn(60, 3), \, 60, \, \, Pn([60, \, \], 2), \, \, \], inf),
	sn01: Pseq([\, \, 200,  \, \, \, \, \], inf),
	sn02: Pseq([\, \, 200,  \, \, \, 250, \], inf),
	sn03: Pseq([\, \, Pn(200, 2), \, \, 190, \, \, Pn(200, 4), \, \], inf),
	bass0: Pseq([Pn(\, 20), 30, \, 33, Pn(\, 3), 30, 30, 33, Pn(\, 3)], inf),
	bass1: Pseq([48, \, \, 39, \, \, 42, 43, 36, \, \, 36, \, \, \, \], inf),
	bass2: Pseq([48, \, \, 60, \, \, 48, 45, 48, \, \, 36, \, \, \, \], inf),
	bass3: Pseq([48, Pn(\, 7), 36, Pn(\, 7)], inf),
	bass4: Pseq([48, Pn(\, 7), 36, Pn(\, 7), 42, Pn(\, 7), 46, Pn(\, 7)], inf),
	bass5: Pseq([36, Pn(\, 7), 39, Pn(\, 7), 40, Pn(\, 7), 39, Pn(\, 7), 40, Pn(\, 7), 34, Pn(\, 7)], inf),
	bass6: Pseq([36, Pn(\, 7), 35, Pn(\, 7)], inf),
),

meloPoporgan: (
	bass0: Pseq([48, Pn(\, 7), 36,Pn(\, 7),], inf),
	bass1: Pseq([48, \, \, \, \, \, \, \, 36, \, \, 36, \, \, \, \], inf),
	hh01: Pxrand([0.18, 0.27, 0.16 ], inf),
	hh02: Pseq([Pn(Pwhite(0.18, 0.27, 16), 1), Pseq([0.26, \, 0.3, \], 3)], inf)

),
meloBase: (

	pr11: Pseq([Pn(72, 6), Prand([60, 72, 48], 8)], inf),
	ins11: Pseq([Pn(75, 6), Prand([63, 75, 87], 8)], inf),
	con11: Pseq([Pn(65, 6), Prand([65, 77, 53], 8)], inf),
	lec11: Pseq([Pn(68, 6), Prand([68, 80, 54], 8)], inf),
	dis11: Pseq([Pn(64, 6), Prand([64, 76, 52], 8)], inf),
	kik01: Pseq([60, Pn(\, 7), 60, Pn(\, 7), 60, Pn(\, 6), 60, 60, Pn(\, 7) ], inf),
	kik02: Pseq([Pn(60, 4), Pn(\, 4) ], inf),
	kik03: Pseq([Pn(110, 4), Pn(\, 4) ], inf),
	kik04: Pseq([Pn(60, 3), \, 60, \, \, Pn([60, \, \], 2), \, \, \], inf),
	sn01: Pseq([\, \, 80,  \, \, \, 75, \], inf),
	sn02: Pseq([\, \, 55,  \, \, \, 50, \], inf),
	sn03: Pseq([\, \, Pn(200, 2), \, \, 190, \, \, Pn(200, 4), \, \], inf),
),

feedbacks: (
	pr: 60,
    ins: 71,
    con: 74,
    lec: 68,
    dis: 65,
),


duras:(
    pr: Array.fill(~numSlots, {4}),
    ins: Array.fill(~numSlots, {4}),
    con: Array.fill(~numSlots, {4}),
    lec: Array.fill(~numSlots, {4}),
    dis: Array.fill(~numSlots, {4}),

),

amps:(
    pr: 0.2,
    ins: 0.2,
    con: 0.2,
    lec: 0.2,
    dis: 0.2,
    utt: 0.2,
	bass: 0.3,
	kik02: 0.3,
	sn01: 0.25

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
	con: ~buffers[\catSampEn][0],
	dis: ~buffers[\catSampEn][1],
	ins: ~buffers[\catSampEn][2],
	lec: ~buffers[\catSampEn][3],
	pr: ~buffers[\catSampEn][4],

),

)

