// Lab_1 Arduino_samplecode
int pot = A0;
int val = 0;
int start_time;
int now_time;
int fs = 180;    // sampling frequency

void setup() {
  Serial.begin(250000);    // baud rate
  pinMode(pot, INPUT);
}

void loop() {
  start_time = micros();
  val = analogRead(pot);  //read analog input
//  val = map(val, 0, 1023, 0, 7);    //mapping: 10bits to ?bits
  val = map(val, 100, 800, 0, 255);    //mapping: 10bits to ?bits
  Serial.println(val, DEC);  //print on Matlab  

  now_time = micros();
  while(now_time - start_time < 1E6/fs){  //sample rate  
    now_time = micros();
  }   
}
