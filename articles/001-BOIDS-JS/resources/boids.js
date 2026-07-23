// Roughly following the W3Schools HTML Game Example, and https://vergenet.net/~conrad/boids/pseudocode.html psudeocode
// Elliot Chrystal 4/15/2025

var skyWidth = 0;
var skyHeight = 0;
var intervalTime = 20;
var numBoids = 50;
var padding = 30;
var lineHeight = 15

var sightDistance = 60;
var centreModifier = 1 / 100;
var avoidDistance = 20;
var avoidWallsModifier = 1 / 60;
var velocityModifier = 1 / 8;
var velocityMax = 5;


const boids = [];

var boidSky = {

    canvas : document.getElementById("boidSky"),

    start : function() {
        
        this.context = this.canvas.getContext("2d");
        this.frameNo = 0;
        this.interval = setInterval(updateSky, intervalTime);
        this.context.textAlign = 'center';

    },
    clear: function() {

        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);

    }
}

class boid {
    constructor(id, pos_x, pos_y, vel_x, vel_y, angle) {

        this.id = id;
        this.pos_x = pos_x;
        this.pos_y = pos_y;
        this.vel_x = vel_x;
        this.vel_y = vel_y;
        this.angle = angle;

    }
    update() {

        let oldPos_x = this.pos_x;
        let oldPos_y = this.pos_y;

        let avoidOffset_x = 0;
        let avoidOffset_y = 0;

        let boidsInRange = [];

        boids.forEach(curOtherBoid => {

            let distance = Math.sqrt(Math.pow((curOtherBoid.pos_x - this.pos_x), 2) + Math.pow((curOtherBoid.pos_y - this.pos_y), 2));

            if ((distance <= sightDistance) && (curOtherBoid.id != this.id)) {
                
                // If boid is not THIS boid, and the distance from THIS boid is <= sightDistance, add to boidsInRange
                boidsInRange.push(curOtherBoid);

                if (distance <= avoidDistance) {

                    // if boid is within avoidance distance, make sure boid stays the curent distance away
                    avoidOffset_x -= (curOtherBoid.pos_x - this.pos_x);
                    avoidOffset_y -= (curOtherBoid.pos_y - this.pos_y);

                }

            }

        });

        let boidsPositionTotal_x = 0;
        let boidsPositionTotal_y = 0;

        let boidsVelocityTotal_x = 0;
        let boidsVelocityTotal_y = 0;

        boidsInRange.forEach(curBoidInRange => {

            // Maintain distance from walls
            if (this.pos_x < padding) {
                avoidOffset_x += padding * avoidWallsModifier
            }
            if (this.pos_x > (skyWidth - padding)) {
                avoidOffset_x -= padding * avoidWallsModifier
            }
            if (this.pos_y < padding) {
                avoidOffset_y += padding * avoidWallsModifier
            }
            if (this.pos_y > (skyHeight - padding)) {
                avoidOffset_y -= padding * avoidWallsModifier
            }

            // Calculate totals for average calculation
            boidsPositionTotal_x += curBoidInRange.pos_x;
            boidsPositionTotal_y += curBoidInRange.pos_y;

            boidsVelocityTotal_x += curBoidInRange.vel_x;
            boidsVelocityTotal_y += curBoidInRange.vel_y;

        });

        // Calculate average position offset
        let boidsPositionAverage_x = boidsPositionTotal_x / boidsInRange.length;
        let boidsPositionAverage_y = boidsPositionTotal_y / boidsInRange.length;
        let boidsCenterOffset_x = centreModifier * (boidsPositionAverage_x - this.pos_x);
        let boidsCenterOffset_y = centreModifier * (boidsPositionAverage_y - this.pos_y);

        // Calculate averate velocity offset
        let boidsVelocityAverage_x = boidsVelocityTotal_x / boidsInRange.length;
        let boidsVelocityAverage_y = boidsVelocityTotal_y / boidsInRange.length;
        let boidsVelocityOffset_x = velocityModifier * (boidsVelocityAverage_x - this.vel_x);
        let boidsVelocityOffset_y = velocityModifier * (boidsVelocityAverage_y - this.vel_y);

        // Add offsets to velocity
        this.vel_x += avoidOffset_x + boidsCenterOffset_x + boidsVelocityOffset_x;
        this.vel_y += avoidOffset_y + boidsCenterOffset_y + boidsVelocityOffset_y;

        // Cap off velocity
        if (this.vel_x < -velocityMax){
            this.vel_x = -velocityMax;
        }
        if (this.vel_x > velocityMax){
            this.vel_x = velocityMax;
        }
        if (this.vel_y < -velocityMax){
            this.vel_y = -velocityMax;
        }
        if (this.vel_y > velocityMax){
            this.vel_y = velocityMax;
        }

        // Add velocity to current position
        this.pos_x += this.vel_x;
        this.pos_y += this.vel_y;

        // Cap off position
        if (this.pos_x > skyWidth) {
            this.pos_x = skyWidth;
        }
        if (this.pos_x < 0) {
            this.pos_x = 0;
        }
        if (this.pos_y > skyHeight) {
            this.pos_y = skyHeight;
        }
        if (this.pos_y < 0) {
            this.pos_y = 0;
        }

        let angleRadians = Math.atan2((this.pos_y - oldPos_y), (this.pos_x - oldPos_x));

        // Draw Boid
        let ctx = boidSky.context;
        ctx.save();
        ctx.translate(this.pos_x, this.pos_y);
        ctx.rotate(angleRadians + (-90 * (Math.PI / 180)));
        ctx.fillText("V", 0, lineHeight / 2);
        ctx.restore();

    };

}

function resizeCanvas() {
    const canvas = boidSky.canvas;
    const dpr = window.devicePixelRatio || 1;

    // CSS size
    const cssWidth = window.innerWidth * 0.95;
    const cssHeight = window.innerHeight * 0.7;

    // Update globals
    skyWidth = cssWidth;
    skyHeight = cssHeight;

    // Set the canvas width and height based on the DPR
    canvas.width = cssWidth * dpr;
    canvas.height = cssHeight * dpr;

    // Set the CSS display size
    canvas.style.width = `${cssWidth}px`;
    canvas.style.height = `${cssHeight}px`;

    // Scale the drawing context
    const ctx = canvas.getContext("2d");
    ctx.setTransform(1, 0, 0, 1, 0, 0); // Reset any existing transform
    ctx.scale(dpr, dpr);
}

function updateSky() {

    boidSky.clear();
    
    boids.forEach(curBoid => curBoid.update());

}

console.log(boids);

window.addEventListener("resize", resizeCanvas);
resizeCanvas();

// Initialize boids in array
for (var i = 0; i < numBoids; i++) {

    var curBoid = new boid(
        i,
        skyWidth / 2,
        skyHeight / 2,
        Math.random() * 2,
        Math.random() * 2,
        (Math.random() * 360));

    boids.push(curBoid);

}

boidSky.start();