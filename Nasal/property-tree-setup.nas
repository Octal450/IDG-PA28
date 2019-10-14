# Piper PA28 Property Tree Setup
# Copyright (c) 2019 Joshua Davidson (Octal450)
# Nodes organized like property tree, except when lots of identical (example: Gear wow), where vectors are used to make it easier
# Anything that says Temp is set by another file to avoid multiple getValue calls
# Usage Example: pts.Class.SubClass.node.getValue()

var Controls = {
	Flight: {
		elevatorTrim: props.globals.getNode("/controls/flight/elevator-trim"),
		flaps: props.globals.getNode("/controls/flight/flaps"),
	},
	Gear: {
		brakeParking: props.globals.getNode("/controls/gear/brake-parking"),
		gearDown: props.globals.getNode("/controls/gear/gear-down"),
	},
};

var Fdm = {
	Jsbsim: {
		CrashStress: {
			hTailDamaged: props.globals.getNode("/fdm/jsbsim/crash-stress/htail-damaged"),
			lWingDamaged: props.globals.getNode("/fdm/jsbsim/crash-stress/lwing-damaged"),
			noseDamaged: props.globals.getNode("/fdm/jsbsim/crash-stress/nose-damaged"),
			rWingDamaged: props.globals.getNode("/fdm/jsbsim/crash-stress/rwing-damaged"),
			vTailDamaged: props.globals.getNode("/fdm/jsbsim/crash-stress/vtail-damaged"),
		},
		Contact: {
			posNorm: [
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				props.globals.getNode("/fdm/jsbsim/contact/unit[9]/pos-norm"),
				nil,
				props.globals.getNode("/fdm/jsbsim/contact/unit[11]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/contact/unit[12]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/contact/unit[13]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/contact/unit[14]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/contact/unit[15]/pos-norm")
			],
		},
		Gear: {
			posNorm: [
				props.globals.getNode("/fdm/jsbsim/gear/unit[0]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/gear/unit[1]/pos-norm"),
				props.globals.getNode("/fdm/jsbsim/gear/unit[2]/pos-norm")
			],
		},
	},
};

var Gear = {
	rollspeedMs: [
		props.globals.getNode("/gear/gear[0]/rollspeed-ms"),
		props.globals.getNode("/gear/gear[1]/rollspeed-ms"),
		props.globals.getNode("/gear/gear[2]/rollspeed-ms")
	],
	wow: [
		props.globals.getNode("/gear/gear[0]/wow"),
		props.globals.getNode("/gear/gear[1]/wow"),
		props.globals.getNode("/gear/gear[2]/wow"),
		props.globals.getNode("/gear/gear[3]/wow"),
		props.globals.getNode("/gear/gear[4]/wow"),
		nil,
		nil,
		nil,
		nil,
		props.globals.getNode("/gear/gear[9]/wow"),
		props.globals.getNode("/gear/gear[10]/wow"),
		props.globals.getNode("/gear/gear[11]/wow"),
		props.globals.getNode("/gear/gear[12]/wow"),
		props.globals.getNode("/gear/gear[13]/wow"),
		props.globals.getNode("/gear/gear[14]/wow"),
		props.globals.getNode("/gear/gear[15]/wow")
	],
};

var Orientation = {
	pitchDeg: props.globals.getNode("/orientation/pitch-deg"),
	rollDeg: props.globals.getNode("/orientation/roll-deg"),
};

var Position = {
	altitudeFt: props.globals.getNode("/position/altitude-ft"),
};

var Sim = {
	Replay: {
		replayState: props.globals.getNode("/sim/replay/replay-state"),
	},
	Time: {
		deltaRealtimeSec: props.globals.getNode("/sim/time/delta-realtime-sec"),
		elapsedSec: props.globals.getNode("/sim/time/elapsed-sec"),
	},
};

var Systems = {
	
};

var Velocities = {
	groundspeedKt: props.globals.getNode("/velocities/groundspeed-kt"),
};

setprop("/systems/acconfig/property-tree-setup-loaded", 1);
