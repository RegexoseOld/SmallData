(
obj1: (
	melo: (
		a: Pseq([0, -4, 3], inf) -12,
		b: Pseq([0, -4, 3].reverse, inf),
		c: Pseq((3, 2 .. -3).reverse.mirror, inf),
	),

	lec: (
		instrument: 'lecture',
		dur: 1,
		atk: 0.05,
		sus: 0.5,
		rls: 0.2,
		crv: -3.0,
		modRate: 0.8,
		det1: 0.98,
		det2: 1.02,
		filTime: 0.2,
		amp: 0.1,
		distort: 2.5,
		fade: 0,
		send: -30,
		sustain: 0.2
	),

	fm: (
		instrument: 'fmBass',
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
		dur: Pwrand([1, Pwhite(1/8, 1/2, 1)], [0.2,1].normalizeSum, inf),
		degree: 1,
		atk: 0.01,
		dec: 0.1,
		sus: 0.2,
		rls: 0.1,
		crv: -1.0,
		fdur: 0.12,
		which: Pxrand([0,1,2],inf),
		sustain: Pkey(\rls),
		fade: 1
	)
),

obj2: (
	melo: (
		a: Pseq([0, -4, 3], inf) -12,
		b: Pseq([0, -4, 3].reverse, inf),
	),

	pr: (
		instrument: 'praise',
		dur: 1,
		atk: 0.05,
		sus: 0.5,
		rls: 0.2,
		fade: 0,
		send: -30,
		sustain: 0.2
	),

	con: (
		instrument: 'concession',
		dur: 1,
		atk: 0.04,
		rls: 0.4,
		crv: -4.0,
		distort: 1,
		send: -40,
		sustain: 0.3,
		fade:0
	),

	ins: (
		instrument: 'insinuation',
		dur: 1,
		atk: 0.01,
		dec: 0.2,
		sus: 0.1,
		rls: 0.4,
		fade: 0
	)
),

);