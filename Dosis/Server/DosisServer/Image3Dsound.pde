
class Image3Dsound
{ 
    PImage image3D;
    color col;
    
    //valor del input audio
    int scale;

    Image3Dsound(int selectImage)
    {
        if(selectImage == 1)
        {
          image3D= loadImage("boo1.png");
        }
        if(selectImage == 2)
        {
          image3D= loadImage("hongo.png");
        }        
        
        noStroke();
    }

    void update() 
    {
      noStroke();
      
      fft.analyze();
      
      // draw the spectrum
      pushMatrix();
      
      translate((width/2)-100, (height/2)-100, 0);
     // scale(2);
      
      for (int h=0; h<image3D.width; h+=8)
      {
        pushMatrix();
        for (int k=0; k<image3D.height; k+=8)
        {
          pushMatrix();
          translate(h,k);
    
          col=image3D.pixels[k*image3D.width+h];
          fill(red(col), green(col), blue(col), alpha (col));
          
          for (int i=0; i<bufferSize; i+=10) 
          {
              box(7,7,red(col)*fft.spectrum[i]*10*i);
          }    
          
          popMatrix();
        }
        popMatrix();
      }
      popMatrix();
    }
}
