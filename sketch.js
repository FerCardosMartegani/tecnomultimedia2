let concepto, preConcepto, tiempo, texto;

let posX,posY, tam1,tam2, color1,color2, cambio1,cambio2;
let posXarray=[], posYarray=[], cambio1array=[], cambio2array=[];

function setup() {
  createCanvas(innerWidth, innerHeight);
  colorMode(HSB, 360,100,100,100);
  concepto=tiempo=0;
  preConcepto=-1;
}

function draw() {
  background(360);
  noStroke();
  
  //-----------------------------------------------AQUI: gradación de un círculo que se desvanece
  if(concepto == 1){
    if(preConcepto!=concepto){
      tam1=100; tam2=50;
      posX=width/3;
      posY=height/3;
      color1=50;
      cambio1=0.75;

      texto="AQUI: gradación de un círculo que se desvanece";
    }

    tam1-=cambio1;  tam2-=cambio1;
    if(tam1<=0){ tam1=100; }
    if(tam2<=0){ tam2=100; }

    fill(color1,100,100,100-tam1);
    ellipse(posX,posY, tam1*2);
    fill(color1,100,100,100-tam2);
    ellipse(posX,posY, tam2*2);
  }

  //-----------------------------------------------EXAMINAR: metáfora con "lupa" o "escaner"
  else if(concepto == 2){
    if(preConcepto!=concepto){
      tam1=100; tam2=2.5;
      posX=random(width/2-tam1*tam2, width/2+tam1*tam2);
      cambio1=7.5;

      texto="EXAMINAR: metáfora con 'lupa' o 'escaner'";
    }

    fill(200,100,100,100);
    ellipse(width/2,height/2, tam1*4);
    
    if(abs(width/2-posX)>tam1*3){
      cambio1=-cambio1;
    }
    posX+=cambio1;

    fill(map(posX, width/2-tam1*tam2,width/2+tam1*tam2, 0,360),100,100,30);
    ellipse(posX,height/2, tam1*1.5);
  }

  //-----------------------------------------------PROCESANDO: anáfora de círculos que parpadean
  else if(concepto == 3){
    if(preConcepto!=concepto){
      tam1=100; tam2=100;
      posX=width/2-tam1*2;
      posY=height/2;
      color1=200;

      texto="PROCESANDO: anáfora de círculos que parpadean";
    }

    tam2-=3;
    if(tam2<=0){
      tam2=100;
      posX+=tam1*2;
      if(posX>width/2+tam1*2){
        posX=width/2-tam1*2;
      }
    }

    fill(color1,100,100,tam2);
    ellipse(posX,posY, tam1);
  
    fill(color1,100,100,10);
    ellipse(width/2-tam1*2,posY, tam1);
    ellipse(width/2,posY, tam1);
    ellipse(width/2+tam1*2,posY, tam1);
  }

  //-----------------------------------------------TRANQUILO: metáfora con "respirar"
  else if(concepto == 4){
    if(preConcepto!=concepto){
      tam2=700;
      cambio2=25;
      cambio1=0.25;
      tam1=tam2-cambio2;

      texto="TRANQUILO: metáfora con 'respirar'";
    }

    tam1+=cambio1;
    if(tam1>=tam2+cambio2){ cambio1 = -0.25; }
    if(tam1<=tam2-cambio2){ cambio1 = +0.25; }

    fill(200,100,map(tam1, tam2-cambio2,tam2+cambio2, 45,55),100);
    ellipse(width/2,height/2, tam1);
  }

  //-----------------------------------------------ANIMADO: acumulación de círculos que rebotan
  else if(concepto == 5){
    if(preConcepto!=concepto){
      tam1=100; tam2=5;
      cambio1=60; cambio2=30;
      for(let i=0; i<tam2; i++){
        posXarray[i]=random(width/5, width-width/5);
        posYarray[i]=random(width/5, width-width/5);
        cambio1array[i]=random(cambio1,cambio2);
        cambio2array[i]=random(cambio1,cambio2);
      }

      texto="ANIMADO: acumulación de círculos que rebotan";
    }

    for(let i=0; i<tam2; i++){
      posXarray[i]+=cambio1array[i];
      if(posXarray[i]>width){ cambio1array[i]=-random(cambio1,cambio2); }
      if(posXarray[i]<0){ cambio1array[i]=random(cambio1,cambio2); }

      posYarray[i]+=cambio2array[i];
      if(posYarray[i]>height){ cambio2array[i]=-random(cambio1,cambio2); }
      if(posYarray[i]<0){ cambio2array[i]=random(cambio1,cambio2); }

      fill(map(i, 0,tam2, 0,360),100,100);
      ellipse(posXarray[i],posYarray[i], map(i, 0,tam2, tam1,tam1*tam2));
    }
  }

  //-----------------------------------------------ESTRESADO: intercambio de círculos que se atacan entre sí
  else if(concepto == 6){
    if(preConcepto!=concepto){
      tam1=200; cambio1=1.0, cambio2=75;
      posX=width/2; posY=height/2;

      posXarray[0]=posX;      //posición círculo 1
      posYarray[0]=posY;
      posXarray[1]=random(0,width);      //posición círculo 2
      posYarray[1]=0;

      texto="ESTRESADO: intercambio de círculos que se atacan entre sí";
    }
    
    let a=atan2(posYarray[0]-posYarray[1],posXarray[0]-posXarray[1]);
    let dx=cambio2*cos(a);
    let dy=cambio2*sin(a);

    if(cambio1==0.1){
      if(dist(posXarray[0],posYarray[0],posX,posY)<width*0.75){   //circulo 0 va afuera
        posXarray[0]+=dx; posYarray[0]+=dy;
        posXarray[1]=posX; posYarray[1]=posY;
      }else{
        if(round(random(1))==1){
          posXarray[0]=random(0,width);
          posYarray[0]=map(round(random(1)), 0,1, 0,height);
        }else{
          posYarray[0]=random(0,height);
          posXarray[0]=map(round(random(1)), 0,1, 0,width);
        }
        cambio1=0.0;
      }
    }
    if(cambio1==0.0){
      if(dist(posXarray[0],posYarray[0],posX,posY)>tam1){     //círclo 0 va al centro
        posXarray[0]-=dx; posYarray[0]-=dy;
      }else{
        cambio1=1.1;
      }
    }

    fill(50,100,100);
    ellipse(posXarray[0],posYarray[0], tam1);
    
    if(cambio1==1.1){
      if(dist(posXarray[1],posYarray[1],posX,posY)<width*0.75){   //círculo 1 va afuera
        posXarray[1]-=dx; posYarray[1]-=dy;
        posXarray[0]=posX; posYarray[0]=posY;
      }else{
        if(round(random(1))==1){
          posXarray[1]=random(0,width);
          posYarray[1]=map(round(random(1)), 0,1, 0,height);
        }else{
          posYarray[1]=random(0,height);
          posXarray[1]=map(round(random(1)), 0,1, 0,width);
        }
        cambio1=1.0;
      }
    }
    if(cambio1==1.0){
      if(dist(posXarray[1],posYarray[1],posX,posY)>tam1){   //círculo 1 va al centro
        posXarray[1]+=dx; posYarray[1]+=dy;
      }else{
        cambio1=0.1;
      }
    }
    fill(25,100,100);
    ellipse(posXarray[1],posYarray[1], tam1);

    console.log(a);
  }

  //-----------------------------------------------AL BORDE DEL COLAPSO: suspensión de un círculo que casi se rellena
  else if(concepto == 7){
    if(preConcepto!=concepto){
      tam2=700;
      cambio1=5;
      cambio2=0;
      tam1=tam2-200;

      texto="AL BORDE DEL COLAPSO: suspensión de un círculo que casi se rellena";
    }

    let min=tam2-200;
    let max=tam2;

    tam1+=cambio1;
    if(tam1>=max){ cambio1 = -random(20,30); }
    if(tam1<=min){ cambio1 = +random(5,10); }

    fill(10,100,100);
    ellipse(width/2,height/2, tam2*1.1);

    fill(50-map(tam1, min,max, 0,30),100,100);
    ellipse(width/2+random(-cambio2,cambio2),height/2+random(-cambio2,cambio2), tam1);
  }
  else { texto=" "; }

  preConcepto=concepto;
  tiempo++;
  if(tiempo>frameRate()*7){
    tiempo=0;
    concepto++;
    if(concepto>=9){ concepto=0; }
  }

  textAlign(LEFT,CENTER); textSize(20); fill(0);
  text(texto, 10,30);
  text("Iván Saldaña, Fernando Cardos, Elián Rodriguez, Dana Urquiza, Mateo Andrade, Clara Rovarino, Dante Brachi", 10,height-30);
}

function keyPressed(){
  concepto=int(key);

  console.log(key+" "+concepto);
}
