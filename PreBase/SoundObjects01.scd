/*
SoundObjects kombiniert in Mix UGEns

Bug bei ~totalUtts = 30 gibt es "late" -messages. hier gucken
https://scsynth.org/t/what-are-those-late-messages-in-the-post-window/5718

*/


SynthDescLib.global.browse;
ServerOptions.device;
ServerOptions.inDevices;
ServerOptions.outDevices;

(
~configPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configPath.load;
~dataPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/";

/// load SynthDefs
~synths = ~dataPath ++ "SynthsSoundObjects.scd";
~synths.load;
~synthLoad.value();
"loaded synthdefs".postln;

//load melodies
~melPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/melodies.sc";
~melos = ~melos ? ();
~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.outDevice.postln;

ServerTree.removeAll; // löscht alle funktionen
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);

~cat = "";
~out = 0;
~factor = 1;
~fbVol = 0.4;
~volPlus = 0.009;
~volMax = 0.2;
~volMin = 0.001;
~fadeThres = 0.07;
// wird später in ServerTree angemeldetn
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~grain = Synth('grain', [\in, ~fx3Bus], ~fxGroup);
		~synthLoad.value();

)};

// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	"start boot".postln;
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	~clk01 = TempoClock.new(110/60).permanent_(true);
	~clk02 = TempoClock.new(110/60).permanent_(true);
	~clk03 = TempoClock.new(110/60).permanent_(true);
	~clk04 = TempoClock.new(110/60).permanent_(true);
	~clk05 = TempoClock.new(110/60).permanent_(true);

	~totalUtts = 0;

	~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

	s.sync;

	//////////////////////////////////////////////////////////////////////////////

	~buffers = Dictionary.new;
	//~path = "/Users/borisjoens/Desktop/Soundwesen/percSamples01/";
	PathName(~samplesPath).entries.do({
		arg subfolder;
		~buffers.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		)
	});

	"buffers".postln;
	//////////////////////////////////////////////////////////////////////////////

	s.sync;
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	s.sync;

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~updateUtts.(msg[2]);
			0.1.wait;
			~allocateSynth.value(~cat, ~uttDict[~cat]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);
	"network".postln;
	//////////////////////////////////////////////////////////////////////////////
	// laod reset patterns from external file 'pattern_objects.sc'

	~patPath = ~dataPath ++ "patterns_objects.sc";
	~reset = ~reset ? ();
	~reset = thisProcess.interpreter.compileFile(~patPath.absolutePath).value;
	"compiled resets".postln;

	~makePatterns = {
		~objects = Dictionary.new;
		~reset.keys.do({
			|ob|
			var oP = Dictionary.new /*objectPatterns*/, melo = ~reset[ob][\melo][\a];
			ob.postln;
			~reset[ob].keys.do({
				|k|
				var current;
				k.postln;
				if (k != 'melo', {
					current = Pbindef(k, *~reset[ob][k].asPairs);
					current = Pbindef(k, \midinote, Pseq(melo, inf));
					oP.add(k -> current);
				});
			});
			~objects.add(ob -> oP);
		});
		"made patterns".postln;

	};
	Pbindef.all.do(_.clear);
	~makePatterns.();

	~startObjects = {
		~reset.keys.do({
			|ob|
			var clock, c;
			ob.postln;
			c = case
			{ob == 'obj1'}{clock = ~clk01}
			{ob == 'obj2'}{clock = ~clk02}
			{ob == 'obj3'}{clock = ~clk03}
			{true}{"end of clocks".postln};

			~objects[ob].keys.do({|k|

				Pbindef.all[k].quant_(8);
				Pbindef.all[k].play(clock);
				//postf("starting %\n   isPlaying?  %\n ", k, Pbindef.all[k].isPlaying);
			});

		});
	};

	// set functions
	~setObj01 = (~dataPath ++ "setObj_01.scd").load;
	~setObj02 = (~dataPath ++ "setObj_02.scd").load;
	~setObj04 = (~dataPath ++ "setObj_04.scd").load;
	~setObj03 = (~dataPath ++ "setObj_03.scd").load;
	~setPraise = (~dataPath ++ "setPraise.scd").load;
	~setDissent = (~dataPath ++ "setDissent.scd").load;

	~updateUtts = {
		|cat|
		postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
		postf("\nupdating % ", cat);
		~totalUtts = ~totalUtts + 1;
		if (cat == 'dissence', {~cat = 'dissent'},{~cat = cat});
		// for circular performance, reset counter values
		if(~uttDict[~cat] >= 30, {~uttDict[~cat] = 0}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
	};

	~allocateSynth = {
		|s_name, count|
		var c;

		postf("\ntotalUtts %\n", ~totalUtts);
		postf("\nuttDict: %\t", ~uttDict);
		c = case
		{s_name == \lecture} {~setObj01.value(count)}
		{s_name == \praise} {~setPraise.value(count)} // reverb
		{s_name == \dissent} {~setDissent.value(count)} // granular distortion
		{s_name == \concession} {~setObj02.value(count)}
		{s_name == \insinuation} {~setObj03.value(count)}
		{true}{"end of allocation".postln};
	};

	~setGlobal = {
		var c;
		c = case
		{(~totalUtts >= 41) && (~totalUtts <= 49)} {"starting knacks".postln; ~setObj04.value(~totalUtts) ; }
		{(~totalUtts >= 21) && (~totalUtts <= 29)} {"starting knacks".postln; ~setObj04.value(~totalUtts) ; }
		{~totalUtts ==10} {~uttDict.keys.do({|k| ~uttDict[k]= 1}); ~startObjects.();}
		{(~totalUtts >= 2) && (~totalUtts <= 10)} {~setObj04.(~totalUtts);}
		{true} {"end of global settings".postln};

	};

	s.sync;

	//Server.default.options.outDevice.postln;
	"done".postln;

});
)



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// tests

(
r = Routine.new({
	var newUtt;
	newUtt = {
		var cat;
		cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
		~updateUtts.(cat);
		~allocateSynth.value(cat, ~uttDict[cat]);
		~setGlobal.value();
	};
	//~startObjects.();
	loop{
		2.wait;
		newUtt.value();
	}
}).play;
);

(
~factor = 2
;
postf("\nset factor % \n", ~factor);
)

(
~allocateSynth.value('praise', ~uttDict['praise']);
~allocateSynth.value('dissent', ~uttDict['dissent']);
~allocateSynth.value('concession',~uttDict['concession']);
~allocateSynth.value('insinuation', ~uttDict['insinuation']);
~allocateSynth.value('lecture',~uttDict['lecture']);
)



