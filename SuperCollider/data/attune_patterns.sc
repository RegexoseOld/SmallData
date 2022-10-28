(
musar: (
    instrument: 'bell1',
    scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ruzhim], inf), // akkorde
	dur: Pseq(~melos[\duras][\ruzhim], inf),
	amp: 0.11,
    fade: 1,
    pan: 0,
	atk: 0.1,
	rls: 0.1,
	sus: Pkey(\dur)
),

musar2: (
    instrument: 'musar2',
    scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ruzhim], inf), // akkorde
	dur: Pseq(~melos[\duras][\ruzhim], inf),
    amp: 0.15,
    atk: 0.01,
    sus: 0.99,
    rls: 0.5,
    crv: -4.0,
    modRate: 0.9,
    filTime: 0.3,
    thr: 0.8,
    cgain: 1,
    fade: 0.5,
    pan: 1,
    send: -35
),

pr: (
    instrument: 'bell1',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\pr], inf) -12, // akkorde
	dur: 4,
	amp: 0.05,
    fade: 0.001,
    pan: 0,
	atk: 0.1,
	rls: 0.8,
	sus: Pkey(\dur),
    modF: 0
),

dis: (
    instrument: 'bell1',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\dis], inf) , // akkorde
	dur: 4,
	amp: 0.05,
    fade: 0.001,
    pan: 0,
	atk: 0.1,
	rls: 0.8,
	sus: Pkey(\dur),
    modF: 0
),

ins: (
      instrument: 'bell1',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\ins], inf) , // akkorde
	dur: 4,
	amp: 0.05,
    fade: 0.001,
    pan: 0,
	atk: 0.1,
	rls: 0.8,
	sus: Pkey(\dur),
    modF: 0
),

lec: (
    instrument: 'bell1',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\lec], inf) , // akkorde
	dur: 4,
	amp: 0.05,
    fade: 0.001,
    pan: 0,
	atk: 0.1,
	rls: 0.8,
	sus: Pkey(\dur),
    modF: 0
),

con: (
    instrument: 'bell1',
	scale: Scale.chromatic,
    midinote: Pseq(~melos[\melo][\con], inf) , // akkorde
	dur: 4,
	amp: 0.05,
    fade: 0.001,
    pan: 0,
	atk: 0.1,
	rls: 0.8,
	sus: Pkey(\dur),
    modF: 0
)

)
