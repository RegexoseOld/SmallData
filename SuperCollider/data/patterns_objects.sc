(
obj1: (
	melo: (
		a: [0, \, \, \, 3, \, \, \],
		b: [0, \, \, \, 3, \, \, \, 0, \, \, \, -6, \, \, \],
		c: [-6, \, -5, -3, -8, \, -5, \, -12, \, -10, \, -9, \, -9, \],
		d: [-7, \, -7, \, -9, \, -9, \, -12, \, -12, -10, -9, \, -9, \, -7, \, -12, \, -9, \, -12, \],
		e: [0, \, -2, \, 0, \, \, \, 3, \, \, \, 7, \, \, \],
		f: [\, 0, \, 6, \, \, \, 0, \, \, -1, \, \, 0, \, \],
		g: [0, \, \, \, \, \, \, \, -1, \, \, \, \, \, \, \, 0, \, \, \, \, \, \, \],
		h: [0, \, \, \, -1, \, \, \, 0, \, \, \, 3, \, \, \],
		i: [0, \, \, \, 3, \, \, \],
		j: [0, \, -2, \, 0, \, -12, \,
			-9, \, -6, \, -5, \, -12, \,
			-5, \, -3, \, 0, \, -6, \,
			-5, -7, -9, -5, -9, \, -12, \],
		k: [6, \, 7, 9, 3, \, 6, \, 0, \, 2, \, 3, \, 3, \,
			5, \, 5, \, 3, \, 3, \, 0, \, 0, 2, 3, \, 3, \,
			6, \, 0, \, 6, \, 0, \],
		l:[0, \, -1, \, -2, \, -1, \, 0, -12, \, -0, -12, \, \, 0],
		m:[-9, \, -7, \, -6, \, -5, \, -5, -12, \, -5, -12, \, \, 0],
		n:[-5, \, -4, \, -3, \, -2, \, 0, -5, \, 0, -6, \, \, 0],
		o:[-5, \, -6, \, -8, -9, -10, \, -9, -12, \, -9, -12, \, \, -12],

	),

	lec: (
		instrument: 'lecture',
		scale: Scale.chromatic,
		dur: 1,
		atk: 0.05,
		sus: 0.5,
		rls: 0.2,
		crv: -3.0,
		modRate: 0.8,
		det1: 0.98,
		det2: 1.02,
		filTime: 0.3,
		lag: 0,
		thr: 0.8,
		cgain: 5,
		distort: 2.5,
		fade: 0,
		send: -30,
		sustain: 0.2
	),

	fm: (
		instrument: 'fmBass',
		scale:Scale.chromatic,
		dur: 1,
		atk: 0.04,
		rls: 0.4,
		crv: -4.0,
		distort: 1,
		send: -40,
		sustain: 0.3,
		fade: 0
	),

	atak: (
		instrument: 'attack',
		dur: Pwrand([1, Pwhite(1/8, 1, 2)], [0.2,1].normalizeSum, inf),
		atk: 0.01,
		dec: 0.1,
		sus: 0.2,
		rls: 0.2,
		crv: -1.0,
		freq: 1200,
		ef: 80,
		lag: 0,
		fdur: 0.12,
		which: Pxrand([0,1,2],inf),
		fade: 1,
		outfx:~fx1Bus,
		send: -35
	)
),

obj2: (
	melo: (
		a: [0, -4, 3],
		b: [0, -4, 3],
	),

	atag: (
		instrument: 'attack',
		dur: 4,
		atk: 0.01,
		dec: 0.2,
		sus: 0.01,
		rls: 0.11,
		crv: -1.0,
		fdur: 0.03,
		lag: 0,
		which: Pxrand([0,1,2],inf),
		thres: 0.4,
		cgain: 2,
		fade: 1,
		outfx:~fx1Bus,
		send: -35
	),

	biz: (
		instrument: 'bizz',
		dur: 2,
		atk: 0.01,
		dec: 0.1,
		sus: 0.18,
		rls: 0.2,
		crv: -3.0,
		tRate: Pseq([5, \, \, 5, \, \, 20, \], inf),
		pulseL: Pwhite(80, 150, inf),
		pulseH: Pkey(\tRate) * 80 ,
		phs: 0.0,
		distort: 1.0,
		thres: 0.4,
		cgain: 2,
		fade:1

	),

	bd01: (
		instrument: 'concession',
		buf: ~buffers[\bd][10],
		dur: 1,
		fShift: 0.002,
		mix: -1,
		rate:  Pseq([1, \, \, \, \, \, 1, \, 1, \, \, \, \, \, \, \ ], inf),
		bpf: 100,
		rq: 5,
		thres: 0.7,
		cgain: 2,
		fade: 0.5
	),

	sn01: (
		instrument: 'concession',
		buf: ~buffers[\sn][11],
		dur: 1,
		fShift: 0.002,
		mix: -1,
		rate: Pseq([\, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \], inf),
		bpf: 500,
		rq: 5,
		thres: 0.7,
		cgain: 2,
		fade: 0.5

	),

	hh01: (
		instrument: 'concession',
		buf: Pseq([Prand(~buffers[\hh_spec], 14), ~buffers[\hh][0], ~buffers[\hh_spec][1] ], inf),
		dur: 1/2,
		fShift: 0.002,
		mix: -1,
		rate:1,
		bpf: 500,
		rq: 5,
		thres: 0.7,
		cgain: 2,
		fade: 0.5

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
		cgain: 2,
		amp: 0.3,
		fade: 0.5
	),

	con: (
		instrument: 'concession',
		buf: Pseq(~buffers[\hh_spec],inf),
		dur: 1,
		rate: Pwhite(0.9, 1.1, inf),
		pan: Pwhite(-0.5, 0.5, inf),
		bpf: 400,
		fShift: 0.5,
		outfx: ~fx2Bus,
		amp: 0.2,
		send: -35
	),


),

obj4: (
	melo: (
		a: [0, -4, 3],
		b: [0, -4, 3],
	),

	atack: (
		instrument: 'attack',
		dur: [4, 3].choose,
		atk: 0.01,
		dec: 0.2,
		sus: 0.01,
		rls: 0.11,
		crv: -1.0,
		freq: 700,
		freq2: 200,
		fdur: 0.03,
		phas: 1,
		shift: 0.2,
		which: [0, 1, 2, 3].choose,
		thres: 0.4,
		cgain: 2.3,
		fade: Pgeom(1, 0.9, 12),
		outfx:~fx1Bus,
		send: -35
	),

	blibz: (
		instrument: 'bizz',
		dur: 2,
		atk: 0.01,
		dec: 0.1,
		sus: 0.18,
		rls: 0.2,
		crv: -3.0,
		tRate: Pseq([5, \, \, 5, \, \, 20, \], inf),
		pulseL: Pwhite(80, 150, inf),
		pulseH: Pkey(\tRate) * 80 ,
		phs: 0.0,
		distort: 1.0,
		thres: 0.4,
		cgain: 2,
		fade:0

	),
	sampl: (
		instrument: 'concession',
		buf: Pseq(~buffers[\hh_spec],inf),
		dur: 0.5,
		rate: Pwhite(0.9, 1.1, inf),
		pan: Pwhite(-0.5, 0.5, inf),
		bpf: 400,
		fShift: 0.5,
		outfx: ~fx2Bus,
		amp: 0.2,
		send: -30,
		fade: 0
	)
)

);