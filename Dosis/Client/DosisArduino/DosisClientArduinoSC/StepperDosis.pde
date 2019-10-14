

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

  void update()
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
  
  void  giroDerecha(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
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
   
  void  giroIzquierda(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
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
  
  void idaYvuelta(int inA, int inB,int inC,int inD, int limitAnalogPin,int tEspera1)
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
  
   
   void pararMotorPaso()
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
