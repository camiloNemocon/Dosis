class Pirulina 
{  
  float mx;
  float ang;
  
  Pirulina()
  {
    mx = 0.0;
    ang =0;
  }

  void update()
  {
    strokeWeight(1);
    //espiral principal ke sigue el mouse
    for (int r=0; r<mx; r+=10)
    {
      for (int i=60; i<361; i+=75)
      {
        stroke (0,i,255);
        ang+=5.5;
        line (mx,Ymouse,r*cos(ang*PI/30)+mx, r*sin(ang*PI/30)+Ymouse);
      }
    }
  
  
    if ( mx >= 0 && mx < width)
    {
      // espiral peke�a ke va de la mitad hacia la izkierda
      if (mx >= (width/2)-100 && mx < width/2)
      {
        stroke (196,222,31);
      }
      if (mx >= (width/2)-200 && mx < (width/2)-100)
      {
        stroke (199,222,31);
      }
      if (mx >= (width/2)-300 && mx < (width/2)-200)
      {
        stroke (255,217,0);
      }
      if (mx >= 0 && mx < (width/2)-300)
      {
        stroke (255,132,0);
      }
  
      // espiral peke�a ke va de la mitad hacia la derecha
      if (mx > width/2 && mx < (width/2)+100)
      {
        stroke (28,240,15);
      }
      if (mx >= (width/2)+100 && mx < (width/2)+200)
      {
        stroke (54,224,149);
      }
      if (mx >= (width/2)+200 && mx < (width/2)+300)
      {
        stroke (38,143,222);
      }
      if (mx >= (width/2)+300 && mx < width)
      {
        stroke (19,39,240);
      }
  
      for (int r=0; r<100; r+=5)
      {
        ang+=5;
        if ( Ymouse < height/2)
        {
          line (mx+65,Ymouse+460,r*cos(ang)+mx+65, r*sin(ang)+Ymouse+460);
        }
        if ( Ymouse >= height/2)
        {
          line (mx-65,Ymouse-460,r*cos(ang)+mx-65, r*sin(ang)+Ymouse-460);
        }
      }
    }
    
    if (Ymouse < height/2)
    {
      for (int r=-70; r<mx-275; r+=5)
      {
        ang+=1;  
        line (mx-115,Ymouse+320,r*cos(ang*PI/30)+mx-115, r*sin(ang*PI/30)+Ymouse+320); 
        line (mx+170,Ymouse+225,r*cos(ang*PI/30)+mx+170, r*sin(ang*PI/30)+Ymouse+225); 
        line (mx-250,Ymouse+130,r*cos(ang*PI/30)+mx-250, r*sin(ang*PI/30)+Ymouse+130);   
      }
    }
    if (Ymouse >= height/2)
    {
      for (int r=-70; r<mx-275; r+=5)
      {
        ang+=1; 
        line (mx+115,Ymouse-320,r*cos(ang*PI/30)+mx+115, r*sin(ang*PI/30)+Ymouse-320); 
        line (mx-240,Ymouse-225,r*cos(ang*PI/30)+mx-240, r*sin(ang*PI/30)+Ymouse-225);  
        line (mx+250,Ymouse-130,r*cos(ang*PI/30)+mx+250, r*sin(ang*PI/30)+Ymouse-130);    
      }
    }
      
    // Actualiza a localizaci�n del marcador
    float dif = Xmouse - mx;
    if (abs(dif) > 1.0)
    {
      mx = mx + dif/16.0;
    }
    
  }
}
