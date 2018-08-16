class KinectRepresentation 
{
  float xCabeza=0;
  float yCabeza=0;
  
  float xmanoDer=0;
  float ymanoDer=0;
  
  float xmanoIzq=0;
  float ymanoIzq=0;
  
  
  esfera esf;
  rayo ray;
  
  KinectRepresentation()
  {
    for(int i=0; i<3; i++)
    {
      esf = new esfera();
    }
    
    ray = new rayo();
  }
  

  void update()
  {  
    esf.update(xCabeza,yCabeza);
    esf.update(xmanoDer,ymanoDer);
    esf.update(xmanoIzq,ymanoIzq);
  
    ray.update();     
  }
}


class esfera 
{
  float x=0;
  float y=0;
  
  esfera()
  {
    
  }
  
  void update(float x1, float y1)
  {  
    x=x1;
    y=y1;
    stroke(0);
    
    //dibuja la esfera
    pushMatrix();
    translate(x, y, 10);
    rotateY(radians(x));
    rotateX(radians(y));
    fill(255);
    sphere(50); 
    popMatrix();   
  }
  
}

class rayo 
{    
  int num = 15;  
  int range = 40;
  
  float[] ax;
  float[] ay;
  float[] az;
  
  rayo()
  {
    ax = new float[num];
    ay = new float[num]; 
    az = new float[num]; 
  }
  
  void update()
  {      
    // Shift all elements 1 place to the left
    for(int i=1; i<num; i++) 
    {
      ax[i-1] = ax[i];
      ay[i-1] = ay[i];
      az[i-1] = az[i];
    }
    
    ax[num-1] += random(-range, range);
    ay[num-1] += random(-range, 20);
    az[num-1] += random(-range, range);
    
    if(ay[5]<-600)
    {
      for(int i=0; i<num; i++) 
      {
        ax[i] = 0;
        ay[i] = 0;
        az[i] = 200;
      }
    }
    
    pushMatrix();
      translate(width/2,600,0);  
      for(int i=1; i<num; i++) 
      {    
        float val = float(i)/num * 204.0 + 51;
        fill(val);
    
        beginShape();
        vertex(ax[i-1], ay[i-1],az[i-1]);
        vertex(ax[i], ay[i],az[i]);
        vertex(ax[i]+10, ay[i],az[i]);
        vertex(ax[i-1]+10, ay[i-1],az[i-1]);
        endShape();
      }
    popMatrix();
  }
  
}
