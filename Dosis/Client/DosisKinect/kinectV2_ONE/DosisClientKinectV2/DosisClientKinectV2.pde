//enero 2019
//By. Camilo Nemocon

//-----------------------Librerias-------------------
import oscP5.*;
import netP5.*;
import KinectPV2.KJoint;
import KinectPV2.*;

//------------------------Variables-------------------
OscP5 oscP5;
NetAddress dosisConection;
KinectPV2 kinect;
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
  kinect = new KinectPV2(this);

  //enable rgbImageMap
  //kinect.enableColorImg(true);
  
  //enable depthImageMap
  kinect.enableDepthImg(true);

  //enable 3d  with (x,y,z) position, // enable skeleton generation for all joints
  kinect.enableSkeletonColorMap(true);

  kinect.init();  
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
 
  // draw depthImageMap or grbImageMap
  //image(kinect.getColorImage(), 0, 300, 400, 300);
  image(kinect.getDepthImage(), 0, 300, 400, 300);
    
  //get skeleton users  
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  
  for(int i=0;i<skeletonArray.size();i++)
  {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    
    //si encuentra esqueletos
    if(skeleton.isTracked())
    {
      //guarda las articulaciones en un arreglo
      KJoint[] joints = skeleton.getJoints();
      
      drawSkeleton(joints);
    }   
  }    
  
  pushMatrix();  
    translate(0,300);
    //puntos sobre el cuerpo del usuario
    //fill(200,0,0);
    if(cabezaY > 8) 
    ellipse(cabezaX,cabezaY,15,15);
    
    if(manoIzqY > 8 && manoIzqY < 300)
    ellipse(manoIzqX,manoIzqY,15,15);
    
    if(manoDerY > 8 && manoDerY < 300)
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
  
  
  
// draw the skeleton with the selected joints
void drawSkeleton(KJoint[] joints)
{
  PVector TorsoPos = new PVector(joints[KinectPV2.JointType_SpineMid].getX(),joints[KinectPV2.JointType_SpineMid].getY(),joints[KinectPV2.JointType_SpineMid].getZ());
  //println(TorsoPos.y);
  torsoX = map(TorsoPos.x,280,1680,0,400);
  torsoY = map(TorsoPos.y,100,1000,0,300);
  
  PVector cuelloPos = new PVector(joints[KinectPV2.JointType_Head].getX(),joints[KinectPV2.JointType_Head].getY());
  //println(cuelloPos.x);
  cabezaX = map(cuelloPos.x,280,1680,0,400);
  cabezaY = map(cuelloPos.y,0,1000,10,300);
  
  PVector manoIzqPos = new PVector(joints[KinectPV2.JointType_HandRight].getX(),joints[KinectPV2.JointType_HandRight].getY(),joints[KinectPV2.JointType_HandRight].getZ());
  //println(manoIzqPos.y);
  manoIzqX = map(manoIzqPos.x,280,1680,0,400);
  manoIzqY = map(manoIzqPos.y,0,1000,0,300);
  manoIzqz = TorsoPos.z - manoIzqPos.z;
  
  
  PVector manoDerPos = new PVector(joints[KinectPV2.JointType_HandLeft].getX(),joints[KinectPV2.JointType_HandLeft].getY(),joints[KinectPV2.JointType_HandLeft].getZ());
  //println(manoDerPos.x);
  manoDerX = map(manoDerPos.x,280,1680,0,400);
  manoDerY = map(manoDerPos.y,0,1000,0,300);
  manoDerz = TorsoPos.z - manoDerPos.z ;
   
  //println(manoDerz);
  
  /*
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);
  */
  
}
