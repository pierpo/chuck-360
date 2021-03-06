
// Initialize the 360 controller
0 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;

Hid hi;
HidMsg msg;

if( !hi.openJoystick( device ) ) me.exit();
<<< "joystick '" + hi.name() + "' ready...", "" >>>;

// Define the chords

[0, 4, 7] @=> int C[];
[5, 9, 0] @=> int F[];
[7, 11, 2] @=> int G[];
[9, 0, 4] @=> int Am[];

// Synchronize to period
.5::second => dur T;
T - (now % T) => now;

// Sinusoid & effects definitions
SinOsc s => JCRev r => Chorus c => dac;
SinOsc bass => dac;

0.12 => bass.gain;
0 => c.mix;
.05 => s.gain;
.25 => r.mix;

int currentChord[];
C @=> currentChord;

int isPlaying;
false => isPlaying;

// TODO: use this to disable the bass if not played
int isBassPlaying;
false => isBassPlaying;

while( true )
{
    // Melody
    currentChord[ Math.random2(0,2) ] => float freq;
    Std.mtof( 60 + (Math.random2(0,3)*12 + freq) ) => s.freq;
    // reset phase for extra bandwidth
    0 => s.phase;

    if (isPlaying) {
        0.05 => s.gain;
    } else {
        0 => s.gain;
    }
    
    // advance time
    if( Math.randomf() > .25 ) .25::T => now;
    else .5::T => now;
    
    while( hi.recv( msg ) )
    {
        if ( msg.isAxisMotion() )
        {           
            if (msg.which == 0) {
                float chorusValue;
                (1 + msg.axisPosition) / 2 => chorusValue;
                if (chorusValue < .2) {
                    chorusValue * 2 => c.mix;
                }
            } else if (msg.which == 2) {
                if (msg.axisPosition > .7) {
                     <<< "axe X +1 joy 2" >>>;
                     Std.mtof(60 + currentChord[0]) => bass.freq;
                 } else if (msg.axisPosition < -.7) {
                     <<< "axe X -1 joy 2" >>>;
                     Std.mtof(60 + currentChord[1]) => bass.freq;
                 }
            } else if (msg.which == 3) {
                if (msg.axisPosition > .7) {
                    <<< "axe Y +1 joy 2" >>>;
                     Std.mtof(60 + currentChord[2]) => bass.freq;
                } else if (msg.axisPosition < -.7) {
                    <<< "axe Y -1 joy 2" >>>;
                     Std.mtof(60 + currentChord[0]) => bass.freq;
                 }
            }
        } else if( msg.isButtonDown() ) {
            if (msg.which == 11) {
                C @=> currentChord;
            } else if (msg.which == 12) {
                F @=> currentChord;
            } else if (msg.which == 13) {
                G @=> currentChord;
            } else if (msg.which == 14) {
                Am @=> currentChord;
            }
            true => isPlaying;
        } else if( msg.isButtonUp() ) {
            if (msg.which == 11 || msg.which == 12 || msg.which == 13 || msg.which == 14) {
                false => isPlaying;
            }
        }
    }
}