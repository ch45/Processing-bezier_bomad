//
// bezier_bomad.pde
//

void draw() {
  int maxPoints = 100;

  noFill();
  stroke(255,102,0);

  float bezierCurves[][] = getShapeAsBezierCurves();
  int numCurves = bezierCurves.length;
//  println("numCurves = " + numCurves);
  for (int iCurve = 0; iCurve < numCurves; iCurve++) {
    PVector[] pointsToDraw = bezierToPoints(bezierCurves[iCurve], maxPoints);
    for (int i=0; i < pointsToDraw.length; i++) {
      ellipse(pointsToDraw[i].x, pointsToDraw[i].y, 5, 5);
    }
  }
}

PVector[] bezierToPoints(float[] bezierCurve, int maxPoints) {
  int numPoints = bezierCurve.length;
//  println("numPoints = " + numPoints);

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

float[][] getShapeAsBezierCurves() {
  float arr[][] = {
    {10,10, 50,20, 90,30, 100,100}
  };
  return arr;
}
