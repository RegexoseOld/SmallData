(
// these are Patterns that are manipulated globally, like drums, noises and special sound FX
patterns: (
	drm: (
		instrument:'sampSt',
		buf:  ~buffers[\bd][\BD2],
		cgain: 1,
		fade: 0.5,
		amp: 0.13
	),

	kik01: (
		instrument:'kik1',
		freq: ~melos.melo.kik01,
		dur: 0.25,
		out: ~perc.inbus
	),

	kik02: (
		instrument:'kik2',
		freq: ~melos.melo.kik01,
		amp: 0.65,
		dur: 0.25,
		timb1: -6,
		timb2: -12,
		dist: 1,
		out: ~perc.inbus
	),

	sn01: (
		instrument: 'sn2',
		freq: Pfunc({~melos.melo.sn01}),
		dur: 0.25,
		atk1: 0.2,
		amp: 0.35,
		out: ~perc.inbus
	),

	hh01: (
		instrument: 'percImp',
		dur: 0.25,
		accent:  Pwhite(0, 9.0, inf),
		decayScale: Pwhite(0.1, 0.23, inf),
		amp: 0.43,
		out: ~perc.inbus
	),

	metronom: (
		instrument: 'percImp',
		dur: 0.25,
		amp: Pseq([0.8, 0.1, 0.1, 0.1], inf),
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
		rls: 1.4,
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
		midinote:  ~melos.meloEdge.edgeBass00,
		dur: ~melos.durEdge.edgeBass00,
		amp: 0.33,
		atk: 0.02,
		rls: 0.2,
		crv: -1.0,
		dev1:0.99,
		dev2: 1.01,
		modRate: 1,
		filTime: 0.2,
		thr: 0.6,
		fmFreq: 2000,
		fmVol: 60,
		cgain: 1.4,
		distort: 2.0,
		fade: 1,
		out: ~bass.inbus
	)
)
)

