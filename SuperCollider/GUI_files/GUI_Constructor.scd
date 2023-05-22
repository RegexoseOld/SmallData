//// GUI CONSTRUCTOR
(
~build_window_seq = {
	// Builds the main window that contains everything
	arg window_title, style, x=10, y=10, width, height;
	Window(window_title, Rect(x, y, width, height))
	.background_(style.at("window_color"))
	.front;
};

~build_top_level_seq = {
	// Buildts a top level composite view that manages child views' spacing.
	arg window, posx=10, posy=10, width, height, style;
	var compView = CompositeView(window, Rect(posx, posy, width, height))
	.background_(style["top_level_frame_color"]);
	compView.addFlowLayout(10@10);
	compView.decorator.gap_(0@10);
	//"built toplevel".postln;
	compView;
};

~build_sequencer_header_seq = {
	// Builds a header frame with a static text box with the title of the window
	arg top, hwidth, hheight, style, string;
	var guiTitle;
	guiTitle = StaticText(top, Rect(10, 10, hwidth, hheight));
	guiTitle.string = string;
	guiTitle.background = style["top_level_frame_color"];
	guiTitle.font = style.at("header_font");
	guiTitle.align = \center;
	top.decorator.nextLine;
	//"built header".postln;
	guiTitle;
};

~build_labels_seq = {
	// Builds a frame to contain the labels of the button rows
	arg top_level, width, height, buttonsize, offset, style;
	var array ;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);

	StaticText(compView, Rect(10, 10, width, buttonsize+10))
	.string_("")
	.background_(style["bank_frame_color"])
	.font_(style.at("header_font"))
	.align_(\center);
	compView.decorator.nextLine;
	array = Array.fill(5, {arg i;
		StaticText(compView, Rect(10+(i*buttonsize)+20, 10, width, buttonsize))
		.string_(~categories.at(i))
		.background_(style["bank_frame_color"])
		.font_(style.at("subheader_font"))
		.align_(\right);
	});
	compView.decorator.nextLine;
	StaticText(compView, Rect(10, 10, width, buttonsize+10))
	.string_("")
	.background_(style["bank_frame_color"])
	.font_(style.at("header_font"))
	.align_(\center);
	compView.decorator.nextLine;
	compView;
};

~build_track_buttons_container_seq = {
	// Builds a frame to contain and organize the track and the stack of buttons.
	arg top_level, width, height, style;
	var compView = CompositeView(top_level, Rect(0, 0, width, height))
	.background_(style.at("top_level_frame_color"));
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	compView;
};

~build_mc_labels = {
	// Builds a frame to contain the labels of the button rows
	arg top_level, posx, posy, width, height, style, buttonsize, uttdict;
	var array, compView, labels, counts, label_data;
	//"pos x %   pos y %".format(posx, posy).postln;
	labels = ~categories ++ ["total"];
	counts = uttdict.values ++ [0];
	compView = CompositeView(top_level, Rect(posx, posy, width, height))
	.background_(Color.white);
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@0);
	array = Array.fill(6, {arg i;
		StaticText(compView, Rect(posx, posy, width/6, height))
		.string_(labels.at(i) ++ "\n" ++ counts[i])
		.background_(style[labels[i].asString])
		.font_(style.at("subheader_font"))
		.align_(\top);
	});
	compView.decorator.nextLine;
	label_data = [compView, array]
};

~build_sequencer_tabbed_stack_seq = {
 	// Builds n stacks of columns * rows buttons that control different sequencer levels.
 	arg top_level, sequencer_tab_buttons, width, height, num_tab_buttons, buttonsize, columns, rows, style, memory;
 	var view, stack, buttonsStacked, compViews;

 	// A view container to place a vertical + stack layout.
 	view = View(top_level, Rect(0, 0, width, height));
 	view.background = style.at("bank_frame_color");

 	// Builds an array of sequencer buttons (themselves a 2DArray).
 	buttonsStacked = Array.fill(num_tab_buttons, {arg i; ~build_sequencer_buttons_seq.value(view, buttonsize*columns, buttonsize*rows, style, columns, rows, buttonsize)});

 	// The individual composite views that the buttons will be placed.
 	compViews = Array.fill(num_tab_buttons, {arg i; buttonsStacked[i][0]});

 	// Places the button compviews in the StackLayout
 	view.layout = VLayout(
 		stack = StackLayout(
 			*compViews;
 		);
 	);

 	// The tab buttons gain the action of controlling which stack of buttons is shown
 	sequencer_tab_buttons.do({
 		arg item, i;
 		item.action_({
 			arg button;
 			stack.index = i;
 			memory.at(\seq_mem).put(\current_name, button.string);
 			sequencer_tab_buttons.do({
 				arg item, i;
 				if (button != item, {
 					if (item.value == 1,
 						{ item.value = 0 }
 					);
 				}, {
 					button.value = 1;
 				});
 			});
 			// Set the buttons and sliders on the GUI from memory.
 			~set_buttons_sliders_numBoxes.value(memory);
 		});

 	});
 	//"built tabbed stack".postln;
 	top_level.decorator.nextLine;
 	buttonsStacked;
 };

~build_sequencer_track_seq = {
	// Builds the sequencer track.
	arg top, hwidth, hheight, style, columns, buttonsize;
	var trackCompView, array, sequencer_track_data;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(0, 0, buttonsize*columns+20, hheight-20));
	trackCompView.background = style.at("bank_frame_color");

	// Sequencer Track: A set of static texts that change colors when the pattern
	// scrolls over it.
	array = Array.fill(columns, { arg i;
		StaticText(trackCompView, Rect(i * buttonsize + 10, 10, buttonsize, buttonsize-20))
		.background_(Color.white)
	});
	top.decorator.nextLine;
    //"built sequncer track".postln;
	sequencer_track_data = [trackCompView, array]
};

~build_mc_track = {
	// Builds the MC Track
	arg top, posx, posy, hwidth, hheight, style, columns, buttonsize;
	var trackCompView, fields, values, sequencer_track_data;

	// Track Composite View
	trackCompView = CompositeView(top, Rect(posx, posy, buttonsize*columns+20, hheight-20))
	.background_(Color.white);

	// Sequencer Track: A set of static texts for labels
	// plus StaticTExt that change text values
	// scrolls over it.
	fields = Array.fill(columns, { arg i;
		StaticText(trackCompView, Rect(i * buttonsize, posy, buttonsize,hheight/10))
		.background_(style[~categories[i].asString])
		.string_("value: \n%".format(~volMin))
		.align_(\bottom);
	});

	top.decorator.nextLine;
	sequencer_track_data = [trackCompView, fields]
};

~build_status = {
	// Builds the status area
	arg top, posx, posy, style, fWidth, fHeight, utterances;
	var compView, state, utts, state_data;
	// Track Composite View
	compView = CompositeView(top, Rect(posx, posy, fWidth + 30, fHeight +30))
	.background_(Color.white);
	state = StaticText(compView, Rect(5, 5 , fWidth, fHeight))
	.background_(style["bank_frame_color"])
	.font_(style.at("subheader_font"))
	.string_("state: 00")
	.align_(\bottomLeft);
	compView.addFlowLayout(0@0);
	compView.decorator.gap_(0@5);
	utts = Array.fill(3, { arg i;
		StaticText(compView, Rect(5, 20 * i, fWidth, fHeight/6))
		.background_(style["header_frame_color"])
		.font_(style.at("text_font"))
		.string_(utterances[i])
		.align_(\topLeft);
	});
	//top.decorator.nextLine;
	state_data = [compView, state, utts]
};

~build_slider_buttons_seq = {
	// build the views for the soundfiles and the range sliders
	arg top_level, sliderwidth, button_field_height, buttonsize, offset, rows, style;
	var filler, compView, sliderAndFileViews, slider_button_data, rel_height=0.6;
	compView = CompositeView(top_level, Rect(0, 0, sliderwidth+offset, buttonsize+(2*offset)+button_field_height))
	.background_(style.at("bank_frame_color"));
	filler = CompositeView(compView, Rect(0, 0, sliderwidth+offset, buttonsize+offset))
		.background_(style.at("bank_frame_color"));

	sliderAndFileViews=Dictionary.new;
	~categories.do({arg cat, i;
		var buffer_info = ~uttSamples[~categories[i]];
		var numFrames = buffer_info[0].numFrames;
		sliderAndFileViews[cat] = [
			SoundFileView(compView, Rect(0, buttonsize+offset+(i*buttonsize), sliderwidth, buttonsize*rel_height))
			.readFile(SoundFile.openRead(buffer_info[0].path), 0, numFrames)
			.drawsRMS_(false)
			.yZoom_(2),
			RangeSlider(compView, Rect(0, buttonsize*(1+rel_height)+offset+(i*buttonsize), sliderwidth, buttonsize*(1-rel_height)))
			.action_({ |slider|
				buffer_info[1] = (slider.lo.lincurve(0, 1, 0 , numFrames, 0)).asInteger;
				buffer_info[2] = (slider.hi.lincurve(0, 1, 0 , numFrames, 0)).asInteger;
			})
			.background_(Color.white)
		]
	});

	slider_button_data = [compView, sliderAndFileViews];
};

~build_utterance_selectors_seq = {
	arg top_level, selector_width, button_field_height, buttonsize, offset, rows;
	var compView, selectors;
	compView = CompositeView(top_level, Rect(0, 0, selector_width+offset, buttonsize+(2*offset) + button_field_height))
	.background_(~style_1.at("bank_frame_color"));
	compView;
};


~build_sequencer_buttons_seq = {
	// A function to build a 2D array of buttons that turn on and off the notes
	// selected in the sequencer pattern.
	arg top, hwidth, hheight, style, columns, rows, buttonsize;
	var butCompView, array, sequencer_button_data;

	// Button Composite View
	butCompView = CompositeView(top, Rect(0, 0, buttonsize*columns, buttonsize*rows));
	butCompView.background = style.at("bank_frame_color");

	// Sequencer Buttons
	array = 0!columns!rows;

	array.do{ |rows, i|
		rows.do{ |cell, j|
			// var buttonsize=50;
			Button(butCompView, Rect(j*buttonsize, i*buttonsize, buttonsize, buttonsize))
			.states_([
				["", style.at("text_color"), Color.white],
				["", Color.white, style.at("text_color")],
			])
			.action_{ |v|
				array[i][j] = v.value;
			};
		};
	};

	sequencer_button_data = [butCompView, array];
};

~update_track_seq = {
	// Updates the track, giving one of the StaticText objects a random color and turning
	// off the previous index.
	arg index, track;
	if((index == 0), {
		{ track[1][index].background_(Color.rand).string_(index.asString) }.defer;
		{ track[1][track[1].size-1].background_(Color.white).string_("") }.defer;
	}, {
		{ track[1][index].background_(Color.rand).string_(index.asString) }.defer;
		{ track[1][index-1].background_(Color.white).string_("") }.defer;
	});
};
)


