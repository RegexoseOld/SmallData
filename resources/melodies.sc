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
	lec05: Pseq([Pn(72, 4), Pn(75, 4 ), Pn(75, 4), 72, \, \, \], inf),
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
	pr21: Pseq([Pseq([91, 93, 91, 88], 2), Pseq([95, 94], 16)], inf),
	con21: Pseq([88,84,88,84,81,79,81,83], inf) -12,
	lec21:  Pseq([Pseq([84, 86, 87, 88], 2), Pseq([91, 93], 16)], inf),
	dis21: Pseq([79,80,81,82,83,82,81,82,83,82,83,84,82,84,83,82], inf),
	ins21: Pseq([91, Pn(92, 4), Pn(91, 3), 90, 91 ,90, 88, 90, Pn(85, 4), Pn(87, 4), Pn(88, 4), Pn(90, 4), Pn(91, 3),], inf),
	bass0: Pseq([48, Pn(\, 7), 36,Pn(\, 7),], inf),
	bass1: Pseq([48, \, \, \, \, \, \, \, 36, \, \, 36, \, \, \, \], inf),
	bass21: Pseq([43, 36, 40, 41, 43, 42, 41, 40], inf),
	hh01: Pxrand([0.18, 0.27, 0.16 ], inf),
	hh02: Pseq([Pn(Pwhite(0.18, 0.27, 16), 1), Pseq([0.26, \, 0.3, \], 3)], inf)

),

meloEdge: (
	dis00: Pseq([Pn(\, 24), 66, 63, Pn(\, 6)], inf),
	dis05: Pseq([ \, 69, 69, 71, \, 71, 71, 71, \, 67, 67, 68, \] , inf),
	dis10: Pseq([ \, 79, 79, 79, 80, 80, 79, \, 79, 79, 79, 80, 80, 79, \, 78, 78, 78, 78, 78, 79, 79, 78, 78, \, 79, \, 76, \, 79, 79, 79, 80, 80, 79, \, 79, 79, 80, 80, 79, \, 79, \, 77, 79, 79, \, 76, 77, 77, \, 75, 75, 76, \] , inf),
	dis20: Pseq([66, \, 59, \, 63, \, 66, \, 71, \, Pn(\, 22)], inf),
	pr00: Pseq([63, 66, Pn(\, 30)], inf),
	pr05: Pseq([63, 67, 63, 67, 63, 67, 63, 67, \], inf),
	pr10: Pseq([71, \, 71, 73,\, 71, \, 74, \, 71, \, 73, \, 71, \, 77, 77, 74, 74, \, 71, 73, \, 71, \, 74, \, 71, 77 ], inf),
	ins00: Pseq([Pn(\, 12), 63, 66, Pn(\, 18)], inf),
	ins05: Pseq([\, 67, \, 60, \, 67, \, 60, \, 63, \, 59, \], inf),
	ins10: Pseq([53, \, 54, \, 55, \, 54, \, 55, \, 56, \, 55, \, 56, \, 57, 58, \, 57, \, 58, \, 59, \, 60, \, 59, 59, 58, \, 53, 54, \, 55, \, 54, \, 55, \, 56, \, 55, \, 56, \, 57, \, 58, \, 57, \, 58, \, 59, 60, \, 59, 58, 57, \ ], inf),
	ins20: Pseq([60, \,  60, \, 61, \, 61, \, 62, Pn(\, 7), 62, \, 62,  \, 61, \, 61, \, 60, Pn(\, 7)], inf),
	con00: Pseq([Pn(\, 8), 66, 68, Pn(\, 22)], inf),
	con05: Pseq([51, 60, \, 59, 59, 57, \, 53, \], inf),
	con10: Pseq([ 66, 66, 64, 64, 63, 64, \, 64, 65, 66, 66, 64, 64, 62, 62, \], inf),
	con20: Pseq([66, 66, 66, \, 66, \, \, 66, 66, 66, 65, \, 65, \, \, 66, 66, 65, 66, 65, 66, 60,  Pn(\, 10)], inf),
	lec00: Pseq([Pn(\, 20), 62, 58, Pn(\, 22)], inf),
	lec05: Pseq([\, 55, 61, \, 61, \, 59, \, 59, \, 61, \, 61, \, 59, \, 59, \ ], inf),
	lec10: Pseq([81, 81, 81, 81, 81, \, 77, \, 80, 80, 80, 80, 80, \, 76, \, 78, 78, 78, 78, 78, \, 75, \, 77, 79, 79, 77, 79, \, 73, \, 81, 81, 81, 81, 81, \, 77, \, 80, 80, 80, \, 76, 80, 80, \, 80, \,80, \], inf),
	lec20:  Pseq([54, 55, 50, \, 55, 54, 48, \], inf),
	kik01: Pseq([60, Pn(\, 7), 60, Pn(\, 7), 60, Pn(\, 6), 60, 60, Pn(\, 7) ], inf),
	snip01: Pseq([\, \, 200,  \, \, \, \, \], inf),
	sn05: Pseq([\, \, \, \,  200, \, \, 200], inf),
	bass05: Pseq([36, \, \, 34, \, \, 36, \, 39, Pn(\, 7), 36, \, \, 36, \, \, \, 36, 36, Pn(\, 7) ], inf),
	snap01: Pseq([ \, \, 69, \, 69, \, 69, \, 69, \, 69, \, \ ], inf),
	snap02: Pseq([ \, \, 69, \, 69, \, 69, \, 69, \, 69, \, 69 ], inf),
	snap03: Pseq([ \, \, 69, \, 69, \, 69, \, 69, \, 69, \, 69, \, 69, \, 69, \, 69 ], inf),
	sn02: Pseq([ 67, 67, \, 67, \, 67, \, 67, \, 67, 67, \, 67, \, 67, \, 67 ], inf),
	sn10: Pseq([ \, 62, \, 62, \, 62, \, 62, \, 62, \, 62, 62, 62, \, 62, \, 62, \, 62, \, 62, \, 62, \, 62, \, 62, 62, 62, \, 62 ], inf),
	kik02: Pseq([ 60, \, 60, \, 60, 60, \, 60, \, 60, \, 60, \, 60, 60, \, 60, \, 60 ], inf),
	kik10: Pseq([ 60, \, 60, \, 60, \, 60, \, 60, 60, \, 60, \, 60, \, 60, 60], inf),
	edgeBass00: Pseq([ 36, \, 39, \, 36, \, 36, \, 36, 36, \ ], inf),
	edgeBass01: Pseq([ 48, \, 47, 46, \, 45, 44, \, 45, 46, \, 42, 43, \, 36, 36, \, 36, 36 ], inf),
	edgeBass03: Pseq([ 48, \, 48, \, 48, \, 51, \, 47, \, 47, \, 47, 48, \, 48, 51, \, 51, 51, 48, 51, \, 51, 51 ], inf) -12,
	bass10: Pseq([48, 59, 54, 62, 54, 65, \, 65, \, 58, \], inf) -12,
),

durEdge:(
	dis05: Pseq([4.5, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.75 ], inf),
	dis10: Pseq([0.5, Pn(0.25, 6), 0.5, Pn(0.25, 6), 0.5, Pn(0.25, 13), 0.75, Pn(0.25, 6), 0.5, Pn(0.25, 19), 0.75], inf),
	pr05: Pseq([ 1.5, Pn(0.25, 7), 4.75 ], inf),
	pr10: Pseq([ 0.5, Pn(0.25, 14), 2.0, 1.0, 1.0, 0.5, Pn(0.25, 8), 0.5, 5.0 ], inf),
	ins05: Pseq([ 1.0, 0.25, 0.25, 0.5, 1.0, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 3.25 ], inf),
	ins10: Pseq([ Pn(0.25, 16), 0.5, Pn(0.25, 14), 0.5, Pn(0.25, 22), 0.5, Pn(0.25, 6) ], inf),
	con05: Pseq([ 2.0, 1.0, 3.5, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25], inf),
	con10: Pseq([  0.5, 1.5, 0.5, 1.5, 0.5, 1.25, 0.25, 0.5, 1.5, 0.5, 1.5, 0.5, 1.0, 0.5, 3.75, 0.25], inf),
	lec05: Pseq([3.5, 0.5, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.75], inf),
	lec10: Pseq([ Pn(0.25, 48), 1.5, 2.5], inf),
	snap01: Pseq([ 0.25, 0.75, 0.25, 1.75, 0.25, 0.5, 0.25, 1.0, 0.25, 1.75, 0.25, 0.25, 0.5 ], inf),
	snap02: Pseq([ 0.25, 0.75, 0.25, 1.75, 0.25, 0.5, 0.25, 1.0, 0.25, 1.75, 0.25, 0.5, 0.25 ], inf),
	snap03: Pseq([ 0.25, 0.25, 0.25, 0.25, 0.25, 1.25, 0.25, 0.25, 0.25, 1.25, 0.25, 0.25, 0.25, 1.25, 0.25, 0.25, 0.25, 0.5, 0.25 ], inf),
	sn02: Pseq([ 0.25, 0.25, 0.75, 0.25, 0.5, 0.25, 0.5, 0.25, 1.0, 0.25, 0.25, 0.75, 0.25, 0.5, 0.25, 0.5, 0.25 ], inf),
	sn10: Pseq([1.0, 0.25, 0.5, 0.25, 1.0, 0.25, 1.75, 0.25, 0.5, 0.25, 0.75, 0.125, 0.125, 0.25, 0.25, 0.5], inf),
	kik02: Pseq([ 0.25, 0.5, 0.25, 0.75, 0.25, 0.25, 0.5, 0.25, 1.0, 0.25, 0.5, 0.25, 0.75, 0.25, 0.25, 0.25, 0.25, 0.25, 1.0 ], inf),
	kik10: Pseq([ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.75, 0.25, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], inf),
	edgeBass00: Pseq([ 0.5, 1.25, 0.75, 1.5, 0.5, 0.25, 0.5, 0.5, 0.25, 0.5, 1.5 ], inf),
	edgeBass01: Pseq([ 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 2.0 ], inf),
	edgeBass03: Pseq([ 0.75, 0.75, 0.5, 0.25, 0.25, 0.5, 0.75, 0.25, 0.75, 0.75, 1.0, 0.5, 1.0, 0.75, 0.75, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.75, 0.5, 2.5], inf),
	bass10: Pseq([0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.5, 0.25, 0.75, 0.25, 0.75 ], inf),
),

seqRates:(
	dis: 0,
	pr: 0,
	ins: 0,
	con: 0,
	lec: 0

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
	pr21: Pseq([Pn(0.25, 8), Pn(0.125, 32)], inf),
	ins: Array.fill(~numSlots, {4}),
	ins21: 0.25,
	con: Array.fill(~numSlots, {4}),
	con21: Pseq([1, 1, 1, 0.5, 0.5, 1, 1, 2], inf),
	lec: Array.fill(~numSlots, {4}),
	lec21: Pseq([Pn(1, 8), Pn(0.25, 32)], inf),
	dis: Array.fill(~numSlots, {4}),
	dis21: 0.5,
),

durPoporgan:(
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

seqRates:(
	dis: 0,
	pr: 0,
	ins: 0,
	con: 0,
	lec: 0
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

