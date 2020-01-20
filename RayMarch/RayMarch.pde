int MaxSteps = 100;
float MaxDistance = 10;
float SurfaceDistance = .0001;
PVector CamPos = new PVector(0, 1, -7);
PVector CamRot = new PVector(0, 0, 0);
PVector CurrentMarchPoint = new PVector(0, 1, 0);
PVector LightDir = new PVector(.5, -1, -.5);
float CamDepth = .5;
int PixelSkip = 10;
int Frames = 0;
class ObjectInfo
{
  color Color;
  float Distance;
  
  public ObjectInfo(float Dist, color C)
  {
    Distance = Dist;
    Color = C;
  }
}

abstract class RenderObject
{
  public PVector Position;
  public color Color = color(128);
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
    return (PVector.dist(Pos /*new PVector(Pos.x % 1.0, Pos.y % 1.0, Pos.z % 2)*/, super.Position) - Radius);
  }
}

class Plane extends RenderObject
{
  public PVector Normal = new PVector();
  public Plane(float YPos, PVector Norm)
  {
    Normal = Norm;
    super.Position = new PVector(0, YPos, 0);
  }
  public float Distance(PVector Pos)
  {
    
    if ((int)Pos.z % 2.0 == 0 && (int)Pos.x % 2.0 == 0)
    {
      super.Color = color(255, 0, 0);
    }
    else
    {
      super.Color = color(128, 0, 128);
    }
    
    return(PVector.dot(Pos, Normal.normalize()));
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
    return PVector.dist(Pos, new PVector(Pos.x, super.Position.y, super.Position.z)) - Radius;
  }
}

RenderObject[] SceneObjects = {new Plane(0, new PVector(.5, 1, 0)), new Sphere(.4, new PVector(0, 1, 0), color(0, 0, 255))};

ObjectInfo DistanceArray()
{
  float[] OutArray = new float[SceneObjects.length];
  float LowestDistance = 999998999;
  int LowestIndex = 0;
  for (int Index = 0; Index < SceneObjects.length; Index++)
  {
    //OutArray[Index] = SceneObjects[Index].Distance(CurrentMarchPoint);
    float CurrentDistance = SceneObjects[Index].Distance(CurrentMarchPoint);
    if (CurrentDistance < LowestDistance)
    {
      LowestDistance = CurrentDistance;
      LowestIndex = Index;
    }
  }
  return (new ObjectInfo(LowestDistance, SceneObjects[LowestIndex].Color));
}

void setup()
{
  noSmooth();
  rectMode(CORNER);
  //colorMode(HSB);
  background(0);
  size(1000, 1000);
  frameRate(60);
}

ObjectInfo March(PVector Dir, PVector StartPos, float SurfaceDist, float MaxDist, int MSteps)
{
  CurrentMarchPoint = StartPos;
  ObjectInfo Closest = new ObjectInfo(0, color(255));
  for (int Steps = 0; Steps < MSteps; Steps++)
  {
    Closest = DistanceArray();
    CurrentMarchPoint = PVector.add(CurrentMarchPoint, PVector.mult(Dir, (Closest.Distance)));
    Closest = DistanceArray();
    //if(Steps != 5)
    if (Closest.Distance < SurfaceDist || PVector.dist(StartPos, CurrentMarchPoint) > MaxDist)
    {
      break;
    }
  }
  return new ObjectInfo((float)PVector.dist(StartPos, CurrentMarchPoint) / MaxDist, Closest.Color);
}

void draw()
{
  CamPos.add(new PVector(0, -.1, 0));
  //SceneObjects[0].Normal.add(new PVector(0, -.05, 0));
  //Main Drawing
  for (float X = 0; X < width; X += PixelSkip)
  {  
    for (float Y = 0; Y < height; Y += PixelSkip)
    {
      PVector Direction = new PVector((X / (width / 2) - 1), (Y / (height / 2) - 1) * -1, CamDepth);
      Direction.add(CamRot);
      Direction.normalize();
      ObjectInfo Object = (March(Direction, CamPos, SurfaceDistance, MaxDistance, MaxSteps));
      float CamCol = 1 - Object.Distance;
      //float LightCol = ((March(LightDir.mult(-1), CurrentMarchPoint, .000001, 100, MaxSteps)));
      noStroke();
      fill(color(CamCol * red(Object.Color), CamCol * green(Object.Color), CamCol * blue(Object.Color)));
      //fill(c);
      rect(X, Y, PixelSkip, PixelSkip);
    }
  }
  Frames++;
  println("Frame " + Frames +  " Rendered");
}
