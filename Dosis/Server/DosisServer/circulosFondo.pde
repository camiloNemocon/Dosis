class circulosFondo
{
  int x;
  int y;
  int j;
  
  float velX;
  float velY;
  float velJ;
  
  float circuloR;
  float circuloG;
  float circuloB;
  
  circulosFondo() 
  {  
  
    x=width/2;
    y=height/2;
    j=0;
  
    velX=10;
    velY=20;
    velJ=10;
  }

  void update()
  {
    noStroke();
    
    if (x<=1000)
    {
      y+=velY;
      x+=velX;
      j+=velJ;
    }
    else
    {
      x=width/2;
      y=height/2;
      j=0;
      
      velX=random(-5,-30);
      velY=random(-30,30);
      velJ=random(2,8);
      
      circuloR = random(0,255);
      circuloG = random(0,255);
      circuloB = random(0,255);
      
      fill(circuloR,circuloG,circuloB,30);
    }  
    
    if (x>=-300)
    {
      y+=velY;
      x+=velX;
      j+=velJ;
    }
    else
    {
      x=width/2;
      y=height/2;
      j=0;

      velX=random(5,30);
      velY=random(-30,30);
      velJ=random(2,8);
      
      circuloR = random(0,255);
      circuloG = random(0,255);
      circuloB = random(0,255);
      
      fill(circuloR,circuloG,circuloB,30);
    } 
    
    ellipse(x,y,j,j); 
  }
  
}
