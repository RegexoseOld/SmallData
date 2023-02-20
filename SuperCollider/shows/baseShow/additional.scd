(
// these are Patterns that are manipulated globally, like drums, noises and special sound FX

drm: (
	instrument:'sampSt',
	buf: ~buffers[\bd][7],
	cgain: 1,
	fade: 0.5,
	amp: 0.13
),

vox: (
	instrument:'sampMon',
	buf: ~buffers[\lecture][0],
	dur: 2,
	spos: 0,
	rls: 1,
	fade: 0.5,
	amp: 0.23,
	),

zahl: (
	instrument:'sampMon',
	buf: Pseq(~melos[\melo][\zahlen], inf),
	dur: 1,
	spos: 0,
	rate: 1,
	rls: 1,
	fade: 1,
	amp: 0.43,
	bpf1: 1000
	),

vox2: (
	instrument: \brPhsr,
	buf:  ~buffers[\lecture][0],
	dur: 2,
	atk: 0.01,
	rls: 1.4,
	rate: 1.1,
	start: 0,
	end: 12000,
	amp: 0.3)
)

