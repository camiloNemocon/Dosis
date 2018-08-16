//agosto 2018
//By. Camilo Nemocon

//-----------------------Librerias-------------------
import oscP5.*;
import netP5.*;
import vrpnforprocessing01.vrpnJoystick01;

//------------------------Variables-------------------
OscP5 oscP5;
NetAddress dosisConection;

MsaFluids msaFluids;
vrpnJoystick01 joystick;

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

//envia los datos del mouse 
boolean sendComunicacionMouse = false;

//envia los datos del mouse y pmouse
boolean sendComunicacionMouse2 = false;

//a partir de la palabra detectada escrita por el usuario se determina la instruccion a colocar
int palabraInstruccion = 0;

PImage imgJoystick;

PImage imgJoystickBtn0;
PImage imgJoystickBtn1;
PImage imgJoystickBtn2;
PImage imgJoystickBtn3;
PImage imgJoystickBtn4;
PImage imgJoystickBtn5;

PImage imgJoystickPalancaX1;
PImage imgJoystickPalancaX2;
PImage imgJoystickPalancaY1;
PImage imgJoystickPalancaY2;

int botonJoystick;
float palancaJoystickX;
float palancaJoystickY;

boolean enviarDatosJoystick = false;

//------------------------Setup-------------------
void setup() 
{
  size(400,768);
  frameRate(30);
  
  noCursor();
  
  // start oscP5, listening for incoming messages at port 12000 
  oscP5 = new OscP5(this,12000);
  
  //se conecta al servidor por la dirección ip,port
  // dosisConection = new NetAddress("192.168.0.101",12000);
  dosisConection = new NetAddress("localhost",12000);
  
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
  
  joystick = new vrpnJoystick01();
  joystick.connect("Joystick0@tcp://localhost");

  imgJoystick = loadImage("joystickImg.jpg");
  imgJoystickBtn0 = loadImage("boton0.jpg");
  imgJoystickBtn1 = loadImage("boton1.jpg");
  imgJoystickBtn2 = loadImage("boton2.jpg");
  imgJoystickBtn3 = loadImage("boton3.jpg");
  imgJoystickBtn4 = loadImage("boton4.jpg");
  imgJoystickBtn5 = loadImage("boton5.jpg");
  imgJoystickPalancaX1 = loadImage("palancaX1.jpg");
  imgJoystickPalancaX2 = loadImage("palancaX2.jpg");
  imgJoystickPalancaY1 = loadImage("palancaY1.jpg");
  imgJoystickPalancaY2 = loadImage("palancaY2.jpg"); 
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
  
  vistaJoystick();

  if(enviarDatosJoystick == true)
  {
    msnJoystick();
  }
   
}

void vistaJoystick()
{
  image(imgJoystick, 80, 60);

  botonJoystick =  joystick.getButton();
  palancaJoystickX = (float)joystick.getValue(0);
  palancaJoystickY = (float)joystick.getValue(1);


  if(botonJoystick == 0)
  {
    image(imgJoystickBtn0, 0, 300);
  }
  else if(botonJoystick == 1)
  {
    image(imgJoystickBtn1, 0, 300);
  }
  else if(botonJoystick == 2)
  {
    image(imgJoystickBtn2, 0, 300);
  }
  else if(botonJoystick == 3)
  {
    image(imgJoystickBtn3, 0, 300);
  }
  else if(botonJoystick == 4)
  {
    image(imgJoystickBtn4, 0, 300);
  }
  else if(botonJoystick == 5)
  {
    image(imgJoystickBtn5, 0, 300);
  }

  if(palancaJoystickX > 0)
  {
    image(imgJoystickPalancaX1, 0, 300);
  }
  else if(palancaJoystickX < 0)
  {
    image(imgJoystickPalancaX2, 0, 300);
  }

  if(palancaJoystickY > 0)
  {
    image(imgJoystickPalancaY1, 0, 300);
  }
  else if(palancaJoystickY < 0)
  {
    image(imgJoystickPalancaY2, 0, 300);
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
      
      if(buff.equals("palabras"))
      {
        palabraInstruccion = 1; 
      }
      else if(buff.equals("volumen"))
      {
        palabraInstruccion = 2; 
      }
      else if(buff.equals("barras"))
      {
        palabraInstruccion = 3; 
      }
      else if(buff.equals("particulas"))
      {
        palabraInstruccion = 4; 
      }
      else if(buff.equals("sistemaP"))
      {
        palabraInstruccion = 5; 
      }
      else if(buff.equals("fondo"))
      {
        palabraInstruccion = 6; 
      }
      else if(buff.equals("circulos"))
      {
        palabraInstruccion = 7; 
      }
      else if(buff.equals("gusano"))
      {
        palabraInstruccion = 8; 
      }
      else if(buff.equals("pirulina"))
      {
        palabraInstruccion = 9; 
      }
      else if(buff.equals("imagen3d"))
      {
        palabraInstruccion = 10; 
      }
      else if(buff.equals("fluidos"))
      {
        palabraInstruccion = 11; 
      }
      else if(buff.equals("borrar"))
      {
        palabraInstruccion = 12; 
      }
      else if(buff.equals("joystick"))
      {
        palabraInstruccion = 13; 
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
  if(palabraInstruccion == 1)
  {
    text("palabras(String,String,String,String)",10,630); 
    text("palabras(1) => tamaño de la letra = audioInput",10,670);
    text("palabras(0) => tamaño de la letra = fija",10,710);
  }
  else if(palabraInstruccion == 2)
  {
    text("volumen(float)",10,630);
    text("audio input =>  0.0  -  1.0 ",10,670);
  }
  else if(palabraInstruccion == 3)
  {
    text("barras(int)",10,630);
    text("4 tipos de Buffer =>  1  -  4",10,670);
  }
  else if(palabraInstruccion == 4)
  {
    text("particulas(int)",10,630);
    text("-1 => pos mouse        ||  -2 => pos random",10,660);
    text("-4 => audioReactive   ||  -3 => NO audioReactive",10,695);
    text("0 =>  varios                ||  >0 => tamaño",10,730);
  }
  else if(palabraInstruccion == 5)
  {
    text("sistemaP(String)",10,630);
  }
  else if(palabraInstruccion == 6)
  {
    text("fondo(int)",10,630);
    text("5 tipos de fondo =>  1  -  5",10,660);
    text("fondo(0) => fondo(int,int,int)",10,695);
    text("fondoAlpha(int) => 0 > alpha < 255 ",10,730);
  }
  else if(palabraInstruccion == 7)
  {
    text("circulos()",10,630);
  }
  else if(palabraInstruccion == 8)
  {
    text("gusano(int)",10,630);
    text("int =>  longitud del gusano",10,670);
    text("gusano(-1) => pos mouse",10,710);
  }
  else if(palabraInstruccion == 9)
  {
    text("pirulina() => pos mouse",10,630);
  }
  else if(palabraInstruccion == 10)
  {
    text("imagen3d(int)",10,630);
    text("0 > int <= 2 =>  cambia la imagen",10,670);
  }
  else if(palabraInstruccion == 11)
  {
    text("fluidos() => mov mouse",10,630);
  }
  else if(palabraInstruccion == 12)
  {
    text("borrar",10,630);
    text("borrarBarras()            borrarPalabras()",10,655);
    text("borrarParticulas()      borrarSistemaP()",10,680);
    text("pararCirculos()           borrarGusano()",10,705);
    text("borrarPirulina()          borrarImagen3d()",10,730);
    text("borrarFluidos() ",10,755);
  }
  else if(palabraInstruccion == 13)
  {
    text("joystick()",10,630);
    text("joystickParar() => para el envio de la data",10,670);    
  }
  
}

void keyReleased() 
{
  //cuando opriman enter
  if(keyCode==ENTER)
  {
    //crea un mensaje osc
    OscMessage myMessage = new OscMessage("/comunicacion");

    //adiciona el string al mensaje osc
    myMessage.add(buff); 
    //adiciona el string al arreglo de mensajes enviados para dibujarlos
    codigos.add(buff);   
    
    if(buff.equals("particulas(-1)") || buff.equals("sistemaP(-1)") || buff.equals("gusano(-1)") || buff.equals("pirulina()"))
    {
      sendComunicacionMouse = true;
    }
    else
    {
      sendComunicacionMouse = false; 
    }
    
    if(buff.equals("fluidos()"))
    {
      sendComunicacionMouse2 = true;
    }
    else
    {
      sendComunicacionMouse2 = false; 
    }

    //envia el mensaje osc
    oscP5.send(myMessage, dosisConection); 
    
    
    if(buff.equals("joystick()"))
    { 
      enviarDatosJoystick = true;
    }

    if(buff.equals("joystickParar()"))
    { 
      enviarDatosJoystick = false;
    }
    
    //limpia los strings del mensaje que se envia y del que se aparece en el canvas
    buff = "";
    buff1 = "";
    palabraInstruccion = 0;
    
    //coloca el mensaje del historial abajo de la otra palabra
    y+=30;    
  }
  
  if(keyCode==RIGHT)
  {
    palabraInstruccion ++;
    
    if(palabraInstruccion > 12)
    {
      palabraInstruccion = 0;
    }
  }
  
  if(keyCode==LEFT)
  {
    palabraInstruccion --;
    
    if(palabraInstruccion < 0)
    {
      palabraInstruccion = 12;
    }
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
  
  if(sendComunicacionMouse == true)
  {
    //crea un mensaje osc
    OscMessage myMessage1 = new OscMessage("/comunicacionMouse");
    
    myMessage1.add(mouseX);
    myMessage1.add(mouseY);
      
    //envia el mensaje osc
    oscP5.send(myMessage1, dosisConection);  
  }
  
  if(sendComunicacionMouse2 == true)
  {
    //crea un mensaje osc
    OscMessage myMessage2 = new OscMessage("/comunicacionMouse2");
    
    myMessage2.add(mouseX);
    myMessage2.add(mouseY);
    myMessage2.add(pmouseX);
    myMessage2.add(pmouseY);
      
    //envia el mensaje osc
    oscP5.send(myMessage2, dosisConection);  
  }
}
  
void msnJoystick()
{
  //crea un mensaje osc
  OscMessage myMessage3 = new OscMessage("/comunicacionJoystickBtn");
  
  myMessage3.add(botonJoystick);
  myMessage3.add(palancaJoystickX);
  myMessage3.add(palancaJoystickY);
    
  //envia el mensaje osc
  oscP5.send(myMessage3, dosisConection);  
}
