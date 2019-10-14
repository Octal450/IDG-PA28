#########################################################################################
# $Id$
# this are the helper functions for the dme indicator ki266
# Maintainer: Torsten Dreyer (Torsten at t3r dot de)
#
# $Log$
# Revision 1.1  2009/12/08 15:25:29  jmt
# Dave Perry:
# (1)  Fixes the odd halo around the 3d instruments.
# (2)  Marker beacon lights now match actual warrior pictures.
# (3)  AC ID placard added to panel matching actual warrior pictures.
# (4)  Added power quadrant texture.
# (5)  Added a setlistener("sim/signals/reset", init_actions); at the end
# of update_actions to reinitialize action-sim.nas on reset.
# (6) Replaces 2D radio_stack with 3D radio_stack.
#
# Revision 1.1  2008/12/22 00:25:55  mfranz
# Dave PERRY:
#
# "This patch adds instrument lights to the radio stack and a repaint of
# the fuselage and tail to look better with osg."
#
# Revision 1.2  2008/11/21 09:21:03  torsten
# make use of new Node.initNode() method
#
# Revision 1.1  2008/11/03 16:18:06  torsten
# added ki266 3d-instrument, see ki266.xml for help
#
#
# Basically, we check the "time to station", "distance to station" and "speed"
# properties and generate the values to show on the displays, based on the switch-
# setting.
#
# Usage:
# just create one instance of ki266 class for each dme you have in your aircraft
# like this:
# ki266.new(0);

var ki266 = {};
ki266.new = func(idx) {
  var obj = {};
  obj.parents = [ki266];

  obj.rootNode = props.globals.getNode( "/instrumentation/dme[" ~ idx ~ "]", 1 );

  obj.powerNode = obj.rootNode.initNode( "power-btn", 1, "BOOL" );
  obj.distNode = obj.rootNode.initNode( "indicated-distance-nm", 0.0 );
  obj.timeNode = obj.rootNode.initNode( "indicated-time-min", 0.0 );
  obj.ktsNode = obj.rootNode.initNode( "indicated-ground-speed-kt", 0.0 );
  obj.minKtsNode = obj.rootNode.initNode( "switch-min-kts", 1, "BOOL" );
  obj.minKtsDisplayNode = obj.rootNode.initNode( "min-kts-display", 0.0 );
  obj.milesDisplayNode = obj.rootNode.initNode( "miles-display", 0.0 );
  obj.leftDotNode = obj.rootNode.initNode( "left-dot", 0, "BOOL" );
# aircraft.data.add( obj.powerNode, obj.minKtsNode );

  obj.update();

  return obj;
};

ki266.update = func {
  var v = 0.0;

  if( me.minKtsNode.getValue() ) {
    v = me.ktsNode.getValue();
  } else {
    v = me.timeNode.getValue();
  }
  if( v > 999.0 ) {
    v = 999.0;
  }
  if( v < 0.0 ) {
    v = 0.0;
  }
  me.minKtsDisplayNode.setIntValue( v );

  v = me.distNode.getValue();
  if( v > 999.9 ) {
    v = 999.9;
  }
  if( v < 0.0 ) {
    v = 0.0;
  }
  if( v < 100.0 ) {
    me.milesDisplayNode.setIntValue( v * 10.0 );
    me.leftDotNode.setBoolValue( 1 );
  } else {
    me.milesDisplayNode.setIntValue( v );
    me.leftDotNode.setBoolValue( 0 );
  }

  settimer( func { me.update() }, 0.2 );
}
