const int ledPin = 2; 
const int tableSize = 628;
float sineTable[tableSize];

// Control variables
float frequency = 3.0; // Hz or speed multiplier
float phase = 1.571;     // Phase offset
int currentIndex = 0;

void setup() {
  // put your setup code here, to run once:

  pinMode(ledPin, OUTPUT);

  for (int i = 0; i<tableSize; i++){
    float angle = (float)i / tableSize * 2.0 * PI;

    float val = (sin(angle) + 1.0) * 127.5;

    sineTable[i] = val;
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  for (int j = 0; j<tableSize; j+=frequency){
      currentIndex = int(j + phase * 100) % tableSize;

    analogWrite(ledPin, sineTable[currentIndex]);
    delay(20);
  }
}
