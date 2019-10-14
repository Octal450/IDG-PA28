# Aircraft Config Center
# Copyright (c) 2019 Joshua Davidson (Octal450)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

var failReset = func {
	systems.ELEC.resetFail();
	systems.ENG.resetFail();
	systems.FUEL.resetFail();
}

setlistener("/systems/failures/misc/stec-55x", func {
	setprop("/it-stec55x/serviceable", !getprop("/systems/failures/stec-55x"));
});

setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/options/revision", 0);
setprop("/systems/acconfig/new-revision", "");
setprop("/systems/acconfig/out-of-date", 0);
setprop("/systems/acconfig/options/welcome-skip", 0);
setprop("/systems/acconfig/options/panel", "HSI Panel");
setprop("/systems/acconfig/options/show-l-yoke", 1);
setprop("/systems/acconfig/options/show-r-yoke", 1);
setprop("/systems/acconfig/options/mini-panel", 0);
setprop("/systems/acconfig/options/no-rendering-warn", 0);
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/IDG-PA28/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/IDG-PA28/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/IDG-PA28/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/IDG-PA28/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/IDG-PA28/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/IDG-PA28/AircraftConfig/help.xml");
var about_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/about/dialog", "Aircraft/IDG-PA28/AircraftConfig/about.xml");
var update_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/update/dialog", "Aircraft/IDG-PA28/AircraftConfig/update.xml");
var updated_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/updated/dialog", "Aircraft/IDG-PA28/AircraftConfig/updated.xml");
var fail_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/IDG-PA28/AircraftConfig/fail.xml");
var controlpanel_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/controlpanel/dialog", "Aircraft/IDG-PA28/AircraftConfig/control-panel.xml");
var minipanel_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/minipanel/dialog", "Aircraft/IDG-PA28/AircraftConfig/mini-panel.xml");
var rendering_dlg = gui.Dialog.new("sim/gui/dialogs/rendering/dialog", "Aircraft/IDG-PA28/AircraftConfig/rendering.xml");
spinning.start();
init_dlg.open();

http.load("https://raw.githubusercontent.com/Octal450/IDG-PA28/master/revision.txt").done(func(r) setprop("/systems/acconfig/new-revision", r.response));
var revisionFile = (getprop("/sim/aircraft-dir") ~ "/revision.txt");
var current_revision = io.readfile(revisionFile);
print("IDG-PA28 Revision: " ~ current_revision);
setprop("/systems/acconfig/revision", current_revision);

setlistener("/systems/acconfig/new-revision", func {
	if (getprop("/systems/acconfig/new-revision") > current_revision) {
		setprop("/systems/acconfig/out-of-date", 1);
	} else {
		setprop("/systems/acconfig/out-of-date", 0);
	}
});

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	if (getprop("/systems/acconfig/out-of-date") == 1) {
		update_dlg.open();
		print("System: The IDG-PA28 is out of date!");
	}
	readSettings();
	if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/options/revision") < current_revision) {
		updated_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	} else if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/options/welcome-skip") != 1) {
		welcome_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	}
	setprop("/systems/acconfig/options/revision", current_revision);
	writeSettings();
	spinning.stop();
	if (getprop("/options/mini-panel") == 1) {
		minipanel_dlg.open();
	}
});

var renderingSettings = {
	check: func() {
		var rembrandt = getprop("/sim/rendering/rembrandt/enabled");
		var ALS = getprop("/sim/rendering/shaders/skydome");
		var customSettings = getprop("/sim/rendering/shaders/custom-settings") == 1;
		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!rembrandt and (!ALS or !customSettings or !landmass or !model)) {
			rendering_dlg.open();
		}
	},
	fixAll: func() {
		me.fixCore();
		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!landmass) {
			setprop("/sim/rendering/shaders/landmass", 4);
		}
		if (!model) {
			setprop("/sim/rendering/shaders/model", 2);
		}
	},
	fixCore: func() {
		setprop("/sim/rendering/shaders/skydome", 1); # ALS on
		setprop("/sim/rendering/shaders/custom-settings", 1);
		gui.popupTip("Rendering Settings updated!");
	},
};

var readSettings = func {
	io.read_properties(getprop("/sim/fg-home") ~ "/Export/IDG-PA28-config.xml", "/systems/acconfig/options");
	setprop("/options/show-l-yoke", getprop("/systems/acconfig/options/show-l-yoke"));
	setprop("/options/show-r-yoke", getprop("/systems/acconfig/options/show-r-yoke"));
	setprop("/options/panel", getprop("/systems/acconfig/options/panel"));
	setprop("/options/mini-panel", getprop("/systems/acconfig/options/mini-panel"));
	autopilotSettings();
}

var writeSettings = func {
	setprop("/systems/acconfig/options/show-l-yoke", getprop("/options/show-l-yoke"));
	setprop("/systems/acconfig/options/show-r-yoke", getprop("/options/show-r-yoke"));
	setprop("/systems/acconfig/options/panel", getprop("/options/panel"));
	setprop("/systems/acconfig/options/mini-panel", getprop("/options/mini-panel"));
	autopilotSettings();
	io.write_properties(getprop("/sim/fg-home") ~ "/Export/IDG-PA28-config.xml", "/systems/acconfig/options");
}

var autopilotSettings = func {
	if (getprop("/options/panel") == "HSI Panel") {
		setprop("/it-stec55x/settings/hsi-equipped-1", 1);
	} else {
		setprop("/it-stec55x/settings/hsi-equipped-1", 0);
	}
}

################
# Panel States #
################

# Cold and Dark
var colddark = func {
	spinning.start();
	ps_loaded_dlg.close();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	libraries.crashStress.reset();
	# Initial shutdown, and reinitialization.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0.11);
	setprop("/controls/gear/brake-parking", 0);
	libraries.systemsReset();
	if (getprop("/engines/engine[0]/rpm") < 421) {
		colddark_b();
	} else {
		var colddark_eng_off = setlistener("/engines/engine[0]/rpm", func {
			if (getprop("/engines/engine[0]/rpm") < 421) {
				removelistener(colddark_eng_off);
				colddark_b();
			}
		});
	}
}
var colddark_b = func {
	# Continues the Cold and Dark script, after engines fully shutdown.
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Start Eng
var beforestart = func {
	spinning.start();
	ps_loaded_dlg.close();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	libraries.crashStress.reset();
	# First, we set everything to cold and dark.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0.11);
	setprop("/controls/gear/brake-parking", 0);
	libraries.systemsReset();
	
	# Now the Startup!
	setprop("/controls/electrical/switches/battery", 1);
	setprop("/controls/electrical/switches/alternator", 1);
	setprop("/controls/electrical/switches/avionics-master", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/strobe-lights", 1);
	setprop("/controls/engines/engine[0]/mixture", 1);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Taxi
var taxi = func {
	spinning.start();
	ps_loaded_dlg.close();
	ps_load_dlg.open();
	setprop("/systems/acconfig/autoconfig-running", 1);
	libraries.crashStress.reset();
	# First, we set everything to cold and dark.
	setprop("/controls/flight/flaps", 0.0);
	setprop("/controls/flight/elevator-trim", 0.11);
	setprop("/controls/gear/brake-parking", 0);
	libraries.systemsReset();
	
	# Now the Startup!
	setprop("/controls/electrical/switches/battery", 1);
	setprop("/controls/electrical/switches/alternator", 1);
	setprop("/controls/electrical/switches/avionics-master", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/strobe-lights", 1);
	setprop("/controls/switches/nav-lights-factor", 1);
	setprop("/controls/engines/engine[0]/mixture", 1);
	setprop("/controls/engines/engine[0]/throttle", 0.25);
	setprop("/controls/engines/engine[0]/magnetos-switch", 4);
	interpolate("/controls/engines/engine[0]/throttle", 0.0, 2);
	var runchk = setlistener("/engines/engine[0]/running", func {
		if (getprop("/engines/engine[0]/running") == 1) {
			removelistener(runchk);
			interpolate("/controls/engines/engine[0]/throttle", 0.16, 1);
		}
	});
	settimer(func {
		setprop("/controls/engines/engine[0]/magnetos-switch", 3);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 3);
}

# Ready to Takeoff
var takeoff = func {
	# The same as taxi, except we set some things afterwards.
	taxi();
	var rpmchk = setlistener("/engines/engine[0]/rpm", func {
		if (getprop("/engines/engine[0]/rpm") >= 421) {
			removelistener(rpmchk);
			setprop("/controls/fuel/switches/pump", 1);
			setprop("/controls/switches/landing-light", 1);
		}
	});
}
