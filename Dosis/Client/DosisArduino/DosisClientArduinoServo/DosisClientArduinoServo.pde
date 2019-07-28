
//julio 2018
//By. Camilo Nemocon

//-----------------------Librerias-------------------
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;
import processing.serial.*;

//------------------------Variables-------------------

MsaFluids msaFluids;

Arduino arduino;



ServoDosis servoPin2;
ServoDosis servoPin4;
ServoDosis servoPin7;
ServoDosis servoPin8;
ServoDosis servoPin12;
ServoDosis servoPin13;

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


  
 
//------------------------Setup-------------------
void setup() 
{
  size(400,768);
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
  //invHeight = 1.0f/( height/2 )-10;
    
  //inicializa la visual de fluidos
  msaFluids = new MsaFluids();
  
  //inicializa el arreglo de los mensajes a enviar
  //codigosArduino = new ArrayList<String>();
  
  // imprime el puerto en el que esta conectado arduino
  println(Arduino.list());
  
  //puerto serial por donde le va a enviar los datos a arduino para Windows
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
  //puerto serial por donde le va a enviar los datos a arduino para MAC
  //arduino = new Arduino(this, "/dev/cu.usbmodem1411", 57600); 
  
  for (int i = 0; i <= 22; i++)
  {
    arduino.pinMode(i, Arduino.OUTPUT);
    
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
    arduino.analogWrite( i, 0 );
  }
}


//------------------------Draw-------------------
void draw() 
{
  
  msaFluids.update();
  
  //color para titilar el cuadrado
  if((millis() % 500) < 250)
  {
    noFill();
  }
  else
  {
    fill(#D3EAE3);
    stroke(#D3EAE3);
  }
  
  
  pushMatrix();

  //ubicacion del rectangulo que titila
  float rPos;
  rPos = textWidth(buff1)+leftmargin;
  rect(rPos+1, 19, 10, 21);

  translate(rPos,10+25);
  char k;
 
  //color de las palabras
  fill(#D3EAE3);

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
  
}



void keyPressed()
{
  char k;
  k = (char)key;
  
  switch(k)
  {    
    //cuando se se le da backspace
    case 8:    
    if(buff1.length()>0)
    {
      buff1 = buff1.substring(1);
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
    
    
    if(textWidth(buff+k)+leftmargin < width-rightmargin)
    {
      //mensaje en el orden correcto de caracteres para enviar
      buff=buff+k;
      
      if(buff.equals("PararA"))
      {
      	palabraInstruccion = 13;
      }
      if(buff.equals("servo"))
      {
        palabraInstruccion = 14; 
      }    
      
    }
    
    break;
  }
}


//muestra los mensajes enviados a costado derecho del canvas
void historialCodigo()
{
    //color y ubicación de cada letra que se coloca
    fill(#45DB0B);
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

void instrucciones()
{
  fill(#8B8A8B);
  noStroke();
  rect(0,600,width,height);
  
  fill(#550F90);
  
  if(palabraInstruccion == 13)
  {
    textSize(25);
    text("PararArduino() => para el envio de la data",10,690);
  }
  else if(palabraInstruccion == 14)
  {
    textSize(25);
    text("servoArduino(outPin,ptoIn,estado,ang,tiempo)",10,630);
    textSize(16);
    text("int outPin => pin al que esta conectado el servo",10,650);
    text("int ptoIn => donde empieza el giro",10,670);
    text("int estado => estados desde el 0 hasta el 7",10,690);
    text("int ang => rotación en el estado 2, 3, 4, 5, 6",10,710);
    text("int tiempo en millisegundos => estado 2, 3",10,730);
    textSize(25);
    text("         ",10,750);
  }
  
}

void keyReleased() 
{
  //cuando opriman enter
  if(keyCode==ENTER)
  { 
    if(buff.equals("PararArduino()"))
    {
      stopArduino();
    }

    String temp1 = "";
    String[] mensaje1;
    String[] mensajeDatos1;
    boolean mensajeValido1 = false;
    
    if(buff.substring(buff.length()-1).equals(")"))
    {
      temp1 = buff.substring(0,buff.length()-1);    
      mensajeValido1 = true;
    }
    
    if(mensajeValido1 == true )
    {
      mensaje1 = split(temp1,'('); 
      
      //si recibe el mensaje correcto de servoArduino
      if (mensaje1[0].equals("servoArduino"))
      { 
         //si no hay nada dentro del parentesis ()
         if(mensaje1[1].equals("")||mensaje1[1].equals(" "))
         {
              println("Faltan los 5 parametros");
         }
         else
         {
             mensajeDatos1 = split(mensaje1[1],',');
             
            //si la cantidad de parametros son correctos  
            if(mensajeDatos1.length == 5)
            {
              if(int(mensajeDatos1[0])==2)
              {
                servoPin2 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin2 = true;
              }
              if(int(mensajeDatos1[0])==4)
              {
                servoPin4 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin4 = true;
              }
              if(int(mensajeDatos1[0])==7)
              {
                servoPin7 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin7 = true;
              }
              if(int(mensajeDatos1[0])==8)
              {
                servoPin8 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin8 = true;
              }
              if(int(mensajeDatos1[0])==12)
              {
                servoPin12 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin12 = true;
              }
              if(int(mensajeDatos1[0])==13)
              {
                servoPin13 = new ServoDosis(int(mensajeDatos1[0]),int(mensajeDatos1[1]),int(mensajeDatos1[2]),int(mensajeDatos1[3]),int(mensajeDatos1[4]));   
                servoActivoPin13 = true;
              }
              
            }
            //si la cantidad de parametros dentro del parentesis no son correctos
            else
            {
              println("Faltan los 5 parametros");
            }
         }
         
         
      }
    }
    
    
    //adiciona el string al arreglo de mensajes enviados para dibujarlos
    codigos.add(buff); 
     
    
    //limpia los strings del mensaje que se envia y del que se aparece en el canvas
    buff = "";
    buff1 = "";
//    buff2 = "";
    palabraInstruccion = 0;
    
    //coloca el mensaje del historial abajo de la otra palabra
    y+=30;    
  }
  
  if(keyCode==RIGHT)
  {   
     palabraInstruccion ++;
    
    if(palabraInstruccion > 14)
    {
      palabraInstruccion = 13;
    }
  }
  
  if(keyCode==LEFT)
  {
     palabraInstruccion --;
    
    if(palabraInstruccion < 13)
    {
      palabraInstruccion = 14;
    }
  }
  
    
   
}



void stopArduino()
{  
	servoActivoPin2 = false;
	servoActivoPin4 = false;
	servoActivoPin7 = false;
	servoActivoPin8 = false;
	servoActivoPin12 = false;
	servoActivoPin13 = false;

  for (int i = 0; i <= 22; i++)
  {
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
    arduino.analogWrite( i, 0 );
  } 
}


void mouseMoved() 
{
    if(mouseY < (height/2)-60 && mouseY > 0)
    {
      float mouseNormX = mouseX * invWidth;
      float mouseNormY = mouseY * invHeight;
      float mouseVelX = (mouseX - pmouseX) * invWidth;
      float mouseVelY = (mouseY - pmouseY) * invHeight;
  
      msaFluids.addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
    }
    
   
}
