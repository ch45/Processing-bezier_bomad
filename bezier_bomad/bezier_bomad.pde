/*
 * bezier_bomad.pde
 * Bezier Optimization Minimum Angle & Distance (BOMAD)
 *
 * Charles Ford, 2020
 */

import java.util.ArrayDeque;

public void setup() {
  size(1280, 720);
}

int oneShot = 0;

void draw() {
  if (oneShot == 0) {
  fill(255, 102, 0);
  stroke(255, 102, 0);

  float bezierCurves[][] = scaleBezierCurves(getBasicShapeAsBezierCurves(), 6.0, 6.0, 0.0, 0.0);

  int maxPoints = 100;
  float maxAngle = TWO_PI * 2.4 / 360; // with getBasicShape... 0.50 => 64 points
  float maxDistance = 4.0;             // with getBasicShape... 0.15 => 63 points
  int count = 0;
  for (float[] bez : bezierCurves) {
    // PVector[] pointsToDraw = bezierToPointsUnoptimized(bez, maxPoints);
    PVector[] pointsToDraw = bezierToPointsBinTreeOptimized(bez, maxAngle, maxDistance);
    for (PVector vec : pointsToDraw) {
      ellipse(vec.x, vec.y, 5, 5);
      if (count == 0) {
        moveTo(vec.x, vec.y);
      } else {
        lineTo(vec.x, vec.y);
      }
      count++;
    }
  }
  println("count="+count);
  oneShot++;
  }
}

float _x, _y;

void moveTo(float x, float y) {
  _x = x; _y = y;
}

void lineTo(float x, float y) {
  line(_x, _y, x, y);
  _x = x; _y = y;
}

PVector[] bezierToPointsUnoptimized(float[] bezierCurve, int maxPoints) {
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

PVector[] bezierToPointsBinTreeOptimized(float[] bezierCurve, float maxAngle, float maxDistance) {
  float x1 = bezierCurve[0];
  float y1 = bezierCurve[1];
  float x2 = bezierCurve[2];
  float y2 = bezierCurve[3];
  float x3 = bezierCurve[4];
  float y3 = bezierCurve[5];
  float x4 = bezierCurve[6];
  float y4 = bezierCurve[7];

  float fromT = 0.0;
  float toT = 1.0;
  float fromX = bezierPoint(x1, x2, x3, x4, fromT);
  float fromY = bezierPoint(y1, y2, y3, y4, fromT);
  float toX = bezierPoint(x1, x2, x3, x4, toT);
  float toY = bezierPoint(y1, y2, y3, y4, toT);

  BinTree root = new BinTree(fromT, toT, fromX, fromY, toX, toY);

  // Start a FIFO stack
  ArrayDeque<BinTree> btStack = new ArrayDeque<BinTree>();
  btStack.push(root);

  BinTree cur;
  while ((cur = btStack.poll()) != null) {

    cur.insertSplit(); // Leaves some data unpopulated

    // Populate the intermediate point from the bezier curve
    BinTree btL = cur.getLeft();
    BinTree btR = cur.getRight();

    float midT = btL.getToT();
    float midX = bezierPoint(x1, x2, x3, x4, midT);
    float midY = bezierPoint(y1, y2, y3, y4, midT);
    btL.setToX(midX);
    btL.setToY(midY);
    btR.setFromX(midX);
    btR.setFromY(midY);

    float curAngle = cur.getAngle();

    float diffAngleL = diffRadianAngle(curAngle, btL.getAngle());
    float diffAngleR = diffRadianAngle(curAngle, btR.getAngle());

    // the minimumu distance the point is from the current line, opposite = hypotenuse * sine(angle)
    float distancePtL = btL.getMagnitude() * sin(diffAngleL);
    float distancePtR = btR.getMagnitude() * sin(diffAngleR);;

    if (diffAngleR > maxAngle || distancePtR > maxDistance) {
      println("angles cur="+curAngle*360/TWO_PI+" btR="+btR.getAngle()*360/TWO_PI+" diffAngleR="+diffAngleR*360/TWO_PI+" distancePtR="+distancePtR);
      btStack.push(btR);
    }

    if (diffAngleL > maxAngle || distancePtL > maxDistance) {
      println("angles cur="+curAngle*360/TWO_PI+" btL="+btL.getAngle()*360/TWO_PI+" diffAngleL="+diffAngleL*360/TWO_PI+" distancePtL="+distancePtL);
      btStack.push(btL);
    }
  }

  // Takes a (2d for now) bezier curve anchor and control points and returns an array of points along that curve
  ArrayList<PVector> bezierPoints = new ArrayList<PVector>();

  bezierPoints.add(new PVector(root.getFromX(), root.getFromY()));

  cur = root;
  while ((cur = cur.nextLeaf()) != null) {
    bezierPoints.add(new PVector(cur.getToX(), cur.getToY()));
  }

  return bezierPoints.toArray(new PVector[bezierPoints.size()]);
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

float diffRadianAngle(float a1, float a2) {
  float diff = abs(a1 - a2);
  if (diff > PI) { // wrap around at 2pi
    diff = TWO_PI - diff;
  }
  return diff;
}

float[][] getBasicShapeAsBezierCurves() {
  float arr[][] = {
    {10,10, 50,20, 90,30, 100,100}
  };
  return arr;
}
