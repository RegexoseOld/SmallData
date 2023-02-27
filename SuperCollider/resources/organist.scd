/*
Aktivieren von Fadern für die Lautstärke Regelung der Patterns
*/

~activateFader = {
	|ch, i|
	var value;
	"chan % and i %".format(ch, i).postln;
	value = MIDIFunc.cc(
		{arg ...args;
			args[0].postln;
			~cat2Channel[ch].postln;
			~cat2Channel[ch].level = args[0].linlin(0, 127, 0.0, 1.0);
		},
		i,
		1
	);

};





/*Assuming a melo is a sequence with 32 slots, Organist presses a key N and assigns a sample or a note event to slot number N
too advanced. wirklich interessant wird das erst, wenn man Pbindef mit verschiedenen \instrument machen kann. D.h. zwischen einen Synth und einem Sampler wechselt.
Das geht, aber wo sind diese \instrument Patterns abgelegt? in ~melos?
*/

~makeSlot = {
	|cat, newEvent|
	var notes, slots, on, off, mel;
	notes = Array.newClear(128);    // array has one slot per possible MIDI note
	slots = (48..80);    // here, array has 32 slots

	on = MIDIFunc.noteOn({ |veloc, num, chan, src|
		notes[num] = Synth(\default, [\freq, num.midicps, \amp, veloc * 0.001]); // also allows chords
		"note %".format(num).postln;
		if (slots.includes(num),
			{
			mel = ~melos[\melo][cat].collect({
					|nt, i|
					if(i== (num - slots[0]),
						{newEvent},
						{nt})
				}); // die melo Sequenz ändern, Meinungsorganis ordnet per Taste den Slot zu
			mel.postln;
			Pbindef(cat, \midinote, Pseq(mel, inf));
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