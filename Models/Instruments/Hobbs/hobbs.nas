################################################################################
#
# Hobbs Meter
#
# The Hobbs meter measures flight hours in the same way that a mileage
# is maintained on a car. It is not user-resettable (apart from updating
# the entry in the property tree).
#
# Different aircraft use different switches to start and stop the Hobbs meter.
# The HobbsMeter class can be constructed with different switches, e.g.
#
# Airborne:
#   HobbsMeter.new(index: 0, switchPath: 'gear/gear/wow', inverted: 1);
#
# Engines running:
#   HobbsMeter.new(index: 0, switchPath: 'engines/engine/running', inverted: 0);
#
# Note the use of the inverted parameter to invert the sense of a property
# so that the Hobbs meter runs when the property is false.
#
# ------------------------------------------------------------------------------
#
# Copyright (c) 2014, Richard Senior
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
# MA 02110-1301, USA.
#
################################################################################

# Scaling for digits of the Hobbs meter, in seconds.
var Scale = {
    tenths:     360,
    hours:      3600,
    tens:       36000,
    hundreds:   360000,
    thousands:  3600000
};

var HobbsMeter = {

    # Constructor:
    # switchPath -- property tree path that switches the timer on and off
    # inverted -- inverts switch so that when it goes false, timer starts
    # rootNode -- root property for this meter. (Must match model XML file).
    #
    new: func(index, switchPath, inverted) {
        var m = { 
            parents: [HobbsMeter], 
            index: index,
            switchPath: switchPath, 
            inverted: inverted 
        };
        m.index = index;
        m.switchPath = switchPath;
        m.inverted = inverted;

        var instrumentationN = props.globals.getNode('instrumentation');
        m.rootN = instrumentationN.getChild('hobbs-meter', index, 1);

        # Ensure the display nodes are the correct type.
        m.rootN.initNode('tenths', 0, 'INT');
        m.rootN.initNode('hours', 0, 'INT');
        m.rootN.initNode('tens', 0, 'INT');
        m.rootN.initNode('hundreds', 0, 'INT');
        m.rootN.initNode('thousands', 0, 'INT');

        # The seconds node is driven by the timer and holds the Hobbs time.
        var secondsN = m.rootN.initNode('seconds', 0, 'INT');
        var secondsPath = secondsN.getPath();

        m.hobbsTimer = aircraft.timer.new(prop: secondsPath, res: 30, save: 1);

        # Listener to update the digit properties when the meter value changes
        setlistener(
            node: secondsPath, 
            fn: func { m._hobbsListenerFunc() },
            init: 1, 
            runtime: 0
        );

        # Listener to start and stop the meter when the switch changes
        setlistener(
            node: m.switchPath, 
            fn: func { m._switchListenerFunc() },
            runtime: 0
        );

        return m;        
    },

    getHobbsSeconds: func {
        return me.rootN.getChild('seconds').getValue();
    },

    # Updates a digit of the Hobbs meter.
    # name -- the child of the Hobbs property node to be updated
    # scale -- the scale of the corresponding digit relative to seconds
    #
    _update: func(name, scale) {
        var digitN = me.rootN.getChild(name);
        digitN.setIntValue(math.mod(int(me.getHobbsSeconds() / scale), 10));
    },

    # Listeners

    # Called when the Hobbs timer changes value.
    #
    _hobbsListenerFunc: func {
        me._update(name: 'tenths', scale: Scale.tenths);
        me._update(name: 'hours', scale: Scale.hours);
        me._update(name: 'tens', scale: Scale.tens);
        me._update(name: 'hundreds', scale: Scale.hundreds);
        me._update(name: 'thousands', scale: Scale.thousands);
    },

    # Called when the switch property changes value.
    #
    _switchListenerFunc: func {
        var switch = getprop(me.switchPath);
        if (me.inverted) 
            switch = !switch;
        if (switch)
            me.hobbsTimer.start();
        else
            me.hobbsTimer.stop();
    },

};
