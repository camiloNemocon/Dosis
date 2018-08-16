//junio 2018
//By. Camilo Nemocon

//-----------------------Librerias-------------------
import oscP5.*;
import netP5.*;
import SimpleOpenNI.*;

//------------------------Variables-------------------
OscP5 oscP5;
NetAddress dosisConection;
NetAddress superColliderConection;
SimpleOpenNI  context;
MsaFluids msaFluids;

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
int y=90;

//arreglo con los mensajes enviados
ArrayList<String> codigos;

//envia los datos del mouse 
boolean sendComunicacionMouse = false;

//envia los datos del mouse y pmouse
boolean sendComunicacionMouse2 = false;

//a partir de la palabra detectada escrita por el usuario se determina la instruccion a colocar
int palabraInstruccion = 0;

////////////////////////kinect
PVector com = new PVector();                                   
PVector com2d = new PVector();   

 float cabezaX;
 float cabezaY;
 
 float manoIzqX;
 float manoIzqY;
 float manoIzqz; 
 
 float manoDerX;
 float manoDerY;
 float manoDerz; 
 
 float torsoX;
 float torsoY;

 boolean enviaMsn = true;

 //medio segundo
 int tiempoEspera = 500;  
 int tiempoInicio = 0;
 
 boolean enviarDatosKinect = false;

//------------------------Setup-------------------
void setup() 
{
  size(400,768);
  frameRate(30);
  
  noCursor();
  
  // start oscP5, listening for incoming messages at port 12000 
  oscP5 = new OscP5(this,12000);
  
  //se conecta al servidor por la dirección ip,port
  // myRemoteLocation = new NetAddress("192.168.0.101",12000);
  dosisConection = new NetAddress("localhost",12000);
    
  superColliderConection = new NetAddress("localhost",33333);
    
  //tipografia
  fuente = loadFont("AgencyFB-Reg-48.vlw");
  //tamaño de la fuente
  textFont(fuente, 25);
  
  //inicializa el arreglo de los mensajes a enviar
  codigos = new ArrayList<String>();
  
  //fondo
  background(0);
  
  invWidth = 1.0f/width;
  invHeight = 1.0f/((height/2)-300);
    
  //inicializa la visual de fluidos
  msaFluids = new MsaFluids();
  
  //kinect
  context = new SimpleOpenNI(this);
   
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
  
  
}


//------------------------Draw-------------------
void draw() 
{
  fill(0);
  rect(0,0,width,(height/2)-290);
  
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
  
  vistaKinect();
  
  if(enviarDatosKinect == true)
  {
    msnKinect();
  }   
}

void vistaKinect()
{
   //kinect
  // update the cam
  context.update();
  
  // draw depthImageMap
  image(context.depthImage(),0,300,400,300);
  //image(context.userImage(),0,300,400,300);
  
  int[] userList = context.getUsers();
  
  for(int i=0;i<userList.length;i++)
  {
    //dibuja los circulos a partir de las ubicaciones del esqueleto
    if(context.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);
      
    // dibuja el centro de masa
    if(context.getCoM(userList[i],com))
      context.convertRealWorldToProjective(com,com2d);
  }    
  
  pushMatrix();  
    translate(0,300);
    //puntos sobre el cuerpo del usuario
    ellipse(cabezaX,cabezaY,15,15);
    ellipse(manoIzqX,manoIzqY,15,15);
    ellipse(manoDerX,manoDerY,15,15);
    ellipse(torsoX,torsoY,15,15);  
  popMatrix();

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
      else if(buff.equals("kinect"))
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
    if(y >= 300)
    {
      //borre el historial
      background(0);
      //inicie el texto al comienzo del canvas
      y = 120; 
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
    text("5 tipos de fondo =>  1  -  5",10,670);
    text("fondo(0) => fondo(int,int,int)",10,710);
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
    text("kinect()",10,630);
    text("kinectParar() => para el envio de la data",10,670);    
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
    
    if(buff.equals("kinect()"))
    { 
      enviarDatosKinect = true;
    }

    if(buff.equals("kinectParar()"))
    { 
      enviarDatosKinect = false;
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
    
    if(palabraInstruccion > 13)
    {
      palabraInstruccion = 0;
    }
  }
  
  if(keyCode==LEFT)
  {
    palabraInstruccion --;
    
    if(palabraInstruccion < 0)
    {
      palabraInstruccion = 13;
    }
  }
  
  if(keyCode == UP)
  tiempoEspera = tiempoEspera + 500; 
  
  if(keyCode == DOWN)
  tiempoEspera = tiempoEspera - 500; 

  
}

  
void mouseMoved() 
{
  if(mouseY < (height/2)-300 && mouseY > 0)
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


void msnKinect()
{
  //crea un mensaje osc
  OscMessage myMessage3 = new OscMessage("/comunicacionKinect");
  
  myMessage3.add((int)cabezaX);
  myMessage3.add((int)cabezaY);
  myMessage3.add((int)manoIzqX);
  myMessage3.add((int)manoIzqY);
  myMessage3.add((int)manoDerX);
  myMessage3.add((int)manoDerY);
  myMessage3.add((int)torsoX);
  myMessage3.add((int)torsoY);
    
  //envia el mensaje osc
  oscP5.send(myMessage3, dosisConection);  
}
  
  
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


  
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  PVector TorsoPos = new PVector();
  //println(com2d.y);
  torsoX = map(com2d.x,0,600,0,400);
  torsoY = map(com2d.y,150,500,100,300);
  
  PVector cuelloPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,cuelloPos);
  //println(cuelloPos.y);
  cabezaX = map(cuelloPos.x,-850,780,0,400);
  cabezaY = map(cuelloPos.y,700,-400,0,300);
  
  PVector manoIzqPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,manoIzqPos);
  //println(manoIzqPos.x);
  manoIzqX = map(manoIzqPos.x,-800,900,0,400);
  manoIzqY = map(manoIzqPos.y,900,-900,0,300);
  manoIzqz = TorsoPos.z - manoIzqPos.z;
  
  
  PVector manoDerPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,manoDerPos);
  //println(manoDerPos.y);
  manoDerX = map(manoDerPos.x,-900,800,0,400);
  manoDerY = map(manoDerPos.y,950,-800,0,300);
  manoDerz = TorsoPos.z - manoDerPos.z ;
   
  //println(manoDerz);
  
  
  if (millis() - tiempoInicio > tiempoEspera) 
  {
    if(enviaMsn == true)
    {
      //enviamos el mensaje osc
      OscMessage myMsn = new OscMessage("/DosisComunicacionSC");
      myMsn.add(manoIzqX);  
      myMsn.add(manoDerX);
     
      //push mano derecha
      if(manoDerz > 270)
      {
        myMsn.add(1);
      }
      else
      {
        myMsn.add(0);
      }
            
      //push mano izquierda
      if(manoIzqz > 270)
      {
        myMsn.add(1);
      }
      else
      {
        myMsn.add(0);
      }
      
      oscP5.send(myMsn, superColliderConection); 
      
     
  
      enviaMsn=false;
    }    
    tiempoInicio = millis();
   }
   else
   {
     enviaMsn = true;
   }	
  

  /*
    context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
  */
}
