

class ServoDosis
{ 
  
  //pin al que esta conectado el servo  ServoDosis(int outputPin)
  int outputPin;
  
  //indica cuando el giro llega hasta 180
  boolean llego1=false;
  boolean llego2=false;
  
  //int estado => estados desde el 0 hasta el 5, cada estado corresponde a una forma distinta de giro
  int estado;  
  
  //int puntoInicio => donde empieza el giro
  int puntoInicio;
  
  //int angulo => rotación cuando se usa el estado 2, 3 o 4 
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
    puntoInicio = estadoT;
    angulo = anguloT;
    tEspera = tEsperaT;
  
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
        puntoInicio = 0;
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
      if (puntoInicio == 0)
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
        puntoInicio = 0;
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

      if (puntoInicio >= 170)
      {
        llego2 = true;
      }
      if (puntoInicio <= 10)
      {
        llego2 = false;
      }
    }
    
    if (estado == 4)
    {
      if (puntoInicio < 180)
      {
          puntoInicio += angulo;     
      } 
      else
      {
        puntoInicio = 0;
      }
    }

    if (estado == 5)
    {
      puntoInicio = 0;
    }

    arduino.servoWrite(outputPin, puntoInicio);
  }
  
}
