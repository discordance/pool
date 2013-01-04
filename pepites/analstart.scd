(
{
var freq = 100, shape, up, down, output;

shape = MouseX.kr(0, 1);

up = shape.clip(0.5, 1.0);
up = [0.5, 1.0].asSpec.unmap(up);
up = [0.0, 0.5].asSpec.map(up);
down = shape.clip(0.0, 0.5);

//up.poll; down.poll;

output = Lag2UD.ar(Pulse.ar(freq, 0.5), freq.reciprocal * up, freq.reciprocal * down);
output ! 2

}.scope;
)