# Garmin GTX-327 Transponder
# Copyright (c) 2019 Joshua Davidson (Octal450)

# Initialize variables
var annuns = ["off", "stby", "off", "stby", "on", "alt"];
var code = "1200";
var mode = 1; # 0 = OFF, 1 = STANDBY, 4 = ON, 5 = ALTITUDE
var modes = ["OFF", "STANDBY", "TEST", "GROUND", "ON", "ALTITUDE"];
var powerUpTime = 0;
var powerUpTestAnnun = 0;
var identTime = 0;

# Initialize all used property nodes
var elapsedSec = props.globals.getNode("/sim/time/elapsed-sec");
var powerSrc = props.globals.getNode("/systems/electrical/outputs/transponder", 1); # Transponder power source
var serviceable = props.globals.initNode("/instrumentation/it-gtx327/serviceable", 1, "BOOL");
var systemAlive = props.globals.initNode("/instrumentation/it-gtx327/internal/system-alive", 0, "BOOL");
var systemAliveTemp = 0;
var powerUpTest = props.globals.initNode("/instrumentation/it-gtx327/internal/powerup-test", -1, "INT"); # -1 = Powerup test not done, 0 = Powerup test complete, 1 = Powerup test in progress
var powerUpTestTemp = 0;
var idCode = props.globals.getNode("/instrumentation/transponder/id-code", 1);
var modeKnob = props.globals.getNode("/instrumentation/transponder/inputs/knob-mode", 1);
var identBtn = props.globals.getNode("/instrumentation/transponder/inputs/ident-btn", 1);
var modeID = props.globals.getNode("/sim/gui/dialogs/radios/transponder-mode", 1);
var displayMode = props.globals.initNode("/instrumentation/it-gtx327/internal/display-mode", "PA", "STRING");
var displayOn = props.globals.initNode("/instrumentation/it-gtx327/internal/display-on", 0, "BOOL");
var codeEntryActive = props.globals.initNode("/instrumentation/it-gtx327/internal/code-entry-active", 0, "BOOL");

var Annun = {
	code: [nil, props.globals.initNode("/instrumentation/it-gtx327/annun/code-1", 1, "INT"), props.globals.initNode("/instrumentation/it-gtx327/annun/code-2", 2, "INT"), props.globals.initNode("/instrumentation/it-gtx327/annun/code-3", 0, "INT"), props.globals.initNode("/instrumentation/it-gtx327/annun/code-4", 0, "INT")],
	fail: props.globals.initNode("/instrumentation/it-gtx327/annun/fail", 0, "BOOL"),
	ident: props.globals.initNode("/instrumentation/it-gtx327/annun/ident", 0, "BOOL"),
	mode: props.globals.initNode("/instrumentation/it-gtx327/annun/mode", "off", "STRING"),
	r: props.globals.initNode("/instrumentation/it-gtx327/annun/reply", 0, "BOOL"),
	sel: props.globals.initNode("/instrumentation/it-gtx327/annun/sel", 0, "INT"),
	selTemp: 0,
	test: props.globals.initNode("/instrumentation/it-gtx327/annun/test", 0, "BOOL"),
};

setlistener("/sim/signals/fdm-initialized", func {
	system.init();
});

var system = {
	init: func() {
		mode = 1;
		codeEntryActive.setBoolValue(0);
		code = idCode.getValue(); # If a code was saved via aircraft-data or other means, import it
		me.updateCode();
		identBtn.setBoolValue(0);
		powerUpTest.setValue(-1);
		displayMode.setValue("PA");
		displayOn.setBoolValue(0);
		Annun.fail.setBoolValue(0);
		Annun.ident.setBoolValue(0);
		Annun.r.setBoolValue(0);
		Annun.sel.setValue(0);
		Annun.test.setBoolValue(0);
		me.setMode(mode);
		update.start();
	},
	loop: func() {
		if (powerSrc.getValue() >= 8) {
			systemAlive.setBoolValue(1);
			if (powerUpTest.getValue() == -1 and mode != 0) { # Begin power on test
				powerUpTest.setValue(1);
				powerUpTime = elapsedSec.getValue();
			} else if (powerUpTest.getValue() != -1 and mode == 0) {
				powerUpTest.setValue(-1);
			}
		} else {
			systemAlive.setBoolValue(0);
			if (powerUpTest.getValue() != -1) {
				powerUpTest.setValue(-1);
			}
		}
		
		systemAliveTemp = systemAlive.getBoolValue();
		
		if (systemAliveTemp != 0 and serviceable.getBoolValue()) {
			if (powerUpTest.getValue() >= 1 and powerUpTime + 3 < elapsedSec.getValue()) {
				powerUpTest.setValue(0);
			}
		} else if (systemAliveTemp != 0 and !serviceable.getBoolValue()) {
			if ((powerUpTest.getValue() == 0 or powerUpTest.getValue() == 1) and powerUpTime + 3 < elapsedSec.getValue()) {
				powerUpTest.setValue(2);
			}
		}
		
		powerUpTestTemp = powerUpTest.getValue();
		
		if (systemAliveTemp and powerUpTestTemp != -1) {
			displayOn.setBoolValue(1);
		} else {
			displayOn.setBoolValue(0);
		}
		
		# Annunciators
		if (powerUpTestTemp == 1 and systemAliveTemp) {
			Annun.test.setBoolValue(1);
		} else {
			Annun.test.setBoolValue(0);
		}
		
		if (powerUpTestTemp == 2 and systemAliveTemp) {
			Annun.fail.setBoolValue(1);
		} else {
			Annun.fail.setBoolValue(0);
		}
		
		if (powerUpTestTemp == 0 and systemAliveTemp) {
			Annun.mode.setValue(annuns[modeKnob.getValue()]);
		} else {
			Annun.mode.setValue("off");
		}
		
		if (identBtn.getBoolValue() and powerUpTestTemp == 0 and systemAliveTemp) {
			Annun.ident.setBoolValue(1);
		} else {
			Annun.ident.setBoolValue(0);
		}
		
		# Update transponder modes
		if (powerUpTestTemp == 0 and serviceable.getBoolValue()) {
			if (modeKnob.getValue() != mode) {
				me.setMode(mode);
			}
		} else {
			me.setMode(0);
		}
	},
	compileCode: func() {
		system.setCode(Annun.code[1].getValue() ~ Annun.code[2].getValue() ~ Annun.code[3].getValue() ~ Annun.code[4].getValue());
	},
	setCode: func(c) {
		me.endCodeEntry();
		code = c;
		idCode.setValue(c);
		me.updateCode();
	},
	updateCode: func() { #  ~ "" exists to make sure it is a string
		Annun.code[1].setValue(substr(code ~ "", 0, 1));
		Annun.code[2].setValue(substr(code ~ "", 1, 1));
		Annun.code[3].setValue(substr(code ~ "", 2, 1));
		Annun.code[4].setValue(substr(code ~ "", 3, 1));
	},
	beginCodeEntry: func() {
		codeEntryActive.setBoolValue(1);
		Annun.sel.setValue(2)
	},
	endCodeEntry: func() {
		Annun.sel.setValue(0);
		codeEntryActive.setBoolValue(0);
		me.updateCode();
	},
	setMode: func(m) {
		modeKnob.setValue(m);
		modeID.setValue(modes[m]);
	},
	beginIdent: func(t) {
		identTime = t;
		identBtn.setBoolValue(1);
		identChk.start();
	},
};

var button = {
	OFF: func() {
		if (systemAlive.getBoolValue()) {
			mode = 0;
		}
	},
	STBY: func() {
		if (systemAlive.getBoolValue()) {
			mode = 1;
		}
	},
	ON: func() {
		if (systemAlive.getBoolValue()) {
			mode = 4;
		}
	},
	ALT: func() {
		if (systemAlive.getBoolValue()) {
			mode = 5;
		}
	},
	IDENT: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			system.beginIdent(elapsedSec.getValue());
		}
	},
	VFR: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			system.setCode(1200);
		}
	},
	CLR: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			if (codeEntryActive.getBoolValue()) {
				Annun.selTemp = Annun.sel.getValue();
				if (Annun.selTemp > 1) {
					Annun.sel.setValue(Annun.selTemp - 1);
					Annun.code[Annun.selTemp - 1].setValue(-1);
				}
			} else {
				# TODO: If within 5sec of entry, return cursor to 4th line
			}
		}
	},
	CRSR: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			system.endCodeEntry();
		}
	},
	Number: func(n) {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			if (n != 8 and n != 9) {
				if (codeEntryActive.getBoolValue()) {
					if (Annun.code[1].getValue() == -1) {
						Annun.code[1].setValue(n);
						Annun.sel.setValue(2);
					} else if (Annun.code[2].getValue() == -1) {
						Annun.code[2].setValue(n);
						Annun.sel.setValue(3);
					} else if (Annun.code[3].getValue() == -1) {
						Annun.code[3].setValue(n);
						Annun.sel.setValue(4);
					} else if (Annun.code[4].getValue() == -1) {
						Annun.code[4].setValue(n);
						system.compileCode();
					}
				} else {
					system.beginCodeEntry();
					Annun.code[1].setValue(n);
					Annun.code[2].setValue(-1);
					Annun.code[3].setValue(-1);
					Annun.code[4].setValue(-1);
				}
			}
		}
	},
};

var identChk = maketimer(0.5, func {
	if (identBtn.getBoolValue() and systemAlive.getBoolValue() and mode != 0) {
		if (identTime + 18 <= elapsedSec.getValue()) {
			identChk.stop();
			identBtn.setBoolValue(0);
		}
	} else {
		identChk.stop();
		identBtn.setBoolValue(0);
	}
});

# Handler for code change from generic dialog
setlistener("/instrumentation/transponder/id-code", func {
	if (code != idCode.getValue()) {
		system.setCode(sprintf("%04d", idCode.getValue()));
	}
}, 0, 0);

var update = maketimer(0.1, system, system.loop);
