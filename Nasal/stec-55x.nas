# S-TEC Fifty Five X Autopilot System
# Copyright (c) 2019 Joshua Davidson (Octal450)

# Initialize variables
var cdiDefl = 0;
var aoffset = 0;
var vspeed = 0;
var NAV = 0;
var REV = 0;
var CNAV = 0;
var CREV = 0;
var VSError = 0;
var isTrimming = 0;
var NAVFlag = 0;
var GSFlag = 0;
var ALTOffsetDeltaMax = 0;
var NAVGainStd = 1.0;
var NAVGainCap = 0.9;
var NAVGainCapSoft = 0.8;
var NAVGainSoft = 0.6;
var GSNeedleInCapt = 0;
var NAVStep1Time = 0;
var NAVStep2Time = 0;
var NAVStep3Time = 0;
var NAVOver50Time = 0;
var NAVOver50Counting = 0;
var hdgButtonTime = 0;
var powerUpTime = 0;
var powerUpTestAnnun = 0;
var powerUpTestVSAnnun = 0;
var showSoftwareRevision = 0;
var VSFlashTime = 0;
var VSFlashCounting = 0;
var TRIMFlashTime = 0;
var TRIMFlashCounting = 0;
var NAVFlash_annun = 0;
var REVFlash_annun = 0;
var GSFlash_annun = 0;
var VSFlash_annun = 0;
var TRIMFlash_annun = 0;
var rollMode = -1;
var pitchMode = -1;

# Initialize custom nav inputs
props.globals.initNode("/it-stec55x/custom-nav/in-range-1", 0, "BOOL");
props.globals.initNode("/it-stec55x/custom-nav/in-range-2", 0, "BOOL");
props.globals.initNode("/it-stec55x/custom-nav/nav-needle-1", 0, "DOUBLE");
props.globals.initNode("/it-stec55x/custom-nav/nav-needle-2", 0, "DOUBLE");
props.globals.initNode("/it-stec55x/custom-nav/nav-course-1", 0, "INT");
props.globals.initNode("/it-stec55x/custom-nav/nav-course-2", 0, "INT");

# Initialize all used property nodes
var elapsedSec = props.globals.getNode("/sim/time/elapsed-sec");
var powerSrc = props.globals.getNode("/systems/electrical/outputs/autopilot", 1); # Autopilot power source
var powerSrcTrim = props.globals.getNode("/systems/electrical/outputs/electrim", 1); # Electric trim power source
var serviceable = props.globals.initNode("/it-stec55x/serviceable", 1, "BOOL");
var systemAlive = props.globals.initNode("/it-stec55x/internal/system-alive", 0, "BOOL");
var hdg = props.globals.initNode("/it-stec55x/input/hdg", 360, "DOUBLE");
var hdgButton = props.globals.initNode("/it-stec55x/input/hdg-button", 0, "BOOL");
var alt = props.globals.initNode("/it-stec55x/input/alt", 0, "DOUBLE"); # Altitude is in static pressure, not feet
var altOffset = props.globals.initNode("/it-stec55x/input/alt-offset", 0, "DOUBLE"); # Altitude offset
var vs = props.globals.initNode("/it-stec55x/input/vs", 0, "DOUBLE");
var cwsSW = props.globals.initNode("/it-stec55x/input/cws", 0, "BOOL");
var discSW = props.globals.initNode("/it-stec55x/input/disc", 0, "BOOL");
var manTrimSW = props.globals.initNode("/it-stec55x/input/man-trim", 0, "INT");
var masterAPSW = props.globals.initNode("/it-stec55x/input/ap-master-sw", 0, "BOOL");
var masterAPFDSW = props.globals.initNode("/it-stec55x/input/apfd-master-sw", 0, "INT");
var elecTrimSW = props.globals.initNode("/it-stec55x/input/electric-trim-sw", 0, "BOOL");
var yawDamperSW = props.globals.initNode("/it-stec55x/input/yaw-damper-sw", 0, "INT"); # 0 = AUTO, 1 = ON
var yawDamperTrim = props.globals.initNode("/it-stec55x/input/yaw-damper-trim", 0, "DOUBLE");
var NAVSelector = props.globals.initNode("/it-stec55x/input/nav-selector", 0, "INT"); # 0 = NAV1, 1 = NAV2, 2 = CUSTOM1, 3 = CUSTOM2
var hasPower = props.globals.initNode("/it-stec55x/internal/hasPower", 0, "BOOL");
var roll = props.globals.initNode("/it-stec55x/output/roll", -1, "INT");
var pitch = props.globals.initNode("/it-stec55x/output/pitch", -1, "INT");
var yaw = props.globals.initNode("/it-stec55x/output/yaw", -1, "INT");
var HDG_annun = props.globals.initNode("/it-stec55x/annun/hdg", 0, "BOOL");
var NAV_annun = props.globals.initNode("/it-stec55x/annun/nav", 0, "BOOL");
var APR_annun = props.globals.initNode("/it-stec55x/annun/apr", 0, "BOOL");
var REV_annun = props.globals.initNode("/it-stec55x/annun/rev", 0, "BOOL");
var ALT_annun = props.globals.initNode("/it-stec55x/annun/alt", 0, "BOOL");
var GS_annun = props.globals.initNode("/it-stec55x/annun/gs", 0, "BOOL");
var VS_annun = props.globals.initNode("/it-stec55x/annun/vs", 0, "BOOL");
var VSS_annun = props.globals.initNode("/it-stec55x/annun/vs-sign", 0, "BOOL");
var VSD_annun = props.globals.initNode("/it-stec55x/annun/vs-digit", 0, "BOOL");
var RDY_annun = props.globals.initNode("/it-stec55x/annun/rdy", 0, "BOOL");
var CWS_annun = props.globals.initNode("/it-stec55x/annun/cws", 0, "BOOL");
var FAIL_annun = props.globals.initNode("/it-stec55x/annun/fail", 0, "BOOL");
var GPSS_annun = props.globals.initNode("/it-stec55x/annun/gpss", 0, "BOOL");
var TRIM_annun = props.globals.initNode("/it-stec55x/annun/trim", 0, "BOOL");
var UP_annun = props.globals.initNode("/it-stec55x/annun/up", 0, "BOOL");
var DN_annun = props.globals.initNode("/it-stec55x/annun/dn", 0, "BOOL");
var NAVManIntercept = props.globals.initNode("/it-stec55x/internal/nav-man-intercept", 1, "BOOL");
var REVManIntercept = props.globals.initNode("/it-stec55x/internal/rev-man-intercept", 1, "BOOL");
var minTurnRate = props.globals.initNode("/it-stec55x/internal/min-turn-rate", -0.9, "DOUBLE");
var maxTurnRate = props.globals.initNode("/it-stec55x/internal/max-turn-rate", 0.9, "DOUBLE");
var manTurnRate = props.globals.initNode("/it-stec55x/internal/man-turn-rate", 0, "DOUBLE");
var NAVGain = props.globals.initNode("/it-stec55x/internal/nav-gain", NAVGainStd, "DOUBLE");
var powerUpTest = props.globals.initNode("/it-stec55x/internal/powerup-test", -1, "INT"); # -1 = Powerup test not done, 0 = Powerup test complete, 1 = Powerup test in progress
var APRModeActive = props.globals.initNode("/it-stec55x/internal/apr-mode-active", 0, "BOOL");
var ALTOffsetDelta = props.globals.getNode("/it-stec55x/internal/static-20ft-delta");
var noGSAutoArm = props.globals.initNode("/it-stec55x/internal/no-gs-auto-arm", 0, "BOOL");
var GSArmed = props.globals.initNode("/it-stec55x/internal/gs-armed", 0, "BOOL");
var masterSW = props.globals.initNode("/it-stec55x/internal/master-sw", 0, "INT"); # 0 = OFF, 1 = FD, 2 = AP/FD
var servoRollPower = props.globals.initNode("/it-stec55x/internal/servo-roll-power", 0, "BOOL");
var servoPitchPower = props.globals.initNode("/it-stec55x/internal/servo-pitch-power", 0, "BOOL");
var pressureRate = props.globals.getNode("/it-stec55x/internal/pressure-rate", 1);
var VSSlowTarget = props.globals.getNode("/it-stec55x/internal/vs-slow", 1);
var NAVIntercept = props.globals.getNode("/it-stec55x/internal/intercept-angle", 1);
var discSound = props.globals.initNode("/it-stec55x/sound/disc", 0, "BOOL");
var HDGIndicator = props.globals.getNode("/instrumentation/heading-indicator/indicated-heading-deg");
var NAVCourse = props.globals.getNode("/it-stec55x/nav/nav-course", 1);
var OBSNAVNeedle = props.globals.getNode("/it-stec55x/nav/nav-needle", 1);
var OBSGSNeedle = props.globals.getNode("/it-stec55x/nav/gs-needle", 1);
var OBSActive = props.globals.initNode("/it-stec55x/nav/in-range", 0, "BOOL");
var OBSIsLOC = props.globals.initNode("/it-stec55x/nav/is-loc", 0, "BOOL");
var OBSHasGS = props.globals.getNode("/it-stec55x/nav/has-gs", 0, "BOOL");
var NAV0Power = props.globals.getNode("/systems/electrical/outputs/nav[0]");
var GPSActive = props.globals.getNode("/autopilot/route-manager/active");
var turnRate = props.globals.getNode("/instrumentation/turn-indicator/indicated-turn-rate");
var turnRateSpin = props.globals.getNode("/instrumentation/turn-indicator/spin");
var staticPress = props.globals.getNode("/systems/static[0]/pressure-inhg");

# Initialize setting property nodes
var isTurboprop = props.globals.getNode("/it-stec55x/settings/is-turboprop"); # Does the aircraft have turboprop engines?
var FDequipped = props.globals.getNode("/it-stec55x/settings/fd-equipped"); # Does the aircraft have a flight director installed?
var YDequipped = props.globals.getNode("/it-stec55x/settings/yd-equipped"); # Does the aircraft have the optional yaw damper installed?
var useControlsFlight = props.globals.getNode("/it-stec55x/settings/use-controls-flight"); # Use generic /controls/flight for control loop output instead of custom properties

setlistener("/sim/signals/fdm-initialized", func {
	ITAF.init();
});

var ITAF = {
	init: func() {
		hdg.setValue(360);
		alt.setValue(0);
		altOffset.setValue(0);
		vs.setValue(0);
		cwsSW.setBoolValue(0);
		discSW.setBoolValue(0);
		masterAPSW.setBoolValue(0);
		masterAPFDSW.setValue(0);
		powerUpTest.setValue(-1);
		elecTrimSW.setBoolValue(0);
		yawDamperSW.setBoolValue(0);
		yawDamperTrim.setValue(0);
		NAVManIntercept.setBoolValue(0);
		REVManIntercept.setBoolValue(0);
		GSArmed.setBoolValue(0);
		noGSAutoArm.setBoolValue(0);
		roll.setValue(-1);
		pitch.setValue(-1);
		yaw.setValue(-1);
		HDG_annun.setBoolValue(0);
		NAV_annun.setBoolValue(0);
		APR_annun.setBoolValue(0);
		REV_annun.setBoolValue(0);
		ALT_annun.setBoolValue(0);
		GS_annun.setBoolValue(0);
		VS_annun.setBoolValue(0);
		VSS_annun.setBoolValue(0);
		VSD_annun.setBoolValue(0);
		RDY_annun.setBoolValue(0);
		CWS_annun.setBoolValue(0);
		FAIL_annun.setBoolValue(0);
		GPSS_annun.setBoolValue(0);
		TRIM_annun.setBoolValue(0);
		UP_annun.setBoolValue(0);
		DN_annun.setBoolValue(0);
		NAVFlash_annun = 0;
		REVFlash_annun = 0;
		GSFlash_annun = 0;
		VSFlash_annun = 0;
		TRIMFlash_annun = 0;
		discSound.setBoolValue(0);
		update.start();
		updateFast.start();
	},
	loop: func() {
		rollMode = roll.getValue();
		pitchMode = pitch.getValue();
		
		if (FDequipped.getBoolValue()) {
			masterSW.setValue(masterAPFDSW.getValue());
			if (masterAPSW.getBoolValue() != 0) { # Just in case the FD equipped option is changed while system operating
				masterAPSW.setBoolValue(0);
			}
		} else {
			masterSW.setValue(masterAPSW.getValue() * 2);
			if (masterAPFDSW.getValue() != 0) { # Just in case the FD equipped option is changed while system operating
				masterAPFDSW.setValue(0);
			}
		}
		
		if (hasPower.getBoolValue() and turnRateSpin.getValue() >= 0.2) { # Requires turn indicator spin over 20%
			systemAlive.setBoolValue(1);
		} else {
			systemAlive.setBoolValue(0);
			if (rollMode != -1 or pitchMode != -1) {
				me.killAP();
			}
		}
		
		if (powerSrc.getValue() >= 8 and masterSW.getValue() > 0) {
			hasPower.setBoolValue(1);
			if (powerUpTest.getValue() == -1 and systemAlive.getBoolValue()) { # Begin power on test
				powerUpTest.setValue(1);
				powerUpTime = elapsedSec.getValue();
				vs.setValue(1800); # For startup test only
			}
		} else {
			hasPower.setBoolValue(0);
			if (powerUpTest.getValue() != -1 or systemAlive.getBoolValue() != 1) {
				powerUpTest.setValue(-1);
			}
			if (rollMode != -1 or pitchMode != -1) {
				me.killAP();
			}
		}
		
		# Powerup Test Annunciators
		if (powerUpTest.getValue() == 1) {
			if (powerUpTime + 3 >= elapsedSec.getValue()) {
				powerUpTestAnnun = 1;
				showSoftwareRevision = 0;
			} else if (powerUpTime + 8 >= elapsedSec.getValue()) {
				powerUpTestAnnun = 0;
				showSoftwareRevision = 1;
				vs.setValue(600); # For startup test only, software revision
			} else {
				powerUpTestAnnun = 0;
				showSoftwareRevision = 0;
			}
		} else {
			powerUpTestAnnun = 0;
			showSoftwareRevision = 0;
		}
		
		NAV = rollMode == 3 or rollMode == 4; # Is NAV armed?
		REV = rollMode == 7; # Is REV armed?
		CNAV = rollMode == 0 and NAVManIntercept.getBoolValue(); # Is NAV with custom intercept heading armed?
		CREV = rollMode == 0 and REVManIntercept.getBoolValue(); # Is REV with custom intercept heading armed?
		
		if (!systemAlive.getBoolValue()) { # AP Failed when false
			RDY_annun.setBoolValue(0);
			FAIL_annun.setBoolValue(0);
		} else {
			if (powerUpTest.getValue() == 1 and powerUpTime + 10 < elapsedSec.getValue()) {
				powerUpTest.setValue(0);
			}
			if (powerUpTestAnnun == 1) {
				RDY_annun.setBoolValue(1);
			} else if (rollMode == -1 and serviceable.getBoolValue() and powerUpTest.getValue() == 0) {
				RDY_annun.setBoolValue(1);
			} else {
				RDY_annun.setBoolValue(0);
			}
			if (serviceable.getBoolValue() != 1) {
				FAIL_annun.setBoolValue(1);
				powerUpTest.setValue(0);
				if (rollMode != -1 or pitchMode != -1) {
					me.killAP();
				}
			} else if (powerUpTestAnnun == 1 or ((rollMode == 1 or rollMode == 3 or rollMode == 7 or CNAV or CREV) and OBSActive.getBoolValue() != 1)) {
				FAIL_annun.setBoolValue(1);
			} else if (powerUpTestAnnun == 1 or ((rollMode == 2 or rollMode == 4) and GPSActive.getBoolValue() != 1)) {
				FAIL_annun.setBoolValue(1);
			} else {
				FAIL_annun.setBoolValue(0);
			}
		}
		
		# Mode Annunciators
		# AP does not power up or show any signs of life unless if has power (obviously), and the turn coordinator is working
		if ((rollMode == 0 or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			HDG_annun.setBoolValue(1);
		} else {
			HDG_annun.setBoolValue(0);
		}
		
		if ((rollMode == 1 or rollMode == 2 or ((NAV or CNAV) and NAVFlash_annun) or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			NAV_annun.setBoolValue(1);
		} else {
			NAV_annun.setBoolValue(0);
		}
		
		if ((((rollMode == 1 or rollMode == 6 or ((CNAV or rollMode == 3) and NAVFlash_annun) or ((CREV or rollMode == 7) and REVFlash_annun)) and APRModeActive.getBoolValue()) or powerUpTestAnnun == 1) and 
		systemAlive.getBoolValue()) {
			APR_annun.setBoolValue(1);
		} else {
			APR_annun.setBoolValue(0);
		}
		
		if ((rollMode == 6 or ((REV or CREV) and REVFlash_annun) or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			REV_annun.setBoolValue(1);
		} else {
			REV_annun.setBoolValue(0);
		}
		
		if ((pitchMode == 0 or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			ALT_annun.setBoolValue(1);
		} else {
			ALT_annun.setBoolValue(0);
		}
		
		if (((pitchMode == 1 and VSFlash_annun != 1) or pitchMode == -2 or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			VS_annun.setBoolValue(1);
		} else {
			VS_annun.setBoolValue(0);
		}
		
		if ((pitchMode == 1 or pitchMode == -2 or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			VSS_annun.setBoolValue(1);
		} else {
			VSS_annun.setBoolValue(0);
		}
		
		if ((pitchMode == 1 or pitchMode == -2 or powerUpTestAnnun == 1 or showSoftwareRevision == 1) and systemAlive.getBoolValue()) {
			VSD_annun.setBoolValue(1);
		} else {
			VSD_annun.setBoolValue(0);
		}
		
		if ((rollMode == 5 or rollMode == -2 or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			CWS_annun.setBoolValue(1);
		} else {
			CWS_annun.setBoolValue(0);
		}
		
		if ((rollMode == 2 or (rollMode == 4 and NAVFlash_annun) or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			GPSS_annun.setBoolValue(1);
		} else {
			GPSS_annun.setBoolValue(0);
		}
		
		if ((pitchMode == 2 or GSArmed.getBoolValue() or (!GSArmed.getBoolValue() and GSFlash_annun) or powerUpTestAnnun == 1) and systemAlive.getBoolValue()) {
			GS_annun.setBoolValue(1);
		} else {
			GS_annun.setBoolValue(0);
		}
		
		# Electric Pitch Trim
		if (systemAlive.getBoolValue()) {
			if (powerUpTestAnnun == 1 or (pitchMode > -1 and getprop("/it-stec55x/internal/elevator") < -0.025 and masterSW.getValue() == 2)) {
				UP_annun.setBoolValue(1);
			} else if (pitchMode > -1 and UP_annun.getBoolValue() and getprop("/it-stec55x/internal/elevator") < -0.01 and masterSW.getValue() == 2) {
				UP_annun.setBoolValue(1);
			} else {
				UP_annun.setBoolValue(0);
			}
			if (powerUpTestAnnun == 1 or (pitchMode > -1 and getprop("/it-stec55x/internal/elevator") > 0.025 and masterSW.getValue() == 2)) {
				DN_annun.setBoolValue(1);
			} else if (pitchMode > -1 and DN_annun.getBoolValue() and getprop("/it-stec55x/internal/elevator") > 0.01 and masterSW.getValue() == 2) {
				DN_annun.setBoolValue(1);
			} else {
				DN_annun.setBoolValue(0);
			}
		} else {
			UP_annun.setBoolValue(0);
			DN_annun.setBoolValue(0);
		}
		
		if ((UP_annun.getBoolValue() or DN_annun.getBoolValue() or manTrimSW.getValue() != 0 or powerUpTestAnnun == 1) and TRIMFlash_annun != 1 and systemAlive.getBoolValue()) {
			TRIM_annun.setBoolValue(1);
		} else {
			TRIM_annun.setBoolValue(0);
		}
		
		cdiDefl = OBSNAVNeedle.getValue();
		
		# NAV/REV mode gain, reduces as the system captures the course
		if (rollMode == 1 or rollMode == 6) {
			if (abs(cdiDefl) <= 1.5 and NAVGain.getValue() == NAVGainStd) { # CAP mode
				NAVGain.setValue(NAVGainCap);
				NAVStep1Time = elapsedSec.getValue();
			} else if (NAVStep1Time + 15 <= elapsedSec.getValue() and NAVGain.getValue() == NAVGainCap) { # CAP SOFT mode
				NAVGain.setValue(NAVGainCapSoft);
				NAVStep2Time = elapsedSec.getValue();
			} else if (NAVStep2Time + 75 <= elapsedSec.getValue() and NAVGain.getValue() == NAVGainCapSoft and !APRModeActive.getBoolValue()) { # SOFT mode
				NAVGain.setValue(NAVGainSoft);
				NAVStep3Time = elapsedSec.getValue();
			}
			
			# Return to CAP SOFT if needle deflection is >= 50% for 60 seconds
			if (cdiDefl >= 5 and NAVGain.getValue() == NAVGainSoft) {
				if (NAVOver50Counting != 1) { # Prevent it from constantly updating the time
					NAVOver50Counting = 1;
					NAVOver50Time = elapsedSec.getValue();
				}
				if (NAVOver50Time + 60 < elapsedSec.getValue()) { # CAP SOFT mode
					NAVGain.setValue(NAVGainCapSoft);
					NAVStep2Time = elapsedSec.getValue();
					if (NAVOver50Counting != 0) {
						NAVOver50Counting = 0;
					}
				}
			}
		} else {
			if (NAVGain.getValue() != NAVGainStd) {
				NAVGain.setValue(NAVGainStd);
			}
			if (NAVOver50Counting != 0) {
				NAVOver50Counting = 0;
			}
		}
		
		# Limit the turn rate depending on the mode
		if (isTurboprop.getBoolValue()) { # Turboprop aircraft have lower turn rates
			if (rollMode == 1 or rollMode == 6) { # Turn rate in NAV/REV mode
				if (NAVGain.getValue() == NAVGainCapSoft) {
					minTurnRate.setValue(-0.375);
					maxTurnRate.setValue(0.375);
				} else if (NAVGain.getValue() == NAVGainSoft) {
					minTurnRate.setValue(-0.125);
					maxTurnRate.setValue(0.125);
				} else {
					minTurnRate.setValue(-0.75);
					maxTurnRate.setValue(0.75);
				}
			} else { # 75% turn rate in all other modes
				minTurnRate.setValue(-0.75);
				maxTurnRate.setValue(0.75);
			}
		} else {
			if (rollMode == 1 or rollMode == 6) { # Turn rate in NAV/REV mode
				if (NAVGain.getValue() == NAVGainCapSoft) {
					minTurnRate.setValue(-0.45);
					maxTurnRate.setValue(0.45);
				} else if (NAVGain.getValue() == NAVGainSoft) {
					minTurnRate.setValue(-0.15);
					maxTurnRate.setValue(0.15);
				} else {
					minTurnRate.setValue(-0.9);
					maxTurnRate.setValue(0.9);
				}
			} else { # 90% turn rate in all other modes
				minTurnRate.setValue(-0.9);
				maxTurnRate.setValue(0.9);
			}
		}
		
		NAVFlag = !OBSActive.getBoolValue() or NAV0Power.getValue() < 8; # NAV Flag
		GSFlag = !OBSActive.getBoolValue() or NAV0Power.getValue() < 8 or !OBSHasGS.getBoolValue(); # GS Flag
		
		# Automatically arm GS
		if (rollMode == 1 and APRModeActive.getBoolValue() and pitchMode == 0 and !NAVFlag and !GSFlag and OBSIsLOC.getBoolValue() and abs(cdiDefl) <= 5 and OBSGSNeedle.getValue() >= 0.35 and !GSArmed.getBoolValue()) {
			if (!noGSAutoArm.getBoolValue()) {
				GSArmed.setBoolValue(1);
				GSchk();
				GSt.start();
			}
		}
		
		# Flash VS if the autopilot is not able to hold the VS
		VSError = abs(math.round(pressureRate.getValue() * -58000, 100) - VSSlowTarget.getValue()) > 200; # Find VS Error from converted pressure rate, and VS Slow Target
		if (pitchMode == 1 and masterSW.getValue() == 2) {
			if (VSFlashCounting != 1 and VSError) {
				VSFlashCounting = 1;
				VSFlashTime = elapsedSec.getValue();
			} else if (VSFlashCounting != 0 and !VSError) {
				VSl.stop();
				VSFlash_annun = 0;
				VSFlashCounting = 0;
			}
		} else {
			VSl.stop();
			VSFlash_annun = 0;
			VSFlashCounting = 0;
		}
		
		if (VSFlashCounting == 1 and VSFlashTime + 15 <= elapsedSec.getValue()) {
			if (VSError) { # Check if we are still out of range
				VSl.start();
			} else {
				VSl.stop();
				VSFlash_annun = 0;
				VSFlashCounting = 0;
			}
		}
		
		# Flash TRIM if the autopilot is trimming for over 4 seconds
		isTrimming = (UP_annun.getBoolValue() or DN_annun.getBoolValue()) and powerUpTestAnnun == 0 and elecTrimSW.getBoolValue() and powerSrcTrim.getValue() >= 8;
		if (masterSW.getValue() == 2) {
			if (TRIMFlashCounting != 1 and isTrimming) {
				TRIMFlashCounting = 1;
				TRIMFlashTime = elapsedSec.getValue();
			} else if (VSFlashCounting != 0 and !isTrimming) {
				TRIMl.stop();
				TRIMFlash_annun = 0;
				TRIMFlashCounting = 0;
			}
		} else {
			TRIMl.stop();
			TRIMFlash_annun = 0;
			TRIMFlashCounting = 0;
		}
		
		if (TRIMFlashCounting == 1 and TRIMFlashTime + 4 <= elapsedSec.getValue()) {
			if (isTrimming) { # Check if we are still out of range
				TRIMl.start();
			} else {
				TRIMl.stop();
				TRIMFlash_annun = 0;
				TRIMFlashCounting = 0;
			}
		}
	},
	loopFast: func() {
		# Roll Servo
		if (masterSW.getValue() == 2 and roll.getValue() > -1) {
			if (servoRollPower.getBoolValue() != 1) {
				servoRollPower.setBoolValue(1);
				discSound.setBoolValue(0);
			}
		} else {
			if (servoRollPower.getBoolValue() != 0) {
				servoRollPower.setBoolValue(0);
				if (useControlsFlight.getBoolValue()) {
					setprop("/controls/flight/aileron", 0);
				}
				if (roll.getValue() != -2) {
					discSound.setBoolValue(1);
				}
			}
		}
		
		# Pitch Servo
		if (masterSW.getValue() == 2 and pitch.getValue() > -1) {
			if (servoPitchPower.getBoolValue() != 1) {
				servoPitchPower.setBoolValue(1);
			}
		} else {
			if (servoPitchPower.getBoolValue() != 0) {
				servoPitchPower.setBoolValue(0);
				if (useControlsFlight.getBoolValue()) {
					setprop("/controls/flight/elevator", 0);
				}
			}
		}
		
		# Man Trim AP DISC
		if (manTrimSW.getValue() != 0 and pitch.getValue() > -1 and masterSW.getValue() == 2) {
			me.killAPPitch();
		}
		
		# Yaw Damper Logic
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			if (YDequipped.getBoolValue() and !yawDamperSW.getBoolValue() and roll.getValue() > -1) {
				yaw.setValue(0);
			} else if (YDequipped.getBoolValue() and yawDamperSW.getBoolValue()) {
				yaw.setValue(0);
			} else {
				if (yaw.getValue() != -1) {
					yaw.setValue(-1);
					if (useControlsFlight.getBoolValue()) {
						setprop("/controls/flight/rudder", 0);
					}
				}
			}
		} else {
			if (yaw.getValue() != -1) {
				yaw.setValue(-1);
				if (useControlsFlight.getBoolValue()) {
					setprop("/controls/flight/rudder", 0);
				}
			}
		}
	},
	killAP: func() { # Kill all AP modes
		NAVt.stop();
		GPSt.stop();
		GSt.stop();
		GSArmed.setBoolValue(0);
		roll.setValue(-1);
		pitch.setValue(-1);
	},
	killAPPitch: func() { # Kill only the pitch modes
		GSt.stop();
		GSArmed.setBoolValue(0);
		pitch.setValue(-1);
	},
};

var button = {
	DISC: func() {
		ITAF.killAP();
	},
	HDGB: func(d) {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			if (d == 1) { # Button pushed
				hdgButton.setBoolValue(1);
				hdgButtonTime = elapsedSec.getValue();
			} else if (d == 0) { # Button released
				if (hdgButtonTime + 0.48 >= elapsedSec.getValue()) { # Button pops out and HDG gets engaged only if depressed for less than 0.48 seconds
					me.HDG();
					hdgButton.setBoolValue(0);
				}
			}
		} else {
			if (d == 1) { # Button pushed
				hdgButton.setBoolValue(1);
			} else if (d == 0) { # Button released
				hdgButton.setBoolValue(0);
			}
		}
	},
	HDG: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			NAVManIntercept.setBoolValue(0);
			REVManIntercept.setBoolValue(0);
			roll.setValue(0);
			APRModeActive.setBoolValue(0);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
		}
	},
	HDGNInt: func() { # Heading Custom Intercept Mode NAV
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			NAVManIntercept.setBoolValue(1);
			REVManIntercept.setBoolValue(0);
			roll.setValue(0);
			APRModeActive.setBoolValue(0);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
		}
	},
	HDGRInt: func() { # Heading Custom Intercept Mode REV
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			NAVManIntercept.setBoolValue(0);
			REVManIntercept.setBoolValue(1);
			roll.setValue(0);
			APRModeActive.setBoolValue(0);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
		}
	},
	NAV: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			APRModeActive.setBoolValue(0);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
			if (hdgButton.getBoolValue()) { # If the HDG button is being pushed, arm NAV for custom intercept angle
				me.CNAV();
			} else {
				if (roll.getValue() == 1 or roll.getValue() == 3) { # If NAV active or armed, switch to GPSS NAV mode
					roll.setValue(4);
					GPSchk();
					GPSt.start();
				} else { # If not regular NAV mode, switch to NAV
					roll.setValue(3);
					NAVchk();
					NAVt.start();
					if (OBSIsLOC.getBoolValue()) {
						APRModeActive.setBoolValue(1);
					}
				}
			}
		}
	},
	APR: func() {
		hdgButton.setBoolValue(0);
		CNAV = roll.getValue() == 0 and NAVManIntercept.getBoolValue(); # Is NAV with custom intercept heading armed?
		CREV = roll.getValue() == 0 and REVManIntercept.getBoolValue(); # Is REV with custom intercept heading armed?
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and (CNAV or roll.getValue() == 1 or roll.getValue() == 3) and serviceable.getBoolValue()) {
			if (GSArmed.getBoolValue() and !noGSAutoArm.getBoolValue() and APRModeActive.getBoolValue()) {
				noGSAutoArm.setBoolValue(1);
				GSArmed.setBoolValue(0);
				GSl.start();
			} else if (noGSAutoArm.getBoolValue() and APRModeActive.getBoolValue()) {
				GSl.stop();
				GSFlash_annun = 0;
				settimer(func {
					GSArmed.setBoolValue(1);
					noGSAutoArm.setBoolValue(0);
					GSchk();
					GSt.start();
				}, 1);
			}
			APRModeActive.setBoolValue(1);
			# If in SOFT mode, go back to CAP SOFT
			if (APRModeActive.getBoolValue() and NAVGain.getValue() == NAVGainSoft) {
				NAVGain.setValue(NAVGainCapSoft);
				NAVStep2Time.setValue(elapsedSec.getValue());
			}
		} else if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and (CREV or roll.getValue() == 6 or roll.getValue() == 7) and serviceable.getBoolValue()) {
			APRModeActive.setBoolValue(1);
		}
	},
	REV: func() {
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			APRModeActive.setBoolValue(0);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
			if (hdgButton.getBoolValue()) { # If the HDG button is being pushed, arm REV for custom intercept angle
				me.CREV();
			} else {
				roll.setValue(7);
				REVchk();
				REVt.start();
				if (OBSIsLOC.getBoolValue()) {
					APRModeActive.setBoolValue(1);
				}
			}
		}
	},
	CNAV: func() {
		me.HDGNInt();
		NAVchk();
		NAVt.start();
		if (OBSIsLOC.getBoolValue()) {
			APRModeActive.setBoolValue(1);
		}
		hdgButton.setBoolValue(0);
		GSArmed.setBoolValue(0);
		noGSAutoArm.setBoolValue(0);
	},
	CREV: func() {
		me.HDGRInt();
		REVchk();
		REVt.start();
		if (OBSIsLOC.getBoolValue()) {
			APRModeActive.setBoolValue(1);
		}
		hdgButton.setBoolValue(0);
		GSArmed.setBoolValue(0);
		noGSAutoArm.setBoolValue(0);
	},
	ALT: func() {
		hdgButton.setBoolValue(0);
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and roll.getValue() != -1 and serviceable.getBoolValue()) {
			GSNeedleInCapt = abs(OBSGSNeedle.getValue()) >= 0.001 and abs(OBSGSNeedle.getValue()) <= 0.175; # Are we in capture range?
			if (roll.getValue() == 1 and pitch.getValue() == 0 and APRModeActive.getBoolValue() and GSNeedleInCapt == 1) { # Immediately go to GS mode
				GSt.stop();
				GSFlash_annun = 0;
				pitch.setValue(2);
				GSArmed.setBoolValue(0);
			} else {
				altOffset.setValue(0);
				alt.setValue(staticPress.getValue());
				pitch.setValue(0);
				noGSAutoArm.setBoolValue(0);
			}
		}
	},
	VS: func() {
		hdgButton.setBoolValue(0);
		if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and roll.getValue() != -1 and serviceable.getBoolValue()) {
			pitch.setValue(1);
			GSArmed.setBoolValue(0);
			noGSAutoArm.setBoolValue(0);
		}
	},
	Knob: func(d) {
		if (pitch.getValue() == 0 and powerUpTest.getValue() == 0 and serviceable.getBoolValue()) {
			if (d < 0) {
				aoffset = altOffset.getValue() + ALTOffsetDelta.getValue();
				ALTOffsetDeltaMax = ALTOffsetDelta.getValue() * 18; # Get the static pressure delta value and multiply by 18 to limit it at +360ft
				if (aoffset > ALTOffsetDeltaMax) {
					aoffset = ALTOffsetDeltaMax;
				}
			} else {
				aoffset = altOffset.getValue() - ALTOffsetDelta.getValue();
				ALTOffsetDeltaMax = ALTOffsetDelta.getValue() * -18; # Get the static pressure delta value and multiply by -18 to limit it at -360ft
				if (aoffset < ALTOffsetDeltaMax) {
					aoffset = ALTOffsetDeltaMax;
				}
			}
			altOffset.setValue(aoffset);
		} else if (pitch.getValue() == 1 and powerUpTest.getValue() == 0) {
			if (d < 0) {
				vspeed = vs.getValue() - 100;
				if (vspeed < -1600) {
					vspeed = -1600;
				}
			} else {
				vspeed = vs.getValue() + 100;
				if (vspeed > 1600) {
					vspeed = 1600;
				}
			}
			vs.setValue(vspeed);
		}
	},
	CWS: func(d) {
		if (d == 1) { # Button pushed
			cwsSW.setBoolValue(1);
			if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and roll.getValue() != -1 and serviceable.getBoolValue()) {
				roll.setValue(-2);
				pitch.setValue(-2);
				APRModeActive.setBoolValue(0);
				GSArmed.setBoolValue(0);
				noGSAutoArm.setBoolValue(0);
			}
		} else if (d == 0) { # Button released
			cwsSW.setBoolValue(0);
			if (systemAlive.getBoolValue() and powerUpTest.getValue() == 0 and roll.getValue() != -1 and serviceable.getBoolValue()) {
				manTurnRate.setValue(math.round(math.clamp(turnRate.getValue(), -0.9, 0.9), 0.1));
				roll.setValue(5);
				me.VS();
			}
		}
	},
};

var NAVchk = func {
	if (roll.getValue() == 3) {
		if (OBSActive.getBoolValue()) { # Only engage NAV if OBS reports in range
			NAVt.stop();
			NAVFlash_annun = 0;
			roll.setValue(1);
			if (NAVGain.getValue() != NAVGainStd) {
				NAVGain.setValue(NAVGainStd);
			}
			if (OBSIsLOC.getBoolValue()) {
				APRModeActive.setBoolValue(1);
			}
			if (abs(OBSNAVNeedle.getValue()) <= 1 and abs(HDGIndicator.getValue() - NAVCourse.getValue()) < 5 and !APRModeActive.getBoolValue()) { # Immediately go to SOFT mode if within 10% of deflection and within 5 degrees of course.
				NAVGain.setValue(NAVGainSoft);
				NAVStep1Time = elapsedSec.getValue() - 90;
				NAVStep2Time = elapsedSec.getValue() - 75;
				NAVStep3Time = elapsedSec.getValue();
			}
		} else {
			NAVl.start();
		}
	} else if (roll.getValue() == 0 and NAVManIntercept.getBoolValue()) {
		if (abs(NAVIntercept.getValue()) > 0.1 and abs(NAVIntercept.getValue()) < 40) { # Only engage NAV if within capture
			NAVt.stop();
			NAVFlash_annun = 0;
			roll.setValue(1);
			if (NAVGain.getValue() != NAVGainStd) {
				NAVGain.setValue(NAVGainStd);
			}
			if (OBSIsLOC.getBoolValue()) {
				APRModeActive.setBoolValue(1);
			}
			if (abs(OBSNAVNeedle.getValue()) <= 1 and abs(HDGIndicator.getValue() - NAVCourse.getValue()) < 5 and !APRModeActive.getBoolValue()) { # Immediately go to SOFT mode if within 10% of deflection and within 5 degrees of course.
				NAVGain.setValue(NAVGainSoft);
				NAVStep1Time = elapsedSec.getValue() - 90;
				NAVStep2Time = elapsedSec.getValue() - 75;
				NAVStep3Time = elapsedSec.getValue();
			}
		} else {
			NAVl.start();
		}
	} else {
		NAVt.stop();
	}
}

var GPSchk = func {
	if (roll.getValue() == 4) {
		if (GPSActive.getBoolValue()) { # Only engage GPSS NAV if GPS is activated
			GPSt.stop();
			NAVFlash_annun = 0;
			roll.setValue(2);
		} else {
			NAVl.start();
		}
	} else {
		GPSt.stop();
	}
}

var REVchk = func {
	if (roll.getValue() == 7) {
		if (OBSActive.getBoolValue()) { # Only engage NAV if OBS reports in range
			REVt.stop();
			REVFlash_annun = 0;
			roll.setValue(6);
			if (NAVGain.getValue() != NAVGainStd) {
				NAVGain.setValue(NAVGainStd);
			}
			if (OBSIsLOC.getBoolValue()) {
				APRModeActive.setBoolValue(1);
			}
		} else {
			REVl.start();
		}
	} else if (roll.getValue() == 0 and REVManIntercept.getBoolValue()) {
		if (abs(NAVIntercept.getValue()) > 0.1 and abs(NAVIntercept.getValue()) < 40) { # Only engage REV if within capture
			REVt.stop();
			REVFlash_annun = 0;
			roll.setValue(6);
			if (NAVGain.getValue() != NAVGainStd) {
				NAVGain.setValue(NAVGainStd);
			}
			if (OBSIsLOC.getBoolValue()) {
				APRModeActive.setBoolValue(1);
			}
		} else {
			REVl.start();
		}
	} else {
		REVt.stop();
	}
}

var GSchk = func {
	if (GSArmed.getBoolValue()) {
		if (OBSGSNeedle.getValue() >= 0.0035 and OBSGSNeedle.getValue() <= 0.175) { # Within 5% below GS
			GSt.stop();
			GSFlash_annun = 0;
			pitch.setValue(2);
			GSArmed.setBoolValue(0);
		}
	} else {
		GSt.stop();
	}
}

var NAVl = maketimer(0.5, func { # Flashes the NAV (and sometimes GPSS) lights when NAV modes are armed
	NAV = roll.getValue() == 3 or roll.getValue() == 4; # Is NAV armed?
	CNAV = roll.getValue() == 0 and NAVManIntercept.getBoolValue(); # Is NAV with custom intercept heading armed?
	if ((NAV or CNAV) and NAVFlash_annun != 1) {
		NAVFlash_annun = 1;
	} else if ((NAV or CNAV) and NAVFlash_annun != 0) {
		NAVFlash_annun = 0;
	} else {
		NAVl.stop();
		NAVFlash_annun = 0;
	}
});

var GSl = maketimer(0.5, func { # Flashes the GS light when GS is manually disarmed
	if (noGSAutoArm.getBoolValue() and pitch.getValue() == 0 and GSFlash_annun != 1) {
		GSFlash_annun = 1;
	} else if (noGSAutoArm.getBoolValue() and pitch.getValue() == 0 and GSFlash_annun != 0) {
		GSFlash_annun = 0;
	} else {
		GSl.stop();
		GSFlash_annun = 0;
	}
});

var REVl = maketimer(0.5, func { # Flashes the REV lights when REV mode is armed
	REV = roll.getValue() == 7; # Is REV armed?
	CREV = roll.getValue() == 0 and REVManIntercept.getBoolValue(); # Is REV with custom intercept heading armed?
	if ((REV or CREV) and REVFlash_annun != 1) {
		REVFlash_annun = 1;
	} else if ((REV or CREV) and REVFlash_annun != 0) {
		REVFlash_annun = 0;
	} else {
		REVl.stop();
		REVFlash_annun = 0;
	}
});

var VSl = maketimer(0.5, func { # Flashes the VS light if the autopilot is not able to hold the VS
	if (VSError and pitch.getValue() == 1 and VSFlash_annun != 1) {
		VSFlash_annun = 1;
	} else if (VSError and pitch.getValue() == 1 and VSFlash_annun != 0) {
		VSFlash_annun = 0;
	} else {
		VSl.stop();
		VSFlash_annun = 0;
	}
});

var TRIMl = maketimer(0.5, func { # Flashes the TRIM light if the autopilot is trimming for over 4 seconds
	if (isTrimming and masterSW.getValue() == 2 and TRIMFlash_annun != 1) {
		TRIMFlash_annun = 1;
	} else if (isTrimming and masterSW.getValue() == 2 and TRIMFlash_annun != 0) {
		TRIMFlash_annun = 0;
	} else {
		TRIMl.stop();
		TRIMFlash_annun = 0;
	}
});

var NAVt = maketimer(0.5, NAVchk);
var GPSt = maketimer(0.5, GPSchk);
var REVt = maketimer(0.5, REVchk);
var GSt = maketimer(0.5, GSchk);
var update = maketimer(0.1, ITAF, ITAF.loop);
var updateFast = maketimer(0.05, ITAF, ITAF.loopFast);
