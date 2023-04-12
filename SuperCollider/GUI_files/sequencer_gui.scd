// Sequencer
(
var buttonsize=40, columns=16, rows=5, window, categories =  ["praise", "concession", "insinuation","dissent","lecture"], top_level, track_buttons_container, labels, header, buttons, track, sequencer_tab_buttons, stacked_buttons, start_instrument=\default, pattern, instruments=[\default, \peep_sequencer, \sin_tone_sequencer, \buzzy_bram_sequencer, \phase_mod_sequencer, \sin_fb_synth_sequencer, \subtract_noise_synth_sequencer], memory=~gm, mc_window, mc_top, mc_labels,  mc_track, mc_toplevel, mc_category_container, mc_catwidth, mc_catheight;

// #############################
// Initialize Base Memory Values
// #############################

memory.atFail(\seq_mem, {
	memory.put(\seq_mem, Dictionary.newFrom([
		// Some pattern data for start up.
		\currentOctave, 0,
		\melody_octave, 6,
		\melody_scale, Scale.major,
		\melody_instrument, start_instrument,
		\delta, ~t.beatDur/4,
		\melody_sus, 0.1,
		\melody_amp, 0.5,
		\pattern_out, 79,
		\current_name, \melody
	]));
});

// ##################################
// Create objects for sound synthesis
// ##################################

// Create a buffer
memory.at(\seq_mem).put(\buffer, Buffer.alloc(s, s.sampleRate * columns * memory.at(\seq_mem).at(\delta), 1));

// Initialize input and pointer buses for granulator control.
memory.at(\seq_mem).put(\inputBus, Bus.audio(s, 1));
memory.at(\seq_mem).put(\ptrBus, Bus.audio(s, 1));

// Initialize groups to organize order of execution on the scsynth side.
memory.at(\seq_mem).put(\inputGroup, Group.new);
memory.at(\seq_mem).put(\ptrGroup, Group.after(memory.at(\seq_mem).at(\inputGroup)));
memory.at(\seq_mem).put(\recGroup, Group.after(memory.at(\seq_mem).at(\ptrGroup)));

// #########
// BUILD GUI
// #########

// Build window, top_level and header
window = ~build_window_seq.value("Sequencer", ~style_1, 10, 10,  buttonsize*columns+740, buttonsize*rows+380);
top_level = ~build_top_level_seq.value(window, 10, 10, buttonsize*columns+720, buttonsize*rows+360, ~style_1);
header = ~build_sequencer_header_seq.value(top_level, buttonsize*columns+700, 80, ~style_1, "Sequencer");

// Build Track
labels = ~build_labels_seq.value(top_level, 100, (buttonsize) + (buttonsize*rows+20), ~style_1, buttonsize, categories);
track_buttons_container = ~build_track_buttons_container_seq.value(top_level, 0, 0, buttonsize*columns+20, (buttonsize) + (buttonsize*rows+20), ~style_1);
track = ~build_sequencer_track_seq.value(track_buttons_container, buttonsize*columns+20, buttonsize+20, ~style_1, columns, buttonsize);

// Build the Sequencer Buttons
stacked_buttons = ~build_sequencer_tabbed_stack_seq.value(track_buttons_container, sequencer_tab_buttons, buttonsize*columns+20, buttonsize*rows+20, 3, buttonsize, columns, rows, ~style_1, memory);

// build the MC Window
mc_catwidth = 100;
mc_catheight = 120;
mc_window = ~build_window_seq.("MC", ~style_1, 10, 10, mc_catwidth*5+500, mc_catheight + 380);
mc_top = ~build_top_level_seq.(mc_window, 10, 10, mc_catwidth*5+ 720, mc_catheight*5+360, ~style_1);

// frame for MC Track
~mc_track = ~build_mc_track.(mc_top, 10, 0,  mc_catwidth*5+20, mc_catheight *3, ~style_1, 5, mc_catwidth, ~fadingSynths);
mc_labels = ~build_mc_labels.(mc_top, 10, mc_catheight *3 + 30, mc_catwidth*5 , 30, ~style_1, mc_catheight, ~fadingSynths);


// ##############
// Build Patterns
// ##############

Pdefn(\melody, Ppar(
	stacked_buttons[0][1].collect({
		arg c, r;
		var currentOctaveDegree = stacked_buttons[0][1].size - r + memory.at(\seq_mem).at(\melody_octave);
		Pbind(
			\instrument, Pdefn(\p_melody_instrument, memory.at(\seq_mem).at(\melody_instrument)),
			\scale, Pdefn(\p_scale, memory.at(\seq_mem).at(\melody_scale)),
			\octave, Pdefn(\p_melody_octave, memory.at(\seq_mem).at(\melody_octave)),
			\degree, Pif(Pseq(stacked_buttons[0][1][r], inf).coin, currentOctaveDegree, \rest),
			\delta, Pdefn(\p_delta, memory.at(\seq_mem).at(\delta)),
			\sustain, Pdefn(\p_melody_sus,  memory.at(\seq_mem).at(\melody_sus)),
			\amp, Pdefn(\p_melody_amp, memory.at(\seq_mem).at(\melody_amp)),
			\out, Pdefn(\p_out, memory.at(\seq_mem).at(\pattern_out)),
			\track_index, Pdefn(\p_track_index, Pseq((0..15), inf)),
			\track_func, Pdefn(\p_track_func, Pfunc({|ev| ~update_track_seq.value(ev.track_index, track)}));
)}), inf));


CmdPeriod.add({window.close;});
)
