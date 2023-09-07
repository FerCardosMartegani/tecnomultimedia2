//--------------------------------------------------------------------------------------------------------------------------------COMPORTAMIENTO COMPARTIDO
class FBodyPlus {
  
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tamX, tamY, tam;
  int index;

  int arreglo;
  int SinG = 0;
  int ConG = 1;

  
  //------------------------------------------------------------------------------------------------------------"CONSTRUCTOR"
  void crearCuerpo(int G, FBody cuerpo) {        //agregar nuevo cuerpo con o sin gravedad
    arreglo = G;
    getArray().add(cuerpo);
    this.index = getArray().size()-1;

    this.getFBody().setPosition(this.posX, this.posY);
    mundo.add(this.getFBody());
  }

  
  //------------------------------------------------------------------------------------------------------------DIBUJO
  void imagen(FBodyPlus objeto, PImage img, float ancho) {
    image(img, objeto.posX, objeto.posY, ancho, nuevoAlto(img, ancho));
  }

  
  //------------------------------------------------------------------------------------------------------------ACCIONES
  void actualizarPos() {
    this.posX = this.getFBody().getX();        //actualizar posición
    this.posY = this.getFBody().getY();
  }

  
  //------------------------------------------------------------------------------------------------------------CUERPO FÍSICO
  ArrayList<FBody> getArray() {              //saber en qué arreglo está (con o sin gravedad)
    if (arreglo == SinG) {
      return cuerposSinG;
    } else {
      return cuerposG;
    }
  }
  FBody getFBody() {
    return getArray().get(this.index);      //acceder al cuerpo físico
  }
}





//--------------------------------------------------------------------------------------------------------------------------------DUENDE
class Duende extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float direc, vida, vidaMax, margen, tiempo, delay;
  boolean bombaLanzada;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Duende() {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = width/2;            //posición inicial
    this.posY = height/8;
    this.tam = 75;                  //tamaño para la colisión

    this.margen = width/8;          //distancia a los bordes donde frena para lanzar bombas
    this.direc = +1;                  //dirección a la que arranca mirando

    this.vida = this.vidaMax = 100;        //máximo de vida

    this.delay = 2;                    //tiempo (en segundos) que dura la pausa para lanzar bombas
    this.tiempo = 0;

    this.bombaLanzada = false;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(SinG, new FCircle(this.tam));
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    actualizarPos();

    push();                                    //mostrar imagen
    imagen(this, duendeImg[0], this.tam*1.5);
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void mover() {
    this.getFBody().setVelocity(this.direc*200, 0);      //desplazar

    boolean bordeIzq = (this.posX < 0+this.margen);
    boolean bordeDer = (this.posX > width-this.margen);
    if ((bordeIzq && this.direc == -1) || (bordeDer && this.direc == +1)) {    //frenar en uno de los bordes
      this.direc = 0;
    }
    if (this.direc == 0) {
      this.tiempo++;
      float delayFixed = this.delay*frameRate;
      if ((this.tiempo >= delayFixed/2) && !this.bombaLanzada) {      //lanzar bomba
        lanzarBomba();
      }
      if ((this.tiempo >= delayFixed) && this.bombaLanzada) {        //volver a moverse en dirección contraria
        if (bordeIzq) {
          this.direc = +1;
        }
        if (bordeDer) {
          this.direc = -1;
        }

        this.tiempo = 0;
        this.bombaLanzada = false;
      }
    }
  }

  void lanzarBomba() {
    bombaLanzada = true;
  }
}





//--------------------------------------------------------------------------------------------------------------------------------SPIDERMAN
class Spiderman extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float vida, vidaMax;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Spiderman() {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = width/2;          //posición inicial
    this.posY = height/4;
    this.tam = 50;                //tamaño para la colisión

    this.vida = this.vidaMax = 100;      //máximo de vida

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(ConG, new FBox(this.tam, this.tam));
    this.getFBody().setFriction(100);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    actualizarPos();        //actualizar posición

    push();                                    //mostrar imagen
    imagen(this, spidermanImg[0], this.tam*1.5);
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void saltar() {
    this.getFBody().addImpulse(0, -2000);        //saltar para engancharse si está parado
  }

  //------------------------------------------------------------------------------------------CUERPO FÍSICO
  boolean cayendo() {
    return ((this.getFBody().getVelocityY()) > 1);      //si ya dejó de saltar, está cayendo
  }
  boolean quieto() {
    return (abs(this.getFBody().getVelocityY()) < 1);      //si no tiene velocidad, está quieto
  }
  boolean puedeEnganchar() {
    return (this.quieto() || this.cayendo());      //si está quieto o cayendo, se puede enganchar
  }
}





//--------------------------------------------------------------------------------------------------------------------------------PLATAFORMAS
class Plataforma extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float rot;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Plataforma(float x, float y, float tx, float ty, float r) {      //FALTA AÑADIR UN PARÁMETRO PARA LA IMAGEN
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;            //posición inicial
    this.posY = y;
    this.tamX = tx;            //tamaño para la colisión
    this.tamY = ty;
    this.rot = radians(r);      //rotación

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(SinG, new FBox(this.tamX, this.tamY));
    this.getFBody().setStatic(true);
    this.getFBody().setRotation(this.rot);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    push();                                    //mostrar imagen
    translate(this.posX, this.posY);
    rotate(this.rot);
    fill(360, 25);
    rect(0, 0, this.tamX, this.tamY);        //ESTO TENDRÍA QUE SER ALGUNA IMAGEN
    pop();

    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("p: "+this.index, this.posX, this.posY);      //mostrar índice
      pop();
    }
  }
}





//--------------------------------------------------------------------------------------------------------------------------------GANCHOS
class Gancho extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Gancho(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;
    this.posY = y;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(SinG, new FCircle(10));
    this.getFBody().setStatic(true);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    push();                                    //mostrar imagen
    imagen(this, ganchoImg, 50);
    pop();

    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("g: "+this.index, this.posX, this.posY);        //mostrar índice

      noFill();
      ellipse(this.posX, this.posY, cursorD*2, cursorD*2);
      pop();
    }
  }
}





//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Bomba extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float radio, tiempo, delay;
  boolean explotada;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Bomba(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;          //posición inicial
    this.posY = y;
    this.tam = 50;          //tamaño para las colisiones

    this.radio = this.tam*3;      //radio de la explosión
    this.explotada = false;

    this.delay = 5;        //tiempo (en segundos) que tarda la bomba en explotar
    this.tiempo = 0;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(ConG, new FCircle(this.tam));

    impulsoInicial();
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    actualizarPos();        //actualizar posición

    push();                                    //mostrar imagen
    fill(20, 100, 100);
    ellipse(this.posX, this.posY, this.tam, this.tam);          //ESTO TENDRÍA QUE SER LA IMAGEN DE LA BOMBA
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void impulsoInicial() {
    this.getFBody().addImpulse(random(-100, 100), random(10, 100));    //aparecer con movimiento
  }

  void cuentaAtras() {
    this.tiempo++;
    float delayFixed = this.delay*frameRate;
    if (this.tiempo >= delayFixed) {
      this.explotada = true;
    }
  }
}





//--------------------------------------------------------------------------------------------------------------------------------TELARAÑA
class Telarania {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float[] distancias;
  float distancia;
  int index;
  boolean enganchado, colgado, ganchoSeleccionable;
  FDistanceJoint tela;

  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Telarania() {
    this.enganchado = this.colgado = this.ganchoSeleccionable = false;
    distancias = new float[ganchos.size()];
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    if ((distancias[this.index] <= cursorD) && !this.enganchado) {    //indicar posible telaraña
      push();
      stroke(360, 25);
      strokeWeight(5);
      line(ganchos.get(this.index).posX, ganchos.get(this.index).posY, spiderman.posX, spiderman.posY);
      pop();
    }
    if (this.enganchado) {            //mostrar telaraña lanzada
      push();
      stroke(360);
      strokeWeight(5);
      line(ganchos.get(this.index).posX, ganchos.get(this.index).posY, spiderman.posX, spiderman.posY);
      pop();
    }
  }

  void ubicarGanchos() {
    if (!this.enganchado) {
      for (int i=0; i<distancias.length; i++) {
        distancias[i] = dist(cursorX, cursorY, ganchos.get(i).posX, ganchos.get(i).posY);    //calcular distancia a cada gancho
      }
      this.distancia = min(distancias);                  //guardar distancia al gancho más cercano
      for (int i=0; i<distancias.length; i++) {
        if (distancias[i] == this.distancia) {
          this.index = i;                              //guardar índice del gancho más cercano
        }
      }
    }
  }

  void aplicarJoint() {
    if (!this.enganchado) {                  //colgarse
      if (distancias[this.index] <= cursorD) {
        if (spiderman.quieto()) {
          spiderman.saltar();          //si spiderman está quieto, salta para tomar velocidad y altura
        }

        this.enganchado = true;
      }
    } else {
      if (this.colgado) {                        //descolgarse
        this.tela.removeFromWorld();
      }

      this.enganchado = this.colgado = false;
    }
  }

  void actualizarJoint() {
    this.ubicarGanchos();

    if (this.enganchado && !this.colgado && (spiderman.puedeEnganchar())) {
      this.tela = new FDistanceJoint(spiderman.getFBody(), ganchos.get(this.index).getFBody());
      this.tela.setNoStroke();
      this.tela.addToWorld(mundo);

      this.colgado = true;
    }
  }
}
