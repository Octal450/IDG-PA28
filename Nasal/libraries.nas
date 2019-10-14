# PA28 Libraries
# Joshua Davidson (Octal450)

print("-----------------------------------------------------------------------------");
print("Copyright (c) 2017-2019 Joshua Davidson (Octal450)");
print("-----------------------------------------------------------------------------");

setprop("/sim/menubar/default/menu[2]/item[2]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[9]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[10]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[11]/enabled", 0);

rightDoor = aircraft.door.new("/sim/model/door-positions/rightDoor", 2, 0);

var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 1], "/controls/lighting/beacon");
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.1, 1], "/controls/lighting/strobe");

setlistener("/sim/sounde/switch1", func {
	if (!getprop("/sim/sounde/switch1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/switch1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/switch2", func {
	if (!getprop("/sim/sounde/switch2")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/switch2").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/switch3", func {
	if (!getprop("/sim/sounde/switch3")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/switch3").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/knob", func {
	if (!getprop("/sim/sounde/knob")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/knob").setBoolValue(0);
	}, 0.05);
});

var systemsInit = func {
	crashStress.reset();
	systems.ELEC.init();
	systems.FUEL.init();
	systems.ENG.init();
	variousReset();
	setprop("/engines/engine[0]/fuel-flow-gph", 0.0);
	setprop("/sim/model/material/LandingLight/factor", 0.0);
	setprop("/sim/model/material/LandingLight/factorAGL", 0.0);
	setprop("/instrumentation/adf[0]/rotation-deg", 0);
	systemsLoop.start();
}

var systemsReset = func {
	systemsInit();
	stec55x.ITAF.init();
}

setlistener("sim/signals/fdm-initialized", func {
	systemsInit();
});

var systemsLoop = maketimer(0.1, func {
	systems.ELEC.loop();
});

var variousReset = func {
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/cabin-heat-cmd", 0);
	setprop("/controls/switches/defroster-cmd", 0);
	setprop("/controls/switches/landing-light", 0);
	setprop("/controls/switches/nav-lights-factor", 0);
	setprop("/controls/switches/panel-lights-factor", 0);
	setprop("/controls/switches/pitot-heat", 0);
	setprop("/controls/switches/strobe-lights", 0);
	setprop("/fdm/jsbsim/extra/door-main-cmd", 0);
	setprop("/fdm/jsbsim/extra/door-baggage-cmd", 0);
}

if (getprop("/controls/flight/auto-coordination") == 1) {
	setprop("/controls/flight/auto-coordination", 0);
	setprop("/controls/flight/aileron-drives-tiller", 1);
} else {
	setprop("/controls/flight/aileron-drives-tiller", 0);
}

var slewProp = func(prop, delta) {
	delta *= getprop("/sim/time/delta-realtime-sec");
	setprop(prop, getprop(prop) + delta);
	return getprop(prop);
}

setprop("/controls/flight/elevator-trim-time", 0);

controls.elevatorTrim = func(d) {
	if (getprop("/systems/electrical/outputs/electrim") >= 8 and getprop("/it-stec55x/input/electric-trim-sw")) {
		setprop("/it-stec55x/input/man-trim", d);
		setprop("/controls/flight/elevator-trim-time", getprop("/sim/time/elapsed-sec"));
		elevatorTrimTimer.start();
	} else {
		setprop("/it-stec55x/input/man-trim", 0);
		slewProp("/controls/flight/elevator-trim", d * 0.04);
	}
}

var elevatorTrimTimer = maketimer(0.05, func {
	if (getprop("/systems/electrical/outputs/electrim") >= 8 and getprop("/it-stec55x/input/electric-trim-sw")) {
		if (getprop("/controls/flight/elevator-trim-time") + 0.1 <= getprop("/sim/time/elapsed-sec")) {
			elevatorTrimTimer.stop();
			setprop("/it-stec55x/input/man-trim", 0);
		}
	} else {
		elevatorTrimTimer.stop();
		setprop("/it-stec55x/input/man-trim", 0);
	}
});

# Various Other Stuff
var doIdleThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 0.0);
	setprop("/controls/engines/engine[1]/throttle", 0.0);
}

var doFullThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 1.0);
	setprop("/controls/engines/engine[1]/throttle", 1.0);
}

var APPanel = {
	APDisc: func() {
		stec55x.button.DISC();
	},
};
