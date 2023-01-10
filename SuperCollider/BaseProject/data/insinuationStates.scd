(
patterns: (
    ins0: (
        instrument: 'bellFm',
        scale: Scale.chromatic,
        midinote: Pseq(~melos[\melo][\ins], inf) , // akkorde
        dur: 4,
        amp: 0.05,
        fade: 0.01,
        thr: 0.5,
        cgain: 2,
        pan: 0,
        atk: 0.8,
        rls: 2,
        vibF: 0.2,
        vibVol: 30,
        bpf1: 300,
        bpf2: 5,
        bpf3: 0.3,
        bpfQ: 0.9
    ),
    ins1: (
        instrument: 'bellFm',
        scale: Scale.chromatic,
        midinote: Pseq(~melos[\melo][\ins], inf) , // akkorde
        dur: 2,
        amp: 0.05,
        fade: 0.01,
        thr: 0.5,
        cgain: 2,
        pan: 0,
        atk: 0.8,
        rls: 2,
        vibF: 0.2,
        vibVol: 30,
        bpf1: 300,
        bpf2: 5,
        bpf3: 0.3,
        bpfQ: 0.9
    ),
)
)