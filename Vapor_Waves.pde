import processing.opengl.*;

HE_Mesh mesh;
WB_Render render;
boolean shouldContinue = true;
int modifier = 0;
float multiplier = 0.1;
int u = 30;
int v = 30;
boolean upwards = true;
boolean moonCycle = true;
float moonAngle = 0;
float[][] wavesMatrix;
float[][] volumes;
float[][] mountainsMatrix;

AudioInput in;
Minim minim;
FFT fft;

void setup() {
  size(600, 600, P3D);
  //For retina displays
  pixelDensity(2);

  smooth(10);
  noStroke();
  noCursor();
  render=new WB_Render(this);
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  setupMountainMatrix();
  wavesMatrix = new float[u+1][v+1];
  volumes = new float[u+1][v+1];
}

// The mountains are fixed, so their grid is calculated only once
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
  fft.forward(in.mix);
  directionalLight(mainRed, mainGreen, mainBlue, 0, -1, -0.5);
  directionalLight(secondaryRed, secondaryGreen, secondaryBlue, 0, 1, -0.5);

  translate(width/2, height/2);
  //rotateY(mouseX*1.0f/width*TWO_PI);
  //rotateX(mouseY*1.0f/height*TWO_PI);
  rotateY(HALF_PI);
  rotateX(HALF_PI);
  rotateY(-QUARTER_PI/2);
  checkAudio();
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
  float[][] previousWaves = wavesMatrix;
  wavesMatrix = new float[u+1][v+1];
  for (int i = 0; i < u+1; i++) {
    for (int j = 0; j < v+1; j++) {
      float value = 0;
      if (i != 0 && j != 0 && i != u && j != v){
          value = previousWaves[i][j] + fft.getBand((i)*(j));
          value -= 2;
          
          if (value <= 0){
            value = 0;
          }
          if (value >= height/10){
            value = height/10;
          }
          
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
  pushMatrix();
  rotateZ(HALF_PI);
  HEC_Grid creator=new HEC_Grid();
  creator.setU(u);// number of cells in U direction
  creator.setV(v);// number of cells in V direction
  creator.setUSize(width*3);// size of grid in U direction
  creator.setVSize(height*4);// size of grid in V direction
  creator.setWValues(wavesMatrix);// displacement of grid points (W value)
  mesh=new HE_Mesh(creator);
  fill(0);
  noStroke();
  render.drawFaces(mesh);
  stroke(color(mainRed, mainGreen, mainBlue));
  render.drawEdges(mesh);
  popMatrix();
}

void drawMountains() {
  pushMatrix();
  translate(width*2.5, 0);
  rotateZ(HALF_PI);
  //rotateX(HALF_PI);
  HEC_Grid creator=new HEC_Grid();
  creator.setU(u);// number of cells in U direction
  creator.setV(v/2);// number of cells in V direction
  creator.setUSize(width*5);// size of grid in U direction
  creator.setVSize(height);// size of grid in V direction
  creator.setWValues(mountainsMatrix);// displacement of grid points (W value)
  mesh=new HE_Mesh(creator);
  fill(0);
  noStroke();
  render.drawFaces(mesh);
  stroke(color(secondaryRed, secondaryGreen, secondaryBlue));
  render.drawEdges(mesh);
  popMatrix();
}

void mousePressed() {
  shouldContinue = !shouldContinue;
}