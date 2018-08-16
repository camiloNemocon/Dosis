// imprime el puerto por el que se comunica por defecto con TidalCycles, por tanto, este puerto no lo utiliza DOSIS
NetAddr.langPort;

// imprime la direccion IP y el puerto, la dirección IP que salga es la que se coloca en Dosis Cliente: "dosisConection = new NetAddress(dirección IP,puerto);"
NetAddr.localAddr;

//colocamos el puerto por el que se va a comunicar con Dosis Cliente: "dosisConection = new NetAddress(dirección IP,33333);"
thisProcess.openUDPPort(33333);

//muestra los puertos que estan abiertos, en donde debe aparecer el puerto 33333
thisProcess.openPorts;

// se crea la funcion OSC que recibe los mensajes
o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln; }, '/"DosisComunicacionSC"');


//solo se utiliza para cerrar el puerto y la conexión con Dosis Cliente
//o.free;



(
SynthDef.new(\tone, {
	arg freq=40, nharm=12, detune=0.2, gate=0, pan=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01,2), gate, doneAction:2);
	sig = Blip.ar(
		freq * LFNoise1.kr(0.2!16).bipolar(detune).midiratio,
		nharm
	);
	sig = sig * LFNoise1.kr(0.5!16).exprange(0.1,1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

//reproduce el sonido /tone
x = Synth.new(\tone, [\gate,1])



//se genera una funcion que queda pendiente de recibir el mensaje con los dos valores del mouse de parte de Dosis Cliente
//el primer valor del mensaje recibido modificará \freq y el segundo valor modificará \nharm
//se mapean los valores enviados .linexp(min valor recibido,max  valor recibido,min valor que necesito,max valor que necesito)
(
OSCdef('starlistener',
	{
    	 arg msg, time, addr, port;
		 Synth('tone',[\gate,1, \freq, msg[1].linexp(0,400,20,500), \nharm, msg[2].linexp(0,300,1,500)] );
		 msg[1].postln;
		 msg[2].postln;
	},"/DosisComunicacionSC");
)


//se genera una funcion que queda pendiente de recibir el mensaje con el valor del codigo int de parte de Dosis Cliente
//el unico valor del mensaje recibido modificará \freq
(
OSCdef('starlistener',
	{
        arg msg, time, addr, port;
		Synth('tone',[\gate,1, \freq, msg[1]] );
		msg[1].postln;
	},"/DosisComunicacionSC");
)


