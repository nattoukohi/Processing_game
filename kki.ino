//#include <Serial.h>

void setup() {
     Serial.begin(9600) ;     // 9600bpsでシリアル通信のポートを開きます
 }
 void loop() {
     int ans ;

     ans = analogRead(0)  ;   // センサーから読込む
     Serial.println(ans) ;    // シリアルモニターに表示させる
     delay(10) ;             // 500ms時間待ちで繰り返す

     if(ans>1020){  
      int c = Serial.read();
      Serial.println("kohiiii");
      delay(10);
     }
 }
