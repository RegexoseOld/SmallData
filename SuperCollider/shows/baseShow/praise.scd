(
patterns: (
	pr0: (
		instrument: 'fm',
		midinote: ~melos.melo.pr,
		modRate: 0.4,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.07,
		crv: -7,
		dur: 0.25,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.8,
		sustain: 0.14
	),

	pr1: (
		instrument: 'fm',
		midinote: ~melos.melo.pr,
		modRate: 0.1,
		fmVol: 10,
		devMin: 0.999,
		devMax: 1.0001,
		distort: 1.5,
		thr: 0.99,
		cgain: 1.0,
		atk: 0.02,
		rls: 0.07,
		crv: -7,
		dur: 0.25,
		amp: Pfunc({~melos.amps.pr}),
		fade: 0.8,
		sustain: 0.14

	),
	    pr05: (
        instrument: 'bellFm',
        midinote: ~melos.melo.pr05,
        dur: 0.25,
        amp: Pfunc({~melos.amps.pr}),
        fade: 0.5,
        thr: 0.5,
        cgain: 1,
        pan: 0,
        atk: 0.02,
        rls: 0.09,
        vibF: 0.8,
        vibVol: 30,
        dev: 0.08,
        spread: 0.16,
        bpf1: 500,
        bpf2: 5,
        bpf3: 0.3,
        bpfQ: 0.9,

    ),

    pr10: (
        instrument: 'bellFm',
        midinote: ~melos[\melo][\pr10],
        dur: 1,
        amp:  Pfunc({~melos.amps.pr}),
        fade: 0.5,
        thr: 0.5,
        cgain: 2,
        pan: 0,
        atk: 0.8,
        rls: 2,
        vibF: Pseq([0.6, 0.8, 1.0, 1.2],inf),
        vibVol: 30,
        bpf1: Pwhite(200, 600, inf),
        bpf2: 5,
        bpf3: 0.3,
        bpfQ: 0.9,

))

)