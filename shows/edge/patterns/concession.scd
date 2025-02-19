(
patterns: (
	con00: (
		instrument: 'bellFm',
		midinote: 60,
		amp: Pfunc({~melos.amps.con}),
		fade: 0.2,
		dur: 8,
		index: 1,
		mRatio: 1,
		cRatio: 1,
		atk: 0.5,
		rls: 3,
		crv: 5,
		vibF: 0.2,
		vibVol: 30,
		trmF: 1,
		trmRate: 6,
		trmDep: 0.0,
		trmDel: 1,
		onset: 3,
		rateVar: 0.5,
		varDur: pi/4,
		spread: 0.05,
		dev: 0,
		out: ~ch4.inbus
	),
con05: (
		instrument: 'bellFm',
		midinote: 72,
		amp: Pfunc({~melos.amps.con}),
		fade: 0.2,
		dur: 8,
		index: 1,
		mRatio: 1,
		cRatio: 1,
		atk: 0.5,
		rls: 3,
		crv: 5,
		vibF: 0.2,
		vibVol: 30,
		trmF: 1,
		trmRate: 6,
		trmDep: 0.0,
		trmDel: 1,
		onset: 3,
		rateVar: 0.5,
		varDur: pi/4,
		spread: 0.05,
		dev: 1.5,
		out: ~ch4.inbus
	),
	con10: (
		instrument: 'fmFine',
		midinote: ~melos.melo.con10,
		amp: Pfunc({~melos.amps.con}),
		fade: 0.7,
		detune: Pwhite( -10, 3, inf),
		fratio0: 1, // Integer values for pitch accuracy
		fratio1: 1,
		fratio2: 1,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.0,
		thr: 0.65,
		cgain: 1.3,
		atk: 0.02,
		rls: 0.07,
		crv: -5,
		dur: 0.25,
		out: ~ch4.inbus

	),

	con15: (
		instrument: 'bellFm',
		midinote: ~melos.melo.con15,
		dur: ~melos.dur.con15,
		amp: Pfunc({~melos.amps.con}),
		fade: 0.6,
		thr: 0.5,
		cgain: 1,
		pan: 0,
		atk: 0.05,
		rls: 0.12,
		vibF: 0.8,
		vibVol: 40,
		dev: 0.08,
		spread: 0.07,
		bpf1: 600,
		bpf2: 5,
		bpf3: 0.3,
		bpfQ: 0.9,

	),
	con20: (
		instrument: 'fmFine',
		midinote: ~melos.melo.con20,
		amp: Pfunc({~melos.amps.con}),
		dur: ~melos.dur.con20,
		fade: 0.7,
		detune: Pwhite( -10, 3, inf),
        modInd0: 1,
		fratio0: 1, // Integer values for pitch accuracy
        modInd1: Pwhite(0.1, 3, inf),
		fratio1: 1,
        modInd2: Pwhite(0.1, 3, inf),
		fratio2: 1,
		distort: 1.0,
		thr: 0.65,
		cgain: 1.3,
		protorls: 0.08,
		atk: 0.02,
		rls: 0.08,
		crv: 3,
	),

	con40: (
		instrument: 'bellFm',
		midinote: ~melos[\melo][\con25],
		detune: Pn(Pgeom(20, 0.84, 16), inf),
		amp: Pfunc({~melos.amps.con}),
		dur: 0.25,
		fade: 0.5,
		thr: 0.5,
		cgain: 1.2,
		pan: 0,
		index: 1,
		mRatio: 2,
		cRatio: 3,
		atk: 0.03,
		rls: 0.6,
		crv: -4,
		vibF: 10,
		vibVol: 40,
		dev: 0.01,
		spread: 0.02,
		bpf1: Pn(Pgeom(3000, 0.93, 16), inf),
		bpf2: 3,
		bpf3: 0.3,
		bpfQ: 0.9,
		fmDur: 0.04,
	),


)
)
