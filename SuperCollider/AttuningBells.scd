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
~fbVol = 0.2;
~factor = 1;

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
	// set functions
	~setPraise = (~dataPath ++ "setPraise.scd").load;
	~setDissent = (~dataPath ++ "setDissent.scd").load;
	~dataPath ++ "attuneFunctions.scd".load;

	~allocateSynth = {
		|s_name, count|
		var c;
		c = case
		{s_name == \praise} {~setPraise.value(count)} // reverb
		{s_name == \dissent} {~setDissent.value(count)}
		{true}{"end of allocation".postln};
	};
	Pbindef.all.do(_.clear);

    "done".postln;

});
)
(
Pbindef(\base,
	\instrument, \bell1,
	\scale, Scale.chromatic,
	\midinote, ~melos[\melo][\base01], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
    \modF, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur)
).play;

Pbindef(\pr,
    \instrument, \bell1,
	\scale, Scale.chromatic,
    \midinote, ~melos[\melo][\pr], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;

Pbindef(\dis,
    \instrument, \bell1,
	\scale, Scale.chromatic,
    \midinote, ~melos[\melo][\dis], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;

Pbindef(\ins,
    \instrument, \bell1,
	\scale, Scale.chromatic,
    \midinote, ~melos[\melo][\ins], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;

Pbindef(\lec,
    \instrument, \bell1,
	\scale, Scale.chromatic,
    \midinote, ~melos[\melo][\lec], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;

Pbindef(\con,
    \instrument, \bell1,
	\scale, Scale.chromatic,
    \midinote, ~melos[\melo][\con], // akkorde
	\dur, 1,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;


)


Pbindef(\pr, \amp, 0.1)
Pbindef(\base, \amp, 0.3)
Pbindef(\dis, \amp, 0.0001)
Pbindef(\ins, \amp, 0.0001)
Pbindef(\lec, \amp, 0.0001)
Pbindef(\con, \amp, 0.2)

~allocateSynth.value(\praise, 5)

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

