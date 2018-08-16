// Simple Particle System
// Daniel Shiffman <http://www.shiffman.net>

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem 
{
  
  ArrayList particles;    // An arraylist for all the particles
  PVector origin;        // An origin point for where particles are birthed


  ParticleSystem(int num, PVector v) 
  {   
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.get();                        // Store the origin point
    
    for (int i = 0; i < num; i++) 
    {
      particles.add(new Particle(origin));    // Add "num" amount of particles to the arraylist
    }    
  }

  void run() 
  {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) 
    {
      Particle p = (Particle) particles.get(i);

      p.run();
      
      if (p.dead()) 
      {
        particles.remove(i);
      }
    }
  }

  void addParticle() 
  {
    particles.add(new Particle(origin));
  }

  void addParticle(Particle p) 
  {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() 
  {
    if (particles.isEmpty()) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }

}


class Particle 
{
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float timer;


  // Another constructor (the one we are using here)
  Particle(PVector l) 
  {
    // Boring example with constant acceleration
    acc = new PVector(0,0.009,0);
    vel = new PVector(random(-5,5),random(-6,0),0);
    loc = l.get();
    r = 40.0;
    timer = 100.0;
  }

  void run() 
  {
    update();
    render();
  }

  // Method to update location
  void update() 
  {
    vel.add(acc);
    loc.add(vel);
    timer -= 1;
  }

  //se colocan los elementos que se quieren visualizar como particulas
  void render() 
  {
    ellipseMode(CENTER);
    fill(255,timer);
    textSize(r);
    
               
    text(textoParticula,loc.x,loc.y);

    //rect(loc.x,loc.y,10,10);

  }

  // Is the particle still useful?
  boolean dead() 
  {
    if (timer <= 0.0) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }
}
