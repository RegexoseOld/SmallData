(
patterns: (
    con0: (
        instrument: 'percImp',
        scale: Scale.chromatic,
        midinote: Pseq(~melos[\melo][\ruzhim01], inf) , // akkorde
        dur: 4,
        amp: 0.15,
        fade: 0.5,
        pan: 0,
        accent: 0,
        decayScale: 1,
        minfrq: 80,
        frqOff: 0,
		out: ~ch1.inbus
    ),
    con1: (
        instrument: 'percImp',
        scale: Scale.chromatic,
        midinote: Pseq(~melos[\melo][\ruzhim01], inf) , // akkorde
        dur: 2,
        amp: 0.15,
        fade: 0.5,
        pan: 0,
        accent: 0,
        decayScale: 1,
        minfrq: 80,
        frqOff: 0,
		out: ~ch1.inbus
    ),
    con2: (
        instrument: 'percImp',
        scale: Scale.chromatic,
        midinote: Pseq(~melos[\melo][\ruzhim01], inf) , // akkorde
        dur: 2,
        amp: 0.15,
        fade: 0.5,
        pan: 0,
        accent: 0,
        decayScale: 1,
        minfrq: 80,
        frqOff: 0,
		out: ~ch1.inbus
    ),
)
)