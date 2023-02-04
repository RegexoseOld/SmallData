(

~configFile = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configFile.load;
~resourcePath = PathName(thisProcess.nowExecutingPath).parentPath ++ "resources/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	/*MIDIClient.init;
	~midiOut = MIDIOut.new(0);*/

	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "synths.scd").load;
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "functions.scd").load;

	~allocate = (~resourcePath ++ "allocate.scd").load;

	//~channels.do{|c| if (c.active, {postf("free channel %\n", c.asString); c.free;})};
    MixerChannel.freeAll;
	s.sync;
	ServerTree.add(~makeNodes);
	ServerTree.run;
	"serverTree made nodes".postln;
	s.sync;

//make Dictionary with effekt Patches
	~patches = (~resourcePath ++ "fx_patches.scd").load;

	//load melodies
	~melPath = ~resourcePath ++ "melodies.sc";
	~melos = ~melos ? ();
	~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;

// load state patterns into a Dictionary with different states for the 5 categories
	~states = ~states ? ();
	PathName( ~showFolder).entries.do({
		|pathName, i|
		var categorySymbol;
		var category = pathName.fileNameWithoutExtension;
		var patternStates = thisProcess.interpreter.compileFile(pathName.absolutePath).value;
		if (~categorySymbols.includesKey(category.asSymbol),
			{
				categorySymbol = ~categorySymbols[category.asSymbol];
			},
			{
				[\vox, \drm, \vox2, \zahl].do{
					|name|
					~states.put(name, patternStates[name]);
					Pbindef(name, *~states[name].asPairs);
				}∞
			}
		);
		~states.put(categorySymbol, patternStates[\patterns]);
	});


	// set fade volume low at the beginning
	~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};

	// make Patterns for all fading Synths
	~fadingSynths.do{
		|name|
		var default, c;
		default = (name ++ "0").asSymbol;
		default.postln;
		Pbindef(name, *~states[name][default].asPairs);
		//assign to channel input
		c = case
		{name == \pr} {Pbindef(name, \out, ~ch1.inbus)}
		{name == \dis} {Pbindef(name, \out, ~ch2.inbus)}
		{name == \con} {Pbindef(name, \out, ~ch3.inbus)}
		{name == \lec} {Pbindef(name, \out, ~ch4.inbus)}
		{name == \ins} {Pbindef(name, \out, ~ch5.inbus)}

		{true}{"end out channel assignment ".postln};
	};

	// Send Objekte machen
	~sends = ~sends ? ();

	[~ch1, ~ch2, ~ch3, ~ch4, ~ch5].do{
		|ch, i|
		var sendName;
		//postf("channel %\t i %\n", ch, i);
		[~reverb, ~ringmod, ~chorus].do {
			|fx|
			//postf("fx name %\n", fx.asString);
			sendName = "ch" ++ (i+1).asString ++ "_send_" ++ fx.asString[13..16];
			~sends.put(sendName.asSymbol, ch.newPostSend(fx, 0.01) ); // nicht an patch sondern an channel senden
		}
	};

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~cat = msg[2];
			~updateUtts.(msg[2]);
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);


	"done".postln;
});

)

//  load patches, managed by setGlobal later
~runFx.();

Window.closeAll;
~buffers[\lecture][0].numFrames/s.sampleRate

// Testing
~t.tempo

(
var buf = ~buffers[\lecture][0],
len = buf.numFrames,
pos = 0,
positions = Array.fill(8, {|i| pos + (~t.tempo * s.sampleRate * i).asInteger});
positions.do{|p, i| var buf = ;  ~buffers.add(Buffer.alloc(s, (p-(i*))))}
positions.postln;

Pbindef(\vox, \dur, 1, \spos, Pseq(positions, inf), \rls, 0.5, \sustain, 0.2, \fade, 0.9, \amp, 0.43, \loop, 0);


)
~buffers[\zahlen][2].numChannels
Pbindef(\vox).play(~t);
Pbindef(\vox).stop;

Pbindef(\zahl).play(~t);
Pbindef(\zahl).stop;

(
var buf, len;
buf = ~buffers[\lecture][0];
len = buf.numFrames;
Pbindef(\vox2, \dur, len/s.sampleRate/5, \rate, 1.1, \start, Pwhite(len/10, len/2, inf ), \end, Pwhite(len * 2/3 +1, len -1, inf) );

)
Pbindef(\vox2).play;
Pbindef(\vox2).stop;


(
Pbindef(\lec, \dur, 1.5, \atk, 0.09, \rls, 0.27, \sustain, 0.2, \amp, 0.23).play;
Pbindef(\pr, \dur, 1.25, \midinote, Pwhite(30, 70, inf), \amp, 0.1, \atk, 0.02, \rls, 1.5).play;
Pbindef(\ins,  \dur, 0.33, \amp, 0.1).play;
Pbindef(\con, \dur, 0.63, \amp, 0.25).play;
Pbindef(\dis, \dur, 1.5, \atk, 0.1, \rls, 0.6, \amp, 0.5, \ffreq, Pwhite(100, 1000, inf)).play;

)
Pbindef.all.do(_.stop)
//Pbindef.all.do({|p| p.postln + "\n"})
Pbindef(\drm)
~states[\drm]

~board = MixingBoard("demo",nil, ~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ringmod, ~reverb, ~master);
(
~sim = Routine(
    { loop ( {
        ~mock.();
        [2, 5].choose.wait;
        "mocked".postln;
        }
) }).play;
)

topEnvironment.do(_.pop)
currentEnvironment
s.queryAllNodes
CmdPeriod.run
ServerTree.removeAll

