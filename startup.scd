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

    MixerChannel.freeAll;
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
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~cat = msg[2];
			~updateUtts.(msg[1], msg[2]);
			~blinkSelector.();
			~addNewSample.(msg[4]);
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);
	"done".postln;
})
);
(
~sim = Routine(
    { loop ( {
        ~mock.();
        [5,3].choose.wait;
		//"mocked" .postln;
        }
) }).play;
)
~sim.stop

~t.beatsPerBar
~melos.durEdge
~melos.meloEdge

(1 + (2* 0.177)) * [1, 2.3, 3.5, 5.8]
Synth(\sn2)

~slider_buttons[1]["dissent"]
Pbindef(\kik02).play(~t);
Pbindef(\snip01).play(~t)
Pbindef(\hh01, \amp, 0.1).stop
Pbindef(\snip01, \w, 1.5, \zit1, 5, \zit2, 0.5,  \atk, 0.001, \rls, 0.1,  \trigger, ~melos.meloEdge.snap01, \dur, ~melos.durEdge.snap01).quant_(4)

Pbindef(\sn01, \sweep, 0.04,  \shaper1, 1, \shaper2, 0.9, \rls, 0.3, \dist1, 1.2, \dist2, 1)

Pbindef.all.do(_.stop)
Pbindef(\dis, \devMin, 0.4, \devMax, 6,  \ffreq, 2000)
Pbindef(\dis, \fratio0, 3, \fratio1, 4, \fratio2, 2, \modInd0, 1, \modInd1, 4, \modInd2, 4).quant_(1)
Pbindef(\dis).stop
Pbindef(\dis, \detune, 120)
Pbindef(\bass, \dec, 0.1, \sus, 1, \rls, 0.6)
(
~mock.()
~allocate.(\dis, 14)
~allocate.(\ins, 14)
~allocate.(\lec, 14)
~allocate.(\pr, 14)
~allocate.(\con, 15)

)
(
Pbindef(\kik02).play(~t);
Pbindef(\hh01).play(~t);
Pbindef(\pr).play(~t);
Pbindef(\dis).play(~t);
Pbindef(\con).play(~t);
Pbindef(\con, \rls, 0.05)
Pbindef(\ins).play(~t);
Pbindef(\lec).play(~t);


)
(
Pbindef(\oscfmTest, \instrument, \oscfm, \buf, ~buffers[\wt], \freq, 62.midicps, \spread, 1, \dev, [0.2, 0.22], \ffreq, Pwhite(200, 1000, inf).trace, \rq, 0.02).play(~t)
)

(
Spec.add(\modInd0, [0, 10]);
Spec.add(\modInd1, [0, 10]);
Spec.add(\modInd2, [0, 10]);
Spec.add(\fratio0, [0, 8, \lin]);
Spec.add(\fratio1, [0.1, 10, \lin]);
Spec.add(\fratio2, [0.1, 10, \lin]);
Spec.add(\amp, [0, 8]);
Spec.add(\freq, \freq);
Spec.add(\atk, \delayms);
Spec.add(\rls, [0, 4]);
Spec.add(\crv, [-10, 10]);

)
(
Ndef(\fmFine, {
	|vel=0.5|
	var f, ff0, ff1, ff2,car, mod0, mod1, mod2, env, modInd, osc, sig;
	f = \freq.kr(1000);
	env = EnvGen.kr(
		Env.perc(\atk.kr(0.015) * Rand(0.9, 1.1), \rls.kr(2.02), curve: \crv.kr(-4)),
		gate: Impulse.kr(0.5)) * vel;
	ff0 = f * (\fratio0.kr(1));
	ff1 = f * (\fratio1.kr(1));
	ff2 = f * (\fratio2.kr(4));
	mod0 = SinOsc.ar(ff0) * f * \modInd0.kr(1) * env.pow(0.8); // mod indices correlate with env to emulate brightness
	mod1 = SinOsc.ar(ff1) * f * \modInd1.kr(0.6) * env.pow(1.4);
	mod2 = SinOsc.ar(ff2) * f * \modInd2.kr(0.3) * env.pow(2.5);
	car = SinOsc.ar(f + [mod0, mod1, mod2].sum);
	car = HPF.ar(car * env.pow(0.5), f);
	sig = car * \amp.kr(0.2);
	sig = Pan2.ar(sig, \pan.kr(0.0));
}).play

)

