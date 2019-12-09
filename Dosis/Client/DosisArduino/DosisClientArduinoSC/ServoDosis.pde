

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
  
  int contador = 0;

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
    
    if(estadoT > 7)
    {
      puntoInicioT = 1; 
      println("El estado va  desde 0 hasta 7, NO puede ser un número mayor a 7");
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
  void update()
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
    
    // va desde el punto de inicio hasta el angulo y se devuelve el mismo angulo para devolverce para el tiempo que se le determine, pero solo lo hace una vez
    if (estado == 6)
    {
      //println(puntoInicio);
      int ang = angulo-puntoInicioBK;
      
      if(continuarEstado3 == true)
      {
          //me saca del estado para que solo lo haga una vez 
          if(contador == 1)
          {
            estado = 8;
          }
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
            tInicio = millis();
            continuarEstado3 = true;   
            contador = 1;
          }
          
        }
      }      
    }
    
    //genera el movimiento del servo cada que recibe una señal de super collider por osc
    if (estado == 7)
    {
      //println(puntoInicio);
      int ang = angulo-puntoInicioBK;
      
      if(continuarEstado3 == true)
      {
          //me saca del estado para que solo lo haga una vez 
          if(contador == 1)
          {
            estado = 8;
          }
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
            tInicio = millis();
            continuarEstado3 = true;   
            contador = 1;
          }          
        }
      }      
    }

    arduino.servoWrite(outputPin, constrain(puntoInicio, 0, 180));
  }
  
}
