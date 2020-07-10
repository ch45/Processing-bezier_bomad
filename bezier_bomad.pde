//
// bezier_bomad.pde
//

public void setup() {
  size(1280, 720);
}

void draw() {
  fill(255, 102, 0);
  stroke(255, 102, 0);

  float bezierCurves[][] = scaleBezierCurves(getShapeAsBezierCurves(), 6.0, 6.0, 0.0, 0.0);

  int maxPoints = 100;
  for (float[] bez : bezierCurves) {
    PVector[] pointsToDraw = bezierToPoints(bez, maxPoints);
    for (PVector vec : pointsToDraw) {
      ellipse(vec.x, vec.y, 5, 5);
    }
  }
}

PVector[] bezierToPoints(float[] bezierCurve, int maxPoints) {
  float x1 = bezierCurve[0];
  float y1 = bezierCurve[1];
  float x2 = bezierCurve[2];
  float y2 = bezierCurve[3];
  float x3 = bezierCurve[4];
  float y3 = bezierCurve[5];
  float x4 = bezierCurve[6];
  float y4 = bezierCurve[7];

  // Takes a (2d for now) bezier curve anchor and control points and returns an array of points along that curve
  PVector[] bezierPoints = new PVector[maxPoints];
  for (int i = 0; i < maxPoints; i++) {
    float t = i / float(maxPoints);
    float x = bezierPoint(x1, x2, x3, x4, t);
    float y = bezierPoint(y1, y2, y3, y4, t);
    bezierPoints[i] = new PVector(x, y);
  }
  return bezierPoints;
}

float[][] scaleBezierCurves(float[][] bezierCurves, float mx, float my, float cx, float cy) {
  for (float[] ext : bezierCurves) {
    ext[0] *= mx; ext[0] += cx;
    ext[1] *= my; ext[1] += cy;
    ext[2] *= mx; ext[2] += cx;
    ext[3] *= my; ext[3] += cy;
    ext[4] *= mx; ext[4] += cx;
    ext[5] *= my; ext[5] += cy;
    ext[6] *= mx; ext[6] += cx;
    ext[7] *= my; ext[7] += cy;
  }
  return bezierCurves;
}

float[][] getShapeAsBezierCurves() {
  float arr[][] = {
    {10,10, 50,20, 90,30, 100,100}
  };
  return arr;
}
