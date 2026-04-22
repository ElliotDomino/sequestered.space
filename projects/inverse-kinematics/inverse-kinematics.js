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

  for(let i = 0; i < numSegments; i++) {
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
  for(let i = 0; i < segments.length; i++) {
    segments[i].draw();
  }
}

let numSegments = 2;
let segmentLength = 50;

const segments = [];

function setup() {
  const canvas = createCanvas(400, 400);
  canvas.parent("sketch-container");
  resetSegments(segments, numSegments, segmentLength);
}

function draw() {
  background(220);
  drawSegments(segments);
}
