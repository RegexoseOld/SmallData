// Sequencer
(
var buttonsize=40, columns=16, rows=5, offset=10, labelwidth=100, headerheight=100, sliderwidth=300;
var window, top_level, track_buttons_container, labels, header, buttons, track, sequencer_tab_buttons, stacked_buttons, start_instrument=\default, pattern, memory=~gm;
var mc_window, mc_top, mc_toplevel, mc_category_container, mc_catwidth, mc_catheight;
var button_field_width = buttonsize*columns, button_field_height=buttonsize*rows;

// #############################
// Initialize Base Memory Values
// #############################

memory.atFail(\seq_mem, {
	memory.put(\seq_mem, Dictionary.newFrom([
		// Some pattern data for start up.
		\currentOctave, 0,
		\melody_octave, 6,
		\melody_scale, Scale.major,
		\melody_instrument, \sampMon,
		\delta, 0.25,
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
// BUILD MC WINDOW
// #########

mc_catwidth = 100;
mc_catheight = 120;
mc_window = ~build_window_seq.("MC", ~style_1, 10, 10, mc_catwidth*5+500, mc_catheight + 380);
mc_top = ~build_top_level_seq.(mc_window, 10, 10, mc_catwidth*5+ 720, mc_catheight*5+360, ~style_1);

// frame for MC Track
~mc_track = ~build_mc_track.(mc_top, 10, 0,  mc_catwidth*5+20, mc_catheight *3, ~style_1, 5, mc_catwidth);
~mc_labels = ~build_mc_labels.(mc_top, 10, mc_catheight *3 + 30, mc_catwidth*6 , 60, ~style_1, mc_catwidth, ~uttDict);
~status = ~build_status.(mc_window, mc_catwidth *6, 20, ~style_1, mc_catwidth * 3, mc_catheight * 3.5, ~lastUtterances);


// #########
// BUILD SEQUENCER
// #########

// Build window, top_level and header
window = ~build_window_seq.value("Sequencer", ~style_1, 10, 300,  labelwidth+button_field_width+sliderwidth+(7*offset), buttonsize+offset+button_field_height+headerheight+(6*offset));
top_level = ~build_top_level_seq.value(window, 10, 10, button_field_width+labelwidth+sliderwidth+(5*offset), buttonsize+offset+button_field_height+headerheight+(4*offset), ~style_1);
header = ~build_sequencer_header_seq.value(top_level, button_field_width+labelwidth, headerheight, ~style_1, "Sequencer");

// Build Track
labels = ~build_labels_seq.value(top_level, labelwidth, buttonsize+button_field_height+(2*offset), buttonsize, offset, ~style_1);
track_buttons_container = ~build_track_buttons_container_seq.value(top_level, button_field_width+(2*offset), buttonsize+button_field_height+(2*offset), ~style_1);
track = ~build_sequencer_track_seq.value(track_buttons_container, button_field_width+(2*offset), buttonsize+(2*offset), ~style_1, columns, buttonsize);

// Build the Sequencer Buttons
stacked_buttons = ~build_sequencer_tabbed_stack_seq.value(track_buttons_container, sequencer_tab_buttons, button_field_width+(2*offset), button_field_height+(2*offset), 3, buttonsize, columns, rows, ~style_1, memory);

// Build SoundFileView and RangeSliders
~slider_buttons = ~build_slider_buttons_seq.value(top_level, sliderwidth, button_field_height, buttonsize, offset, rows, ~style_1);

// ##############
// Build Patterns
// ##############

Pdefn(\melody, Ppar(
	stacked_buttons[0][1].collect({
		arg c, r;
		var currentOctaveDegree = stacked_buttons[0][1].size - r + memory.at(\seq_mem).at(\melody_octave);
		var currentVol = memory.at(\seq_mem).at(\melody_amp);
		Pbind(
			\instrument, \uttSampler,
			\buf, Pfunc({~uttSamples[~categories[r]][0]}),
			\delta, memory.at(\seq_mem).at(\delta),
			\sustain, Pdefn(\p_melody_sus,  memory.at(\seq_mem).at(\melody_sus)),
			\amp,  Pif(Pseq(stacked_buttons[0][1][r], inf).coin, currentVol, \rest),
			\start, Pfunc({~uttSamples[~categories[r]][1]}),
			\end, Pfunc({~uttSamples[~categories[r]][2]}),
			\out, 0,
			\start, Pfunc({~uttSamples[~categories[r]][1]}),
			\end, Pfunc({~uttSamples[~categories[r]][2]}),
			\track_index, Pseq((0..15), inf),
			\track_func, Pfunc({|ev| ~update_track_seq.value(ev.track_index, track)});
)}), inf));


/*CmdPeriod.add({
	window.close;
	mc_window.close;
});*/
)
