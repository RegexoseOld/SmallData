
// test routine with simulated utterance receival
(
~sim = Routine({
    loop(
        {
            ~mock.();
            [8, 10].choose.wait;
            "mocked".postln;
        }
    )
}).play;

)
~sim.stop


~melos[\melo][\ruzhim][0..0];
Pbindef(\perc1, \dur, 1/16, \fade, Pseq((0.05,0.1 .. 0.75).mirror, inf), \send, Prand([-18, -12, -9],inf), \pan, Pwhite(-0.5, 0.5, inf), \minFreq, Pwhite(80, 300, inf), \accent, Prand([1, 2, 4], inf)).play

(~fadingSynths.do{|name| Pbindef(name).play(~t, quant:1)};)

//start fadingSynths with fade = 0, they are getting louder with the att* Functions
 (~fadingSynths ).do{|name| Pbindef(name).play(~t, quant:4)};


Pbindef(\dis, \amp, 0.53, \fade, 0.6).trace.play
Pbindef(\dis, \atk, 0.9, \rls, 1.4);
Pbindef(\ins, \resoFreq, 400)
Pbindef(\lec, \resoFreq, 500)
Pbindef(\con, \resoFreq, 500)

~allocateSynth.value(\dissent, 51)
~allocateSynth.value(\praise, 51)
~allocateSynth.value(\concession, 43)
~allocateSynth.value(\lecture, 54)
~allocateSynth.value(\insinuation, 54)

(
var vel;
~tNote = 64;
vel = ~melos[\zit][\vel][~tNote.asSymbol];
~midiOut.noteOn(0, ~tNote, vel)

)
~midiOut.noteOn(0, ~tNote, 0);


~reverb = Synth(\reverb, [\lofr, 100, \hifr, 200])