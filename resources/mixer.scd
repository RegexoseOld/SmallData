// build send Fx
~runFx = {
	~ring = ~ringmod.playfx(Instr.at([\busfx, \ring1], ~patches[\ring]));
	~rev = ~reverb.playfx(Instr.at([\busfx, \rvb_allpass], ~patches[\reverb]));

	// Dynamics als Insert FX
	~mst_lim = ~master.playfx(Instr.at([\busfx, \limiter], ~patches[\limiter]));
	~ch1_dyn = ~ch1.playfx(Instr.at([\busfx, \companderd], ~patches[\compander_beat]));
	~ch2_dyn = ~ch2.playfx(Instr.at([\busfx, \companderd], ~patches[\compander01]));
	~ch3_dyn = ~ch3.playfx(Instr.at([\busfx, \companderd], ~patches[\compander01]));
};


/*
Mehr infos zu Routing und FX hier
// Mixer Routing http://www.dewdrop-world.net/sc3/tutorials/index.php?id=1
// Effects 1 : http://www.dewdrop-world.net/sc3/tutorials/index.php?id=5

Instr.at([\busfx, \ring1], [5, 0.15]).listArgs;
Instr.at([\busfx, \companderd]).listArgs;
Instr.at([\busfx, \rvb_allpass]).listArgs;

// so kann man ~ch1 manipulieren
~ch1.controls
~ch1.level= 0.99

// hiermit kann man die Effekte Bypassen
~ring.synth.run(true)
~ring.synth.run(false)
~rev.synth.run(true)
~rev.synth.run(false)
~ch1_dyn.synth.run(true)
~ch1_dyn.synth.run(false)
~ch2_dyn.synth.run(true)
~ch2_dyn.synth.run(false)
~mst_lim.synth.run(true)
~mst_lim.synth.run(false)








(
// clean up
Pbindef.all.do(_.stop)
[~master,~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ringmod, ~delay, ~compander].free; // free MixerChannels
[~board, ~ring, ~comp, ~del, ~rev].free; // free playfx objects
[~ring, ~comp, ~del, ~rev].free; // free Fxpatches
[~ch1send1, ~ch1send2, ~ch1send3, ~ch2send1, ~ch2send2, ~ch2send3, ~ch3send1, ~ch3send2, ~ch3send3, ~ch4send1, ~ch4send2, ~ch4send3, ~ch5send1, ~ch5send2, ~ch5send3]

)
//// testing

~board = MixingBoard("demo",nil, ~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ringmod, ~reverb, ~master);

(
Pbindef(\k, \instrument, \kik, \dur, 2, \outbus, ~ch1.inbus);
Pbindef(\bs, \instrument, \kik, \basefreq, Pwhite(120, 500, inf), \envratio, 1.002, \freqdecay, 2, \ampdecay, 1, \dur, 2, \outbus, ~ch1.inbus);
)
(

Pbindef(\k).play;
Pbindef(\k).stop;
Pbindef(\bs).play;
Pbindef(\bs).stop;
Pbindef(\bs, \ampdecay, 1.2, \amp, 1.3);
)
*/