import msafluid.*;
import processing.opengl.*;


class MsaFluids
{
  final float FLUID_WIDTH = 120;


  float aspectRatio, aspectRatio2;

  MSAFluidSolver2D fluidSolver;

  PImage imgFluid;


  MsaFluids()
  {
    
    aspectRatio = width * invHeight;
    aspectRatio2 = aspectRatio * aspectRatio;

    // create fluid and set options
    fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
    fluidSolver.enableRGB(true).setFadeSpeed(0.003).setDeltaT(0.5).setVisc(0.0001);

    // create image to hold fluid picture
    imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);
  }




  void update() 
  {
    fluidSolver.update();

      for (int i=0; i<fluidSolver.getNumCells(); i++) 
      {
        int d = 2;
        imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
      }  
      imgFluid.updatePixels();//  fastblur(imgFluid, 2);

      image(imgFluid, 0, 0, width, (height/2)-300);
  }



  // add force and dye to fluid, and create particles
  void addForce(float x, float y, float dx, float dy) 
  {
    float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

    if (speed > 0) {
      if (x<0) x = 0; 
      else if (x>1) x = 1;
      if (y<0) y = 0; 
      else if (y>1) y = 1;

      float colorMult = 5;
      float velocityMult = 30.0f;

      int index = fluidSolver.getIndexForNormalizedPosition(x, y);

      color drawColor;

      colorMode(HSB, 360, 1, 1);
      float hue = ((x + y) * 180 + frameCount) % 360;
      drawColor = color(hue, 1, 1);
      colorMode(RGB, 1);  

      noStroke();
      fill(red(drawColor) * colorMult, green(drawColor) * colorMult, blue(drawColor) * colorMult);
      ellipse(mouseX, mouseY, 10, 10);

      fluidSolver.rOld[index]  += red(drawColor) * colorMult;
      fluidSolver.gOld[index]  += green(drawColor) * colorMult;
      fluidSolver.bOld[index]  += blue(drawColor) * colorMult;

      fluidSolver.uOld[index] += dx * velocityMult;
      fluidSolver.vOld[index] += dy * velocityMult;
    }
  }
}
