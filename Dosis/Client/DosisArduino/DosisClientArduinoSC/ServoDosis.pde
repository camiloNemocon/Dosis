

class ServoDosis
{ 
  
  //pin al que esta conectado el servo  ServoDosis(int outputPin)
  int outputPin;
  
  //indica cuando el giro llega hasta 180
  boolean llego1=false;
  boolean llego2=false;
  
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
    
    if(estadoT > 7)
    {
      puntoInicioT = 1; 
      println("El estado va  desde 0 hasta 7, NO puede ser un número mayor a 7");
    }   
    
    outputPin = outputPinT;
    estado = estadoT;  
    puntoInicio = puntoInicioT;
    angulo = anguloT;
    tEspera = tEsperaT;
    
    puntoInicioBK = puntoInicioT;
  
    //Se inicializan los puertos que no son PWM para usarlos con el servo motor
    arduino.pinMode(outputPin, Arduino.SERVO);
  }

  //void update(int puntoInicio, int estado, int angulo, int tEspera)
  void update()
  {
    if (estado == 0)
    {      
      if (puntoInicio < 180)
      {
        puntoInicio++;
      } else
      {
        puntoInicio = puntoInicioBK;
      }
    }

    if (estado == 1)
    {
      if (puntoInicio < 180 && llego1==false)
      {
        puntoInicio++;
      } else
      {
        puntoInicio--;
      }

      if (puntoInicio == 180)
      {
        llego1 = true;
      }
      if (puntoInicio == puntoInicioBK)
      {
        llego1 = false;
      }
    }

    if (estado == 2)
    {
      if (puntoInicio < 180)
      {
        if (millis() - tInicio > tEspera) 
        {
          puntoInicio += angulo;     
          tInicio = millis();
        }
      } 
      else
      {
        puntoInicio = puntoInicioBK;
      }
    }

    if (estado == 3)
    {
      if (puntoInicio < 180 && llego2==false)
      {
        if (millis() - tInicio > tEspera) 
        {
          puntoInicio += angulo;     
          tInicio = millis();
        }
      } 
      else
      {
        if (millis() - tInicio > tEspera) 
        {
          puntoInicio -= angulo;     
          tInicio = millis();
        }
      }

      if (puntoInicio >= 180)
      {
        llego2 = true;
      }
      if (puntoInicio <= puntoInicioBK)
      {
        llego2 = false;
      }
    }
    
    
    // va desde en punto de inicio hasta 180 girando cada angulo indicado
    if (estado == 4)
    {
      if (puntoInicio < 180)
      {
          puntoInicio += angulo;
          delay(100);
      } 
      else
      {
        puntoInicio = puntoInicioBK;
      }
    }
    
    // va desde el punto de inicio hasta el puno de inicio + el angulo dado y se devuelve el mismo angulo
    if (estado == 5)
    {
      if(puntoInicioBK+angulo > 180)
      {
        println("la rotación desde el punto de inicio y el angulo excede los 180 grados");
      }
      else
      {      
        //println(puntoInicio);
        if (puntoInicio < puntoInicioBK+angulo)
        {
            puntoInicio += angulo;
            delay(200);
        } 
        else
        {
          puntoInicio -= angulo;
          delay(200);
        }
      }      
    }

    if (estado == 6)
    {
      puntoInicio = angulo;
    }

    if (estado == 7)
    {
      puntoInicio = 0;
    }

    arduino.servoWrite(outputPin, puntoInicio);
  }
  
}
