
//Aktivieren von Fadern für die Lautstärke Regelung der Patterns
~activateVolume = {
	|ch, i|
	var value;
	//"chan   %    and i   %  current  % ".format(ch, i, ~currentUttPattern.asString).postln;
	value = MIDIFunc.cc({
		arg ...args;
		args[..2].postln;
		if (i < 5, {
			"activated  % ".format(ch).postln;
			~cat2Channel[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
		}, {
			"activated  % ".format(~currentUttPattern.asString).postln;
			~cat2Channel[~currentUttPattern].level = args[0].linlin(0, 127, 0.0, 1.0);
			//Pbindef(~currentUttPattern, \grainAmp, Pfunc{args[0].linlin(0, 127, 0.0, 1.0)} ):
		})
	},
	i,
	1
	);
};

//Aktivieren von Sends
~activateReverb = {
	|ch, i, offset|
	var value, sendNum;
	"making reverb send   % and i %".format(ch, i).postln;
	sendNum = i + offset;
	value = MIDIFunc.cc(
		{arg ...args;
			args[..2].postln;
			~sends[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
		},
		sendNum,
		1
	);

};


/*Assuming a melo is a sequence with16 slots, Organist presses a key N (i.e. 12) and assigns a sample or a note event to slot number <N> (12)
1. Bei neu eintreffenden Utts wird die globale Varialbe ~uttSample aktualisiert
2. Bei Tastendruck <N> wird mit dem aktuellen ~uttSample ein neuer Eintrag in ~melos[\slots] hinzugefügt.
// d.h.in ~makeSlot wird abhängig von cat neue Pseqs für ~melos[\amps] gemacht (ampSlot)

*/

~makeSlot = {
	|cat, numSlots|
	var notes, slots, on, off, slotName, ampSlot, amps ;
	notes = Array.newClear(128);    // array has one slot per possible MIDI note
	slots = (48..64);    // here, array has 16 slots
	ampSlot = Array.fill(numSlots, {0});

	on = MIDIFunc.noteOn({ |veloc, num, chan, src|
		//notes[num] = Synth(\default, [\freq, num.midicps, \amp, veloc * 0.001]); // also allows chords
		"notes % slotpos %".format(num, (num- slots[0])).postln;
		if (slots.includes(num),{
			// neue amp Pseq
			//~melos[\amps][cat].postln;
			ampSlot.put(num- slots[0],~melos[\amps][cat].sum/numSlots );


			// slot Pattern machen
			slotName = ("utt" ++ cat.asString);
			slotName.postln;
			//~melos[\slots][slotName.asSymbol] = Pbindef(slotName.asSymbol,\instrument, \sampMon, \buf, ~uttSample, \amp, Pseq(amps, inf));
			Pbindef(slotName.asSymbol, \amp, Pseq(ampSlot, inf));
			//Pbindef(cat, \amp, Pseq(amps, inf));
			ampSlot.postln;
			//amps.postln;
		}, {ampSlot = Array.fill(numSlots, {0});})
	});

	off = MIDIFunc.noteOff({ |veloc, num, chan, src|
		//notes[num].release;
		//
	});

	q = { on.free; off.free; };

};


~makeUttSlot = {
	/*
	Organist assigns new samples and CC Values to the slot "allocated"
	*/
	|patName|
	var on, keySlots, slotVolume, slotSpeed, allocated, bufSequence, ampSequence, speedSequence, off, vol=0.5, speed=1;
	~uttSample = ~buffers[\dry].choose;
	~uttSample.numChannels = 1;
    bufSequence = ~melos[\slots][\utt];
	ampSequence = ~melos[\amps][\utt];
	speedSequence = Array.fill(~numSlots, {1});
	keySlots = (48..64);
	allocated = 0; // An dieser Position ein neuer Sample positioniert und die cc Werte geändert
	on = MIDIFunc.noteOn({|veloc, num, chan, src|
		if (keySlots.includes(num),{
			//set allocated for position of ~uttSample
			var newUtt;
			allocated = num - keySlots[0];
		});
	});
	slotVolume = MIDIFunc.cc({
		arg ...args;

		vol = args[0].linlin(0, 127, 0.0, 1.0);
				"slotVol  % ".format(vol).postln;
	},
	5, //(Reloop) fader für channel ~utt (6)
	1
	);
	slotSpeed = MIDIFunc.cc({
		arg ...args;

		speed = args[0].linlin(0, 127, 0.01, 2.5);
		  "slotSpeed  % ".format(speed).postln;
	},
	102, //(Reloop) RotorFader 2 bei ~utt (6)
	1
	);
	off = MIDIFunc.noteOff({ |veloc, num, chan, src|
		bufSequence.put(allocated, ~uttSample);
		//bufSequence.postln;
		Pbindef(patName, \buf, Pseq(bufSequence, inf));
		speedSequence.put(allocated, speed);
		"rates %".format(speedSequence).postln;
		Pbindef(patName, \rate, Pseq(speedSequence, inf));
		ampSequence.put(allocated, vol);
		"amplitudes %".format(ampSequence).postln;
		Pbindef(patName, \amp, Pseq(ampSequence, inf))
	});
};


/*


*/
/*
~playSample = {
	var notes, slots, on, off, buff, len, posi, samp, mel;

	buff =  ~buffers[\lecture][0];
	len = buff.numFrames;

	notes = Array.newClear(128);    // array has one slot per possible MIDI note
	slots = (48..80);    // array has 32 slots

	on = MIDIFunc.noteOn({ |veloc, num, chan, src|
		notes[num] = Synth(\default, [\freq, num.midicps, \amp, veloc * 0.001]); // also allows chords
		if (slots.includes(num),
			{
				posi = len/slots.size * (num % 48);
				"includes % at posi %".format(num, posi).postln;
				samp = Synth(\sampMon, [\buf, buff, \spos, posi, \rate, 1 * (num/48)])};
		);
	});

	off = MIDIFunc.noteOff({ |veloc, num, chan, src|
		notes[num].release;
		samp.release;
	});

	q = { on.free; off.free; };

}
*/