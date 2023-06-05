var mc_window, mc_top, mc_toplevel, mc_category_container, mc_catwidth, mc_catheight;

mc_catwidth = 100;
mc_catheight = 120;
mc_window = ~build_window_seq.("MC", ~style_1, 10, 10, mc_catwidth*6+500, mc_catheight + 380);
mc_top = ~build_top_level_seq.(mc_window, 10, 10, mc_catwidth*5+ 720, mc_catheight*5+360, ~style_1);

// frame for MC Track
~mc_track = ~build_mc_track.(mc_top, 10, 0,  mc_catwidth*5+20, mc_catheight *3, ~style_1, 5, mc_catwidth);
~mc_labels = ~build_mc_labels.(mc_top, 10, mc_catheight *3 + 30, mc_catwidth*6 , 60, ~style_1, mc_catwidth, ~uttDict);
~status = ~build_status.(mc_window, mc_catwidth*6 +50, 20, ~style_1, mc_catwidth * 3, mc_catheight * 3.5, ~lastUtterances);

CmdPeriod.add({
	mc_window.close;
});
