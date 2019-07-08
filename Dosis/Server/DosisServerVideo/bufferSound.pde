class BufferSound
{
  //ancho de las barras del buffer
  int w=2;
  //valor del color de las barras del buffer
  int hVal=0;

  //valor del input audio
  int scale;

  // Create a smoothing vector
  float[] sum;

  // Create a smoothing factor
  float smooth_factor = 200;
  
  BufferSound()
  {
    sum = new float[bufferSize];
  }

  void update() 
  {
    fft.analyze();
    
    // fft.spectrum[0] return a value between 0 and 1. To adjust the scaling and mapping of an ellipse we scale from 0 to 0.5
    scale=int(map(fft.spectrum[0], 0, 0.2, 1, 350));  
    inputAudio=scale;
    
    //color y caracteristicas de las barras de buffer
    pushMatrix();
    colorMode(HSB);
    stroke(hVal, 255, 255);  
    fill(hVal, 255, 255);   
    popMatrix();
    
    //se coloca otra vez el color normal para que no afecte el color de otras clases
    pushMatrix();
    colorMode(RGB);
    if(barra == 1 || barra == 2)
    {
      //genero un barra que se repite varias veces con la misma altura del input audio
      strokeWeight(70);
      for (int i=0; i<width; i+=40) 
      {       
        //barra 1 sobre la vertical
        if(barra == 1)
        {
          line(width,(i*w)+(w/2),width-(2*scale),(i*w)+(w/2));
        }
        
        //barra2 sobre la horizontal
        if(barra == 2)
        {
          line((i*w)+(w/2), height, (i*w)+(w/2), height-(2*scale));
        }
      }
    }

    if(barra == 3 || barra == 4)
    {
      strokeWeight(15);
      for (int i=0; i<bufferSize; i+=10) 
      {
        //barra1 sobre la horizontal   
        if(barra == 3)
        {
          line((i*w)+(w/2),height,(i*w)+(w/2),height-fft.spectrum[i]*height*i);
        }
        
        //barra 2 sobre la vertical
        if(barra == 4)
        {
          line(width, (i*w)+(w/2), width-fft.spectrum[i]*width*i, (i*w)+(w/2));
        }
      }
    }
    popMatrix();

    //genera el cambio del color
    hVal+=1;  
    if (hVal>255) 
    {
      hVal=0;
    }

    //dibuja un circulo que responde al audio
    noStroke();
    ellipse(width/2, height/2, 1*scale, 1*scale);
  }
  
}
