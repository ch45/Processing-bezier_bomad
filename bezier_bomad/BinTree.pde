/*
 * BinTree.pde
 * used by: Bezier Optimization Minimum Angle Distance (BOMAD)
 *
 * Charles Ford, 2020
 */

public class BinTree
{
  private BinTree left;
  private BinTree right;
  private BinTree parent;
  // Data
  float fromT;
  float toT;
  float fromX;
  float fromY;
  float toX;
  float toY;

  BinTree(
    float fromT,
    float toT,
    float fromX,
    float fromY,
    float toX,
    float toY
  ) {
    this.fromT = fromT;
    this.toT = toT;
    this.fromX = fromX;
    this.fromY = fromY;
    this.toX = toX;
    this.toY = toY;
    this.left = null;
    this.right = null;
  }

  float getToT() { return toT; }
  float getFromT() { return fromT; }
  float getFromX() { return fromX; }
  float getFromY() { return fromY; }
  float getToX() { return toX; }
  float getToY() { return toY; }
  BinTree getLeft() { return left; }
  BinTree getRight() { return right; }

  float getMagnitude() {
    float x = toX - fromX;
    float y = toY - fromY;
    float hypotenuse = sqrt(sq(x)+sq(y));
    return hypotenuse;
  }

  float getAngle() {
    float x = toX - fromX;
    float hypotenuse = getMagnitude();
    return HALF_PI + sin(x / hypotenuse);
  }

  void setFromX(float fromX) { this.fromX = fromX; }
  void setFromY(float fromY) { this.fromY = fromY; }
  void setToX(float toX) { this.toX = toX; }
  void setToY(float toY) { this.toY = toY; }

  void insertSplit() {
    if (left != null || right != null) return;
    float midT = fromT + (toT - fromT) / 2.0;
    left = new BinTree(this.fromT, midT, this.fromX, this.fromY, 0.0, 0.0);
    left.parent = this;
    right = new BinTree(midT, this.toT, 0.0, 0.0, this.toX, this.toY);
    right.parent = this;
    println("insertSplit() fromT="+fromT+" midT="+midT+" toT="+toT);
  }

  BinTree nextLeaf() {

    BinTree cur = this;

    println("nextLeaf() start "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));

    // traverse down on the left side
    while (cur.left != null) {
      cur = cur.left;
      println("nextLeaf() traverse #1 to "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
    }
    if (cur != this) {
      println("nextLeaf() return "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
      return cur;
    }

    // This BinTree will not be unbalanced, so no right here, we go up

    while (cur.parent != null && cur.parent.right == cur) {
      cur = cur.parent;
      println("nextLeaf() traverse #2 to "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
    }
    if (cur.parent != null && cur.parent.left == cur) {
      cur = cur.parent.right;
      println("nextLeaf() traverse #3 to "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
      while (cur.left != null) {
        cur = cur.left;
        println("nextLeaf() traverse #4 to "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
      }
      if (cur != this) {
        println("nextLeaf() return "+cur.fromT+"-"+cur.toT+" left="+(cur.left!=null?"ptr":"null")+" right="+(cur.right!=null?"ptr":"null")+" parent="+(cur.parent!=null?"ptr":"null"));
        return cur;
      }
    }

    println("nextLeaf() return null");
    return null;
  }
}
