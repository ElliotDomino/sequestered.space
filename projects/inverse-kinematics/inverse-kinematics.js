// Elliot Chrystal 4/21/2026
// Implementation of CCD inverse kinematics

function Seg(x, y, length, angle = -1 * HALF_PI) {
  this.start = createVector(x, y);
  this.length = length;
  this.angle = angle;

  this.getEnd = function () {
    return createVector(
      this.start.x + cos(this.angle) * this.length,
      this.start.y + sin(this.angle) * this.length
    );
  };

  this.setStart = function (x, y) {
    this.start.set(x, y);
  };

  this.setAngle = function (angle) {
    this.angle = angle;
  };

  this.draw = function () {
    const end = this.getEnd();
    line(this.start.x, this.start.y, end.x, end.y);
  };
}

function resetSegments(segments, numSegments, segmentLength) {
  segments.length = 0;
  let oldSeg = new Seg(width / 2, height / 2, 0);

  for (let i = 0; i < numSegments; i++) {
    const end = oldSeg.getEnd();
    const newSeg = new Seg(
      end.x,
      end.y,
      segmentLength
    );
    segments.push(newSeg);
    oldSeg = newSeg;
  }
}

function drawSegments(segments) {
  for (let i = 0; i < segments.length; i++) {
    segments[i].draw();
  }
}

function updateTarget(newX, newY) {
  if (newX >= 0 && newX <= width && newY >= 0 && newY <= height) {
    target.set(newX, newY);
    doTheMagic();
  }
}

function mousePressed() {
  updateTarget(mouseX, mouseY);
}

function mouseDragged() {
  updateTarget(mouseX, mouseY);
}

function touchStarted() {
  if (touches.length > 0) {
    updateTarget(touches[0].x, touches[0].y);
  }
  return false;
}

function touchMoved() {
  if (touches.length > 0) {
    updateTarget(touches[0].x, touches[0].y);
  }
  return false;
}

function getAngle(vector) {
  return Math.atan2(vector.y, vector.x);
}

function normalizeAngle(angle) {
  while (angle > Math.PI) angle -= 2 * Math.PI;
  while (angle < -Math.PI) angle += 2 * Math.PI;
  return angle;
}

function ccdToTarget(segments, target) {
  for (let i = segments.length - 1; i >= 0; i--) {
    const endEffector = segments[segments.length - 1].getEnd();
    const curSeg = segments[i];

    const toTip = p5.Vector.sub(endEffector, curSeg.start);
    const toTarget = p5.Vector.sub(target, curSeg.start);

    if (toTip.magSq() === 0 || toTarget.magSq() === 0) {
      continue;
    }

    const angleDif = normalizeAngle(getAngle(toTarget) - getAngle(toTip));
    rotateSubchain(segments.slice(i), angleDif);
  }
}

function rotateSubchain(subSegments, rotation) {
  if (subSegments.length === 0) {
    return;
  }

  subSegments[0].setAngle(subSegments[0].angle + rotation);

  for (let i = 1; i < subSegments.length; i++) {
    const prevEnd = subSegments[i - 1].getEnd();
    subSegments[i].setStart(prevEnd.x, prevEnd.y);
  }
}

let numSegments = 2;
let segmentLength = 50;
const segments = [];
let ccdIterations = 10;

let target;

let numSegmentsSlider;
let segmentLengthSlider;
let ccdIterationsSlider;

let numSegmentsLabel;
let segmentLengthLabel;
let ccdIterationsLabel;

function doTheMagic() {
  for (let i = 0; i < ccdIterations; i++) {
    ccdToTarget(segments, target)
  }
}

function rebuildArm() {
  resetSegments(segments, numSegments, segmentLength);
  doTheMagic();
}

function setup() {
  const canvas = createCanvas(400, 400);
  canvas.parent("sketch-container");

  const controls = select("#controls");

  numSegmentsLabel = createP("");
  numSegmentsLabel.parent(controls);

  numSegmentsSlider = createSlider(1, 10, numSegments, 1);
  numSegmentsSlider.parent(controls);
  numSegmentsSlider.input(() => {
    numSegments = numSegmentsSlider.value();
    rebuildArm();
  });

  segmentLengthLabel = createP("");
  segmentLengthLabel.parent(controls);

  segmentLengthSlider = createSlider(10, 100, segmentLength, 1);
  segmentLengthSlider.parent(controls);
  segmentLengthSlider.input(() => {
    segmentLength = segmentLengthSlider.value();
    rebuildArm();
  });

  ccdIterationsLabel = createP("");
  ccdIterationsLabel.parent(controls);

  ccdIterationsSlider = createSlider(1, 50, ccdIterations, 1);
  ccdIterationsSlider.parent(controls);
  ccdIterationsSlider.input(() => {
    ccdIterations = ccdIterationsSlider.value();
    doTheMagic();
  });

  target = createVector(width/2, height);
  
  rebuildArm();
}

function draw() {
  background(220);

  numSegmentsLabel.html("Number of Segments: " + numSegments);
  segmentLengthLabel.html("Segment Length: " + segmentLength);
  ccdIterationsLabel.html("CCD Iterations: " + ccdIterations);

  drawSegments(segments);

  circle(target.x, target.y, 5);
}
