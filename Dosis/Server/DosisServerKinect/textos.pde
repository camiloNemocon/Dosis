class Textos
{
  //imagen del fondo
  //PImage logo;

  //fuente de los textos
  PFont font;

  //arreglo con la cantidad de pálabras que van a pasar de un lado a otro
  String[] palabras;

  //indice del primer arreglo de palabras
  int indice1=0;
  //indice del primer arreglo de palabras
  int indice2=2;

  //desplazamiento horizontal que tienen las palabras del arreglo 1
  int posX=0;
  //desplazamiento horizontal que tienen las palabras del arreglo 2
  int posX2=0;

  //ubicacion en Y de las palabras del primer arreglo
  float posY=150;
  //ubicacion en Y de las palabras del primer arreglo
  float posY2=500;
  
  //determina si el tamaño de texto de segun buffer o tamaño definido 
  boolean textoBuffer = false;
  
  //variable que guerda el dato del buffer
  int textoTamano = 3;
  
  Textos()
  {
    //imagen de fondo
    //logo=loadImage("logo.png");

    //tipografia de las palabras
    font=loadFont("Futura-Medium-32.vlw");

    //arreglo con la cantidad de pálabras que van a pasar de un lado a otro
    palabras=new String[4];   
    awake();
  }
  
  void awake()
  {
    //se asignan las palabras al arreglo
    palabras[0]=new String (palabra1);
    palabras[1]=new String (palabra2);
    palabras[2]=new String (palabra3);
    palabras[3]=new String (palabra4);
  }
  
  void update()
  {
     tint(255, 50);
     
     //coloca la imagen
    //image(logo, width/2-((logo.width*2)/2), height/2-((logo.height*2)/2), logo.width*2, logo.height*2);

    if(mostrarPalabras==true)
    {
      //salga el texto de todas las palabras 
      textFont(font, 32);
      fill(255, 140);
      if(textoBuffer == false)
      {
        textSize(124);
      }
      else
      {
        textSize(textoTamano*inputAudio);
      }
      text(palabras[indice1], 0-textWidth(palabras[indice1])+posX, posY);
      
      if(textoBuffer == false)
      {
        textSize(174);
      }
      else
      {
        textSize(textoTamano*inputAudio);
      }
      fill(255, 140);
      text(palabras[indice2], height-posX2, posY2);
    }

    //mueve las palabras horizontalmente
    posX+=6;
    posX2+=8;  

    //si la primera palabra sale de la pantalla, coloque la siguiente palabra desde el comienzo de la pantalla 
    if (posX>width+textWidth(palabras[indice1])) 
    {
      posX=0;
      indice1++;
      posY=random(150, 600);
    }
    //si la segunda palabra sale de la pantalla, coloque la siguiente palabra desde el comienzo de la pantalla 
    if (posX2>width+textWidth(palabras[indice2])) 
    {
      posX2=0;
      indice2++;
      posY2=random(150, 600);
    }

    //si ya se coloco la segunda palabra, coloque la primera nuevamente
    if (indice1>1) 
    {
      indice1=0;
    }
    //si ya se coloco la cuarta palabra, coloque la tercera nuevamente
    if (indice2>3) 
    {
      indice2=2;
    }
    
    
    strokeWeight(1);
    
  }
}
  
