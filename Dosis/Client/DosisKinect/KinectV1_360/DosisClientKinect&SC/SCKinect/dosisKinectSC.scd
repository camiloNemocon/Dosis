// imprime el puerto por el que se comunica por defecto con TidalCycles, por tanto, este puerto no lo utiliza DOSIS
NetAddr.langPort;   

// imprime la direccion IP y el puerto, la dirección IP que salga es la que se coloca en Dosis Cliente: "dosisConection = new NetAddress(dirección IP,puerto);"
NetAddr.localAddr;   


//colocamos el puerto por el que se va a comunicar con Dosis Cliente: "dosisConection = new NetAddress(dirección IP,33333);"
thisProcess.openUDPPort(33333);

//muestra los puertos que estan abiertos, en donde debe aparecer el puerto 33333
thisProcess.openPorts; 

// se crea la funcion OSC que recibe los mensajes
o = OSCFunc({ arg msg, time, addr, recvPort;[msg, time, addr, recvPort].postln; }, '/DosisComunicacionSC'); // create the OSCFunc

//solo se utiliza para cerrar el puerto y la conexión con Dosis Cliente
//o.free;    // remove the OSCFunc when you are done.


//SONIDO 1: mano izquierda hacia los lados
(
SynthDef(\hola, {|fre=4 freq= 400 amp=1|
var env, adjust, sig, a;
env=EnvGen.kr(Env.perc(0.1,3),doneAction:2);
adjust = AmpCompA.kr(freq, 440, 0.6, 0.3);
a = SinOsc.ar(
LFPulse.kr(fre, 0.5, 0.5, freq * 0.3, [freq,freq]),0, 0.5
)!2;
sig= a*adjust;
OffsetOut.ar(0,
		DirtPan.ar(sig, ~dirt.numChannels,0, env)
	)
}).add
)

x=Synth.new(\hola, [\gate,1])



//SONIDO 2: mano derecha hacia los lados
(
SynthDef(\lola, {|fre=5 freq1=200|
var env, adjust, sig;
env=EnvGen.kr(Env.perc(0.1,1),doneAction:2);
adjust = AmpCompA.kr(freq1, 500, 0.32, 0.3);
a = Saw.ar(
		SinOscFB.ar(fre, 0, freq1 * 0.2,[freq1,freq1]),0.2, 0.5
)!2;
sig= a*adjust;
OffsetOut.ar(0,
		DirtPan.ar(sig, ~dirt.numChannels,0, env)
	)
}).add
)

x=Synth.new(\lola, [\gate,1])



//SONIDO 3: mano derecha hacia hacia el frente
(
SynthDef(\bombo,{|gate=1,frecuencia=70|
	var sen, env;
	sen=Pan2.ar(SinOsc.ar(frecuencia,0,3),0,1);
	env=EnvGen.kr(Env.perc(0,0.13),gate,doneAction:2);
	OffsetOut.ar(1,
		DirtPan.ar(sen, ~dirt.numChannels,0, env)
	)
}).add
)

x=Synth.new(\bombo, [\gate,1])


//SONIDO 4: mano izquierda hacia el frente
(
SynthDef(\hi,{|gate=0|
	var sen, env;
	sen=HPF.ar(WhiteNoise.ar(0.5),2000,0.9);
	env=EnvGen.kr(Env.perc(0.01,0.13),gate,doneAction:2);
	OffsetOut.ar(0,
		DirtPan.ar(sen, ~dirt.numChannels,0, env)
	)
}).add
)

x=Synth.new(\hi, [\gate,1])





//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//el primer valor del mensaje recibido modificará \freq  de hola
//el primer valor lo da la pos de la mano izquierda moviendola horizontalmente
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('hola',[\freq, msg[1]] );
		msg[1].postln;
	},"/DosisComunicacionSC");
)


//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//el segundo valor del mensaje recibido modificará \freq de lola
//el segundo valor lo da la pos de la mano derecha moviendola horizontalmente
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('lola',[\freq1, msg[2]] );
		msg[2].postln;
	},"/DosisComunicacionSC");
)


//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//el terce valor del mensaje recibido reproduce el sonido bombo
//el tercer valor lo da la pos de la mano derecha moviendola hacia el frente dando un valor de 0 y 1, enviaNDO UN 1 cuando la mano esta al frente
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('bombo',[\gate, msg[3]] );
		msg[3].postln;
	},"/DosisComunicacionSC");
)


//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//el cuarto valor del mensaje recibido reproduce el sonido hi
//el cuarto valor lo da la pos de la mano izquierda moviendola hacia el frente dando un valor de 0 y 1, enviaNDO UN 1 cuando la mano esta al frente
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('hi',[\gate, msg[4]] );
	},"/DosisComunicacionSC");
)

//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//reproducie y modifica la frecuencia de los sonidos dependiendo de la posicion de las manos
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('hola',[\freq, msg[1]] );
		Synth('lola',[\freq1, msg[2]] );
		Synth('hi',[\gate, msg[4]] );
		Synth('bombo',[\gate, msg[3]] );
	},"/DosisComunicacionSC");
)

