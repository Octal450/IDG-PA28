# Piper PA28 Systems
# Copyright (c) 2019 Joshua Davidson (Octal450)

# Electrical
var ELEC = {
	Bus: {
		avionics: props.globals.getNode("/systems/electrical/bus/avionics"),
		main: props.globals.getNode("/systems/electrical/bus/main"),
	},
	CB: {
		alternatorField: props.globals.getNode("/controls/electrical/circuit-breakers/alternator-field"),
		autopilot: props.globals.getNode("/controls/electrical/circuit-breakers/autopilot"),
		fuelPump: props.globals.getNode("/controls/electrical/circuit-breakers/fuel-pump"),
		transponder: props.globals.getNode("/controls/electrical/circuit-breakers/transponder"),
		trim: props.globals.getNode("/controls/electrical/circuit-breakers/trim"),
		turnBank: props.globals.getNode("/controls/electrical/circuit-breakers/turn-bank"),
	},
	Fail: {
		alternator: props.globals.getNode("/systems/failures/electrical/alternator"),
		avionicsBus: props.globals.getNode("/systems/failures/electrical/avionics-bus"),
		battery: props.globals.getNode("/systems/failures/electrical/battery"),
		batteryTemp: 0,
	},
	Misc: {
		elapsedSecTemp: 0,
	},
	Source: {
		Alt: {
			amp: props.globals.getNode("/systems/electrical/sources/alt/amp"),
			ampTemp: 0,
			ampCalc: props.globals.getNode("/systems/electrical/sources/alt/amp-calc"),
			ampCalcTemp: 0,
			volt: props.globals.getNode("/systems/electrical/sources/alt/volt"),
		},
		Bat: {
			amp: props.globals.getNode("/systems/electrical/sources/bat/amp"),
			percent: props.globals.getNode("/systems/electrical/sources/bat/percent"),
			percentCalc: 100,
			percentTemp: 100,
			time: 0,
			volt: props.globals.getNode("/systems/electrical/sources/bat/volt"),
		},
	},
	Switch: {
		alternator: props.globals.getNode("/controls/electrical/switches/alternator"),
		avionicsMaster: props.globals.getNode("/controls/electrical/switches/avionics-master"),
		avionicsSecondary: props.globals.getNode("/controls/electrical/switches/avionics-secondary"),
		battery: props.globals.getNode("/controls/electrical/switches/battery"),
	},
	init: func() {
		me.resetFail();
		me.Switch.alternator.setBoolValue(0);
		me.Switch.avionicsMaster.setBoolValue(0);
		me.Switch.avionicsSecondary.setBoolValue(0);
		me.Switch.battery.setBoolValue(0);
		me.Source.Bat.percent.setValue(100);
		ampereTimer.start();
	},
	resetCB: func() {
		me.CB.alternatorField.setBoolValue(0);
		me.CB.autopilot.setBoolValue(0);
		me.CB.fuelPump.setBoolValue(0);
		me.CB.transponder.setBoolValue(0);
		me.CB.trim.setBoolValue(0);
		me.CB.turnBank.setBoolValue(0);
	},
	resetFail: func() {
		me.Fail.alternator.setBoolValue(0);
		me.Fail.avionicsBus.setBoolValue(0);
		me.Fail.battery.setBoolValue(0);
		me.resetCB();
	},
	loop: func() {
		me.Fail.batteryTemp = me.Fail.battery.getBoolValue();
		me.Misc.elapsedSecTemp = pts.Sim.Time.elapsedSec.getValue();
		me.Source.Bat.percentTemp = me.Source.Bat.percent.getValue();
		me.Switch.batteryTemp = me.Switch.battery.getBoolValue();
		
		# Battery Charging/Decharging
		if (me.Source.Bat.percentTemp < 100 and me.Source.Alt.amp.getValue() >= 30 and me.Switch.batteryTemp and !me.Fail.batteryTemp) {
			if (me.Source.Bat.time + 5 < me.Misc.elapsedSecTemp) {
				me.Source.Bat.percentCalc = me.Source.Bat.percentTemp + 0.75; # Roughly 90 percent every 10 mins
				if (me.Source.Bat.percentCalc > 100) {
					me.Source.Bat.percentCalc = 100;
				}
				me.Source.Bat.percent.setValue(me.Source.Bat.percentCalc);
				me.Source.Bat.time = me.Misc.elapsedSecTemp;
			}
		} else if (me.Source.Bat.percentTemp == 100 and me.Source.Alt.amp.getValue() >= 30 and me.Switch.batteryTemp and !me.Fail.batteryTemp) {
			me.Source.Bat.time = me.Misc.elapsedSecTemp;
		} else if (me.Source.Bat.amp.getValue() > 0 and me.Switch.batteryTemp and !me.Fail.batteryTemp) {
			if (me.Source.Bat.time + 5 < me.Misc.elapsedSecTemp) {
				me.Source.Bat.percentCalc = me.Source.Bat.percentTemp - 0.25; # Roughly 90 percent every 30 mins
				if (me.Source.Bat.percentCalc < 5) {
					me.Source.Bat.percentCalc = 5;
				}
				me.Source.Bat.percent.setValue(me.Source.Bat.percentCalc);
				me.Source.Bat.time = me.Misc.elapsedSecTemp;
			}
		} else {
			me.Source.Bat.time = me.Misc.elapsedSecTemp;
		}
	},
	ampereCalc: func() {
		me.Source.Alt.ampTemp = me.Source.Alt.amp.getValue();
		if (me.Source.Alt.ampTemp > 0) {
			me.Source.Alt.ampCalcTemp = me.Source.Alt.ampTemp + (rand() - 0.5) * 15;
			if (me.Source.Alt.ampCalcTemp < 0.1) {
				me.Source.Alt.ampCalcTemp = 0.1;
			}
			me.Source.Alt.ampCalc.setValue(me.Source.Alt.ampCalcTemp);
		} else {
			me.Source.Alt.ampCalc.setValue(0);
		}
	},
};

var ampereTimer = maketimer(0.05, ELEC, ELEC.ampereCalc);

# Fuel
var FUEL = {
	Fail: {
		engSuck: props.globals.getNode("/systems/failures/fuel/eng-suck"),
		pump: props.globals.getNode("/systems/failures/fuel/pump"),
	},
	Switch: {
		pump: props.globals.getNode("/controls/fuel/switches/pump"),
		selectedTank: props.globals.getNode("/controls/fuel/switches/selected-tank"),
	},
	init: func() {
		me.Switch.pump.setBoolValue(0);
		me.Switch.selectedTank.setValue(1);
	},
	resetFail: func() {
		me.Fail.engSuck.setBoolValue(0);
		me.Fail.pump.setBoolValue(0);
	},
};

var ENG = {
	Fail: {
		magnetoL: props.globals.getNode("/systems/failures/eng/magneto-l"),
		magnetoR: props.globals.getNode("/systems/failures/eng/magneto-r"),
		starter: props.globals.getNode("/systems/failures/eng/starter"),
	},
	Switch: {
		carbHeat: props.globals.getNode("/controls/anti-ice/engine[0]/carb-heat-cmd"),
		magnetos: props.globals.getNode("/controls/engines/engine[0]/magnetos-switch"),
		mixture: props.globals.getNode("/controls/engines/engine[0]/mixture"),
		primer: props.globals.getNode("/controls/engines/engine[0]/primer-pump"),
	},
	init: func() {
		me.Switch.carbHeat.setBoolValue(0);
		me.Switch.magnetos.setValue(0);
		me.Switch.mixture.setValue(0);
		me.Switch.primer.setBoolValue(0);
	},
	resetFail: func() {
		me.Fail.magnetoL.setBoolValue(0);
		me.Fail.magnetoR.setBoolValue(0);
		me.Fail.starter.setBoolValue(0);
	},
};

var MISC = {
	Fail: {
		brakeL: props.globals.getNode("/systems/failures/misc/brake-l"),
		brakeR: props.globals.getNode("/systems/failures/misc/brake-r"),
		stec55x: props.globals.getNode("/systems/failures/misc/stec-55x"),
	},
};
