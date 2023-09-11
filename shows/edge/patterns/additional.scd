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
		freq: ~melos.melo.kik01,
		ampdecay: 2,
		dur: 0.25,
		out: ~perc.inbus
	),

	kik02: (
		instrument:'kik2',
		freq: ~melos.meloEdge.kik01,
		amp: 0.65,
		dur: 0.25,
		sweep: 0.06,
		timb1: -12,
		timb2: -28,
		dist: 0.5,
		rls: 1.3,
		out: ~perc.inbus
	),

	sn01: (
		instrument: 'sn2',
		freq: Pfunc({~melos.melo.sn01}),
		dur: 0.25,
		sweep: 0.05,
		shaper1: 1.0, // pumps from 1.0 on
		shaper2: 0.9, //bright
		rls: 0.17,
		amp: 0.35,
		out: ~perc.inbus
	),

	snip01: (
		instrument: 'sampMon',
		buf: ~buffers[\hi][\snap_stereo],
		trigger: ~melos.meloEdge.snap01,
		amp: 0.4,
		fade: 1,
		dur: ~melos.durEdge.snap01,
		rate: 1,
		atk: 0.01,
		rls: 0.8,
		bpf1: 1000,
		cgain: 1.5,
		zit: 0,
		out: ~perc.inbus
	),

	hh01: (
		instrument: 'percImp',
		amp: 0.1,
		dur: 0.25,
		freq: 870,
		maxfrq: 950,
		minRing: 0.01,
		maxRing: 0.08,
		accent:  Pwhite(4.0, 4.1, inf),
		decayScale: 7,
		pan: Pwhite(-0.5, 0.5, inf),
		fade: Pwhite(0.2, 0.7, inf),
		out: ~perc.inbus
	),

	metronom: (
		instrument: 'percImp',
		dur: 0.25,
		amp: 0.05,
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
		instrument: 'bass',
		midinote: ~melos.meloEdge.edgeBass00,
		dur: ~melos.durEdge.edgeBass00,
		amp: 0.45,
		fade: 1,
		modRate: 0.05,
		modPhase: pi/4,
		atk: 0.02,
		dec: 0.3,
		sus: 0.8,
		rls: 0.5,
		crv: -1.0,
		ipeak: 1,
		iatk: 0.05,
		irls: 0.1,
		icrv: -7,
		fmratio: 1,
		oscVol: 0.7,
		oscFB: pi/8, // adds a snary growl use pi/4 multiples
		devMin: 0.99,
		devMax: 1.01,
		slide1: 1.0, // adds a growl use multiples of 0.25
		slide2: 3, // pitch slide dur
		slide3: 1, // pitch slide intensity use Integers to keep Pitch
		thr: 0.6,
		cgain: 1.0,
		distort: 2.5,
		out: ~bass.inbus
	)
)
)

