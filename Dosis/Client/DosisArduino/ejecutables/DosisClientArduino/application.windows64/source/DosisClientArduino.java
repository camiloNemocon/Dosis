import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import cc.arduino.*; 
import org.firmata.*; 
import processing.serial.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DosisClientArduino extends PApplet {

   
//julio 2018
//By. Camilo Nemocon

//-----------------------Librerias-------------------






//------------------------Variables-------------------
Arduino arduino;


//Port numbre Arduino///////////////////////////////////
int portArduino = 0;

ServoDosis servoPin2;
ServoDosis servoPin4;
ServoDosis servoPin7;
ServoDosis servoPin8;
ServoDosis servoPin12;
ServoDosis servoPin13;

StepperDosis motorPaso;
boolean motorPasoActivo = false;

boolean servoActivoPin2 = false;
boolean servoActivoPin4 = false;
boolean servoActivoPin7 = false;
boolean servoActivoPin8 = false;
boolean servoActivoPin12 = false;
boolean servoActivoPin13 = false;

// inverse of screen dimensions
float invWidth, invHeight;    
  
PFont fuente;

int leftmargin = 10;
int rightmargin = 10;

//texto que se envia al servidor
String buff = "";
//texto que se muestra en este canvas
String buff1 = "";
//variable que guarda los caracteres cuando se le da backspace
String letrasSinBorrar="";

//ubicación en y del historial del codigo 
int y=370;

//arreglo con los mensajes enviados
ArrayList<String> codigos;

//a partir de la palabra detectada escrita por el usuario se determina la instruccion a colocar
int palabraInstruccion = 0;

//arreglo con los mensajes enviados
ArrayList<String> codigosArduino;

//texto con serparacion con , para poder hacer split posteriormente
String buff2 = "";

//genera el envio de datos en forma de loop
boolean enviarDatos = false;

//genera el envio de datos solo cuando se le da enter, no todo el tiempo
boolean enviarDatosEnter = false;

//manejo del envio de los datos a arduino cada medio segundo
int tiempoEspera = 500; 
int tiempoInicio = 0;

int totalBytes = 12;
int contadorBytes = 0;

 
 String msnUnidoArduino="";
 
 String[] translate;
 int[] datoSend;
 
 int tempContador = 0;
 boolean activarArduino = false;
 boolean activarArduino2 = false;
 
 //tiempo en que se envian los datos a Arduino para que prendan los pines al tiempo
 String timeSend = "";
 
 //genera el envio de datos a Arduino para que prendan los pines al tiempo usando la funcion SameTime
 boolean enviarDatos2 = false;
 
 //determina si usa el teclado para activar el arduino en vivo
 boolean tecladoLive = false;

 //Tecla del teclado para tecladoLive
 String TeclaLive;

 //variable que determina si se envia loopArduino o sameTime o TimeStart
 int tempSendParameter = 0;

 //genera el envio de datos a Arduino para que prendan los pines al tiempo usando la funcion TimeStart
 boolean enviarDatos3 = false;
 boolean empezar3 = false;
 // tiempo para TimeStart
 int tiempoReiniciar3 = 0;
 
 //genera el envio de datos a Arduino para que se mantengan prendidos los pines todo el tiempo usando la funcion OnArduino
 boolean enviarDatos4 = false;
 IntList prendidos;

 //genera el envio de datos a Arduino para que se apaguen los pines usando la funcion OffArduino
 IntList apagados;

 //tiempo para same Time
 int[] tiempoReiniciar;
 boolean empezar = false;

 //tiempo que mantiene prendido los pines y que se reinicia 
 int[] tiempoReiniciarV2;

 //manejo del envio de los datos a arduino cada tanto tiempo, donde este tiempo se puede modificar con las flechas
 int tiempoFlechas = 0;

 
//------------------------Setup-------------------
public void setup() 
{
  
  frameRate(30);
  
  noCursor();
  
  //tipografia
  fuente = loadFont("AgencyFB-Reg-48.vlw");
  //tamaño de la fuente
  textFont(fuente, 25);
  
  //inicializa el arreglo de los mensajes a enviar
  codigos = new ArrayList<String>();
  
  //fondo
  background(0);
  
  invWidth = 1.0f/width ;
  invHeight = 1.0f/( height/2 );
    
  //inicializa el arreglo de los mensajes a enviar
  codigosArduino = new ArrayList<String>();
  
  // imprime el puerto en el que esta conectado arduino
  println(Arduino.list());
  
  //puerto serial por donde le va a enviar los datos a arduino para Windows
  arduino = new Arduino(this, Arduino.list()[portArduino], 57600);
  
  //puerto serial por donde le va a enviar los datos a arduino para MAC
  //arduino = new Arduino(this, "/dev/cu.usbmodem1411", 57600); 
 
  //le digo que todos los pines sean de salida
  for (int i = 0; i <= 22; i++)
  {
    arduino.pinMode(i, Arduino.OUTPUT);
    
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
    arduino.analogWrite( i, 0 );
  }
  
  stopArduino();
  
  tiempoReiniciar = new int [9];    
  tiempoReiniciarV2 = new int [9];  
}


//------------------------Draw-------------------
public void draw() 
{  
  //fondo
  fill(0);
  rect(0, 0, width, (height/2)-50);
  
  //color para titilar el cuadrado
  if((millis() % 500) < 250)
  {
    noFill();
  }
  else
  {
    fill(0xffD3EAE3);
    stroke(0xffD3EAE3);
  }
  
  
  pushMatrix();

  //ubicacion del rectangulo que titila
  float rPos;
  rPos = textWidth(buff1)+leftmargin;
  rect(rPos+1, 19, 10, 21);

  translate(rPos,10+25);
  char k;
 
  //color de las palabras
  fill(0xffD3EAE3);

  //coloca en orden las letras escritas a costado izquierdo del canvas
  for(int i=0;i<buff1.length();i++)
  {
    k = buff1.charAt(i);
    translate(-textWidth(k),0);
    text(k,0,0);
  }
  
  
  popMatrix();
  
  //muestra los mensajes enviados a costado derecho del canvas
  historialCodigo();
  
  instrucciones();
  
  if(enviarDatos==true)
  {
    enviarArduino();
  }
  
  if(enviarDatos2==true)
  {
    enviarArduinoSameTime(timeSend);
  }
  
  if(enviarDatos3==true)
  {
    enviarArduinoTimeStart(timeSend);
  }
  
  if(enviarDatos4==true)
  {
    prenderArduino();
  }
    
  if(servoActivoPin2==true)
  {
    servoPin2.update();
  }
  if(servoActivoPin4==true)
  {
    servoPin4.update();
  }
  if(servoActivoPin7==true)
  {
    servoPin7.update();
  }
  if(servoActivoPin8==true)
  {
    servoPin8.update();
  }
  if(servoActivoPin12==true)
  {
    servoPin12.update();
  }
  if(servoActivoPin13==true)
  {
    servoPin13.update();
  }
  
  if(motorPasoActivo==true)
  {
    motorPaso.update();
  }
  
  //test pines numeros
  /*for( int i = 2; i < 10; i++ ) 
  { 
        arduino.digitalWrite( i, Arduino.HIGH );
        arduino.analogWrite( i, 255 );
  }
  
  //test pines letras
  for( int i = 11; i < 22; i++ ) 
  { 
        arduino.digitalWrite( i, Arduino.HIGH );
  }*/
  
  
  
}




public void enviarArduino()
{
  //cada medio segundo envia el dato
  if (millis() - tiempoInicio > tiempoEspera) 
  {
    arduino.digitalWrite(datoSend[contadorBytes], Arduino.HIGH);
        
    if( datoSend[contadorBytes] < 19  )
    {
       arduino.analogWrite( datoSend[contadorBytes], 255 );
    }     
    
    if(contadorBytes > 0)
    {
      arduino.digitalWrite(datoSend[contadorBytes-1], Arduino.LOW);  
      arduino.analogWrite( datoSend[contadorBytes-1], 0 );
    }
    
    if(contadorBytes == 0)
    {
      arduino.digitalWrite(datoSend[datoSend.length-1], Arduino.LOW);  
      arduino.analogWrite( datoSend[datoSend.length-1], 0 );
    }
    
    println(datoSend[contadorBytes]);
       
    contadorBytes++;
    
    
    if(contadorBytes>=totalBytes)
    {
       contadorBytes = 0;
    }
  
     tiempoInicio = millis();
  } 
  
  if(contadorBytes==0 && enviarDatosEnter == true)
  {  
    arduino.digitalWrite(datoSend[datoSend.length-1], Arduino.LOW);  
    arduino.analogWrite( datoSend[datoSend.length-1], 0 );
    enviarDatos = false;
    activarArduino = false;
    enviarDatosEnter = false;
  }
 
}

public void prenderArduino()
{
  for(int i=0; i<prendidos.size(); i++)
  {    
    arduino.digitalWrite(prendidos.get(i), Arduino.HIGH);
  }
}

public void apagarArduino()
{
  for(int i=0; i<apagados.size(); i++)
  {
    arduino.digitalWrite(apagados.get(i), Arduino.LOW);
  }
}



public void keyPressed()
{  
    char k;    
    k = (char)key;
    
    TeclaLive = str(k);
    
    switch(k)
    {    
      //cuando se le da backspace
      case 8:    
      if(buff1.length()>0)
      {
        buff1 = buff1.substring(1);
      }
      
      if(buff2.length()>0)
      {
         //buff2 = buff2.substring(0,buff2.length()-2);
         buff2 = buff2.substring(0,buff2.length()-1);
      } 
      
      if(buff.length()>0)
      {
        for(int i=0;i<buff.length()-1;i++)
        {
          k = buff.charAt(i);
          letrasSinBorrar += str(k);
        }
        buff = letrasSinBorrar;
        letrasSinBorrar="";
      }
      break;
    
      case 13:  // Avoid special keys
      case 10:
      case 65535:
      case 127:
      case 27:
      break;
      
    default:
      //el texto que esta dentro del margen
      if(textWidth(buff1+k)+leftmargin < width-rightmargin)
      {
        //texto que se escribe en el orden correcto en el canvas
        buff1=k+buff1;     
      }
      else
      {
         if(tecladoLive == true)
         { 
            codigos.add(buff1);
            buff1 = "";
            //coloca el mensaje del historial abajo de la otra palabra
            y+=30; 
         }
      }
      
      
      if(textWidth(buff+k)+leftmargin < width-rightmargin)
      {
        //mensaje en el orden correcto de caracteres para enviar
        buff=buff+k;
        
        if(buff.equals("Once") || buff.equals("Loop") || buff.equals("PararA"))
        {
          tecladoLive = false;
          palabraInstruccion = 13; 
        }        
        else if (buff.equals("Same") ||  buff.equals("Time"))
        {
          palabraInstruccion = 14;
        }
        else if(buff.equals("Tecla")|| buff.equals("PararT"))
        {
          palabraInstruccion = 15; 
        }
        if(buff.equals("Servo"))
        {
          palabraInstruccion = 16; 
        }
        if(buff.equals("Paso"))
        {
          palabraInstruccion = 18; 
        }
        if(buff.equals("On") || buff.equals("Off"))
        {
          palabraInstruccion = 20; 
        }
        
      }
      
      if(tecladoLive == false)
      {  
        //buff para arduino
        if(textWidth(buff2+k)+leftmargin < width-rightmargin)
        {
          //mensaje que se le incluye la , para hacer posteriormente un split
          //buff2=buff2+k+",";
          buff2=buff2+k;
        }      
      }
      else
      {       
        arduino.digitalWrite(PApplet.parseInt(TeclaLive), Arduino.HIGH);   
      }
        
      break;
    }
}


//muestra los mensajes enviados a costado derecho del canvas
public void historialCodigo()
{
  textSize(25);
    //color y ubicación de cada letra que se coloca
    fill(0xff45DB0B);
    //dibuja cada texto enviado uno debajo del otro
    for(int i=0; i<codigos.size();i++)
    {  
        text(codigos.get(codigos.size()-1),10,y); 
    }
    
    //cuando los textos lleguen al final del canvas
    if(y >= height-170)
    {
      //borre el historial
      background(0);
      //inicie el texto al comienzo del canvas
      y = 370; 
    }
}

public void instrucciones()
{
  fill(0xff8B8A8B);
  noStroke();
  rect(0,600,width,height);
  
  fill(0xff550F90);  
  
  if(palabraInstruccion == 13)
  {
    textSize(25);
    text("OnceArduino() => envia la data una vez.",10,630);
    
    textSize(16);
    text("Ej: OnceArduino()             3,4,5,6(pines)",10,650);
    
    textSize(25);
    text("LoopArduino() => envia la data todo el tiempo",10,680);
    
    textSize(16);
    text("Ej: LoopArduino()             3,4,5,6(pines)",10,700);
    
    textSize(25);    
    text("PararArduino() => para el envio de la data",10,730);
  }
  if(palabraInstruccion == 14)
  {
    textSize(25);
    text("SameTime(int(timeStart)|int(timeOn))",10,630);
    
    textSize(16);
    text("(tiempo empieza a prender cada pin|tiempo dura prendido cada pin)",10,650);
    text("Ej: SameTime(2,4|5,5)        4,8(pines)",10,670);
    
    textSize(25);
    text("TimeStart(int(timeStart)|int(timeOn))",10,700);
    
    textSize(16);
    text("(UN # tiempo empieza a prender los pines|tiempo dura prendido cada pin)",10,720);
    text("Ej: TimeStart(2|3,2)        4,8(pines)",10,740);
    
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 15)
  {
    textSize(25);
    text("Teclado() =>Activa Arduino con las teclas",10,630);
    text("PararTeclado() =>Desactiva Arduino con las teclas",10,660);
  }
  else if(palabraInstruccion == 16)
  {
    textSize(22);
    text("ServoArduino() outPin,AngIn,estado,AngFin,tiempo",10,620);
    textSize(14);
    text("Ej: ServoArduino()          2,1,0,70,0 ",10,640);
    text("int outPin => pin al que esta conectado el servo",10,660);
    text("int AngIn => donde empieza el giro (usado en el estado: 1,2,3)",10,680);
    text("int estado => estados desde el 0 hasta el 5",10,700);
    text("int AngFin => donde termina o el angulo de giro (usado en el estado: 0,1,2,3,4)",10,720);
    text("int tiempo => (usado en el estado: 3)",10,740);
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 17)
  {
    textSize(20);
    text("ServoArduino()",10,620);
    textSize(14);
    text("estado=0 (giro desde 0° hasta AngFin, luego retorna a 0° rápido)",10,640);
    text("estado=1 (giro desde AngIn hasta AngFin, retorna a AngIn con el mismo tiempo de giro)",10,660);
    text("estado=2 (giro desde AngIn hasta 180°, donde el giro se realiza con el AngFin dado, luego retorna rápido y espera TimeWait para empezar)",10,680);
    text("estado=3 (giro desde AngIn hasta AngFin rápidamente, luego espera Tiempo y vuelve a AngIn)",10,700);
    text("estado=4 (giro al AngFin)",10,720);
    text("estado=5 (giro a 0°)",10,740);
    textSize(25);
    text("         ",10,770);
  }
  else if(palabraInstruccion == 18)
  {
    textSize(25);
    text("PasoArduino()",10,630);
    textSize(16);
    text("Ej: PasoArduino()   in1,in2,in3,in4,analog,estado,vel",140,630);
    text("Ej: 2,3,4,5,0,3,5",10,650);
    text("int in => pin al que esta conectado el paso a paso",10,670);
    text("int analog => pin al que esta conectado el pulsador",10,690);
    text("int estado => estados desde el 0 hasta el 3",10,710);
    text("int vel => velocidad para rotar, 3 hasta 11",10,730);
    textSize(25);
    text("         ",10,750);
  }
  else if(palabraInstruccion == 19)
  {
    textSize(20);
    text("PasoArduino()",10,620);
    textSize(14);
    text("estado=0 (no gira, detiene el motor)",10,640);
    text("estado=1 (giro a la derecha y para presionando pulsador)",10,660);
    text("estado=2 (giro a la izquierda y para presionando pulsador)",10,680);
    text("estado=3 (giro a una lado y luego al otro cuando presiona el pulsador)",10,700);
    textSize(25);
    text("         ",10,770);
  }
  if(palabraInstruccion == 20)
  {
    textSize(25);
    text("OnArduino() => prende los pines escritos",10,630);
    
    textSize(16);
    text("Ej: OnArduino()      7,8,9    (pines)",10,650);
    
    textSize(25);
    text("OffArduino() => apaga los pines escritos",10,680);
    
    textSize(16);
    text("Ej: OffArduino()      7,8,9    (pines)",10,700);
    
    textSize(25);    
    text("  ",10,730);
  }
  
}

public void keyReleased() 
{
  if(tecladoLive == true)
  {
    arduino.digitalWrite(PApplet.parseInt(TeclaLive), Arduino.LOW);  
  }
  
  //cuando opriman enter
  if(keyCode==ENTER)
  {    
    //adiciona el string al arreglo de mensajes enviados para dibujarlos
    codigos.add(buff); 
    
    if(buff.equals("PasoArduino()"))
    {  
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 4;
      datosArduino1(tempSendParameter);  
   //   timeSend="";      
    }
    
    if(buff.equals("ServoArduino()"))
    {  
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 3;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("PararArduino()"))
    {
      if(tecladoLive == true)
      {
        tecladoLive = false;  
      }
      
      stopArduino();
    }
    
    if(buff.equals("Teclado()"))
    {
       //stopArduino();
       tecladoLive = true; 
    }
    
    if(buff.equals("PararTeclado()"))
    {
       //stopArduino();
       tecladoLive = false; 
    }
    
    if(buff.equals("OnArduino()"))
    {  
      //stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 5;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("OffArduino()"))
    {  
      //stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 6;
      datosArduino1(tempSendParameter);  
      //timeSend="";
    }
    
    if(buff.equals("LoopArduino()"))
    {  
      stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 0;
      datosArduino(tempSendParameter);  
      timeSend="";
    }
    
    if(buff.equals("OnceArduino()"))
    { 
      stopArduino();
      buff = "";
      buff1 = "";
      buff2 = "";
      tempSendParameter = 0;
      datosArduino(tempSendParameter);
      timeSend="";
      enviarDatosEnter = true;
    }
    
    if(!buff.equals(""))
    {
      String temp = "";
      String[] mensaje;
      boolean mensajeValido = false;
  
      if(buff.substring(buff.length()-1).equals(")"))
      {
        temp = buff.substring(0,buff.length()-1);    
        mensajeValido = true;
      }
      
       if(mensajeValido == true )
        {
            mensaje = split(temp,'(');                  
            
            if (mensaje[0].equals("SameTime"))
            {
              stopArduino();
              timeSend = mensaje[1];
              buff = "";
              buff1 = "";
              buff2 = "";
              tempSendParameter = 1;
              datosArduino(tempSendParameter);
            }
            
            if (mensaje[0].equals("TimeStart"))
            {
              stopArduino();
              timeSend = mensaje[1];
              buff = "";
              buff1 = "";
              buff2 = "";
              tempSendParameter = 2;
              datosArduino(tempSendParameter);
            }
        }
    }
    
    if(!buff.equals("") && activarArduino2 == true)
    {
      datosArduino1(tempSendParameter);
    }
    
    if(!buff.equals("") && activarArduino == true)
    {
      datosArduino(tempSendParameter);
      if(tempSendParameter == 1)
      {       
        for(int i=0; i<tiempoReiniciar.length; i++)
        {          
          tiempoReiniciar[i] = millis();
          tiempoReiniciarV2[i] = millis();
        }
        empezar = true;
      }
      if(tempSendParameter == 2)
      {       
        tiempoReiniciar3 = millis();
        for(int i=0; i<tiempoReiniciarV2.length; i++)
        { 
          tiempoReiniciarV2[i] = millis();
        }
        empezar3 = true;
      }
    }
    
    //limpia los strings del mensaje que se envia y del que se aparece en el canvas
    buff = "";
    buff1 = "";
    buff2 = "";
    palabraInstruccion = 0;
    
    //coloca el mensaje del historial abajo de la otra palabra
    y+=30;    
  }
  
  
  if(keyCode==RIGHT)
  {  
    if(palabraInstruccion == 0)
    {
      palabraInstruccion = 13;
    }
    
    palabraInstruccion ++;
    
    if(palabraInstruccion > 20)
    {
      palabraInstruccion = 13;
    }
  }
  
  if(keyCode==LEFT)
  {
     palabraInstruccion --;
    
    if(palabraInstruccion < 13)
    {
      palabraInstruccion = 20;
    }
  }
  
  if(keyCode == UP)
  {
    if(enviarDatos==true)
    {
      tiempoEspera = tiempoEspera + 50; 
    }
    
    if(enviarDatos2 == true || enviarDatos3 == true)
    {
      tiempoFlechas = tiempoFlechas + 1;
    }
  }
  
  if(keyCode == DOWN)
  {
    if(enviarDatos==true)
    {
      tiempoEspera = tiempoEspera - 50; 
    }
    
    if(enviarDatos2 == true || enviarDatos3 == true)
    {
      tiempoFlechas = tiempoFlechas - 1;
    }
  }
}

public void stopArduino()
{
  /*
  if(motorPasoActivo == false)
  {
    for (int i = 0; i <= 5; i++)
    {
      arduino.analogWrite( i, 0 );
    } 
  }
  else */
  
  if(motorPasoActivo == true)
  {
    motorPaso.pararMotorPaso();
    motorPasoActivo = false;
  } 
  
  activarArduino = false;
  activarArduino2 = false;
  
  if(enviarDatos == true)
  {
    for(int i=0; i<datoSend.length; i++)
    {
      arduino.digitalWrite(datoSend[i], Arduino.LOW);  
      arduino.analogWrite( datoSend[i], 0 );
    } 
    enviarDatos = false;
  }
  
  enviarDatos2 = false;
  enviarDatos3 = false;
  enviarDatos4 = false;
  
  servoActivoPin2 = false;
  servoActivoPin4 = false;
  servoActivoPin7 = false;
  servoActivoPin8 = false;
  servoActivoPin12 = false;
  servoActivoPin13 = false;  
  
  
  for (int i = 0; i <= 13; i++)
  {
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
  }
  
}

public void datosArduino1(int sendTime)
{ 
  if(!buff2.equals(""))      
  {      
    if(sendTime==3)
    {
      servo(buff2);
    }
    if(sendTime==4)
    {
      MotorpasoApaso(buff2);     
    }    
    if(sendTime==5)
    {      
      String[] mensajeDatos1;
    
      mensajeDatos1 = split(buff2,',');      
      
      prendidos = new IntList();
      
      for(int i=0; i<mensajeDatos1.length; i++)
      {
        prendidos.append(PApplet.parseInt(mensajeDatos1[i]));
      }
       
      enviarDatos4 = true;
    }
    
    if(sendTime==6)
    {
      if(enviarDatos4 == true)
      {
        String[] mensajeDatos1;
      
        mensajeDatos1 = split(buff2,',');      
        
        apagados = new IntList();
        
        for(int i=0; i<mensajeDatos1.length; i++)
        {
          apagados.append(PApplet.parseInt(mensajeDatos1[i]));
        }
        
        for(int k=0; k<prendidos.size(); k++)
        {
          if(apagados.hasValue(prendidos.get(k)) == true) 
          {
            prendidos.remove(k); 
          } 
        }
        
        apagarArduino();
      }
    }
  }
    
  activarArduino2 = true;  
}

public void datosArduino(int sendTime)
{ 
  if(!buff2.equals(""))      
  {    
   //adiciona el string al arreglo de mensajes enviados para enviarlos a Arduino
   codigosArduino.add(buff2);
   
    msnUnidoArduino="";
    
    for (int i = 0; i <= 22; i++)
    {
      //apago todos lo pines
      arduino.digitalWrite(i, Arduino.LOW);
      //arduino.analogWrite( i, 0 );
    }
    
    if(codigosArduino.size()>0)
    {
      msnUnidoArduino = codigosArduino.get(codigosArduino.size()-1);
    }
    else
    {
      msnUnidoArduino = buff2;
    }  
    
    translate = split(msnUnidoArduino,',');
    
    datoSend = new int [translate.length];
    
    for (int i = 0; i<translate.length; i++)
    {
      if(translate[i].equals("2") || translate[i].equals("3") || translate[i].equals("4") || translate[i].equals("5") || translate[i].equals("6") || translate[i].equals("7") || translate[i].equals("8") || translate[i].equals("9")|| translate[i].equals("10")|| translate[i].equals("11")|| translate[i].equals("12")|| translate[i].equals("13"))
      {
        datoSend[i] = PApplet.parseInt(translate[i]); 
      }
      else if(translate[i].equals("a") || translate[i].equals("i") || translate[i].equals("p") || translate[i].equals("x"))
      {
        datoSend[i] = 10; 
      }
      else if(translate[i].equals("b") || translate[i].equals("j") || translate[i].equals("q") || translate[i].equals("y"))
      {
        datoSend[i] = 11; 
      }
      else if(translate[i].equals("c") || translate[i].equals("k") || translate[i].equals("r") || translate[i].equals("z"))
      {
        datoSend[i] = 12; 
      }
      else if(translate[i].equals("d") || translate[i].equals("l") || translate[i].equals("s"))
      {
        datoSend[i] = 13; 
      }
      else if(translate[i].equals("e") || translate[i].equals("m") || translate[i].equals("t"))
      {
        datoSend[i] = 18; 
      }
      else if(translate[i].equals("f") || translate[i].equals("n") || translate[i].equals("u"))
      {
        datoSend[i] = 19; 
      }
      else if(translate[i].equals("g") || translate[i].equals("ñ") || translate[i].equals("v"))
      {
        datoSend[i] = 20; 
      }
      else if(translate[i].equals("h") || translate[i].equals("o") || translate[i].equals("w"))
      {
        datoSend[i] = 21; 
      }
    }    
    
    totalBytes = datoSend.length;
    contadorBytes = 0;
    
    
    if(sendTime==0)
    {
      enviarDatos = true;
    }
    if(sendTime==1)
    {
      enviarDatos2 = true;
    }
    if(sendTime==2)
    {
      enviarDatos3 = true;
    }
  } 
  
  activarArduino = true;
}

public void MotorpasoApaso(String data)
{
   String[] mensajeDatos1;
    
   mensajeDatos1 = split(data,',');
   
  //si la cantidad de parametros son correctos  
  if(mensajeDatos1.length == 7)
  {
    motorPaso = new StepperDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]),PApplet.parseInt(mensajeDatos1[5]),PApplet.parseInt(mensajeDatos1[6]));
    motorPasoActivo = true;
  }  
  else
  {
    println("Son 7 parametros: pinOut1,pinOut2,pinOut3,pinOut4,pinIn1,Estado,Vel");
  }
  
}

public void servo(String data)
{
    String[] mensajeDatos1;
    
    mensajeDatos1 = split(data,',');
    
    //si la cantidad de parametros son correctos  
    if(mensajeDatos1.length == 5)
    {
      if(PApplet.parseInt(mensajeDatos1[0])==2)
      {        
        servoPin2 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin2 = true;
      }
      if(PApplet.parseInt(mensajeDatos1[0])==4)
      {
        servoPin4 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin4 = true;
      }
      if(PApplet.parseInt(mensajeDatos1[0])==7)
      {
        servoPin7 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin7 = true;
      }
      if(PApplet.parseInt(mensajeDatos1[0])==8)
      {
        servoPin8 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin8 = true;
      }
      if(PApplet.parseInt(mensajeDatos1[0])==12)
      {
        servoPin12 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin12 = true;
      }
      if(PApplet.parseInt(mensajeDatos1[0])==13)
      {
        servoPin13 = new ServoDosis(PApplet.parseInt(mensajeDatos1[0]),PApplet.parseInt(mensajeDatos1[1]),PApplet.parseInt(mensajeDatos1[2]),PApplet.parseInt(mensajeDatos1[3]),PApplet.parseInt(mensajeDatos1[4]));   
        servoActivoPin13 = true;
      }            
    }
    //si la cantidad de parametros dentro del parentesis no son correctos
    else
    {
      println("Faltan los 5 parametros");
    }
}

public void enviarArduinoSameTime(String timeSend)
{     
  String[] mensajeTimeSendCompleto;  
  mensajeTimeSendCompleto = split(timeSend,'|');
  
  String[] mensajeTimeSend;  
  mensajeTimeSend = split(mensajeTimeSendCompleto[0],','); 
  
  String[] mensajeTimePrendido;  
  mensajeTimePrendido = split(mensajeTimeSendCompleto[1],','); 
  
  
  int[] tiempoIndependiente = new int [mensajeTimeSend.length]; 
  int[] tiempoPrendido = new int [mensajeTimePrendido.length];
  
  if(mensajeTimePrendido.length == mensajeTimeSend.length)
  {
    for(int i=0; i<mensajeTimeSend.length; i++)
    {
      tiempoIndependiente[i] = PApplet.parseInt(mensajeTimeSend[i]);
      tiempoPrendido[i] = PApplet.parseInt(mensajeTimePrendido[i]);
    }
  } 
  
  
  
  if(mensajeTimeSend.length == (totalBytes) && mensajeTimeSend.length == mensajeTimePrendido.length)
  {
    if(mensajeTimeSend.length >= 1)
    {
      if(empezar==true)
      {
        for(int j=0; j<mensajeTimeSend.length; j++)
        {
           tiempoIndependiente[j] = (((PApplet.parseInt(mensajeTimeSend[j])*1000)-(millis()-tiempoReiniciar[j]))/1000)+tiempoFlechas;
                     
          if(tiempoIndependiente[j] < 0)
          {
            arduino.digitalWrite(datoSend[j], Arduino.HIGH);        
            
            tiempoPrendido[j] = ((PApplet.parseInt(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
          
            if(tiempoPrendido[j] < 0)
            {
              arduino.digitalWrite(datoSend[j], Arduino.LOW); 
              tiempoReiniciar[j] = millis();
              tiempoReiniciarV2[j] = millis();
            }
          }
          else
          {
            tiempoReiniciarV2[j] = millis();           
          }
        } 
      }      
    }  
  }
  else
  {
    println("la cantidad de variables de tiempo no corresponde a la cantidad de pines a activar"); 
    println("parametros iniciales "+ mensajeTimeSend.length);
    println("parametros finales "+ mensajeTimePrendido.length);
    println("cantidad de pines " + (totalBytes));
    println("buff " + msnUnidoArduino);
    
    /*for (int i = 0; i<datoSend.length; i++)
    {
      println(datoSend[i]); 
    }*/
  }  
}

public void enviarArduinoTimeStart(String timeSend)
{
  String[] mensajeTimeSendCompleto;  
  mensajeTimeSendCompleto = split(timeSend,'|');
  
  String[] mensajeTimeSend;  
  mensajeTimeSend = split(mensajeTimeSendCompleto[0],','); 
  
  int tempMayor = 0;
  int idMayor = 0;
    
  if(mensajeTimeSend.length == 1)
  {
    int tiempoEmpezar = 0;

    String[] mensajeTimePrendido;  
    mensajeTimePrendido = split(mensajeTimeSendCompleto[1],',');    
    
    int[] tiempoPrendido = new int [mensajeTimePrendido.length];
  
    for(int i=0; i<mensajeTimePrendido.length; i++)
    {
      tiempoPrendido[i] = PApplet.parseInt(mensajeTimePrendido[i]);
      
      //se establece cual pin tiene el mayor tiempo
      if(PApplet.parseInt(mensajeTimePrendido[i]) > tempMayor)
      {
        tempMayor = PApplet.parseInt(mensajeTimePrendido[i]);
        idMayor = i;
      }
    }
   
    if(empezar3==true && mensajeTimePrendido.length == (totalBytes))
    {    
      tiempoEmpezar = (((PApplet.parseInt(mensajeTimeSend[0])*1000)-(millis()-tiempoReiniciar3))/1000)+tiempoFlechas;
      
      if(tiempoEmpezar < 0)
      {       
        for(int j=0; j<mensajeTimePrendido.length; j++)
        {      
          //los prende todos
          arduino.digitalWrite(datoSend[j], Arduino.HIGH);             
          
          //corre el tiempo de prendido de cada pin
          tiempoPrendido[j] = ((PApplet.parseInt(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
                   
          if(tiempoPrendido[j] < 0)
          {
            arduino.digitalWrite(datoSend[j], Arduino.LOW); 
          }
          
          //apenas acabe el tiempo del pin con mayorTiempoPrendido entonces reinicia el tiempo de todo para que prenda
          if(tiempoPrendido[j] < 0 && j == idMayor)
          {
            tiempoReiniciar3 = millis();
          }
        }
      } 
      else
      {
        for(int i=0; i<mensajeTimePrendido.length; i++)
        {
          tiempoReiniciarV2[i] = millis();
        }
      }
    } 
    else
    {
      println("la cantidad de variables de tiempo no corresponde a la cantidad de pines a activar");
      println("parametros finales "+ mensajeTimePrendido.length);
      println("cantidad de pines " + (totalBytes));
      println("buff " + msnUnidoArduino);
      
      for (int i = 0; i<datoSend.length; i++)
      {
        println(datoSend[i]); 
      }
    }
  }
  else
  {
    println("la cantidad de variables del primer parametro sólo debe ser 1 antes del  simbolo |"); 
  }
}


class ServoDosis
{ 
   boolean continuar = true;
   
   //indica cuando llega al angulo 0 para iniciar a girar en el estado 0
   boolean continuarEstado0 = true;
   
   //indica cuando llega al angulo 0 para iniciar a girar en el estado 2
   boolean continuarEstado2 = true;
   
   //indica cuando cada cuanto generar el giro
   boolean continuarEstado3 = true;
   
  //indica cuando el giro llega hasta 180 en el estado 1
  int estadoGiroEstado1=1;
   
  //pin al que esta conectado el servo  ServoDosis(int outputPin)
  int outputPin;
  
  
  //int estado => estados desde el 0 hasta el 7, cada estado corresponde a una forma distinta de giro
  int estado;  
  
  //int puntoInicio => donde empieza el giro
  int puntoInicio;
  int puntoInicioBK;
  
  //int angulo => rotación cuando se usa el estado 2, 3, 4, 5, 6 
  int angulo;

  //manejo del envio de los datos a arduino cada medio segundo
  //int tEspera => tiempo en milisegundos en que hace cada movimiento del giro cuando se usa el estado 2 y 3
  int tEspera;
  int tInicio = 0;

  //ServoDosis(int outputPin)
  ServoDosis(int outputPinT, int puntoInicioT, int estadoT, int anguloT, int tEsperaT)
  {
    if(outputPinT == 0 || outputPinT == 1 || outputPinT == 3 || outputPinT == 5 || outputPinT == 6 || outputPinT == 9 || outputPinT == 10 || outputPinT == 11)
    {
      println("El servo debe estar conectado al pin 2,4,7,8,12 o 13, NO a los PWM"); 
    }
    
    if(puntoInicioT > 180)
    {
      puntoInicioT = 0; 
      println("El punto de inicio debe ser un numero menor a 180");
    }
    
    if(estadoT > 5)
    {
      puntoInicioT = 1; 
      println("El estado va  desde 0 hasta 5, NO puede ser un número mayor a 5");
    }   
    
    outputPin = outputPinT;
    estado = estadoT;  
    puntoInicio = puntoInicioT;
    angulo = anguloT;
    tEspera = tEsperaT*1000;
    
    puntoInicioBK = puntoInicioT;
  
    //Se inicializan los puertos que no son PWM para usarlos con el servo motor
    arduino.pinMode(outputPin, Arduino.SERVO);
  }

  //void update(int puntoInicio, int estado, int angulo, int tEspera)
  public void update()
  {
    //va desde el ptoInicio hasta angulo, cuando se devuelve rapido no llega al puntoInicio sino antes y luego si al puntoInicio, por esa razón se dejo predeterminado que se devuelva a 0
    //va desde el 0 hasta angulo y se devuelve a 0 rápido (no se usa el último parametro, ni tampoco el segundo)
    if (estado == 0)
    {
      //println(puntoInicio);
      if(continuarEstado0 == true)
      {
        if (puntoInicio < angulo)
        {
            puntoInicio++;          
        }
      }
       
      if (puntoInicio == angulo)
      {
        continuarEstado0 = false;
        puntoInicio = 0;
      }
      
      if(puntoInicio == 0)
      {
          continuarEstado0 = true;
      }
    }

    //va desde el ptoInicio hasta el angulo y se devuelve girando normal (no se usa el último parametro)
    if (estado == 1)
    {
       //println(puntoInicio);
       if(puntoInicio==angulo)
       {
         estadoGiroEstado1=2; 
       }
        
       if(puntoInicio==puntoInicioBK)
       {
         estadoGiroEstado1=1;
       }
        
       if(estadoGiroEstado1==2)
       {
         puntoInicio--;
       }
       else
       {
         puntoInicio++;
       }
    }
    
    // va desde en punto de inicio hasta 180 girando cada angulo indicado y se devuelve rápido, luego espera el tiempoEspera para volver a emprezar
    if (estado == 2)
    {      
      //println(puntoInicio);
      if(continuarEstado2 == true)
      {
        if (puntoInicio < 180)
        {
          if(continuar == true)
          {
            puntoInicio += angulo;
            continuar = false;
          }
          else
          {
            if (millis() - tInicio > 200) 
            {
              continuar = true;     
              tInicio = millis();
            }  
          }
        } 
        else
        {
          puntoInicio = puntoInicioBK;          
          continuarEstado2 = false;                
        }
      }
      else
      {
        if (millis() - tInicio > tEspera) 
        {            
          continuarEstado2 = true;
          continuar = true;
          tInicio = millis();
        }    
      }
       
     
    }
    
    // va desde el punto de inicio hasta el angulo y se devuelve el mismo angulo para devolverce para el tiempo que se le determine
    if (estado == 3)
    {
      //println(puntoInicio);
      int ang = angulo-puntoInicioBK;
      
      if(continuarEstado3 == true)
      {
        if (puntoInicio < ang)
        {
            puntoInicio += ang;            
        } 
        else
        {
          if (millis() - tInicio > tEspera) 
          {
             continuarEstado3 = false;     
             tInicio = millis();
          }
        }
      }
      else
      {
        if (puntoInicio > puntoInicioBK)
        {
          puntoInicio -= ang;
        }
        else
        {
          if (millis() - tInicio > tEspera) 
          {
            continuarEstado3 = true;     
            tInicio = millis();
          }
        }
      }      
    }
    
    //va al angulo dado y se queda en esa ubicación (no usa el parametro 2, ni el ultimo 5)
    if (estado == 4)
    {
      puntoInicio = angulo;
    }

    //va a la posición 0
    if (estado == 5)
    {
      puntoInicio = 0;
    }

    arduino.servoWrite(outputPin, constrain(puntoInicio, 0, 180));
  }
  
}


class StepperDosis
{ 
  boolean continuarPaso1 = true;
  boolean continuarPaso2 = false;
  boolean continuarPaso3 = false;
  boolean continuarPaso4 = false;
  boolean continuarPaso5 = false;
  
  //determina en que paso esta
  int estadoPaso = 1;
  
  //manejo del envio de los datos a arduino cada medio segundo
  int tInicio = 0;
  
  //pines digitales a los que estan conectados el motor paso a paso  
  int outputPin1;
  int outputPin2;
  int outputPin3;
  int outputPin4;
  int inputPin0;
    
  //int estado => estados desde el 0 hasta el 2, cada estado corresponde a una forma distinta de giro
  int estado;    
  int pasos = 20;
  int velocidad = 11;
    
  int dir = 0;
  
  //arreglo de 6 posisciones de los datos de los pulsadores
  int analogData[] = {10,10,10,10,10,10};
  
  //tiempos en que dura inactivo el pulsador 
  boolean desactivarFinCarrera = true;
  int contador = 0;
  

  StepperDosis(int outputPin1T, int outputPin2T, int outputPin3T, int outputPin4T, int inputPin0T, int estadoT, int velT)
  {
    if(estadoT > 3)
    {
      estadoT = 3; 
      println("El estado va  desde 0 hasta 3, NO puede ser un número mayor a 3");
    }
    
    if(velT > 11)
    {
      velT = 11; 
      println("la velocidad va desde 3 hasta 11");
    }
    
    if(velT < 3)
    {
      velT = 3; 
      println("la velocidad va desde 3 hasta 11");
    }
    
    outputPin1 = outputPin1T;
    outputPin2 = outputPin2T;
    outputPin3 = outputPin3T;
    outputPin4 = outputPin4T;
    inputPin0 = inputPin0T;
    estado = estadoT;  
    velocidad = velT;
    
    //println(outputPin1+" "+outputPin2+" "+outputPin3+" "+outputPin4+" "+inputPin0+" "+estado+" "+velocidad);
    
  }

  public void update()
  {
    ////gira hacia la derecha
    if (estado == 1)
    {
      giroDerecha(outputPin1,outputPin2,outputPin3,outputPin4,inputPin0,velocidad);
    }
    else if (estado == 2)
    {
      giroIzquierda(outputPin1,outputPin2,outputPin3,outputPin4,inputPin0,velocidad);
    }
    else if (estado == 3)
    {
      idaYvuelta(outputPin1,outputPin2,outputPin3,outputPin4,inputPin0,velocidad);
    }
    else if (estado == 0)
    {
      pararMotorPaso();
    }
    
  }
  
  public void  giroDerecha(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
  {
    if (dir == 0)
    {
      for (int i=0; i<pasos; i++)
      {
        if(estadoPaso == 1)
        {
          if(continuarPaso1 == true)
          {
            //paso1
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.HIGH );
            tInicio = millis();
            continuarPaso1 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso2 = true; 
              estadoPaso = 2;
              tInicio = millis();
            }  
          }
        }
        
        if(estadoPaso == 2)
        {
          if(continuarPaso2 == true)
          {
            //paso2 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW ); 
            arduino.digitalWrite(inC, Arduino.HIGH ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso2 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso3 = true;
              estadoPaso = 3;
              tInicio = millis();
            }  
          }
        }        
        
        if(estadoPaso == 3)
        {
          if(continuarPaso3 == true)
          {
            //paso3 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.HIGH); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso3 = false;  
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso4 = true;
              estadoPaso = 4;
              tInicio = millis();
            }  
          }
        }
        
        
        if(estadoPaso == 4)
        {
          if(continuarPaso4 == true)
          {
            //paso4
            arduino.digitalWrite(inA, Arduino.HIGH);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso4 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso1 = true;
              estadoPaso = 1;
              //continuarPaso5 = true;
              //estadoPaso = 5;
              tInicio = millis();
            }  
          }
        } 
              
      }
     
      if(desactivarFinCarrera == false)
      {
        analogData[5] = (arduino.analogRead(limitAnalogPin) / 16);
      }
      else
      {
        analogData[5] = 10;
      }
      //println(analogData[5]);
     
      //me va acumulando en orden cada una de los datos recibidos
      for(int j=0; j<5; j++)
      {
        analogData[j] = analogData[j+1];
      }
      //println(analogData[0]+"  "+analogData[1]+"  "+analogData[2]+"  "+analogData[3]);
     
      if(analogData[0] == 0 && analogData[0] == analogData[1] && analogData[0] == analogData[2]  && analogData[0] == analogData[3]  && analogData[0] == analogData[4]) 
      {
        desactivarFinCarrera = true;
        dir=1;
      }
      
      if (contador > 400) 
      {        
         desactivarFinCarrera = false;
      }
      else
      {
        contador++;
      }
      
    }
    else
    {      
      estado = 0;
    }
   }
   
  public void  giroIzquierda(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
  {
    if (dir == 0)
    {
      for (int i=0; i<pasos; i++)
      {
        if(estadoPaso == 1)
        {
          if(continuarPaso1 == true)
          {
            //paso1
            arduino.digitalWrite(inA, Arduino.HIGH);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso1 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso2 = true; 
              estadoPaso = 2;
              tInicio = millis();
            }  
          }                  
        }

        if(estadoPaso == 2)
        {
          if(continuarPaso2 == true)
          {
            //paso2 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.HIGH ); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso2 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso3 = true;
              estadoPaso = 3;
              tInicio = millis();
            }  
          } 
        }
                
        if(estadoPaso == 3)
        {
          if(continuarPaso3 == true)
          {
            //paso3 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.HIGH ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso3 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso4 = true;
              estadoPaso = 4;
              tInicio = millis();
            }  
          }
        }  

        if(estadoPaso == 4)
        {
          if(continuarPaso4 == true)
          {
            //paso4
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.HIGH );
            tInicio = millis();
            continuarPaso4 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso1 = true;
              estadoPaso = 1;
              //continuarPaso5 = true;
              //estadoPaso = 5;
              tInicio = millis();
            }  
          }
        }
            
      }
      
      if(desactivarFinCarrera == false)
      {
        analogData[5] = (arduino.analogRead(limitAnalogPin) / 16);
      }
      else
      {
        analogData[5] = 10;
      }
      //println(analogData[5]);
     
      //me va acumulando en orden cada una de los datos recibidos
      for(int j=0; j<5; j++)
      {
        analogData[j] = analogData[j+1];
      }
      //println(analogData[0]+"  "+analogData[1]+"  "+analogData[2]+"  "+analogData[3]);
     
      if(analogData[0] == 0 && analogData[0] == analogData[1] && analogData[0] == analogData[2]  && analogData[0] == analogData[3]  && analogData[0] == analogData[4]) 
      {
        desactivarFinCarrera = true;
        dir=1;
      }
      
      if (contador > 400) 
      {        
         desactivarFinCarrera = false;
      }
      else
      {
        contador++;
      }      
    } 
    else
    {
      estado = 0; 
    }
  }
  
  public void idaYvuelta(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
  {
    if (dir == 0)
    {
      for (int i=0; i<pasos; i++)
      {  
        if(estadoPaso == 1)
        {
          if(continuarPaso1 == true)
          {
            //paso1
            arduino.digitalWrite(inA, Arduino.HIGH);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso1 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso2 = true; 
              estadoPaso = 2;
              tInicio = millis();
            }  
          }        
        }

        if(estadoPaso == 2)
        {
          if(continuarPaso2 == true)
          {
            //paso2 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.HIGH ); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso2 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso3 = true;
              estadoPaso = 3;
              tInicio = millis();
            }  
          }  
        }
        
        if(estadoPaso == 3)
        {
          if(continuarPaso3 == true)
          {
            //paso3 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.HIGH ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso3 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso4 = true;
              estadoPaso = 4;
              tInicio = millis();
            }  
          }
        }  
        
        if(estadoPaso == 4)
        {
          if(continuarPaso4 == true)
          {
            //paso4
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.HIGH );
            tInicio = millis();
            continuarPaso4 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso1 = true;
              estadoPaso = 1;
              //continuarPaso5 = true;
              //estadoPaso = 5;
              tInicio = millis();
            }  
          }
        }   
      }  
      if(desactivarFinCarrera == false)
      {
        analogData[5] = (arduino.analogRead(limitAnalogPin) / 16);
      }
      else
      {
        analogData[5] = 10;
      }
      //println(analogData[5]);
     
      //me va acumulando en orden cada una de los datos recibidos
      for(int j=0; j<5; j++)
      {
        analogData[j] = analogData[j+1];
      }
      //println(analogData[0]+"  "+analogData[1]+"  "+analogData[2]+"  "+analogData[3]);
     
      if(analogData[0] == 0 && analogData[0] == analogData[1] && analogData[0] == analogData[2]  && analogData[0] == analogData[3]  && analogData[0] == analogData[4]) 
      {
        desactivarFinCarrera = true;
        contador = 0;
        dir=1;
      }
      
      if (contador > 400) 
      {        
         desactivarFinCarrera = false;
      }
      else
      {
        contador++;
      }
      
    } 
    else if (dir == 1)
    {
      for (int i=0; i<pasos; i++)
      {
        if(estadoPaso == 1)
        {
          if(continuarPaso1 == true)
          {
            //paso1
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.HIGH );
            tInicio = millis();
            continuarPaso1 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso2 = true; 
              estadoPaso = 2;
              tInicio = millis();
            }  
          }        
        }   
        
        if(estadoPaso == 2)
        {
          if(continuarPaso2 == true)
          {
            //paso2 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.LOW ); 
            arduino.digitalWrite(inC, Arduino.HIGH ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso2 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso3 = true;
              estadoPaso = 3;
              tInicio = millis();
            }  
          }  
        }   
        
        if(estadoPaso == 3)
        {
          if(continuarPaso3 == true)
          {
            //paso3 
            arduino.digitalWrite(inA, Arduino.LOW);
            arduino.digitalWrite(inB, Arduino.HIGH); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso3 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso4 = true;
              estadoPaso = 4;
              tInicio = millis();
            }  
          }
        } 
        
        if(estadoPaso == 4)
        {
          if(continuarPaso4 == true)
          {
            //paso4
            arduino.digitalWrite(inA, Arduino.HIGH);
            arduino.digitalWrite(inB, Arduino.LOW); 
            arduino.digitalWrite(inC, Arduino.LOW ); 
            arduino.digitalWrite(inD, Arduino.LOW );
            tInicio = millis();
            continuarPaso4 = false;
          }
          else
          {
            if (millis() - tInicio > tEspera1) 
            {
              continuarPaso1 = true;
              estadoPaso = 1;
              //continuarPaso5 = true;
              //estadoPaso = 5;
              tInicio = millis();
            }  
          }
        }   
      }      
      
      if(desactivarFinCarrera == false)
      {
        analogData[5] = (arduino.analogRead(limitAnalogPin) / 16);
      }
      else
      {
        analogData[5] = 10;
      }
      //println(analogData[5]);
     
      //me va acumulando en orden cada una de los datos recibidos
      for(int j=0; j<5; j++)
      {
        analogData[j] = analogData[j+1];
      }
      //println(analogData[0]+"  "+analogData[1]+"  "+analogData[2]+"  "+analogData[3]);
     
      if(analogData[0] == 0 && analogData[0] == analogData[1] && analogData[0] == analogData[2]  && analogData[0] == analogData[3]  && analogData[0] == analogData[4]) 
      {
        desactivarFinCarrera = true;
        contador = 0;
        dir=0;
      }
      
      if (contador > 400) 
      {        
         desactivarFinCarrera = false;
      }
      else
      {
        contador++;
      }
      
      
    }        
  }
  
   
   public void pararMotorPaso()
   {
        arduino.digitalWrite(outputPin1,Arduino.LOW);
        arduino.digitalWrite(outputPin2,Arduino.LOW); 
        arduino.digitalWrite(outputPin3,Arduino.LOW ); 
        arduino.digitalWrite(outputPin4,Arduino.LOW );
        for(int i = 0; i<6; i++)
        {
         analogData[i] = 10; 
        }
        desactivarFinCarrera = true;
        contador = 0;
   }
   
  
}
  public void settings() {  size(400,768); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "DosisClientArduino" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
