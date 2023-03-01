
//Aktivieren von Fadern für die Lautstärke Regelung der Patterns
~activateFader = {
	|ch, i|
	var value;
	"chan % and i %".format(ch, i).postln;
	value = MIDIFunc.cc(
		{arg ...args;
			//args[0].postln;
			~cat2Channel[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
		},
		i,
		1
	);

};


/*Assuming a melo is a sequence with 32 slots, Organist presses a key N (i.e. 20) and assigns a sample or a note event to slot number N (20)
1. Bei neu eintreffenden Utts wird die globale Varialbe ~uttSample aktualisiert
2. Bei Tastendruck N wird mit dem aktuellen ~uttSample ein neuer Eintrag in ~melos[\slots] hinzugefügt.
   d.h. Es wird HIER abhängig von ~cat der eine neue Pseq für ~melos[\amps] gemacht
*/

~makeSlot = {
	|cat, newEvent|
	var notes, slots, on, off, slotName, amps;
	notes = Array.newClear(128);    // array has one slot per possible MIDI note
	slots = (48..64);    // here, array has 16 slots

	on = MIDIFunc.noteOn({ |veloc, num, chan, src|
		notes[num] = Synth(\default, [\freq, num.midicps, \amp, veloc * 0.001]); // also allows chords
		"note % slotpos %".format(num, (num- slots[0])).postln;
		if (slots.includes(num),
			{
		    // neue amp Pseq
		    ~melos[\amps][cat].postln;
			amps = ~melos[\amps][cat].collect({
					|a, i|
					if(i == (num - slots[0]), {a}, {0})
				});
			// slot Pattern machen
				slotName = ("utt" ++ ~cat.asString[..2]);
				slotName.postln;
				//~melos[\slots][slotName.asSymbol] = Pbindef(slotName.asSymbol,\instrument, \sampMon, \buf, ~uttSample, \amp, Pseq(amps, inf));
				 Pbindef(slotName.asSymbol, \amp, Pseq(amps, inf));
				amps.postln;
	})
	});

	off = MIDIFunc.noteOff({ |veloc, num, chan, src|
		notes[num].release;
	});

	q = { on.free; off.free; };

};


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