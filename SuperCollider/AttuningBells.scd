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
~fadingSynths = [\pr, \dis, \con, \lec, \ins];

s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
	Pbindef.all.do(_.clear);
    s.sync;
    MIDIClient.init;
    ~midiOut = MIDIOut.new(0);
	~t = TempoClock(100/60);
    s.sync;
    /// load SynthDefs
	~patterns = Dictionary.new;
   (~dataPath ++ "SynthsAttuning.scd").load;
    ~synthLoad.value();
    "loaded synthdefs".postln;
	~fadingSynths.do{|k| ~patterns.add(k -> (\vol: 0.2))};

    //load melodies
    ~melPath = ~dataPath ++ "attune_melos.sc";
    ~melos = ~melos ? ();
    ~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;
	// set functions
	~setPraise = (~dataPath ++ "setPraise.scd").load;
	~setDissent = (~dataPath ++ "setDissent.scd").load;
	(~dataPath ++ "attuneFunctions.scd").load;

	~allocateSynth = {
		|s_name, count|
		var c;
		c = case
		{s_name == \praise} {~addVolume.value(\pr, 0.1, 0.8, 0.2 ); ~setPraise.value(count)} // reverb
		{s_name == \dissent} {~addVolume.value(\dis, 0.1, 0.8, 0.2 )}
		{s_name == \insinuation} {~addVolume.value(\ins, 0.1, 0.8, 0.2 )}
		{s_name == \lecture} {~addVolume.value(\lec, 0.1, 0.8, 0.2 )}
		{s_name == \concession} {~addVolume.value(\con, 0.1, 0.8, 0.2)}
		{true}{"end of allocation".postln};
	};

    "done".postln;

});
)

(
Pbindef(\base,
	\instrument, \bell1,
	\scale, Scale.chromatic,
	\midinote, ~melos[\melo][\base01], // akkorde
	\dur, 2,
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
	\dur, 2,
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
	\dur, 2,
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
	\dur, 2,
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
	\dur, 2,
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
	\dur, 2,
	\amp, 0.15,
    \pan, 0,
	\atk, 0.1,
	\rls, 0.8,
	\sus, Pkey(\dur),
    \modF, 0
).play;


)
	~t.schedAbs(~t.nextTimeOnGrid, {~continuousFadeOut.value(~fadingSynths, 0.001, 0.001, 0.1); 1});

~patterns[\pr][\vol]
Pbindef.all[\pr].next[\amp]
Pbindef(\pr, \amp, 0.1)
Pbindef(\base, \amp, 0.3)
Pbindef(\dis, \amp, 0.0001)
Pbindef(\ins, \amp, 0.0001)
Pbindef(\lec, \amp, 0.0001)
Pbindef(\con, \amp, 0.2)

~allocateSynth.value(\insinuation, 3)

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

