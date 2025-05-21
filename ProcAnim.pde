Fish fish;
Snake snake;
Lizard lizard;

int animal;

void setup() {
  fullScreen();
  smooth();  // Enable anti-aliasing
  
  fish = new Fish(new PVector(width/2, height/2));
  snake = new Snake(new PVector(width/2, height/2));
  lizard = new Lizard(new PVector(width/2, height/2));

  animal = 0;
}

void draw() {
  background(40, 44, 52);

  switch (animal) {
  case 0:
    fish.resolve();
    fish.display();
    break;
  case 1:
    snake.resolve();
    snake.display();
    break;
  case 2:
    lizard.resolve();
    lizard.display();
    break;
  }
}

void mousePressed() {
  if (++animal > 2) {
    animal = 0;
  }
}
