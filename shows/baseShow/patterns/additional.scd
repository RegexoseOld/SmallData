(
// these are Patterns that are manipulated globally, like drums, noises and special sound FX
patterns: (
	drm: (
		instrument:'sampSt',
		buf: ~buffers[\bd][\BD2],
		cgain: 1,
		fade: 0.5,
		amp: 0.13
	),

	kik01: (
		instrument:'kik1',
		dur: 0.125,
		amp: 0.6,
		freq: ~melos.melo.kik01,
		freqdecay: 0.1,
		ampdecay: Pseq([1.3, Pn(\, 7), 0.6, Pn(\, 7), 0.6, Pn(\, 6), 0.6, 1.5, Pn(\, 7) ], inf),
		out: ~perc.inbus,
	),

	kik02: (
		instrument:'kik2',
		dur: 0.125,
		freq: ~melos.melo.kik01,
		amp: 0.5,
		timb1: -8,
		timb2: -20,
		dist: 1,
		out: ~perc.inbus
	),

	sn01: (
		instrument: 'sn1',
		dur: 0.25,
		atk1: 0.001,
		rls1: Pwhite(0.2, 1.2, inf),
		crv1: -2,
		ghosts: Pseq([\, \, 50,  \, \, \, 45, \], inf),
		freqDecay: 2.3,
		numharm: 100,
		distort: 2,
		ffreq: Pwhite(800, 2000, inf),
		amp: 0.5,
		out: ~perc.inbus
	),

	hh01: (
		instrument: 'percImp',
		dur: 0.125,
		accent:  Pwhite(3, 5, inf),
		decayScale:  Pwhite(0.01, 0.2, inf),
		out: ~perc.inbus
	),

	metronom: (
		instrument: 'percImp',
		dur: 0.25,
		amp: 0.1,
		minfrq: 800,
		maxfrq: 900,
		accent: Pseq([4, 1, 1, 1], inf),
		out: ~perc.inbus
	),

	mono: (
		instrument:'sampMon',
		buf:  Pseq(~melos[\slots][\utt], inf),
		dur: 2,
		spos: 0,
		rls: 1,
		fade: 0.5,
		amp: 0.23,
	),

	stereo: (
		instrument:'sampSt',
		buf:  Pseq(~melos[\slots][\utt], inf),
		dur: 2,
		spos: 0,
		rls: 1,
		fade: 0.5,
		amp: 0.23,
	),

	zahl: (
		instrument:'sampMon',
		buf: Pseq(~melos[\slots][\zahlen], inf),
		dur: 1,
		spos: 0,
		rate: 1,
		rls: 1,
		fade: 1,
		amp: 0.8,
		cgain: 2,
		bpf1: 1000
	),

	vox: (
		instrument: 'brPhsr',
		buf: Pseq(~melos[\slots][\utt], inf),
		dur: 2,
		atk: 0.01,
		rls: 0.1,
		start: 0,
		end: 5000,
		amp: 0.3
	),

	grainvox: (
		instrument: 'tgrains',
		buf: Pseq(~melos[\slots][\utt], inf),
		dur: 2,
		atk: 0.01,
		sus: 2,
		rls: 1.4,
		dens: 10,
		rate: 1,
		harm: [1, -1],
		pos: 0.5,
		grainDur: 1.5,
		pan:0,
		amp: 0.3
	),

	bass: (
		instrument:'bass',
		midinote:  ~melos.melo.bass3,
		dur: 0.125,
		amp: 0.3,
		atk: 0.02,
		rls: 0.2,
		crv: -3.0,
		modRate:0.6,
		filTime: 0.1,
		thr: 0.6,
		fmFreq: 1400,
		fmVol: 60,
		cgain: 2.0,
		distort: 2.5,
		fade: 1,
		sustain: 0.2,
		out: ~bass.inbus
	),

	bass1: (
		instrument:'bass',
		midinote:  ~melos.melo.bass4,
		dur: 0.125,
		amp: 0.3,
		atk: 0.02,
		rls: 0.2,
		crv: -3.0,
		modRate: 0.2,
		filTime: 0.65,
		thr: 0.6,
		fmFreq: 1400,
		fmVol: 110,
		cgain: 2.0,
		distort: 1.5,
		fade: 1,
		sustain: 0.2,
	    out: ~bass.inbus
	)
)
)

