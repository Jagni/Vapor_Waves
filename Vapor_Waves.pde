import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

import processing.opengl.*;

HE_Mesh mesh;
WB_Render render;
boolean shouldContinue = true;
int modifier = 0;
float multiplier = 0.1;
int u = 50;
int v = 50;
boolean upwards = true;
boolean moonCycle = true;
float moonAngle = 0;
float[][] wavesMatrix;
float[][] mountainsMatrix;

void setup() {
  size(600, 600, P3D);
  //For retina displays
  pixelDensity(2);

  smooth(10);
  noStroke();
  noCursor();
  render=new WB_Render(this);
  
  setupMountainMatrix();
}

void setupMountainMatrix(){

  mountainsMatrix = new float[u+1][v+1];
  for (int j = 0; j < u+1; j++) {
    for (int i = 0; i < v+1; i++) {
      float value = 0;
      if (i != 0 && j != 0 && i != u && j != v){
          value = height/2*noise(0.2*i, 0.2*j);
      }
      mountainsMatrix[i][j]=value;
    }
  }
  
}

void draw() {
  background(10);

  directionalLight(251, 7, 118, 0, -1, -0.5);
  directionalLight(255, 204, 0, 0, 1, -0.5);

  translate(width/2, height/2);
  rotateY(HALF_PI);
  rotateX(HALF_PI);
  rotateY(-QUARTER_PI/2);

  drawMountains();
  
  updateWavesMatrix();
  drawWaves();
  
  drawMoon();

  
  if (shouldContinue || modifier > 0) {
    if (upwards) {
      modifier+=3;
    } else {
      modifier-=3;
    }
    if (modifier <= 0) {
      upwards = true;
      multiplier = random(0.2) + 0.1;
    }
    if (modifier >= height/4) {
      upwards = false;
    }
  }
}

void updateWavesMatrix(){

  wavesMatrix = new float[u+1][v+1];
  for (int j = 0; j < u+1; j++) {
    for (int i = 0; i < v+1; i++) {
      float value = 0;
      if (i != 0 && j != 0 && i != u && j != v){
          value = modifier*noise(multiplier*i, multiplier*j);
      }
      wavesMatrix[i][j]=value;
    }
  }
  
}

void drawMoon() {
  pushMatrix();
  translate(width*5, 0, height*0.05);
  rotateZ(moonAngle);
  moonAngle+=0.005;
  fill(255);
  HEC_Sphere moonCreator=new HEC_Sphere();
  moonCreator.setRadius(width); 
  moonCreator.setUFacets(16);
  moonCreator.setVFacets(16);
  HE_Mesh moonMesh=new HE_Mesh(moonCreator);
  noStroke();
  render.drawFaces(moonMesh);
  popMatrix();
}

void drawWaves() {

  HEC_Grid creator=new HEC_Grid();
  creator.setU(u);// number of cells in U direction
  creator.setV(v);// number of cells in V direction
  creator.setUSize(width*4);// size of grid in U direction
  creator.setVSize(height*3);// size of grid in V direction
  creator.setWValues(wavesMatrix);// displacement of grid points (W value)
  mesh=new HE_Mesh(creator);
  fill(0);
  noStroke();
  render.drawFaces(mesh);
  stroke(#0DDEFF);
  render.drawEdges(mesh);
}

void drawMountains() {

  pushMatrix();
  translate(width*2.5, 0);
  rotateZ(HALF_PI);
  //rotateX(HALF_PI);
  HEC_Grid creator=new HEC_Grid();
  creator.setU(u);// number of cells in U direction
  creator.setV(v/2);// number of cells in V direction
  creator.setUSize(width*4);// size of grid in U direction
  creator.setVSize(height);// size of grid in V direction
  creator.setWValues(mountainsMatrix);// displacement of grid points (W value)
  mesh=new HE_Mesh(creator);
  fill(0);
  noStroke();
  render.drawFaces(mesh);
  stroke(#fb0776);
  render.drawEdges(mesh);
  popMatrix();
}


void mousePressed() {
  shouldContinue = !shouldContinue;
}