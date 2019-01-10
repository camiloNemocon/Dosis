//abril 2017
//By. Camilo Nemocon


//-----------------------Librerias-------------------
import oscP5.*;
import netP5.*;
import processing.sound.*;


//------------------------Variables-------------------
OscP5 oscP5;
NetAddress myRemoteLocation;

AudioIn myInput;
FFT fft;



BufferSound bufferSound; 

ParticulasC particulasC;

ParticleSystem ps;

Textos textos;

Fondo fondo;

circulosFondo circulosfondo;

Gusano gusano;

Pirulina pirulina;

Image3Dsound image3Dsound;

MsaFluids msaFluids;

KinectRepresentation kinectVis;

int fondoDegrade = 60;
int numFondo=0;

String palabra1 = "sound gives reason to life";
String palabra2 = "live coding";
String palabra3 = "coders";
String palabra4 = "DOSIS";

//el texto que se ve como particulas
String textoParticula="coderos";

//variable que determina si se visualiza o no las particulas
boolean mostrarBuffarBarras= false;

//variable que determina si se visualiza o no las particulas
boolean mostrarParticula= false;

//variable que determina si se visualiza o no el sistema de particulas
boolean mostrarSistemaP= false;

//determina si mostrar o no mostrar las palabras
boolean mostrarPalabras = false;

//determina si mostrar o no mostrar los circulos que salen desde el centro
boolean mostrarCirculos = false;

//determina si mostrar o no mostrar el gusano
boolean mostrarGusano = false;

//determina si mostrar o no mostrar la pirulina
boolean mostrarPirulina = false;

//determina si mostrar o no mostrar la imagen3D
boolean mostrarImagen3D = false;

//determina si mostrar o no mostrar los fluidos
boolean mostrarFluidos = false;

//determina si mostrar o no mostrar los fluidos
boolean mostrarKinectVis = false;


// el tamaño de ancho que va a tener el buffer
int bufferSize=512;
//volumen del audio input
float volAudioInput = 1.0;
//valor del audio recibido
float inputAudio;
//el tipo de barra de buffer a visualizar
int barra=1;

//ubicacion del mouse en el osc cliente
float Xmouse;
float Ymouse;
float pXmouse;
float pYmouse;

//aumentar el tamaño de la particula
int ParticulaSize = 2;
//se determina si la particula se va a mover con el mouse o aleatoriamente 0 o -1
int modoP = -1;
//se determina si el tamaño de la particula cambia con el somido o es aleatoria
int tipoP = -3;






//------------------------Setup-------------------
void setup() 
{
  noCursor();
  size(1000, 768, OPENGL);
  frameRate(30);
  
  smooth();
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);

  //Create an Audio input and grab the 1st channel
  myInput = new AudioIn(this, 0);

  // start the Audio Input
  myInput.start();

  //volumen del audio input va de 0.0 a 1.0
  myInput.amp(volAudioInput);


  delay(1000);
  
  // Create and patch the FFT analyzer
  fft = new FFT(this, bufferSize);  
  fft.input(myInput);
  
  delay(1000);
    
  fondo = new Fondo();
       
}


//------------------------Draw-------------------
void draw() 
{   
  
      //el color de fondo 
      fondo.run();
      
      if(mostrarFluidos == true)
      {   
        //muestra msaFluids
        float mouseNormX = Xmouse * msaFluids.invWidth;
        float mouseNormY = Ymouse * msaFluids.invHeight;
        float mouseVelX = (Xmouse - pXmouse) * msaFluids.invWidth;
        float mouseVelY = (Ymouse - pYmouse) * msaFluids.invHeight;
        
        msaFluids.update();
        msaFluids.addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
      }
        
      if(mostrarBuffarBarras == true)
      {
        //muestra las barras de buffer
        bufferSound.update();
      }
      
      if(mostrarPalabras == true)
      {
        //muestra los textos
        textos.update();
      }
      
      if(mostrarParticula == true)
      {
        //muestra las particulas
        particulasC.update();
      }
      
      if(mostrarSistemaP == true)
      {
        //muestra las particulas de palabras
        ps.run();
        ps.addParticle();  
      }
      
      if(mostrarCirculos == true)
      {
        //muestra los circulos que salen desde el centro
        fill(circulosfondo.circuloR,circulosfondo.circuloG,circulosfondo.circuloB,30);
        circulosfondo.update();
      }    
      
      if(mostrarGusano == true)
      {
        //muestra el gusano 
        fill( random(0,255), random(0,255), random(0,255));
        gusano.update();    
      }
      
      if(mostrarPirulina == true)
      {
        //muestra las espirales
        pirulina.update(); 
      }
      
      if(mostrarImagen3D == true)
      {
        image3Dsound.update(); 
      }  
      
      if(mostrarKinectVis == true)
      {
        kinectVis.update();  
      }
      
}


//------------------------Metodos-------------------
void oscEvent(OscMessage theOscMessage)
{
  //si recibe el mensaje 
  if (theOscMessage.checkAddrPattern("/comunicacion")==true) 
  {
    //guardo el string recibido
    String firstValue = theOscMessage.get(0).stringValue();

   // print("### received an osc message ifs.");
   // println(" values: "+firstValue);

    //a partir del mensaje recibido se determina que visualizar
    protocolo(firstValue);

    return;
  }
  
  if (theOscMessage.checkAddrPattern("/comunicacionMouse")==true) 
  {
    //guardo el string recibido
    float ValueX = theOscMessage.get(0).intValue();
    float ValueY = theOscMessage.get(1).intValue();

    //print("### received an osc message ifs.");
    //println(" values: "+ValueX+"  "+ValueY);

    //a partir del mensaje recibido se determina que visualizar
    Xmouse = map(ValueX,0,400,0,width);
    Ymouse = map(ValueY,0,768/2,0,height);

    return;
  }
  
  if (theOscMessage.checkAddrPattern("/comunicacionMouse2")==true) 
  {
    //guardo el string recibido
    float ValueX = theOscMessage.get(0).intValue();
    float ValueY = theOscMessage.get(1).intValue();
    float ValuepX = theOscMessage.get(2).intValue();
    float ValuepY = theOscMessage.get(3).intValue();

    //print("### received an osc message ifs.");
    //println(" values: "+ValueX+"  "+ValueY+"  "+ValuepX+"  "+ValuepY);

    //a partir del mensaje recibido se determina que visualizar
    Xmouse = map(ValueX,0,400,0,width);
    Ymouse = map(ValueY,0,768/2,0,height);
    pXmouse = map(ValuepX,0,400,0,width);
    pYmouse = map(ValuepY,0,768/2,0,height);

    return;
  }
  
  if (theOscMessage.checkAddrPattern("/comunicacionKinect")==true) 
  {
    //guardo el string recibido
    int ValueCX = theOscMessage.get(0).intValue();
    int ValueCY = theOscMessage.get(1).intValue();
    int ValueM1X = theOscMessage.get(2).intValue();
    int ValueM1Y = theOscMessage.get(3).intValue();
    int ValueM2X = theOscMessage.get(4).intValue();
    int ValueM2Y = theOscMessage.get(5).intValue();
    int ValueTX = theOscMessage.get(6).intValue();
    int ValueTY = theOscMessage.get(7).intValue();

    //print("### received an osc message ifs.");
    //println(" values: "+ValueCX+"  "+ValueCY+"  "+ValueM1X+"  "+ValueM1Y+"  "+ValueM2X+"  "+ValueM2Y+"  "+ValueTX+"  "+ValueTY);

    //a partir del mensaje recibido se determina que visualizar
    Xmouse = map(ValueM1X,0,400,0,width);
    Ymouse = map(ValueM1Y,0,300,0,height);
    
    kinectVis.xCabeza = map(ValueCX,0,400,0,width);
    kinectVis.yCabeza = map(ValueCY,0,300,0,height);
    
    kinectVis.xmanoDer = map(ValueM1X,0,400,0,width);
    kinectVis.ymanoDer = map(ValueM1Y,0,300,0,height);
    
    kinectVis.xmanoIzq = map(ValueM2X,0,400,0,width);
    kinectVis.ymanoIzq = map(ValueM2Y,0,300,0,height);
    
    return;
  }
}


void protocolo(String msn)
{
  String temp = "";
  String[] mensaje;
  String[] mensajeDatos;
  boolean mensajeValido = false;
  
  if(msn.substring(msn.length()-1).equals(")"))
  {
    temp = msn.substring(0,msn.length()-1);    
    mensajeValido = true;
  }
  
  if(mensajeValido == true )
  {
      mensaje = split(temp,'(');      
      
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR LAS PALABRAS
      if (mensaje[0].equals("palabras"))
      {        
        //inicializa los textos
        textos = new Textos();
        
        mensajeDatos = split(mensaje[1],',');
        
        if(mensajeDatos.length == 4)
        {
          palabra1 = mensajeDatos[0];
          palabra2 = mensajeDatos[1];
          palabra3 = mensajeDatos[2];
          palabra4 = mensajeDatos[3];
        }
        
        if(mensajeDatos.length == 1)
        {
           if(int(mensaje[1]) == 1)
           {
             textos.textoBuffer = true; 
           }
           else
           {
              textos.textoBuffer = false;
           }
        }        
        
        fondoDegrade=60;
        
        textos.awake();
        
        //dice que muestre las palabras
        mostrarPalabras=true;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR el volumen del microfono
      else if (mensaje[0].equals("volumen"))
      {
        volAudioInput = float(mensaje[1]);
        //volumen del audio input va de 0.0 a 1.0
         myInput.amp(volAudioInput);
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR el tipo de barra
      else if (mensaje[0].equals("barras"))
      {                      
           //inicializa las barras de buffer
           bufferSound = new BufferSound();
           
           if(!mensaje[1].equals(""))
           {
             barra = int(mensaje[1]);
           }
           else
           {
             barra = 2;
           }
                      
           mostrarBuffarBarras = true;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR las particulasC
      else if (mensaje[0].equals("particulas"))
      {
           particulasC = new ParticulasC();
           
           if(mensaje[1].equals(""))
           {
              mensaje[1] = "-2";
           }
           
           if(int(mensaje[1]) == -1 || int(mensaje[1]) == -2)
           {
              particulasC.unaParticulas();
              modoP = int(mensaje[1]); 
           }
           if(int(mensaje[1]) == -4 || int(mensaje[1]) == -3)
           {
              bufferSound = new BufferSound();
           
              tipoP = int(mensaje[1]); 
           }
           else if(int(mensaje[1]) == 0)
           {
              particulasC.muchasParticulas();
           }
           else
           {
             ParticulaSize = int(mensaje[1]);
           }                      
           
           mostrarParticula = true;
                      
           //el fondo lo cambia para que deje ver mejor el trazado de las particulas
           fondoDegrade=5;
      }       
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR el sistema de particulas palabras
      else if (mensaje[0].equals("sistemaP"))
      {
           if(!mensaje[1].equals(""))
           {
             textoParticula = mensaje[1];
           }
           else
           {
             textoParticula = "DOSIS";
           }
           
           ps = new ParticleSystem(0,new PVector(random(100,width-100),height,0));
                      
           fondoDegrade=60;
           
           mostrarSistemaP = true;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR 4 opciones de fondo
      else if (mensaje[0].equals("fondo"))
      {
       // modoColor = 1;
        
        mensajeDatos = split(mensaje[1],',');
        
        if(mensajeDatos.length == 1)
        {
          numFondo = int(mensaje[1]);          
        }
        else if(mensajeDatos.length == 3)
        {
          fondo.r = int(mensajeDatos[0]);
          fondo.g = int(mensajeDatos[1]);
          fondo.b = int(mensajeDatos[2]);          
        }  
      }   
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR 4 opciones de fondo
      else if (mensaje[0].equals("fondoAlpha"))
      {
        fondoDegrade = int(mensaje[1]);
      }   
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR los circulos que salen del centro
      else if (mensaje[0].equals("circulos"))
      {
        circulosfondo = new circulosFondo();

        //el fondo lo cambia para que deje ver mejor el trazado de las particulas
        fondoDegrade=2;
             
        //permite ver los circulos
        mostrarCirculos=true;
      }  
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR el gusano 
      else if (mensaje[0].equals("gusano"))
      {
         //  gusano
         if(int(mensaje[1]) > 0)
         {
           gusano = new Gusano(int(mensaje[1]));
         }         
         else
         {
           gusano = new Gusano(200);
         }
         
         mostrarGusano = true;         
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR la espiral pirulina
      else if (mensaje[0].equals("pirulina"))
      {        
         pirulina = new Pirulina();
         
         //  pirulina         
         mostrarPirulina = true;         
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR la imagen3D
      else if (mensaje[0].equals("imagen3d"))
      {
         //  imagen3D
         if(int(mensaje[1]) > 0)
         {
           image3Dsound = new Image3Dsound(int(mensaje[1]));
         }
         else
         {
           image3Dsound = new Image3Dsound(1);
         }
         //  pirulina         
         mostrarImagen3D = true;         
      }
      
       //SI LLEGA ESA PALABRA ENTONCES VA A COLOCAR la imagen3D
      else if (mensaje[0].equals("fluidos"))
      {
         //  fluidos
         msaFluids = new MsaFluids();
         
//         modoColor = 2;
                         
         mostrarFluidos = true;         
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar los fluidos
      else if (mensaje[0].equals("kinect"))
      {  
        kinectVis = new KinectRepresentation();
        mostrarKinectVis = true;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar la barras
      else if (mensaje[0].equals("borrarBarras"))
      {                
         mostrarBuffarBarras = false; 
         bufferSound = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar las palabras
      else if (mensaje[0].equals("borrarPalabras"))
      {                
         mostrarPalabras = false; 
         textos = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar la particulas
      else if (mensaje[0].equals("borrarParticulas"))
      {                
         mostrarParticula = false; 
         tipoP = -3;
         particulasC = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar la particulas de palabra
      else if (mensaje[0].equals("borrarSistemaP"))
      {                
         mostrarSistemaP = false;
         ps = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a parar de generar los circulos
      else if (mensaje[0].equals("pararCirculos"))
      {                
         mostrarCirculos = false;
         circulosfondo = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar el gusano
      else if (mensaje[0].equals("borrarGusano"))
      {  
        mostrarGusano = false;
        gusano = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar las espirales
      else if (mensaje[0].equals("borrarPirulina"))
      {  
        mostrarPirulina = false;
        pirulina = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar las imagenes3D
      else if (mensaje[0].equals("borrarImagen3d"))
      {  
        mostrarImagen3D = false;
        image3Dsound = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar los fluidos
      else if (mensaje[0].equals("borrarFluidos"))
      {  
        mostrarFluidos = false;
        msaFluids = null;
      }
      
      //SI LLEGA ESA PALABRA ENTONCES VA a borrar los fluidos
      else if (mensaje[0].equals("kinectParar"))
      {  
        mostrarKinectVis = false;
        kinectVis = null;
      }
         
      
  }
  
}
