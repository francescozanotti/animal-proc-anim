class Chain {
  ArrayList<PVector> joints;
  int linkSize; // Space between joints

  // Only used in non-FABRIK resolution
  ArrayList<Float> angles;
  float angleConstraint; // Max angle diff between two adjacent joints, higher = loose, lower = rigid

  Chain(PVector origin, int jointCount, int linkSize) {
    this(origin, jointCount, linkSize, TWO_PI);
  }

  Chain(PVector origin, int jointCount, int linkSize, float angleConstraint) {
    this.linkSize = linkSize;
    this.angleConstraint = angleConstraint;
    joints = new ArrayList<>(); // Assumed to be >= 2, otherwise it wouldn't be much of a chain
    angles = new ArrayList<>();
    joints.add(origin.copy());
    angles.add(0f);
    for (int i = 1; i < jointCount; i++) {
      joints.add(PVector.add(joints.get(i - 1), new PVector(0, this.linkSize)));
      angles.add(0f);
    }
  }

  void resolve(PVector pos) {
    // Calculate the target angle from the first joint to the position
    PVector toPos = PVector.sub(pos, joints.get(0));
    float targetAngle = toPos.heading();
    
    // Smoothly interpolate the angle to prevent sudden flips
    float currentAngle = angles.get(0);
    float angleDiff = atan2(sin(targetAngle - currentAngle), cos(targetAngle - currentAngle));
    float newAngle = currentAngle + constrain(angleDiff, -angleConstraint, angleConstraint);
    
    // Update the first joint
    angles.set(0, newAngle);
    joints.set(0, pos);
    
    // Update subsequent joints with angle constraints
    for (int i = 1; i < joints.size(); i++) {
      PVector dir = PVector.sub(joints.get(i-1), joints.get(i));
      float currentJointAngle = dir.heading();
      
      // Calculate the desired angle (pointing towards previous joint)
      float desiredAngle = PVector.sub(joints.get(i-1), joints.get(i)).heading();
      
      // Constrain the angle relative to the previous segment
      float prevAngle = angles.get(i-1);
      float constrainedAngle = constrainAngle(desiredAngle, prevAngle, angleConstraint);
      
      // Update the joint position
      PVector newPos = PVector.sub(joints.get(i-1), PVector.fromAngle(constrainedAngle).mult(linkSize));
      joints.set(i, newPos);
      angles.set(i, constrainedAngle);
    }
  }

  void fabrikResolve(PVector pos, PVector anchor) {
    // Forward pass
    joints.set(0, pos);
    for (int i = 1; i < joints.size(); i++) {
      joints.set(i, constrainDistance(joints.get(i), joints.get(i-1), linkSize));
    }

    // Backward pass
    joints.set(joints.size() - 1, anchor);
    for (int i = joints.size() - 2; i >= 0; i--) {
      joints.set(i, constrainDistance(joints.get(i), joints.get(i+1), linkSize));
    }
  }

  void display() {
    strokeWeight(8);
    stroke(255);
    for (int i = 0; i < joints.size() - 1; i++) {
      PVector startJoint = joints.get(i);
      PVector endJoint = joints.get(i + 1);
      line(startJoint.x, startJoint.y, endJoint.x, endJoint.y);
    }

    fill(42, 44, 53);
    for (PVector joint : joints) {
      ellipse(joint.x, joint.y, 32, 32);
    }
  }
}
