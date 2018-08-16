class Fondo
{
  //imagen del fondo
  PImage logo;

  int r;
  int g;
  int b;
  
  float rectx;
  

  Fondo() 
  {  
    r=0;
    g=0;
    b=0;
    
    rectx= 0;

    //imagen de fondo
    logo=loadImage("logo.png");

  }
  
  void run() 
  {   
    //fondo de un solo tono
    if(numFondo == 0)
    {
      fill(r,g,b, fondoDegrade);
      rect(0, 0, width, height);
    }    
    //fondo de varios colores
    else if(numFondo == 1 || numFondo == 2 || numFondo == 3)
    {
      //dibuja un rectangulo sobre toda la pantalla
      noStroke();
      for (int i=0; i<width; i+=10)
      {
        for (int j=0; j<height; j+=10)
        {
          if(numFondo == 1)
          {
            fill(j,i,i,fondoDegrade);
          }
          if(numFondo == 2)
          {
            fill(j,j,i,fondoDegrade);
          }
          if(numFondo == 3)
          {
            fill(i,j,j,fondoDegrade);
          }
          
          rect (i,j,10,10);
        }
      }
    }
    
     //coloca la imagen
    image(logo, width/2-((logo.width*2)/2), height/2-((logo.height*2)/2), logo.width*2, logo.height*2);


    //rectangulo que gira y se va agrandando, generando una espiral
    if(numFondo == 4)
    {
      
      //espiral a agrandar
      pushMatrix();
      strokeWeight(1);
      stroke(12,25,0);
      translate(width/2, height/2);
      rotate(rectx+PI/3);
      
      if(rectx>=270)
      {
        rectx=rectx*-1;
      }
      
      rectx+=0.1;
      rect(rectx, rectx, 15, 15);
      
      popMatrix();
    }
   
    
    
    lights();
  }
  
}
