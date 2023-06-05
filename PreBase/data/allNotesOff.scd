~allNotesOff =
    Routine({
        (1 .. 73).do{|nn|  ~midiOut.noteOn(0, nn, 0);
0.05.wait
        };
    "allNotesOff".postln;
    });