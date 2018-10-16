import processing.serial.*;

int gseq;
int px = 200;
int py = 620;
int pw = 400;//bar no width
int ph = 10;// bar no height
float bx; //ball zahyou
float by;
float spdx; //ball speed 
float spdy;
int bw = 7;// ball width and height
int bh = 7;
int phit = 0;  //
int blw = 39; //block width
int blh = 15;//block height
int[] blf = new int[400]; //number of block
float lastx;
float lasty;
int bexist = 0;
int score;
int mcnt;
int coin=0; //コイン枚数
int input_money=0; //入れた金額
int clear; //tensai
int pause;
int kasoku_count=0;
int input;
boolean pause_kun=false; //ポーズ
int item_selector=1;
int item2=0;

// Serialクラスのインスタンス
Serial myPort;
// シリアルポートから取得したデータ(Byte)
int inByte=0;

int baseTime;

void setup(){
  size (820,700);
  noStroke();
  colorMode(HSB,100,100,100);
  gameInit();
  
     // Macのシリアルのリストの最初のポートがFTDIアダプタのポート
    String portName = Serial.list()[2]; //macなら２でクランクなら０かな〜やっぱりw
    // ポートとスピードを設定して、Serialクラスを初期化、
    
    
   myPort = new Serial(this, portName, 9600);
  
  baseTime = millis();
}

void serialEvent(Serial p){
    // 設定したシリアルポートからデータを読み取り
    /*if(inByte<myPort.read()+50){
      coin=coin+5;
    }*/
    inByte = myPort.read();
    //println(pw);
    println(inByte);
    
    //経過時間
    int elapsedTime = millis() - baseTime;
    
    if(inByte==49&&elapsedTime>1000){
      coin++;
      baseTime = millis(); //reset
      
    }
    
     if(inByte==48&&elapsedTime>1000){
      coin=coin+5;
      baseTime = millis(); //reset
      
    }
    
    if(inByte==50){
      println("");
      if(pause_kun==true&&elapsedTime>1000){//ポーズ状態ならアイテムの移動よう
      
        item_selector -=1;
        if(item_selector<0){
          item_selector = 3;
        }
      }
      if(pause_kun==false){
      if(input>0){
      input -= 10;
      }else{
        input = 0;
      }
      }
    }
    if(inByte==52){
      println("");
      if(pause_kun==true&&elapsedTime>1000){//ポーズ状態ならアイテムの移動よう
      
        item_selector +=1;
        
        if(item_selector>3){
          item_selector = 1;
        }
      }
      if(pause_kun==false){
      if(input< 420){
        
      input += 10;
      
      }else{
        input = 420;
      }
      }
    }
    if(inByte==56){
      println("");
      if(gseq==3||gseq==2){// ゲームオーバーかゲームクリアの画面で続けるか決める
        stop_game();
      }
      
      if(pause_kun==true){
        pause_kun=false;
      }else if(pause_kun==false&&gseq==1){
      pause_kun = true;
      }
    }
    if(inByte==45){
     if(pause_kun==true){
       if(item_selector == 1&&coin>=1){
         kasoku();
         coin--;

       }else if(item_selector == 2&&coin>=3){
           bar_enchou();
           coin = coin-3;

       }else if(item_selector == 3&&coin>=5){
           block_destroyer();
           coin = coin-5;
       }
     }
      GameStatus();
      
      
    }
}

void draw(){
  
  background(0);
  //println(myPort.read());
  //println(inByte+"kohi");
  if(gseq == 0){
    gameTitle();
  }else if(gseq == 1){
    gamePlay();
  }else if(gseq == 2){
    gameOver();
  }else if(gseq == 3){
    gameClear();
  }
  
    textSize(24);
    fill (20,200,100);
    textAlign(RIGHT);
    text("Credit: "+coin*100, 800,35); //かね
  
  
}

void gameInit(){
  gseq = 0;
  pw = 400;//bar no width
  bx =100;
  by = 450;
  kasoku_count=0; //ボールの色を戻す
  spdx = 2;
  spdy = 2;
  phit = 0;
  for( int i=0; i<400;i++){ //なんかふやしとけ
    blf[i] = 1;
  }
  bexist = 0;
  score = 0;
  mcnt = 0;
}

void gameTitle(){
  playerMove();
  playerDisp();
  blockDisp();
  scoreDisp();
  myPort.write(100);
  mcnt++;
  if((mcnt%60)<40){
    textSize(20);
    fill (20,100,100);
    textAlign(CENTER);
    if(coin<1){
          text("Insert 100 yen to start", 410,460);
    }
    if(coin>=1){
     text("Click to start", 410,460);
    }
  }
  
}

void gamePlay(){
  //if(keyPressed==true){
   // keyPressed();
  //}
  //keyPressed();
  if(pause_kun==false){
  playerMove();
  playerDisp();
  blockDisp();
  ballMove();
  ballDisp();
  scoreDisp();
  }else{//ポーズ時の画面にも後ろのゲーム画面を表示
     playerDisp();
  blockDisp();
  ballDisp();
  scoreDisp();
  itemDisp();
  }
  clear=0;
  for(int i=0; i<400; i++){
    clear=clear +blf[i];
  }
  if(clear==0){
    gseq = 3;
    //gameClear();
  }
}

void gameOver(){
  playerDisp();
  blockDisp();
  scoreDisp();
  textSize(50);
  fill(1,100,100);
  text("GAMEOVER", 270, 300);
  mcnt++;
  pw=400;
  if((mcnt%60)<40){
    textSize(20);
    fill (20,100,100);
    text("Click and return to start menu", 260,360);
  }
}

void gameClear(){
  playerDisp();
  blockDisp();
  scoreDisp();
  textSize(50);
  fill(1,100,100);
  text("GAMECLEAR", 270, 300);
  mcnt++;
  if((mcnt%60)<40){
    textSize(20);
    fill (20,100,100);
    text("Click to start AGAIN", 310,360);
  }
}

void stop_game(){//コインを排出する
  coin=0;
  myPort.write(50); //
  println("ゲームやめるよ〜〜");
}

//アイテムの表示用
void itemDisp(){
    // 設定したシリアルポートからデータを読み取り
    /*if(inByte<myPort.read()+50){
      coin=coin+5;
    }*/
    
    //println(item_selector + "uooo");
    fill(0,0,100);
    text("Choose item to use", 270,360);
    
    if(item_selector == 1){
      fill(0,100,100);
    }else{
      fill(0,0,100);
    }
     text("Speed up", 100,460);
     text("Price: 100YEN", 100,510);
if(item_selector == 2){
      fill(0,100,100);
    }else{
      fill(0,0,100);
    }
     text("Bar extension", 300,460);
     text("Price: 300YEN", 300,510);
     if(item_selector == 3){
      fill(0,100,100);
    }else{
      fill(0,0,100);
    }
     text("Block destroy", 500,460);
     text("Price: 500YEN", 500,510);
     
     fill(0,100,100);
     
    
}

void playerDisp(){
  fill(0,0,100);
  rect(px,py,pw, ph, 5);
}
void playerMove(){
  //px = mouseX; //なしにすること
  px = input;
  if( (px+pw)>width){
    px = width -pw;
    //input = 0; //0にすること
  }
}
void ballDisp(){
  imageMode(CENTER);
  
  fill(0,kasoku_count*25,100); //速度ふえるたびにどんどん赤になる
  //print(kasoku_count);
  
  //rect(bx,by,bw+10,bh+10);
  ellipse(bx,by,bw+10,bh+10);
  imageMode(CORNER);
}
void ballMove(){
  lastx = bx;
  lasty = by;
  bx += spdx;
  by += spdy;
  if(by>height){
    gseq = 2;
  }
  if(by < 0){
    spdy = -spdy ;
  }
  //gamengai
  if((bx<0)||(bx>width)){
    spdx = -(spdx+random(-1,1)); //x方向の反射のあれ 大丈夫そう
  }
  //atarihantei
  if((phit == 0)&&(px<bx)&&(px + pw>bx)&&(py<by)&&(py+ph > by)){
    if(abs(spdy)<1){
      spdy = -spdy;
    }else{
    spdy = -spdy-0.05;// ブロックとぶつかったあとの速度　マイナスがデカくなればはやくなる！w
    }
    
    phit = 1;
    if(bexist == 0){
      //hukatsu
      for(int i=0; i<400; i++){
        blf[i] = 1;
      }
      score += 10;
    }
  }
  
  if(by < py-30){
    phit = 0;
  }
}
void blockDisp(){ //そのまんま
  int xx, yy;
  bexist = 0;
  for (int i=0; i<400;i++){//25 ->50
    if (blf[i] == 1){
      fill((i/60)*15,100,100);// 10をいじる
      xx = (i%20) * (blw +2); // よこ１０いじる
      yy = 50 + (i/20)*(blh +2);// 50はうえからの距離  2はすきまハート
      blockHitCheck(i,xx,yy);
      if(blf[i] == 1){
        rect(xx,yy,blw, blh, 2);
        bexist = 1;
      }
    }
  }
}
void blockHitCheck(int ii, int xx, int yy){
  if(!((xx<bx)&& (xx+blw > bx)&&(yy<by)&&(yy+blh > by))){
    return;
  }
  blf[ii] = 0;
  score += 100;
  if (ii<10){
    score +=100;
  }
  
  if((xx<lastx)&&(xx+blw>lastx)){
    spdy = -spdy;
    return;
  }
  
  if((yy<lasty)&&(yy+blh>lasty)){
    spdx = -spdx;
    return;
  }
  spdx = -spdx;
  spdy = -spdy;
}

void scoreDisp(){
  textSize(24);
  textAlign(LEFT);
  fill(0,0,100);
  text("Score: "+score,10,35);
}

void mousePressed(){
  if ( gseq == 0&&coin>=1){//&&coin>=1
    gseq = 1;
    //myPort.write(3);
  }
  if(gseq ==2 ){
    if(coin>=1){
    coin=coin-1;
    }
    gameInit();
    //myPort.write(3);
  }
  if(gseq ==3 ){
    if(coin>=1){
    coin=coin-1;
    }
    gameInit();
  }
  //spdy = spdy - 1;
}

//ゲームの状態を管理ハート
void GameStatus(){
  if ( gseq == 0&&coin>=1){//&&coin>=1
    gseq = 1;
  }
  if(gseq ==2 ){
    if(coin>=1){
    coin=coin-1;
    }
    gameInit();
  }
  if(gseq ==3 ){
    if(coin>=1){
    coin=coin-1;
    }
    gameInit();
  }
}

void bar_enchou(){ //2つ目のアイテム
      pw = 1000;

}

void block_destroyer(){ //3つ目のアイテム
  
      for(int i=0;i<400;i++){
      blf[int(random(0,400))] = 0;
      }
      //text("waseda 51 destory",400,100);
   
}

void kasoku(){
  
  if(gseq==1){ //ゲームモードの時&&key=='s'
    if(coin>=1){
    if(abs(spdy)<10){
    spdy = spdy * 1.5;
    kasoku_count++;
    coin--;
    }
    
    }
    
    
  }
}

void keyPressed(){
  
  
  if(key=='q'){
    coin = coin+114514;
    
    
    
  }
  
  if(key == 's')  kasoku();
  if(key == 'e')  bar_enchou();
  if(key == 'd')  block_destroyer();
  
  if(key=='w'){
    
  }
  
  
    
    if(key=='p'){
      if(pause_kun==true){
        pause_kun=false;
      }else{
      pause_kun = true;
      }
      
    }
    
    if(pause_kun==true&&keyCode == RIGHT){//ポーズ状態ならアイテムの移動よう
      
       item_selector +=1;
        
        if(item_selector>3){
          item_selector = 1;
        }
        
        println(item_selector + "kohiii");
        
         
      }
      
      if(keyCode == ENTER&&pause_kun==true){//アイテム使用・PC
       if(item_selector == 1&&coin>1){
         kasoku();
         coin--;

       }else if(item_selector == 2&&coin>3){
           bar_enchou();
           coin = coin-3;
           println("うーーーー");

       }else if(item_selector == 3&&coin>5){
           block_destroyer();
           coin = coin-5;
       }
     }
     
      
      if(pause_kun==true&&keyCode == LEFT){//ポーズ状態ならアイテムの移動よう
      
       item_selector -=1;
        
        if(item_selector<1){
          item_selector = 3;
        }
        
        println(item_selector + "kohiii");
        
         
      }
      
      
      
}