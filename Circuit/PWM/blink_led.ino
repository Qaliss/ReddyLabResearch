uint8_t LED_PIN = 2;


void setup() {
  // put your setup code here, to run once:
pinMode(LED_PIN, OUTPUT);
digitalWrite(LED_PIN, LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(LED_PIN, HIGH);
  delay(500);
  digitalWrite(LED_PIN, LOW);
  delay(500);
}
