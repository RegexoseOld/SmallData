(
obj1: (
	melo: (
		a: [0, \, \, \, \, \, \, \, \, \, \, \, \, \, \, \ ],
		b: [0, \, \, \, \, \, \, \, -2, \, \, \, \, \, \, \ ],
	    c: [0, 0, 0, 0, 0, \, \, \, -2, -2, -2, -2, \, \, \],
		held1: [-6, \, -5, -3, -8, \, -5, \, -12, \, -10, \, -9, \, -9, \],
		held2: [-7, \, -7, \, -9, \, -9, \, -12, \, -12, -10, -9, \, -9, \, -7, \, -12, \, -9, \, -12, \],
		hast1: [0, \, -2, \, 0, \, -12, \, -9, \, -6, \, -5, \, -12, \,
			-5, \, -3, \, 0, \, -6, \, -5, -7, -9, -5, -9, \, -12, \],
		hast2: [-6, \, -5, -3, -9, \, -6, \, 12, \, -10, \, -9, \, -9, \,
			-7, \, -7, \, -9, \, -9, \, -12, \, -12, -10, -9, \, -9, \,
			-6, \, -12, \, -6, \, -12, \],
		ha1: [0, \, -1, \, -2, \, -1, \, 0, -12, \, -0, -12, \, \, 0],
		ha2: [-9, \, -7, \, -6, \, -5, \, -5, -12, \, -5, -12, \, \, 0],
		ha3: [-5, \, -4, \, -3, \, -2, \, 0, -5, \, 0, -6, \, \, 0],
		ha4: [-5, \, -6, \, -8, -9, -10, \, -9, -12, \, -9, -12, \, \, -12],
		ha5: [0, \, -2, \, 0, \, -12, \,-9, \, -6, \, -5, \, -12, \],
		ha6: [-5, \, -3, \, 0, \, -6, \, -5, -7, -9, -5, -9, \, -12, \],
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
		thr: 0.6,
		cgain: 5,
		distort: 2.5,
		fade: 0,
		send: -30,
		sustain: 0.2
	),

	fm: (
		instrument: 'fmBass',
		scale: Scale.chromatic,
		dur: 1,
		atk: 0.04,
		rls: 0.4,
		crv: -4.0,
		distort: 1,
		send: -40,
		sustain: 0.3,
		fade: 0
	),

),

obj2: (
	melo: (
		a: [1],
		bd01: [1, \, \, \, \, \, 1, \, 1, \, \, \, \, \, \, \ ],
		bd02: [1, 1, 1, \, \, \, 1, \, 1, 1, \, \, \, \, \, \ ],
		bd03: [1, \, 1, \,  \, \, \, \],
		bd04: [1, 1, 1, 1, \, \, \, \, \, 1, \, \, \, \, \, \],
		sn01: [\, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, 1],
		sn02: [\, \, \, \, \, \, \, \, 1, 1, 1, \, \, \, \, \],
		sn03: [1, 1, \, \, 1, \, \, \, \, \, \, 1, \, \, \, \],
		sn04: [\, \, \, \, 1, \, \, \, \, \, \, 1, \, \, \, \],
		hh01: [1, \, 1, \, 1, \, 1, \, 1, \, 1, \, 1, \,
			1, \, 1, \, 1, \, 1, \, 1, \, 1, \, 1, 1],
		arp1: [Prand(~buffers[\klics], 24), Pn(\,32), Pseq([~buffers[\klics][2], 76]),  Pn(\, 32) ]
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
	arp: (
		instrument: 'concession',
		buf: ~buffers[\klics][6],
		dur: 1/2,
		atk: 0.02,
		rls: 0.1,
		sus: 0.1,
		spos: 0,
		mix: 0,
		bpf: 1000,
		fade: 0.0
	),

	bd1: (
		instrument: 'concession',
		buf: ~buffers[\bd][10],
		dur: 4,
		fShift: 0.002,
		mix: -1,
		rate: 1,
		bpf: 100,
		rq: 2,
		thres: 0.7,
		cgain: 4,
		amp: 0.3,
		fade: 0.6
	),

	sn1: (
		instrument: 'concession',
		buf: ~buffers[\sn][11],
		dur: 2,
		fShift: 0.002,
		mix: -1,
		rate: 1,
		bpf: 500,
		rq: 5,
		thres: 0.7,
		cgain: 3,
		fade: 0.6

	),

	hh1: (
		instrument: 'concession',
		buf: ~buffers[\hh][2],
		dur: 1/2,
		fShift: 2,
		mix: 1,
		rate: 1,
		bpf: 1900,
		rq: 2,
		thres: 0.7,
		cgain: 2,
		fade: 0.2
	),

	zahl: (
		instrument: 'concession',
		buf: Pseq([~buffers[\zahlen][0], ~buffers[\zahlen][1], ~buffers[\zahlen][2], ~buffers[\zahlen][3], ~buffers[\zahlen][4], ~buffers[\zahlen][5], ~buffers[\zahlen][6], ~buffers[\zahlen][7]], inf),
		dur: 1,
		fShift: 0.002,
		mix: -1,
		rate: 1.2,
		bpf: 1700,
		rq: 5,
		thres: 0.4,
		cgain: 2,
		amp: 0.3,
		fade: 0.5
	),

),

obj3: (
	melo: (
		a: [[60, 63, 67]],
		partA: [[60, 64, 67, 72]],
		partB: [[58, 64, 68, 72]],
		partC: [[59, 65, 69]]
	),

	org1: (
		instrument: 'insinuation',
		dur: 0.5,
		slideTime: 0,
		noisFreq: 0.0,
		maxF: 1000,
		modWidth: 0.3,
		fShift: 20,
		fade: 0.2
	),

	org2: (
		instrument: 'praise',
		dur: 0.5,
		atk: 0.4,
		rls: 1,
		pulRate:4,
		pulWidth: 1,
		ampScale: 0.9,
		fade: 0.2
	)
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
		buf: Pseq(~buffers[\hh],inf),
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

)