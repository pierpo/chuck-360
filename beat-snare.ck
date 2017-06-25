//----------------------------|
// on-the-fly synchronization
// adapted from Perry's ChucK Drummin' + Ge's sine poops
//
// authors: Perry Cook (prc@cs.princeton.edu)
//          Ge Wang (gewang@cs.princeton.edu)
// --------------------|
// add one by one into VM (in pretty much any order):
//
// terminal-1%> chuck --loop
// ---
// terminal-2%> chuck + otf_01.ck
// (anytime later)
// terminal-2%> chuck + otf_02.ck
// (etc...)
//--------------------------------------|


0 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;

// hid objects
Hid hi;
HidMsg msg;

// try
if( !hi.openJoystick( device ) ) me.exit();
<<< "joystick '" + hi.name() + "' ready...", "" >>>;

// this synchronizes to period
1::second => dur T;
T - (now % T) => now;

.5::T => now;

// construct the patch
SndBuf buf => Gain g => dac;
// read in the file
me.dir() + "samples/Snaredrum.wav" => buf.read;
// set the gain
.5 => g.gain;

int isBeating;
false => isBeating;

// time loop
while( true )
{
    // set the play position to beginning
    0 => buf.pos;
    // randomize gain a bit
    Math.random2f(.8,.9) => buf.gain;
    
    isBeating => buf.gain;
        
    // advance time
    1::T => now;
    
    while( hi.recv( msg ) )
    {
        if( msg.isButtonDown() )
        {
            if (msg.which == 9) {
                !isBeating => isBeating;
            }
        }
    }
}
