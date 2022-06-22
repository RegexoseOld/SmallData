(
dis: (
	instrument: 'dissent',
	scale: Pfunc({~sharedValues[\scale]}),
	degree: Pseq([0, Pseq([\], 7)], inf),
	ctranspose: Pfunc({~sharedValues[\transpose]}),
	dur: 1,
	atk:1.5,
	sus: 0.9,
	rls: 4.5,
	ampDist: 0.5,
	durDist: 1.0,
	minfreq: 200,
	maxfreq: 750,
	ffreq: 300,
	gendAmp: 0.4,
	resoFreq: 800,
	modF: 0.8,
	width: 0.8,
	pulseMul: 0.61,
	amp: Pfunc({~sharedValues[\vol]}),
	pan: 0.0,
	sustain: 2.0,
	send: -30,
),

lec: (
	instrument: 'lecture',
	scale: Pfunc({~sharedValues[\scale]}),
	ctranspose: Pfunc({~sharedValues[\transpose]}) -12,
	degree: Pseq((0, -1 .. -7), inf),
	dur: 2,
	atk: 0.05,
	sus: 0.9,
	rls: 1.2,
	crv: -3.0,
	modRate: 0.8,
	det1: 0.98,
	det2: 1.02,
	filTime: 0.2,
	amp: 0.1,
	distort: 2.5,
	fade: 1,
	send: -30,
	sustain: 0.2
),

fm: (
	instrument: \fmBass,
	scale: Pfunc({~sharedValues[\scale]}),
	ctranspose: Pfunc({~sharedValues[\transpose]}),
	degree: Pseq([0, \r, \r, \r,
		-6, Pseq([\r], 3),
		-5, Pseq([\r], 3),
		-6, Pseq([\r], 3),
	], inf),
	dur: 1,
	atk: 0.04,
	rls: 0.4,
	crv: -4.0,
	distort: 1,
	amp: Pfunc({~sharedValues[\vol]}) /2,
	send: -40,
	sustain: 0.3,
	fade:0

),

ins: (
	instrument: 'insinuation',
	scale: Pfunc({~sharedValues[\scale]}),
	ctranspose: Pfunc({~sharedValues[\transpose]}) +12,
	degree: Pseq([
		Pseq([-5],5), Pseq([\r],13),
		[-8, 0], Pseq([\r], 15),
		[-5, 3], Pseq([\r],15),
		Pseq([\r], 16)
	], inf),
	dur: 1/8,
	atk: 0.01,
	sus: 0.05,
	rls: 0.05,
	slideTime: 0.02,
	noisFreq: 0.1,
	maxF: 600,
	ffreq: 3.0,
	modWidth: 0.15,
	preamp: 0.3,
	fShift: 100,
	sustain: 0.1,
	send: -30
),

bass01: (
	instrument: 'lecture',
	ctranspose: Pfunc({~sharedValues[\transpose]}) -24,
	degree: Pseq([0,3], inf),
	dur: 4,
	atk: 0.05,
	sus: 0.9,
	rls: 1.2,
	crv: -3.0,
	modRate: 0.8,
	det1: 0.98,
	det2: 1.02,
	filTime: 0.6,
	amp: 0.5,
	distort: 2.5,
	fade: 1,
	send: -30,
	sustain: 0.2
),

bd01: (
	instrument: \concession,
	buf: ~buffers[\bd][10],
	dur: 1,
	fShift: 0.002,
	mix: -1,
	rate:  Pseq([1, \, \, \, \, \, 1, \, 1, \, \, \, \, \, \, \ ], inf),
	bpf: 100,
	rq: 5,
	thres: 0.7,
	cgain: 5

),
sn01: (
	instrument: \concession,
	buf: ~buffers[\sn][11],
	dur: 1,
	fShift: 0.002,
	mix: -1,
	rate: Pseq([\, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \], inf),
	bpf: 500,
	rq: 5,
	thres: 0.7,
	cgain: 5

),

hh01: (
	instrument: \concession,
	buf: Pseq([Prand(~buffers[\hh_spec], 14), ~buffers[\hh][0], ~buffers[\hh_spec][1] ], inf),
	dur: 1/2,
	fShift: 0.002,
	mix: -1,
	rate:1,
	bpf: 500,
	rq: 5,
	thres: 0.7,
	cgain:  5

),

zahl: (
	instrument: 'concession',
	buf: Pseq([~buffers[\zahlen][0], ~buffers[\zahlen][1], ~buffers[\zahlen][2], ~buffers[\zahlen][3], ~buffers[\zahlen][4], ~buffers[\zahlen][5], ~buffers[\zahlen][6], ~buffers[\zahlen][7]], inf),
	// buf: Pseq([Prand(~buffers[\zahlen], 14), ~buffers[\zahlen][0], ~buffers[\zahlen][7] ], inf),
	dur: 1,
	fShift: 0.002,
	mix: -1,
	rate: 1.2,
	bpf: 800,
	rq: 5,
	thres: 0.4,
	cgain: 5,
	amp: 0.3
),

con: (
	instrument: 'concession',
	buf: Pseq(~percArray,inf),
	dur: 1,
	rate: Pwhite(0.9, 1.1, inf),
	pan: Pwhite(-0.5, 0.5, inf),
	bpf: 400,
	fShift: 0.5,
	outfx: ~fx2Bus,
	amp: 0.2,
	send: -35
),

pr: (
	instrument:'praise',
	ampHz: 0.2,
	pulWidth: 0.9,
	ampScale: 0.75,
	atk: 0.01,
	rls: 3.5,
	fRate: 0.2,
	//degree: Pseq([[0, 4, 7], [2, 8, 11], [4, 2, 5]], inf),
	degree: Pwrand(
		[
			Pseq([12, \r, \r, \r,
				Prand([9, 6, 10],1), \r, \r, \r,
				Prand([10, 9, 6], 1), \r, \r, \r,
				Pseq([\], 4)],1),
			Pseq([[12, 9 ,4], \r, \r, \r,
				[9, 12], \r, \r, \r,
				4, \r, \r, \r,
				Pseq([\], 4)],1),
			Pseq([\r],16)
	], [0.1, 0.5, 0.1, 0.2].normalizeSum, inf),
	fMul: 1,
	rnd: 1.0,
	pulRate: Pwrand([Pn(Pseq([0.2], 11), Pseq([5], 5), 1), Pseq([0.2], 16)], [0.1, 0.9], inf),
	width: 0.2,
	ffreq: 300,
	rq: 1.0,
	bpf: Prand([120, 130, 220, 330], inf),
	send: -30,
	dur: 1,
	amp: Pfunc({~sharedValues[\vol]}),
	sustain: 1.2

)
);