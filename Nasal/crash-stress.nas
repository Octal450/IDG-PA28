# Crash and Stress
# Copyright (c) 2019 Joshua Davidson (Octal450)

var loaded = 0;
var damagedHappened = 0;
pts.Fdm.Jsbsim.CrashStress.noseDamaged.setBoolValue(0);
pts.Fdm.Jsbsim.CrashStress.lWingDamaged.setBoolValue(0);
pts.Fdm.Jsbsim.CrashStress.rWingDamaged.setBoolValue(0);
pts.Fdm.Jsbsim.CrashStress.hTailDamaged.setBoolValue(0);
pts.Fdm.Jsbsim.CrashStress.vTailDamaged.setBoolValue(0);

var crashStress = {
	reset: func() {
		if (damagedHappened) {
			loaded = 0;
			pts.Position.altitudeFt.setValue(pts.Position.altitudeFt.getValue() + 5);
			pts.Orientation.rollDeg.setValue(0);
			pts.Orientation.pitchDeg.setValue(4); # Prevent tail from striking when the gears come back
			pts.Fdm.Jsbsim.Gear.posNorm[0].setValue(1); # Nose Gear
			pts.Fdm.Jsbsim.Gear.posNorm[1].setValue(1); # Left Gear
			pts.Fdm.Jsbsim.Gear.posNorm[2].setValue(1); # Right Gear
			pts.Fdm.Jsbsim.Contact.posNorm[9].setValue(1);
			pts.Fdm.Jsbsim.Contact.posNorm[11].setValue(1);
			pts.Fdm.Jsbsim.Contact.posNorm[12].setValue(1);
			pts.Fdm.Jsbsim.Contact.posNorm[13].setValue(1);
			pts.Fdm.Jsbsim.Contact.posNorm[14].setValue(1);
			pts.Fdm.Jsbsim.Contact.posNorm[15].setValue(1);
			pts.Fdm.Jsbsim.CrashStress.noseDamaged.setBoolValue(0);
			pts.Fdm.Jsbsim.CrashStress.lWingDamaged.setBoolValue(0);
			pts.Fdm.Jsbsim.CrashStress.rWingDamaged.setBoolValue(0);
			pts.Fdm.Jsbsim.CrashStress.hTailDamaged.setBoolValue(0);
			pts.Fdm.Jsbsim.CrashStress.vTailDamaged.setBoolValue(0);
			damagedHappened = 0;
			settimer(func { # Delay taking damage again just in case
				loaded = 1;
			}, 1);
		} else {
			loaded = 1;
		}
	},
};

setlistener("/gear/gear[3]/wow", func {
	if (pts.Gear.wow[3].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.noseDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[9].setValue(0);
		pts.Fdm.Jsbsim.Gear.posNorm[0].setValue(0); # Nose Gear
	}
}, 0, 0);

setlistener("/gear/gear[4]/wow", func {
	if (pts.Gear.wow[4].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.noseDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[9].setValue(0);
		pts.Fdm.Jsbsim.Gear.posNorm[0].setValue(0); # Nose Gear
	}
}, 0, 0);

setlistener("/gear/gear[9]/wow", func {
	if (pts.Gear.wow[9].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.noseDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[9].setValue(0);
		pts.Fdm.Jsbsim.Gear.posNorm[0].setValue(0); # Nose Gear
	}
}, 0, 0);

setlistener("/gear/gear[10]/wow", func {
	if (pts.Gear.wow[10].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.hTailDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[14].setValue(0);
		pts.Fdm.Jsbsim.Contact.posNorm[15].setValue(0);
	}
}, 0, 0);

setlistener("/gear/gear[11]/wow", func {
	if (pts.Gear.wow[11].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.vTailDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[11].setValue(0);
	}
}, 0, 0);

setlistener("/gear/gear[12]/wow", func {
	if (pts.Gear.wow[12].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.lWingDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[12].setValue(0);
		pts.Fdm.Jsbsim.Gear.posNorm[1].setValue(0); # Left Gear
	}
}, 0, 0);

setlistener("/gear/gear[13]/wow", func {
	if (pts.Gear.wow[13].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.rWingDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[13].setValue(0);
		pts.Fdm.Jsbsim.Gear.posNorm[2].setValue(0); # Right Gear
	}
}, 0, 0);

setlistener("/gear/gear[14]/wow", func {
	if (pts.Gear.wow[14].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.hTailDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[14].setValue(0);
		pts.Fdm.Jsbsim.Contact.posNorm[15].setValue(0);
	}
}, 0, 0);

setlistener("/gear/gear[15]/wow", func {
	if (pts.Gear.wow[15].getBoolValue() and loaded) {
		damagedHappened = 1;
		pts.Fdm.Jsbsim.CrashStress.hTailDamaged.setBoolValue(1);
		pts.Fdm.Jsbsim.Contact.posNorm[14].setValue(0);
		pts.Fdm.Jsbsim.Contact.posNorm[15].setValue(0);
	}
}, 0, 0);
