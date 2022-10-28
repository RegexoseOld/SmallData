
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
~cat = "";
~totalUtts = 0;
~fbVol = 0.3;
~factor = 1;
~fadingSynths = [\pr, \dis, \con, \lec, \ins];
// values for addVolume
~volPlus = 0.04;
~volMax = 0.25;
~volMin = 0.00002;
~volThres = 0.1;
//fade Increase for fadePatterns
~fadeInc = 0.04;

s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
	Pbindef.all.do(_.clear);
    s.sync;
    //MIDIClient.init;
    //~midiOut = MIDIOut.new(0);
	~t = TempoClock(60/60).permanent_(true);
    s.sync;
    /// load SynthDefs
	~fadePatterns = Dictionary.new;
   (~dataPath ++ "SynthsAttuning.scd").load;
    ~synthLoad.value();

    "loaded synthdefs".postln;

    OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
            ~cat = msg[2];
			~updateUtts.(msg[2]);
			0.1.wait;
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);

    //load melodies
    ~melPath = ~dataPath ++ "attune_melos.sc";
    ~melos = ~melos ? ();
    ~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;
    ~musarMel = ~melos[\melo][\ruzhim];
    ~musarDur = ~melos[\duras][\ruzhim];

    ~fadingSynths.do{|k| ~fadePatterns.add(k -> (\vol: 0.005))};
    ~patPath = ~dataPath ++ "attune_patterns.sc";
    ~reset = ~reset ? ();
    ~reset = thisProcess.interpreter.compileFile(~patPath.absolutePath).value;

    (~fadingSynths ++ [\musar]).do{
        |name|
        name.postln;
        Pbindef(name, *~reset[name].asPairs);
    };
	// set functions
	~attPraise = (~dataPath ++ "attunePraise.scd").load;
	~attDissent = (~dataPath ++ "attuneDissent.scd").load;
	~attInsinuation = (~dataPath ++ "attuneInsinuation.scd").load;
	~attLecture = (~dataPath ++ "attuneLecture.scd").load;
	~attConcession = (~dataPath ++ "attuneConcession.scd").load;
	~setRauschen = (~dataPath ++ "setRauschen.scd").load;
    ~setMusar = (~dataPath ++ "setMusar.scd").load;
	(~dataPath ++ "attuneFunctions.scd").load;
    "done".postln;

});
)
(
~sim = Routine({
    loop(
        {
            ~mock.();
            [2, 4, 7, 11].choose.wait;
            "mocked".postln;
        }
    )
}).play;
)
~sim.stop

~t.tempo = 60/60;

~melos[\melo][\ruzhim][0..0];

~fadingSynths.do{|name| Pbindef(name).play(~t, quant:4)};

//start fadingSynths with fade = 0, they are getting louder with the att* Functions
 (~fadingSynths ++[\musar]).do{|name| Pbindef(name).play(~t, quant:4)};


Pbindef(\musar).play(~t, quant:1);
Pbindef(\musar, \amp, 0.12)



~t.schedAbs(~t.nextTimeOnGrid, {~continuousFadeOut.value(~fadingSynths, ~volMin, 0.0012, ~volThres); 1});

Pbindef(\pr, \amp, 0.2, \lag, 0.0, \detune, -230, \vibF, 0.5, \vibVol, 0.6);
Pbindef(\musar2, \amp, 0.3, \rls, 0.2, \sus, 1.2, \filTime, 0.1);
Pbindef(\dis, \amp, 0.3, \vibF, 12, \vibVol, 0.5, \trmF, 1.001, \trmRate, 1, \trmDep, 0.01);
Pbindef(\ins, \fade, 0.3, \detune, Pwhite(-150, 50, inf), \vibF, 0.9, \vibvol, 0.001, \dur, 0.3);
Pbindef(\lec, \amp, 0.1, \vibF, 0.5, \vibvol, 0.1, \fade, 0.8, \dur, 1.5 );
Pbindef(\con, \vibF, 1.1, \vibvol, 0.99 );

~allocateSynth.value(\dissent, 1)
~allocateSynth.value(\praise, 1)
~allocateSynth.value(\concession, 2)
~allocateSynth.value(\lecture, 1)
~allocateSynth.value(\insinuation, 1)

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

