
//---------------------------------------------------------------------------------------------------COLUMNAS
class Columna{

  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x1, _x4, _esCentral){    //X inicial, X final, si usa o no imágenes
    
    //calcula la curva de la línea a partir de X inicial y X final; la altura siempre ocupa toda la pantalla
    this.x1=_x1;                        this.y1=0;
    this.x2=map(2, 0,10, _x1,_x4);      this.y2=map(2, 0,5, 0,height);
    this.x3=map(8, 0,10, _x1,_x4);      this.y3=map(3, 0,5, 0,height);
    this.x4=_x4;                        this.y4=height;

    this.esCentral = _esCentral;

    this.pintura = [];
    this.cantidadManchas = 6;    //cantidad de manchas por columna
    //this.chanceManchas = 1;      //una entre cuántas manchas puede ser imagen (para no saturar el programa y darle variedad)
    let posX=0, posY=0;
    let prePosX = posX, prePosY=posY;
    for(let i=0; i<this.cantidadManchas; i++){
      posX = bezierPoint(this.x1,this.x2,this.x3,this.x4, i/this.cantidadManchas);  //instanciar manchas sobre la bezier
      posY = bezierPoint(this.y1,this.y2,this.y3,this.y4, i/this.cantidadManchas);

      if(i>0){    //ignorar la primera mancha (siempre se dibuja mal por no tener prePos)
        let imagenCentral = false;
        //if((posY>this.y2 && posY<this.y3) && (floor(random(1,this.chanceManchas))==1) && _esCentral){  //sólo algunas manchas son PNGs grandes y siempre sobre el centro de la columna
        if((posY>this.y2 && posY<this.y3) && _esCentral){  //sólo algunas manchas son PNGs grandes y siempre sobre el centro de la columna
          imagenCentral=true;
        }
        this.pintura[i] = new Mancha(posX,posY, prePosX,prePosY, imagenCentral);    //instanciar objeto mancha (posición XY, posición de la anterior, si usa o no imágenes)
      }

      prePosX = posX, prePosY=posY;    //guardar posición anterior para calcular el ángulo de la curva
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
    let prePosX = posX, prePosY=posY;
    for(let i=0; i<this.cantidadManchas; i++){
      posX = bezierPoint(this.x1,this.x2,this.x3,this.x4, i/this.cantidadManchas);  //acomodar manchas a la nueva bezier
      posY = bezierPoint(this.y1,this.y2,this.y3,this.y4, i/this.cantidadManchas);
      if(i>0 && this.manchaEnPantalla(i)){
        this.pintura[i].recalcular(posX,posY, prePosX,prePosY);
      }

      prePosX=posX, prePosY=posY;    //guardar estado anterior
    }
  }


  //-------------------------------------------------------------------------------------METODO DIBUJAR
  dibujar(){
    /*
    push();
      noFill(); strokeWeight(50); stroke(this.x1, 0,width, 0,360);
      bezier(this.x1,this.y1, this.x2,this.y2, this.x3,this.y3, this.x4,this.y4);   //línea bezier base
    pop();
    */

    if(this.esCentral == false){
      for(let i=1; i<this.cantidadManchas; i++){    //dibujar fondo por abajo
        if(this.manchaEnPantalla(i)){
          this.pintura[i].dibujar();
        }
      }
    }else{
      for(let i=1; i<this.cantidadManchas; i++){    //dibujar manchas centrales por encima
        if(this.pintura[i].esCentral && this.manchaEnPantalla(i)){
          this.pintura[i].dibujar();
        }
      }
    }
  }


  //-------------------------------------------------------------------------------------SEGURO POR RENDIMIENTO
  manchaEnPantalla(_i){        //ocultar las manchas que quedan fuera de la pantalla para mejorar rendimiento
    let margenVisual = width/2;
    return (this.pintura[_i].posX>=-margenVisual && this.pintura[_i].posX<=width+margenVisual);
  }
}





//---------------------------------------------------------------------------------------------------MANCHAS DE PINTURA
class Mancha{
  
  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(_x, _y, _px, _py, _imagenCentral){ //posición XY, posición de la anterior, si usa o no imágenes
    this.desviacion = random(-10,10);           //desplaza ligeramente la mancha para hacer la curva más imperfecta
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);          //ángulo entre el punto actual y el anterior, para seguir la curva
    
    this.cambiaColor;   //si cambia de color o se mantiene
    this.cambioTinte = random(5,15);    //cuánto cambia el color al prolongar el sonido, para que se vayan desfasando
    
    let chanceAzul = round(random(0,100-map(this.posY, 50,height-50, 0,100)));
    if(chanceAzul == 0){ this.tinte = 245; this.cambiaColor = false; }  //las manchas de abajo tienden a ser más azules
    else{ this.tinte = random(360); this.cambiaColor = true; }
    this.limitarTinte();

    this.brillo = random(75,100);                         //elegir brillo base al azar
    this.saturacion = map(this.posY, 0,height, 10,60);   //cuanto más abajo, más saturado está
    this.alfa = map(this.posY, 0,height/2, 5,10)*random(5,20);             //cuanto más abajo, menos transparencia tiene

    this.mancha = int(random(0,cantidadImagenesCentro));    //asignar una de las imagenes
    this.esCentral = _imagenCentral;
    if(this.esCentral){
      this.grosor = random(25,35)*random(3, 5);                 //tamaño de manchas centrales
      this.largo = random(45, 55)*random(8,10);
    }else{
      //this.grosor = map(this.posY, 0,height, 10,20)*random(2, 4);                   //tamaño de manchas del fondo

      this.factorGrosor = random(3, 6);
      this.factorLargo = random(25, 35);
      this.grosor = (10-map(abs(this.posX-width/2), 0,width, 0,3))*this.factorGrosor;
      this.largo = (10-map(abs(this.posX-width/2), 0,width, 0,3))*this.factorLargo;
    }
  }


  //-------------------------------------------------------------------------------------METODO CALCULADORA
  recalcular(_x, _y, _px, _py){                   //actualizar datos tras recibir sonido
    this.posX=_x+this.desviacion; this.posY=_y;
    this.angulo = atan2(_y-_py, _x-_px);

    if(!this.esCentral){
      //this.grosor = map(this.posY, 0,height, 10,20)*random(2, 4);                   //tamaño de manchas del fondo
      this.grosor = (10-map(abs(this.posX-width/2), 0,width, 0,3))*this.factorGrosor;
      this.largo = (10-map(abs(this.posX-width/2), 0,width, 0,3))*this.factorLargo;
    }

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
      rotate(this.angulo-90);

      if(this.esCentral){
        tint(360, 75);
        image(pngCentro[this.mancha], 0,0, this.grosor,this.largo);    //mostrar imágenes
      }else{
        //fill(this.tinte, this.saturacion,this.brillo, this.alfa);
        //noStroke();
        tint(this.tinte, this.saturacion,this.brillo, this.alfa);
        image(pngFondo[this.mancha], 0,0, this.grosor,this.largo);    //mostrar imágenes
        //ellipse(0,0, this.alto,this.ancho);     //dibujar elipses para las que no son imágenes (hacer todo con imágenes explota la compu)
      }
    pop();
  }
}