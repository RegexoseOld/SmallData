(
~configPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configPath.load;
~dataPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.outDevice.postln;

ServerTree.removeAll; // löscht alle funktionen
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);

s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    s.sync;
    MIDIClient.init;
    ~midiOut = MIDIOut.new(0);
    s.sync;
    /// load SynthDefs
    ~synths = ~dataPath ++ "SynthsAttuning.scd";
    ~synths.load;
    ~synthLoad.value();
    "loaded synthdefs".postln;

    //load melodies
    ~melPath = ~dataPath ++ "attune_melos.sc";
    ~melos = ~melos ? ();
    ~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;

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

Pbindef(\at,
    \instrument, \bell1,
    \atk, 0.1,
    \rls, 1.0,
    \sus, Pkey(\rls),
     \freq, 320, // akkorde
	\dur, 4,
	\amp, 0.15,
    \pan, 0,
    \modF, 0
).play;
)
Pbindef(\b2, \midinote, Pxrand([[53, 72]], inf) -10, \modF, 0.1);


Pbindef(\b1, \pan, -1, \amp, 0.3, \freq, Pseq((72, 74 .. 92), inf).trace, \dur, 8 );
Pbindef(\b1, \pan, -1, \amp, 0.2, \freq, Pseq((315, 316 .. 325), inf)-238, \dur, 8 );
Pbindef(\at, \atk, 0.05, \freq, 320, \rls, 2.5, \modF, 5, \amp, Pgeom(0.01, 1.02, inf), \crv, 10);
Pbindef(\b2, \pan, 1, \amp, 0.2, \freq, 82, \dur, 4, \atk, 1, \rls, 2.5, \sus, Pkey(\rls)*2/3);


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
            ~midiOut.noteOn(0, nn, 30);

        };
        1.wait;
        [53, 55, 61, 66].do{|nn| ~midiOut.noteOn(0, nn, 0)};
        5.wait;

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