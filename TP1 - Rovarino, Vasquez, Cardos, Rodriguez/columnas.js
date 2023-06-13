
//---------------------------------------------------------------------------------------------------COLUMNAS
class Columna{

  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x1, _x4, _tieneImagenes){
    
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
        if((posY>this.y2 && posY<this.y3) && (floor(random(0,this.chanceManchas))==0) && _tieneImagenes){
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
      this.pintura[i].dibujar();
    }
    for(let i=1; i<this.cantidadManchas; i++){    //manchas de pintura de imagen por encima
      if(this.pintura[i].esImagen){
        this.pintura[i].dibujar();
      }
    }
  }
}





//---------------------------------------------------------------------------------------------------MANCHAS DE PINTURA
class Pintura{
  
  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x, _y, _px, _py, _usarImagen){
    this.desviacion = random(-20,20);
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);
    
    this.cambiaColor;
    this.cambioTinte = random(5,15);
    
    let chanceAzul = round(random(0,map(this.posY, 50,height-50, 100,1)));
    if(chanceAzul == 0){ this.tinte = 245; this.cambiaColor = false; }  //las manchas de abajo tienden a ser más azules
    else{ this.tinte = random(360); this.cambiaColor = true; }
    this.limitarTinte();

    this.brillo = random(75,100);     //elegir brillo base al azar
    this.saturacion = map(this.posY, 0,height, 10,100);   //cuanto más abajo, más saturado está
    //this.alfa = constrain(100-map(abs(this.posY-height/2), 0,height/2, 0,200), 10,100);   //hacia el centro son menos transparentes
    this.alfa = map(this.posY, 0,height, 10,30);             //cuanto más abajo, menos transparencia tiene

    //this.ancho = constrain(100-map(abs(this.posY-height/2), 0,height/2, 0,200), 10,100);
    this.ancho = map(this.posY, 0,height, 5,10)*random(2, 3);   //hacia el centro tienden a ser más grandes
    this.alto = (10-map(abs(this.posX-width/2), 0,width, 0,3))*random(20, 50);   //hacia el centro, tienden a ser más altas

    this.esImagen = _usarImagen;
    if(this.esImagen){
      this.mancha = int(random(0,cantidadImagenes));    //asignar una de las imagenes

      this.ancho = this.ancho*8;
      this.alto = this.alto*2;
    }
  }


  //-------------------------------------------------------------------------------------METODO CALCULADORA
  recalcular(_x, _y, _px, _py){                   //actualizar datos tras recibir sonido
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);

    if(this.cambiaColor){
      this.tinte += longitud/this.cambioTinte;    //cambiar la paleta a medida que el sonido siga sonando
    }
    this.limitarTinte();
  }

  limitarTinte(){     //mantener el tinte dentro de los 360 grados
    if(this.tinte>360){ this.tinte-=360; }
    if(this.tinte<0){ this.tinte+=360; }
  }


  //-------------------------------------------------------------------------------------METODO DIBUJAR
  dibujar(){
    push();
      translate(this.posX,this.posY);

      if(this.esImagen){
        rotate(this.angulo-90);
        tint(360, 75);
        image(PNGs[this.mancha], 0,0, this.ancho,this.alto);
      }else{
        rotate(this.angulo);
        fill(this.tinte, this.saturacion,this.brillo, this.alfa); 
        noStroke();
        ellipse(0,0, this.alto,this.ancho);
      }
    pop();
  }
}