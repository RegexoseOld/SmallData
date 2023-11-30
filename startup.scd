(
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;

~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
//Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiOut = MIDIOut.new(0);
	~midiIn = MIDIIn.new(0);

	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "synths.scd").load;
	(~resourcePath ++ "story.scd").load;
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "initialisation.scd").load;
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "organist.scd").load;

	// LOAD GUI FILES
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Styles.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Constructor.scd");
	// Wait until boot is done and then begin launching the rest of the prograam
	s.sync;


	// Load song specific files
	~allocate = (~showFolder +/+ "allocate.scd").load;
	(~showFolder +/+ "constants.scd").load;
	(~showFolder +/+ "synths.scd").load;


	s.sync;
	ServerTree.add(~makeNodes);
	ServerTree.run;
	"serverTree made nodes".postln;
	 ~makeWaveTable.(4096); // for WaveTable Synth
	s.sync;

	Window.closeAll;
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/sequencer_gui.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/mc_gui.scd");

	//make Dictionary with effekt Patches
	~patches = (~resourcePath ++ "fx_patches.scd").load;
	//make all other Dictionaries, that can't be made in constants
	// load state patterns into a Dictionary with different states for the 5 categories
	//~states = ~states ? ();
	~states = ();
	(PathName(~showFolder) +/+ "patterns").entries.do({
		|pathName, i|
		var categorySymbol, category, patternStates;
		category = pathName.fileNameWithoutExtension;
		patternStates = thisProcess.interpreter.compileFile(pathName.absolutePath).value;
		if (~categorySymbols.includesKey(category.asSymbol),
			{
				categorySymbol = ~categorySymbols[category.asSymbol];
				~states.put(categorySymbol, patternStates[\patterns]);
			},
			{
				categorySymbol = \additional;
				patternStates[\patterns].keys.do{
					|k|
					~states.put(k, patternStates[\patterns][k]);
					Pbindef(k, *~states[k].asPairs);
					~additionalSynths.add(k);
				};
			};
		);
	});

	// set fade volume low at the beginning
	~fadingSynths.do{| k|  ~faderControl.add(k)};

	[\utt, \perc, \bass].do {|k| ~faderControl.add(k)};
	// make Patterns for all fading Synths
	~fadingSynths.do{
		|name|
		var default, c;
		default = (name ++ "0").asSymbol;
		default.postln;
		Pbindef(name, *~states[name][default].asPairs);
	};

	// Send Objekte machen
	~sends = ~sends ? ();

	[~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~utt, ~perc, ~bass].do{
		|ch, i|
		var sendName;
		//postf("channel %\t i %\n", ch, i);
		[~reverb, ~ringmod, ~chorus].do {
			|fx|
			//postf("fx name %\n", fx.asString);
			sendName = "ch" ++ (i+1).asString ++ "_snd_" ++ fx.asString[13..16];
			~sends.put(sendName.asSymbol, ch.newPostSend(fx, 0.01) ); // nicht an patch sondern an channel senden
		}
	};

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			//postf("\nmessage?: %\n", msg);
		/*	postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);*/
			~cat = msg[2];
			~updateUtts.(msg[1], msg[2]);
			~blinkSelector.();

			msg[3].postln;
            if(msg[3] != nil, {~addNewSample.(msg[3])});
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);
	CmdPeriod.add(~mixClear);
	"done".postln;
})
);
(
~sim = Routine(
    { loop ( {
        ~mock.();
        [4.0, 1.5].choose.wait;
		//"mocked" .postln;
        }
) }).play;
)
~sim.stop
(
//Zugriff auf Synths
var synthArgs;
SynthDescLib.global.browse;
SynthDescLib.global.synthDescs.at(\bellFm)
SynthDescLib.at(~states.pr.pr0.instrument).controlNames;
SynthDescLib.global.synthDescs.at(~states.pr.pr10.instrument);
synthArgs = SynthDescLib.at(~states.pr.pr0.instrument).controlDict.collect(_.defaultValue);
synthArgs.postln;
Synth(~states.pr.pr0.instrument, [\freq, 300]);
)
(
var buf, start, dur, end, opm;
opm = 10;
buf = ~buffers[\catSampEn];
start = opm.linlin(0, 10, 0, buf.numFrames-1);
dur = opm.linlin(0, 10, 1000, buf.numFrames/2);
x = Synth(\brPhsr, [\buf, buf, \start, start, \end, start+dur]);
)



)
(
var a = Array(~categoryTranslator.keys.size);

)

(
Pbindef(\kik02);
Pbindef(\hh01);
Pbindef(\bass);
Pbindef(\pr).play(~t.pr);
Pbindef(\dis).play(~t.dis);
Pbindef(\con).play(~t.con);
Pbindef(\con);
Pbindef(\ins).play(~t.ins);
Pbindef(\lec).play(~t.lec);

)


(
var n = 1;
~mock.();
~allocate.(\dis, n);
~allocate.(\ins, n);
~allocate.(\lec, n);
~allocate.(\pr, n);
~allocate.(\con, n);

~allocate.(\dis, 24);
~allocate.(\ins, 8);
~allocate.(\lec, 4);
~allocate.(\pr, 25);
~allocate.(\con, 24);

)
