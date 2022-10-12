(
Server.default.options.outDevice_("Scarlett 4i4 USB");
s.options.sampleRate = 48000;
s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    s.sync;
    MIDIClient.init;
    ~midiOut = MIDIOut.new(0);
    s.sync;


    SynthDef.new(\bell1, {
        // a long bell
        |gate=1|
        var sig, env, volMod, trem;
        env = EnvGen.kr(Env.adsr(\atk.kr(3.1), 0.2, 1, \rls.kr(3.1), curve:\crv.kr(10)), gate, doneAction:2);
        volMod = SinOsc.kr(\modF.kr(1), 0, 0.5)  ; // vol modulation
        trem = Vibrato.kr(\vibF.kr(1), \vibRate.kr(2), \dep.kr(0.0), \del.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1) );
        sig = SinOsc.ar(\freq.kr(100) * trem, 0, 0.5 + volMod );
        sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
        Out.ar(\out.ir(0), sig);
    }).add;



    "done".postln;

});
)
(
Pbindef(\b1,
	\instrument, \bell1,
    \freq, 320, // akkorde
	\dur, 8,
	\amp, 0.15,
    \pan, -1,
    \modF, 0
).play;

Pbindef(\b2,
    \instrument, \bell1,
    //\midinote, Pseq([53], inf), // akkorde
    \freq, 320, // akkorde
	\dur, 8,
	\amp, 0.15,
    \pan, 1,
    \modF, 0
).play;
)
Pbindef(\b2, \midinote, Pxrand([53, 72], inf) -10, \modF, 0.1 );


Pbindef(\b1, \pan, -1, \amp, 0.2, \freq, Pseq((315, 316 .. 325), inf)-238, \dur, 8 );
Pbindef(\b2, \pan, 1, \amp, 0.2, \freq, 82, \dur, 8)


Pbindef(\b1).play
Pbindef(\b1).stop
Pbindef(\b1, \midinote, [55, 59, 61], \vibF, 1, \vibRate, 1, \modF, 1, \dep, 0, \dur, 8, \rateVar, 5);


~syn = Synth(\bell1, [\freq, 200, \amp, 0.11] );
~syn.set(\modF, 0.2, \freq, 400, \modF, 0.02, \vibF, 1.5, \vibRate, 0.1, \dep, 0.1, \onset, 3, \del, 4);



(
~r1 = Routine({
      {
        [53, 55, 61, 66].do{
            |nn|
            ~midiOut.noteOn(0, nn, 20);
            //4.wait;
            //~midiOut.noteOn(0, nn, 0); // zither noteOff = noteOn mit Velocity = 0

        };
        rand(10).wait;
        [53, 55, 61, 66].do{|nn| ~midiOut.noteOn(0, nn, 0)};

    }.loop;


});

)
~r1.play;
~r1.stop;

(0..127).do{|nn| ~midiOut.noteOn(0, nn, 0)};
[53, 55, 61, 66].do{|nn| ~midiOut.noteOn(0, nn, 0)};
~midiOut.noteOn(0, 66, 0);


(
~r1 = Routine({
        [[60, 63], [70, 72]].do{
        |ch|
        ch.postln;
        Synth(\dis, [\midinote, ch, \amp, 0.11, \modF, [1, 2, 4].choose]);
        5.wait;
    }
}).play
)
~r1.stop



Pbindef(\test, \ctranspose, 0, \scale, ~values[\scale])
~values[\scale] = Scale.iraq

[1, 2, 3, 4].resamp0(12);
~values[\sequence].resamp1(3)
~values[\key] = 58







(
	s.sync;



	~values = (
		key: 48,
		scale: Scale.chromatic,
		sequence: Array.new,
		chords: Array.new
	);

	s.sync;

	~seqCalc = {
		var key, scale, seq;
		key = ~values[\key];
		scale = ~values[\scale];
		seq = scale.degrees + key;
	};

	~chordCalc = {
		var seq, prog, chords;
		seq = ~values[\sequence].scramble.resamp0(3);
		prog = [0, 4, 8, 3];
		chords = Array.fillND(prog.size, {|i| seq + prog[i]});


	};
	s.sync;




)