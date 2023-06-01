
//---------------------------------------------------------------------------------------------------COLUMNAS
class Columna{

  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x1, _x4, usarImagenes){
    
    //calcula la curva de la línea a partir de X inicial y X final; la altura siempre ocupa toda la pantalla
    this.x1=_x1;                        this.y1=0;
    this.x2=map(2, 0,10, _x1,_x4);      this.y2=map(2, 0,5, 0,height);
    this.x3=map(8, 0,10, _x1,_x4);      this.y3=map(3, 0,5, 0,height);
    this.x4=_x4;                        this.y4=height;
    
    this.pintura = [];
    this.cantidadManchas = 30;    //manchas por columna
    this.chanceManchas = 5;      //una entre cuántas manchas puede ser imagen (para no saturar el programa)
    let posX=0, posY=0;
    let prePosX = posX, prePosY=posY;                     //instanciar manchas sobre la bezier
    for(let i=0; i<this.cantidadManchas; i++){
      posX = bezierPoint(this.x1,this.x2,this.x3,this.x4, i/this.cantidadManchas);
      posY = bezierPoint(this.y1,this.y2,this.y3,this.y4, i/this.cantidadManchas);
      if(i>0){
        let esImagen = false;                       //sólo algunas manchas son PNGs
        if((posY>this.y2 && posY<this.y3) && (floor(random(0,this.chanceManchas))==0) && usarImagenes){
          esImagen=true;
        }
        this.pintura[i] = new Pintura(posX,posY, prePosX,prePosY, esImagen);
      }

      prePosX = posX, prePosY=posY;    //guardar estado anterior
    }
  }


  //-------------------------------------------------------------------------------------METODO CALCULADORA
  recalcular(_x1, _x4){
    //calcula la curva de la línea a partir de X inicial y X final; la altura siempre ocupa toda la pantalla
    this.x1=_x1;
    this.x2=map(2, 0,10, _x1,_x4);
    this.x3=map(8, 0,10, _x1,_x4);
    this.x4=_x4;

    let posX=0, posY=0;
    let prePosX = posX, prePosY=posY;                     //instanciar manchas sobre la bezier
    for(let i=0; i<this.cantidadManchas; i++){
      posX = bezierPoint(this.x1,this.x2,this.x3,this.x4, i/this.cantidadManchas);
      posY = bezierPoint(this.y1,this.y2,this.y3,this.y4, i/this.cantidadManchas);
      if(i>0){
        this.pintura[i].recalcular(posX,posY, prePosX,prePosY);
      }

      prePosX = posX, prePosY=posY;    //guardar estado anterior
    }
  }


  //-------------------------------------------------------------------------------------METODO DIBUJAR
  dibujar(){
    push();
      noFill(); strokeWeight(50);
      //bezier(this.x1,this.y1, this.x2,this.y2, this.x3,this.y3, this.x4,this.y4);   //línea bezier base
    pop();

    for(let i=1; i<this.cantidadManchas; i++){    //manchas de pintura sin imagen por abajo
      this.pintura[i].dibujar(false);
    }
    for(let i=1; i<this.cantidadManchas; i++){    //manchas de pintura de imagen por encima
      if(this.pintura[i].esImagen){
        this.pintura[i].dibujar(true);
      }
    }
  }
}



//---------------------------------------------------------------------------------------------------MANCHAS DE PINTURA
class Pintura{
  
  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x, _y, _px, _py, usarImagen){
    this.desviacion = random(-20,20);
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);
    
    this.tinte = random(360);        //elegir color al azar para diferenciar manchas entre sí
    this.cambioTinte = random(10,30);
    this.brillo = random(75,100);     //elegir brillo base al azar

    this.saturacion = map(this.posY, 0,height, 10,70);   //cuanto más abajo, más saturado está
    //this.alfa = constrain(100-map(abs(this.posY-height/2), 0,height/2, 0,200), 10,100);   //hacia el centro son menos transparentes
    this.alfa = map(this.posY, 0,height, 10,50);             //cuanto más abajo, menos transparencia tiene
    this.ancho = map(this.alfa, 0,100, 5,10)*random(1, 3);   //hacia el centro tienden a ser más grandes
    this.alto = this.ancho*random(20, 50);

    this.esImagen = usarImagen;
    if(this.esImagen){ this.mancha = int(random(0,cantidadImagenes)); }    //asignar una de las imagenes
  }


  //-------------------------------------------------------------------------------------METODO CALCULADORA
  recalcular(_x, _y, _px, _py){
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);

    this.tinte += longitud/this.cambioTinte;        //cambiar la paleta a medida que el sonido siga sonando
    if(this.tinte>360){ this.tinte-=360; }
    if(this.tinte<0){ this.tinte+=360; }
  }

  //-------------------------------------------------------------------------------------METODO DIBUJAR
  dibujar(usarImagen){
    push();
      translate(this.posX,this.posY);

      if(usarImagen){
        rotate(this.angulo+90);
        tint(this.tinte, 100,this.brillo, 100);
        image(PNGs[this.mancha], 0,0, this.ancho*5,this.alto);
      }else{
        rotate(this.angulo);
        fill(this.tinte, this.saturacion,this.brillo, this.alfa); 
        noStroke();
        ellipse(0,0, this.alto,this.ancho);
      }
    pop();
  }
}