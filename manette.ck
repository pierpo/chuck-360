
0 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;

// variables
int base;
float a0;
float a1;
float a2;
int count;

// start things
SinOsc m => SinOsc c => Envelope e => dac;

// hid objects
Hid hi;
HidMsg msg;

// try
if( !hi.openJoystick( device ) ) me.exit();
<<< "joystick '" + hi.name() + "' ready...", "" >>>;



100::ms => dur T; T - (now % T) => now;

SinOsc s => JCRev r => dac;

.1 => s.gain;
0.3 => r.mix;

[ 0, 2, 4, 7, 9 ] @=> int scale[];
[0, 4, 7] @=> int C[];
[5, 9, 0] @=> int F[];
[7, 11, 2] @=> int G[];
[9, 0, 4] @=> int Am[];

int currentChord[];
C @=> currentChord;

while (true) {
    // Melody
    currentChord[ Math.random2(0,2) ] => float freq;
    Std.mtof( 72 + (Math.random2(0,1)*12 + freq) ) => s.freq;
    0 => s.phase;
   
    // Beat
    SndBuf buf => Gain g => dac;
    me.dir() + "audio/kick_01.wav" => buf.read;
    1 => g.gain;
    0 => buf.pos;
    1::T => now;
    Math.random2f(.8,.9) => buf.gain;
    
    while( hi.recv( msg ) )
    {
        if( msg.isButtonDown() )
        {
            if (msg.which == 11) {
                C @=> currentChord;
            } else if (msg.which == 12) {
                F @=> currentChord;
            } else if (msg.which == 13) {
                G @=> currentChord;
            } else if (msg.which == 14) {
                Am @=> currentChord;
            }
            <<<"---">>>;
            <<<msg.which>>>;
            msg.which => base;
            count++;
            if( count == 1 ) e.keyOn();
        }
    }
    120::ms => now;


}