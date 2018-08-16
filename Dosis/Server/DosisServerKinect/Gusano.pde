float[] x;
float[] y;
float segLength = 3;


class Gusano
{ 
  
  Gusano(int numCirculos)
  {
    x = new float[numCirculos];
    y = new float[numCirculos];
  }

  void update() 
  {
    noStroke();
    
    dragSegment(0, Xmouse, Ymouse);

    for (int i=0; i<x.length-1; i++) 
    {
      dragSegment(i+1, x[i], y[i]);
    }
  }

  void dragSegment(int i, float xin, float yin) 
  {
    float dx = xin - x[i];
    float dy = yin - y[i];
    float angle = atan2(dy, dx);  
    x[i] = xin - cos(angle) * segLength;
    y[i] = yin - sin(angle) * segLength;
    segment(x[i], y[i], angle);
  }

  void segment(float x, float y, float a) 
  {
    pushMatrix();
    translate(x, y);
    rotate(a);
    ellipse(0, 0, 15, 15);
    popMatrix();
  }
  
  
  
}
