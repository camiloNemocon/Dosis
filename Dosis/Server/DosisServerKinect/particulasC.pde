int numCircles;
boolean bMouseMode = true;
VECTORFIELD VectorField = new VECTORFIELD(2, 0.5, 1, 1);
float fHeadSpeed = 2;
float fNoiseSpeed = 1;
int MAX_CIRCLE_SIZE = 40;


float tamano = 0;
  
class ParticulasC
{

  int numBranches;
  
  BRANCH[] branches;


  ParticulasC()
  {
    smooth();
   
    Init(1, 1000);

    noCursor();
  }

  void Init(int nb, int nc) 
  {
    numBranches = nb;
    numCircles = nc;
    branches = new BRANCH[numBranches];
    for(int i=0; i<numBranches; i++)
    {
      branches[i] = new BRANCH(); 
    }
  }

  
  void update() 
  {    
    fill(100);
    noStroke();


    for (int i=0; i<numBranches; i++) 
    {
      branches[i].draw();
    }
    
    if(modoP == -1)
    {
      bMouseMode = true;
    }
    else if(modoP == -2)
    {
      bMouseMode = false;
    }     
  }
  
  void muchasParticulas()
  {
     Init((int)random(1, 10), 1000);
   }
   
   void unaParticulas()
   {
     Init(1, 1000);
   }
   
}  

class BRANCH 
{
  int curCircle = 0;
  CIRCLE[] circles = new CIRCLE[numCircles];
  float x, y, oldX, oldY;
  float vx, vy;
  float seed;

  BRANCH() 
  {
    init();
  }

  void init()
  {
    oldX = x = random(0, width);
    oldY = y = random(0, height);
    vx = vy = 0;
    seed = random(10);
    
    for(int i=0; i<numCircles; i++) 
    {
      circles[i] = new CIRCLE(0, 0, 0);
    }
  }

  void draw() 
  {
   // strokeWeight(1);
    
    //si se mueve con el mouse
    if(bMouseMode) 
    {
        x = Xmouse;
        y = Ymouse;
        
        //x = mouseX;
        //y = mouseY;
        AddCircle(x, y);
  
    } 
    //aparesca en una ubicación aleatoria y se mueva
    else 
    {
      if(x<0 || x >= width || y<0 || y>= height)
      {
        init();
      }
      if(x<0)
      {
        x+=width;
      }
      else if(x>width) 
      {
        x-=width;
      }

      if(y<0)
      {
        y+=height;
      }
      else if(y>height)
      {
        y-=height;
      }

      float fAngle = VectorField.force(x,y, 0, 1, 1) * PI * 2;
      x += cos(fAngle) * fHeadSpeed;
      y += sin(fAngle) * fHeadSpeed;
      AddCircle(x, y);
    }

    for(int i=0; i<numCircles; i++) 
    {
      if(circles[i].r>0.001) 
      {
        fill(255);
        circles[i].draw();
      }
    }

    oldX = x;
    oldY = y;
  }

  void AddCircle(float x, float y)
  {    
    if(tipoP == -3)
    {
      tamano = random(MAX_CIRCLE_SIZE);
    }
    else if(tipoP == -4)
    {
      if(mostrarBuffarBarras == false)
      {
        fft.analyze();
      
        // fft.spectrum[0] return a value between 0 and 1. To adjust the scaling and mapping of an ellipse we scale from 0 to 0.5
        inputAudio=int(map(fft.spectrum[0], 0, 0.2, 1, 350));
      }
      
      tamano = abs(inputAudio*ParticulaSize);
    }
    
    //println(tamano);
    
    circles[curCircle].init(x, y, tamano );
    
    curCircle++;
    
    if(curCircle>=numCircles) 
    {
      curCircle = 0;
    }
  }
}

  /************************************* CIRCLE ****************************************/
  class CIRCLE 
  {
    float x, y, r;
    float rs;
    float rs2;
    float a;
    float fNoiseSpeed;
    int c;

    CIRCLE(float tx, float ty, float t_r) 
    {
      init(tx, ty, t_r);
    }

    void init(float tx, float ty, float t_rx) 
    {
      x = tx; 
      y = ty; 
      r = t_rx;
      a = 100;
      rs = random(0.5, 0.98);
      rs2 = sqrt(rs);
      fNoiseSpeed = random(0.5, 20);
      //   c = int(255 * VectorField(x, y, 0, 1, 1));
    }

    void draw() 
    {
      r *= rs;
      a *= rs2;
      c = int(150 * VectorField.force(x, y, 0, 1, 1));
      //stroke(c * a/255.0, a);

      //    sets the circle color
      fill(255, 255, 255);

     
        float fAngle = VectorField.force(x, y, 10, fNoiseSpeed, fNoiseSpeed) * PI * 2;
        x += cos(fAngle);
        y += sin(fAngle);
      ellipse(x, y, r, r);
    }
  }

  /************************************* VECTORFIELD ****************************************/
  class VECTORFIELD 
  {
    private float fNoiseMin, fNoiseMax;    // used for scaling values to white and black
    private float fScaleMult, fSpeedMult;
    private int iOctaves;
    private float fFallOff;

    VECTORFIELD(int to, float tf, float ts1, float ts2) 
    {
      init( to, tf, ts1, ts2);
    }

    void init(int to, float tf, float ts1, float ts2)
    {
      float w = 500, h = 500;
      iOctaves = to;
      fFallOff = tf;
      fScaleMult = 0.01 * ts1;      // some good default values
      fSpeedMult = 0.0005 * ts2;
      fNoiseMin = 1;
      fNoiseMax = 0;
      noiseDetail(iOctaves, fFallOff);

      for (int x=0; x<w; x++)
      {
        for (int y=0; y<h; y++) 
        {
          float c = noise(x * fScaleMult, y * fScaleMult);
          fNoiseMin = min(c, fNoiseMin);
          fNoiseMax = max(c, fNoiseMax);
        }
      }
    }

    float force(float x, float y, float z, float fScaleMultExtra, float fSpeedMultExtra) {
      float f = fScaleMult * fScaleMultExtra;
      float f2 = fSpeedMult * fSpeedMultExtra;
      noiseDetail(iOctaves, fFallOff);
      float c = map( noise(x*f, y*f, z + f2 * millis()), fNoiseMin, fNoiseMax, -0.2, 1.2);
      c = max(min(c, 1), 0);
      return c;
    }
  }
