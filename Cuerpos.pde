//--------------------------------------------------------------------------------------------------------------------------------COMPORTAMIENTO COMPARTIDO
class FBodyPlus {

  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tamX, tamY, tam;
  int index;

  boolean conGravedad;
  boolean SinG = false;
  boolean ConG = true;


  //------------------------------------------------------------------------------------------------------------"CONSTRUCTOR"
  void crearCuerpo(boolean G, FBody cuerpo) {        //agregar nuevo cuerpo con o sin gravedad
    this.conGravedad = G;
    this.getArray().add(cuerpo);
    this.index = getArray().size()-1;

    this.getFBody().setPosition(this.posX, this.posY);
    mundo.add(this.getFBody());
  }


  //------------------------------------------------------------------------------------------------------------ACCIONES
  void actualizarPos() {
    this.posX = this.getFBody().getX();        //actualizar posición
    this.posY = this.getFBody().getY();
  }


  //------------------------------------------------------------------------------------------------------------CUERPO FÍSICO
  ArrayList<FBody> getArray() {              //saber en qué arreglo está (con o sin gravedad)
    if (this.conGravedad) {
      return cuerposG;
    } else {
      return cuerposSinG;
    }
  }
  FBody getFBody() {
    return getArray().get(this.index);      //acceder al cuerpo físico
  }
}

class Personaje extends FBodyPlus {
  float vida, vidaMax, tiempoGolpe, delayGolpe;
  boolean golpeado;

  void recibirGolpe() {
    if (!this.golpeado) {
      this.golpeado = true;                    //recibir patada aerea ninja giratoria de Spiderman
      this.vida--;
    }
  }
  void recuperar() {
    if (this.golpeado) {
      this.tiempoGolpe++;
      float delayFixed = this.delayGolpe*frameRate;            //breve tiempo de ser invulnerable tras un golpe
      if (this.tiempoGolpe >= delayFixed) {
        this.golpeado = false;
        this.tiempoGolpe = 0;
      }
    }
  }
}





//--------------------------------------------------------------------------------------------------------------------------------DUENDE
class Duende extends Personaje {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float vel, direc, margen, posYfija, tiempoMov, delayMov;
  boolean bombaLanzada;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Duende() {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = width/2;                  //posición inicial
    this.posY = posYfija = height/8;
    this.tam = 75;                        //tamaño para la colisión

    this.vel = 200;              //velocidad

    this.margen = width/8;          //distancia a los bordes donde frena para lanzar bombas
    this.direc = +1;                  //dirección a la que arranca mirando

    this.vida = this.vidaMax = 3;        //máximo de vida

    this.delayMov = 2;                    //tiempo (en segundos) que dura la pausa para lanzar bombas
    this.tiempoMov = 0;

    this.delayGolpe = 3;                 //tiempo (en segundos) que tarda en poder recibir daño de nuevo
    this.tiempoGolpe = 0;

    this.bombaLanzada = this.golpeado = false;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    this.crearCuerpo(SinG, new FCircle(this.tam));
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    this.actualizarPos();

    push();                                        //mostrar imagen
    imagen(duendeImg[0], this.posX, this.posY, this.tam*1.5);
    pop();

    push();                                        //mostrar vidas    //ESTO TENDRÍA QUE SER DE OTRA FORMA
    textSize(24);
    text(int(this.vida)+"/"+int(this.vidaMax), this.posX+50, this.posY-50);
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void mover() {
    this.getFBody().setVelocity(this.getFBody().getVelocityX(), (this.posYfija-this.posY)*10);    //mantener en la misma línea

    this.getFBody().setVelocity(this.direc*this.vel, this.getFBody().getVelocityY());      //desplazar izquierda y derecha

    boolean bordeIzq = (this.posX < 0+this.margen);
    boolean bordeDer = (this.posX > width-this.margen);
    if ((bordeIzq && this.direc == -1) || (bordeDer && this.direc == +1)) {    //frenar en uno de los bordes
      this.direc = 0;
      this.getFBody().setStatic(true);
    }
    if (this.direc == 0) {
      this.tiempoMov++;
      float delayFixed = this.delayMov*frameRate;
      if ((this.tiempoMov >= delayFixed/2) && !this.bombaLanzada) {      //lanzar bomba
        this.lanzarBomba();
      }
      if ((this.tiempoMov >= delayFixed) && this.bombaLanzada) {        //volver a moverse en dirección contraria
        if (bordeIzq) {
          this.direc = +1;
        }
        if (bordeDer) {
          this.direc = -1;
        }
        this.getFBody().setStatic(false);

        this.tiempoMov = 0;
        this.bombaLanzada = false;
      }
    }
  }

  void lanzarBomba() {
    int oculta = -1;
    for (int i=0; i<bombas.size(); i++) {
      if ((bombas.get(i).explotada) && (oculta == -1)) {       //buscar bombas que ya hayan explotado
        oculta = i;
      }
    }
    if (oculta != -1) {
      bombas.get(oculta).lanzar(this.posX, this.posY);          //si hay una bomba explotada, volver a lanzarla
    } else {
      bombas.add(new Bomba(this.posX, this.posY));            //si no hay bombas explotadas, lanzar una nueva
    }
    this.bombaLanzada = true;
  }
}





//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Bomba extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float radio, tiempo, delay;
  boolean explotada, lanzada;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Bomba(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;          //posición inicial
    this.posY = y;
    this.tam = 50;          //tamaño para las colisiones

    this.radio = this.tam*3;      //radio de la explosión
    this.explotada = this.lanzada = false;

    this.delay = 4;        //tiempo (en segundos) que tarda la bomba en explotar
    this.tiempo = 0;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(ConG, new FCircle(this.tam));

    this.getFBody().setDensity(0.1);
    this.getFBody().setRestitution(0.75);                      //rebotes
    this.getFBody().setDamping(0.025);
    this.getFBody().setStatic(false);

    this.lanzar(this.posX, this.posY);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    this.actualizarPos();        //actualizar posición

    if (!this.explotada) {
      push();                                    //mostrar imagen (cuando no explotó)
      fill(20, 100, 100);
      ellipse(this.posX, this.posY, this.tam, this.tam);          //ESTO TENDRÍA QUE SER LA IMAGEN DE LA BOMBA
      pop();
    }
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void lanzar(float x, float y) {
    this.getFBody().setPosition(x, y);
    this.getFBody().setStatic(false);
    this.getFBody().addImpulse(random(-1000, 1000), 0);    //aparecer con movimiento

    this.explotada = false;
    this.lanzada = true;
    this.tiempo = 0;
  }

  void cuentaAtras() {
    this.tiempo++;
    float delayFixed = this.delay*frameRate;
    if ((this.tiempo >= delayFixed) && (!this.explotada)) {
      this.explotar();
    }
  }

  void explotar() {
    this.explotada = true;
    this.lanzada = false;

    this.getFBody().setPosition(width/2, -height/2);      //--tira error con el Contact()
    this.getFBody().setStatic(true);      //--tira error con el Contact()
  }
}





//--------------------------------------------------------------------------------------------------------------------------------SPIDERMAN
class Spiderman extends Personaje {
  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Spiderman() {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = width/2;          //posición inicial
    this.posY = height/4;
    this.tam = 50;                //tamaño para la colisión

    this.vida = this.vidaMax = 3;      //máximo de vida

    this.delayGolpe = 3;                 //tiempo (en segundos) que tarda en poder recibir daño de nuevo
    this.tiempoGolpe = 0;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    this.crearCuerpo(ConG, new FBox(this.tam, this.tam));
    this.getFBody().setFriction(100);
    this.getFBody().setDensity(0.25);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    this.actualizarPos();        //actualizar posición

    push();                                    //mostrar imagen
    imagen(spidermanImg[0], this.posX, this.posY, this.tam*1.5);
    pop();

    push();                                        //mostrar vidas    //ESTO TENDRÍA QUE SER DE OTRA FORMA
    textSize(24);
    text(int(this.vida)+"/"+int(this.vidaMax), this.posX+50, this.posY-50);
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void saltar() {
    this.getFBody().addImpulse(0, -1000);        //saltar para engancharse si está parado
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
    this.crearCuerpo(SinG, new FBox(this.tamX, this.tamY));
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
    crearCuerpo(SinG, new FCircle(1));
    this.getFBody().setStatic(true);
    this.getFBody().setSensor(true);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    push();                                    //mostrar imagen
    imagen(ganchoImg, this.posX, this.posY, 50);
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
    }
  }
  void soltarJoint() {
    if (this.enganchado) {
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
