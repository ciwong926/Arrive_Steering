/**
 * Holds kinematic data for the character.
 */
Kinematic character;

/**
 * Holds kinematic data for the target.
 */
Kinematic target;

/**
 *  Max acceleration & speed of the character.
 */
float maxAccel;
float maxSpeed;

/**
 * Holds the radius for arriving at the target.
 */
float targetRadius;
 
 /**
  * Holds the radius for slowing down.
  */ 
float slowRadius;

/**
 * Holds the time in which to keep the target 
 * speed.
 */
float timeToTarget = 0.1;

/**
 * Indication of whether the mouse has been pressed.
 */
boolean pressed;

/** 
 * Any potential drag.
 */
float drag; 

/**
 * The size of the character that will be moving.
 */
float size;

/**
 * The distance between the character and the target.
 */
float distance;
 
/**
 * Funciton for setting up varaibles at the beganning of
 * the program.
 */
void setup() {
  
  // Initializing the size of the canvas. 
  size(800, 800);
  
  // Initializing character and target kinematics.
  character = new Kinematic();
  target = new Kinematic();
  
  // Initializing mouse pressed boolean.
  pressed = false;
  
  // Initializing drag.
  drag = 0;
  
  // Initializing size of the character and its distance from the target.
  size = 20;
  distance = 0;
  
  // Updating character starting position.
  character.position.x = size;
  character.position.y = size;
  
  // Initalizing max speed & acceleration and radius sizes.
  maxAccel = 2; 
  maxSpeed = 10; 
  targetRadius = 20; 
  slowRadius = 60; 
}

/**
 * Responsible for graphics on the canvas.
 */
void draw() {
  
  // Establishing background color.
  background(25);
  
  // Displays character at the appropriate location and orientation.
  translate( character.position.x, character.position.y );
  rotate(character.orientation);  
  fill(180);
  noStroke();
  ellipse(0,0,size,size);
  triangle( 0 + size/3.5, 0 + size/2.5, 0 + size/3.5, 0 - size/2.5, 0 + size, 0);
  
  // If the button has been pressed, update the character & target kinemeatics. 
  if ( pressed == true ) {   
    update();
  }
  
}

/**
 * Function that handles when the mouse is pressed.
 */
void mousePressed() {
  // Target position becomes the location of mouse click.
  target.position = new PVector( mouseX, mouseY );
  pressed = true;
}  

/**
 * A steering update function responsible for updating 
 * variables, steering out & kinematics. 
 */
void update() {
  
  // Get Acceleration Requests
  SteeringOutput out = getSteering( target );
  
  //character.velocity.add(out.linAccel);
  character.velocity.x += out.linAccel.x;
  character.velocity.y += out.linAccel.y;
  
  // Clip to max velocity
  if ( character.velocity.mag() > maxSpeed ) {
     character.velocity.normalize();
     character.velocity.mult(maxAccel);
  }
  
  // Apply Drag
  float speed = character.velocity.mag();
  if ( speed > 0 ) {
    float slower = speed - drag;
    character.velocity = character.velocity.normalize().mult(slower);
  }  
  
  // Character is only updated if target radius is not hit.
  if ( distance > targetRadius ) {
    
    // Calculate new position.
    character.position.x += character.velocity.x;
    character.position.y += character.velocity.y; 
    
    // Calculate orientation.
    if ( character.velocity.x == 0 ) {
      character.orientation = 0;
    } else {  
     character.orientation = atan2( ( character.velocity.y), character.velocity.x);
    }  
    
  }
  
}
    
  
/**
 * Implementation of Arrive Algorithm from "Artificial Intellegence for Games" 2nd Ed. 
 * Ian Millington, John Funge - pg. 61
 */
SteeringOutput getSteering ( Kinematic t ) {
  
  // A structure for holding our output.
  SteeringOutput steering = new SteeringOutput();
  
  // Get the direction of the target  
  PVector directionOfTarget = new PVector( 0, 0 );
  directionOfTarget.x += t.position.x;
  directionOfTarget.y += t.position.y; 
  directionOfTarget.x -= character.position.x;
  directionOfTarget.y -= character.position.y;
  
  distance = directionOfTarget.mag();
  
  // Check if we are there, if so return empty steering.
  if ( distance < targetRadius ) {
    return steering;
  }
  
  // The speed one should use to approach the target.
  float targetSpeed;
  
  // If we are outside the slowRadius, then go to max speed.
  if ( distance > slowRadius ) {
    targetSpeed = maxSpeed;
    
  // Otherwise calculate a scaled speed. 
  } else {
    targetSpeed = maxSpeed * distance / slowRadius;
  }  
  
  // The target velocity combines speed and direction.
  t.velocity = directionOfTarget.normalize();
  t.velocity.mult(targetSpeed);
  
  // Acceleration tries to get to the target velocity.
  steering.linAccel.x = t.velocity.x;
  steering.linAccel.y = t.velocity.y;
  steering.linAccel.x -= character.velocity.x;
  steering.linAccel.y -= character.velocity.y;
  
  steering.linAccel.div( timeToTarget );
  
  // Check if acceleration is too fast.
  if ( steering.linAccel.mag() > maxAccel ) {
    steering.linAccel.normalize();
    steering.linAccel.mult(maxAccel);
  }  
  
  // Output the steering. 
  return steering;
}


/**
 * A class that acts as a struct for holding 
 * kinematic variables. 
 */
class Kinematic {
  PVector velocity;
  PVector position;
  float orientation;
  float rotation; 
  
  public Kinematic() {
    velocity = new PVector(0, 0);
    position = new PVector(0, 0);
    orientation = 0;
    rotation = 0;
  }  
}

/**
 * A class that acts as a struct for holding
 * steering output.
 */
class SteeringOutput {
  PVector linAccel;
  float rotAccel;
  
  public SteeringOutput() {
    linAccel = new PVector(0, 0);
    rotAccel = 0;
  }  
}  
  
