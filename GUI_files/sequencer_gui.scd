// Sequencer
(
var buttonsize=40, columns=16, rows=5, offset=10, labelwidth=100, headerheight=100, sliderwidth=300, selector_width=200, rotarywidth=200, rotarysize=75;

var window, top_level, track_buttons_container, labels, header, buttons, track, sequencer_buttons, start_instrument=\default, pattern;
var button_field_width = buttonsize*columns, button_field_height=buttonsize*rows;

// #########
// BUILD SEQUENCER
// #########

// Build window, top_level and header
window = ~build_window_seq.value("Sequencer", 10, 550,  labelwidth+button_field_width+sliderwidth+selector_width+(8*offset), buttonsize+offset+button_field_height+headerheight+(6*offset));
top_level = ~build_top_level_seq.value(window, 10, 10, button_field_width+labelwidth+sliderwidth+selector_width+(6*offset), buttonsize+offset+button_field_height+headerheight+(4*offset));
header = ~build_sequencer_header_seq.value(top_level, button_field_width+labelwidth, headerheight, "Sequencer");

~density_knobs = ~build_rotary_fader.(window, labelwidth+(buttonsize *columns)+(6*offset), offset, rotarysize, [\thresCont, \addFac, \subFac], [0.05, 0.5, 0.2], [0.4, 1.7, 2.2]);

// Build Track
labels = ~build_labels_seq.value(top_level, labelwidth, buttonsize+button_field_height+(2*offset), buttonsize, offset);
track_buttons_container = ~build_track_buttons_container_seq.value(top_level, button_field_width+(2*offset), buttonsize+button_field_height+(2*offset));
track = ~build_sequencer_track_seq.value(track_buttons_container, columns, buttonsize);

// Build the Sequencer Buttons
sequencer_buttons = ~build_sequencer_buttons_seq.value(track_buttons_container, button_field_width+(2*offset), button_field_height+(2*offset), buttonsize, offset, rows, columns);

// Build SoundFileView and RangeSliders
~slider_buttons = ~build_slider_buttons_seq.value(top_level, sliderwidth, button_field_height, buttonsize, offset, rows);

~utterance_selectors = ~build_utterance_selectors_seq.value(top_level, selector_width, button_field_height, buttonsize, offset, rows);

// ##############
// Build Patterns
// ##############

Pdefn(\melody, Ppar(
	sequencer_buttons[1].collect({
		arg c, r;
		var delta = 0.25, currentVol = 0.5, sustain = 0.1;
		Pbind(
			\instrument, \uttSampler,
			\buf, Pfunc({~uttSamples[~categories[r]][0]}),
			\delta, delta,
			\sustain, Pdefn(\p_melody_sus, sustain),
			\amp,  Pif(Pseq(sequencer_buttons[1][r], inf).coin, currentVol, \rest),
			\start, Pfunc({~uttSamples[~categories[r]][1]}),
			\end, Pfunc({~uttSamples[~categories[r]][2]}),
			\out, 0,
			\start, Pfunc({~uttSamples[~categories[r]][1]}),
			\end, Pfunc({~uttSamples[~categories[r]][2]}),
			\track_index, Pseq((0..15), inf),
			\track_func, Pfunc({|ev| ~update_track_seq.value(ev.track_index, track)});
)}), inf));


CmdPeriod.add({
	window.close;
});
)
