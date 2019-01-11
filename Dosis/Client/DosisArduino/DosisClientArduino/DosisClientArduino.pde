
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
int tiempoEspera = 500 ; 
int tiempoInicio = 0;

int totalBytes = 12;
int contadorBytes = 0;

 
 String msnUnidoArduino="";
 
 String[] translate;
 int[] datoSend;
 
 int tempContador = 0;
 boolean activarArduino = false;
 
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

 //tiempo para same Time
 int[] tiempoReiniciar;
 boolean empezar = false;

 //tiempo que mantiene prendido los pines y que se reinicia 
 int[] tiempoReiniciarV2;

 //manejo del envio de los datos a arduino cada tanto tiempo, donde este tiempo se puede modificar con las flechas
 int tiempoFlechas = 0;

 
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
  
  //inicializa la visual de fluidos
  msaFluids = new MsaFluids();
  
  //inicializa el arreglo de los mensajes a enviar
  codigosArduino = new ArrayList<String>();
  
  // imprime el puerto en el que esta conectado arduino
  println(Arduino.list());
  
  //puerto serial por donde le va a enviar los datos a arduino para Windows
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  
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
  
  tiempoReiniciar = new int [9];    
  tiempoReiniciarV2 = new int [9];  
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




void enviarArduino()
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
    enviarDatos = false;
    activarArduino = false;
    enviarDatosEnter = false;
  }
 
}


void keyPressed()
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
         buff2 = buff2.substring(0,buff2.length()-2);
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
        
        if(buff.equals("Once") || buff.equals("Loop") || buff.equals("PararA") ||  buff.equals("Same") ||  buff.equals("TimeS"))
        {
          tecladoLive = false;
          palabraInstruccion = 13; 
        }        
        else if(buff.equals("Tecla")|| buff.equals("PararT"))
        {
          palabraInstruccion = 14; 
        }    
      }
      
      if(tecladoLive == false)
      {  
        //buff para arduino
        if(textWidth(buff2+k)+leftmargin < width-rightmargin)
        {
          //mensaje que se le incluye la , para hacer posteriormente un split
          buff2=buff2+k+",";
        }      
      }
      else
      {       
        arduino.digitalWrite(int(TeclaLive), Arduino.HIGH);   
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
    text("OnceArduino() => envia la data una vez",10,630);
    text("LoopArduino() => envia la data todo el tiempo",10,660);
    text("PararArduino() => para el envio de la data",10,690);
    text("SameTime(int(timeStart)|int(timeOn))",10,720);
    text("TimeStart(int(timeStart)|int(timeOn))",10,750);
  }
  else if(palabraInstruccion == 14)
  {
    text("Teclado() =>Activa Arduino con las teclas",10,630);
    text("PararTeclado() =>Desactiva Arduino con las teclas",10,660);
  }
  
}

void keyReleased() 
{
  if(tecladoLive == true)
  {
    arduino.digitalWrite(int(TeclaLive), Arduino.LOW);  
  }
  
  //cuando opriman enter
  if(keyCode==ENTER)
  {    
    //adiciona el string al arreglo de mensajes enviados para dibujarlos
    codigos.add(buff);         
   
    if(buff.equals("PararArduino()"))
    {
      stopArduino();
    }
    
    if(buff.equals("Teclado()"))
    {
       stopArduino();
       tecladoLive = true; 
    }
    
    if(buff.equals("PararTeclado()"))
    {
       stopArduino();
       tecladoLive = false; 
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

void stopArduino()
{
  activarArduino = false;
  enviarDatos = false;
  enviarDatos2 = false;
  enviarDatos3 = false;
  
  for (int i = 0; i <= 22; i++)
  {
    //apago todos lo pines
    arduino.digitalWrite(i, Arduino.LOW);
    arduino.analogWrite( i, 0 );
  } 
}


void datosArduino(int sendTime)
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
      arduino.analogWrite( i, 0 );
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
      if(translate[i].equals("2") || translate[i].equals("3") || translate[i].equals("4") || translate[i].equals("5") || translate[i].equals("6") || translate[i].equals("7") || translate[i].equals("8") || translate[i].equals("9"))
      {
        datoSend[i] = int(translate[i]); 
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
    
    
    if(sendTime == 0)
    {
      enviarDatos = true;
    }
    else if(sendTime == 1)
    {
      enviarDatos2 = true;
    }
    else if(sendTime == 2)
    {
      enviarDatos3 = true;
    }
  }
  
  activarArduino = true;
}



void enviarArduinoSameTime(String timeSend)
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
      tiempoIndependiente[i] = int(mensajeTimeSend[i]);
      tiempoPrendido[i] = int(mensajeTimePrendido[i]);
    }
  } 
  
  
  //totalBytes-1 porque siempre envia un cero a arduino al final del arreglo
  if(mensajeTimeSend.length == (totalBytes-1) && mensajeTimeSend.length == mensajeTimePrendido.length)
  {
    if(mensajeTimeSend.length >= 1)
    {
      if(empezar==true)
      {
        for(int j=0; j<mensajeTimeSend.length; j++)
        {
           tiempoIndependiente[j] = (((int(mensajeTimeSend[j])*1000)-(millis()-tiempoReiniciar[j]))/1000)+tiempoFlechas;
                     
          if(tiempoIndependiente[j] < 0)
          {
            arduino.digitalWrite(datoSend[j], Arduino.HIGH);        
            
            tiempoPrendido[j] = ((int(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
          
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
    print("la cantidad de variables de tiempo no cerresponde a la cantidad de pines a activar"); 
  }  
}

void enviarArduinoTimeStart(String timeSend)
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
      tiempoPrendido[i] = int(mensajeTimePrendido[i]);
      
      //se establece cual pin tiene el mayor tiempo
      if(int(mensajeTimePrendido[i]) > tempMayor)
      {
        tempMayor = int(mensajeTimePrendido[i]);
        idMayor = i;
      }
    }
   
    if(empezar3==true && mensajeTimePrendido.length == (totalBytes-1))
    {    
      tiempoEmpezar = (((int(mensajeTimeSend[0])*1000)-(millis()-tiempoReiniciar3))/1000)+tiempoFlechas;
      
      if(tiempoEmpezar < 0)
      {       
        for(int j=0; j<mensajeTimePrendido.length; j++)
        {      
          //los prende todos
          arduino.digitalWrite(datoSend[j], Arduino.HIGH);             
          
          //corre el tiempo de prendido de cada pin
          tiempoPrendido[j] = ((int(mensajeTimePrendido[j])*1000)-(millis()-tiempoReiniciarV2[j]))/1000;
                   
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
      print("la cantidad de variables de tiempo no cerresponde a la cantidad de pines a activar"); 
    }
  }
  else
  {
    print("la cantidad de variables del primer parametro sólo debe ser 1 antes del  simbolo |"); 
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
