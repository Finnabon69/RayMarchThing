int MaxSteps = 1000;
float MaxDistance = 50;
float SurfaceDistance = .01;
PVector CamPos = new PVector(0, 1, -3.5);
PVector CamRot = new PVector(0, 0, 0);
PVector CurrentMarchPoint = new PVector(0, 1, 0);
PVector LightDir = new PVector(.5, -1, -.5);
float CamDepth = .5;
int PixelSkip = 5;
abstract class RenderObject
{
  public PVector Position;
  public color Color;
  public float Distance(PVector Pos)
  {
    println("Trying to get the distance to an empty renderobject.");
    return(0);
  }
}

class Sphere extends RenderObject
{
  float Radius;
  public Sphere(float Rad, PVector Pos, color Col)
  {
    super.Color = Col;
    Radius = Rad;
    super.Position = Pos;
  }

  public float Distance(PVector Pos)
  {
    return (PVector.dist(Pos, super.Position) - Radius);
  }
}

class XZPlane extends RenderObject
{
  public XZPlane(float YPos)
  {
    super.Position = new PVector(0, YPos, 0);
  }
  public float Distance(PVector Pos)
  {
    return(abs(super.Position.y - Pos.y));
  }
}

class Box extends RenderObject
{
  public Box(PVector Pos)
  {
    super.Position = Pos;
  }
  public float Distance(PVector Pos)
  {
    return(tan(Pos.y));
  }
}

class InfCylinder extends RenderObject
{
  float Radius;
  public InfCylinder(PVector Pos, float Rad)
  {
    Radius = Rad;
    super.Position = Pos;
  }
  
  public float Distance(PVector Pos)
  {
    return (PVector.dist(Pos, new PVector(super.Position.x, super.Position.y, Pos.z)) - Radius);
  }
}

RenderObject[] SceneObjects = {new XZPlane(0), new Sphere(1, new PVector(0, 1, -1), color(255, 0, 0)), new InfCylinder(new PVector(2, 1, 0), .3)};

float DistanceArray()
{
  float[] OutArray = new float[SceneObjects.length];
  for (int Index = 0; Index < SceneObjects.length; Index++)
  {
    OutArray[Index] = SceneObjects[Index].Distance(CurrentMarchPoint);
  }
  //println("Got Distances");
  return (min(OutArray));
}

void setup()
{
  noSmooth();
  rectMode(CORNER);
  colorMode(HSB);
  background(0);
  size(1000, 1000); 
  frameRate(60);
}

float March(PVector Dir, PVector StartPos, float SurfaceDist, float MaxDist)
{
  CurrentMarchPoint = StartPos;
  for (int Steps = 0; Steps < MaxSteps; Steps++)
  {
    CurrentMarchPoint = PVector.add(CurrentMarchPoint, PVector.mult(Dir, (DistanceArray() )));
    //if(Steps != 5)
    if (DistanceArray() < SurfaceDist || PVector.dist(StartPos, CurrentMarchPoint) > MaxDist)
    {
      break;
    }
  }
  return (float)PVector.dist(StartPos, CurrentMarchPoint) / MaxDist * 255.0;
}

void draw()
{
  CamPos.add(new PVector(.05, .05, 0));
  //SceneObjects[1].Position.add(new PVector(0, -.05, 0));
  clear();
  //Main Drawing
  for (float X = 0; X < width; X += PixelSkip)
  {  
    for (float Y = 0; Y < height; Y += PixelSkip)
    {
      PVector Direction = new PVector((X / (width / 2) - 1), (Y / (height / 2) - 1) * -1, CamDepth);
      Direction.add(CamRot);
      Direction.normalize();
      float CamCol = (March(Direction, CamPos, SurfaceDistance, MaxDistance));
      float LightCol = ((March(LightDir.mult(-1), CurrentMarchPoint, .00001, 1000)));
      noStroke();
      fill(color(255.0 - LightCol));
      rect(X, Y, PixelSkip, PixelSkip);
    }
  }
  println("Frame Rendered");
}
