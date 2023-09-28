//--------------------------------------------------------------------------------------------------------------------------------COMPORTAMIENTO COMPARTIDO
class FBodyPlus {

  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tamX, tamY, tam, posXog, posYog;
  int bodyIndex;
  int plusIndex;

  boolean conGravedad;
  boolean SinG = false;
  boolean ConG = true;


  //------------------------------------------------------------------------------------------------------------"CONSTRUCTOR"
  void crearCuerpo(boolean G, FBody cuerpo) {        //agregar nuevo cuerpo con o sin gravedad
    this.conGravedad = G;
    this.getArray().add(cuerpo);
    this.bodyIndex = getArray().size()-1;

    this.getFBody().setPosition(this.posX, this.posY);
    mundo.add(this.getFBody());
  }


  //------------------------------------------------------------------------------------------------------------ACCIONES
  void actualizarPos() {
    this.posX = this.getFBody().getX();        //actualizar posición
    this.posY = this.getFBody().getY();
  }

  boolean caerDelMundo() {
    return ((this.posX <= 0) || (this.posX >= width) || (this.posY >= height));
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
    return getArray().get(this.bodyIndex);      //acceder al cuerpo físico
  }

  void resetPos() {
    this.getFBody().setPosition(this.posXog, this.posYog);
    this.getFBody().setRotation(radians(0));
    this.getFBody().setVelocity(0, 0);
    this.getFBody().setAngularVelocity(0);
  }
}

class Personaje extends FBodyPlus {
  int vida, vidaMax;
  float tiempoGolpe, delayGolpe;
  boolean golpeado;
  int sprite, mirar;
  int IZQ = 0;
  int DER = 1;

  void recibirGolpe() {
    if (!this.golpeado) {
      if (this.getFBody() == duende.getFBody()) {
        golpeDuende.play();
      } else if (this.getFBody() == spiderman.getFBody()) {
        golpeSpiderman.play();
      }

      this.golpeado = true;                    //recibir golpe
      this.vida--;
    }
  }
  void cooldown() {
    if (this.golpeado) {
      this.tiempoGolpe++;
      float delayFixed = this.delayGolpe*frameRate;            //breve tiempo de ser invulnerable tras un golpe
      if (this.tiempoGolpe >= delayFixed) {
        this.golpeado = false;
        this.tiempoGolpe = 0;
      }
    }
  }

  void resetVidas() {
    this.vida = this.vidaMax;
    this.tiempoGolpe = 0;
    this.golpeado = false;
  }
}





//--------------------------------------------------------------------------------------------------------------------------------DUENDE
class Duende extends Personaje {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float vel, direc, direcOg, margen, tiempoMov, delayMov;
  boolean bombaLanzada;

  int IDLE = 0;
  int LANZAR = 1;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Duende(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = this.posXog = x;                  //posición inicial
    this.posY = this.posYog = y;
    this.tam = 75;                        //tamaño para la colisión

    this.vel = 200;              //velocidad

    this.margen = width/8;          //distancia a los bordes donde frena para lanzar bombas
    this.direc = direcOg = -1;                  //dirección a la que arranca mirando (-1,1)

    this.vida = this.vidaMax = 3;        //máximo de vida

    this.delayMov = 2;                    //tiempo (en segundos) que dura la pausa para lanzar bombas
    this.tiempoMov = 0;

    this.delayGolpe = 3;                 //tiempo (en segundos) que tarda en poder recibir daño de nuevo
    this.tiempoGolpe = 0;

    this.bombaLanzada = this.golpeado = false;

    this.sprite = IDLE;
    this.mirar = IZQ;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    this.crearCuerpo(SinG, new FCircle(this.tam));
    this.getFBody().setSensor(true);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    this.actualizarPos();

    push();
    if (!this.bombaLanzada) {                //cambiar imagen
      this.sprite = IDLE;
      if (this.direc == -1) {
        this.mirar = IZQ;
      } else if (this.direc == +1) {
        this.mirar = DER;
      }
    } else {
      this.sprite = LANZAR;
    }
    if (this.golpeado) {      //enrojecer por el daño
      tint(0, 100, 100);
    }
    float vx=0, vy=0;
    float delayFixed = this.delayGolpe*frameRate;            //sacudir un poco al recibir golpe
    if ((this.golpeado) && (this.tiempoGolpe <= delayFixed/4)) {
      vx = random(-5, 5);
      vy = random(-5, 5);
    }

    imagen(duendeImg[this.sprite][this.mirar], this.posX+vx, this.posY+vy, this.tam*1.5);         //mostrar imagen

    imagen(duendeVida[constrain(this.vida-1, 0, duendeVida.length)], width*1/10+vx, height*0.5/10+vy, width*2/10);
    pop();

    if (debug) {
      push();                                        //mostrar vidas (rústico)
      textSize(24);
      text(int(this.vida)+"/"+int(this.vidaMax), this.posX+50, this.posY-50);
      pop();
    }
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void mover() {
    this.getFBody().setVelocity(this.getFBody().getVelocityX(), (this.posYog-this.posY)*10);    //mantener en la misma línea

    this.getFBody().setVelocity(this.direc*this.vel, this.getFBody().getVelocityY());      //desplazar izquierda y derecha

    if ((this.posX < width) && (this.posX > 0)) {
      this.getFBody().setSensor(false);
    }

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
        if (!this.golpeado) {
          this.lanzarBomba();
        }
      }
      if ((this.tiempoMov >= delayFixed)) {        //volver a moverse en dirección contraria
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

  void reset() {
    this.direc = this.direcOg;
    this.tiempoMov = 0;
    this.getFBody().setStatic(false);
    this.bombaLanzada = false;

    this.resetVidas();
    this.resetPos();

    this.getFBody().setSensor(true);
  }
}





//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Bomba extends FBodyPlus {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float tiempo, delay1, delay2;
  boolean explotada, lanzada, consumida;
  int sprite;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Bomba(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;          //posición inicial
    this.posY = y;
    this.tam = 50;          //tamaño para las colisiones

    this.explotada = this.lanzada = this.consumida = false;

    this.delay1 = 4;                          //tiempo (en segundos) que tarda la bomba en explotar
    this.delay2 = this.delay1+1;               //tiempo (en segundos) que tarda la bomba en desaparecer
    this.tiempo = 0;

    this.plusIndex = bombas.size()-1;

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

    push();                                    //mostrar imagen (cuando no explotó)
    translate(this.posX, this.posY);
    rotate(this.getFBody().getRotation());
    if (this.explotada) {
      if (!this.consumida) {
        tint(360, map(this.tiempo, this.delay1*frameRate, this.delay2*frameRate, 100, 0));
        image(bombaImg[1], random(-5, 5), random(-5, 5));
      }
    } else {
      image(bombaImg[0], 0, 0);
    }
    pop();
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void lanzar(float x, float y) {
    this.getFBody().setPosition(x, y);
    this.getFBody().setStatic(false);
    this.getFBody().setSensor(false);
    this.getFBody().addImpulse(random(-1000, 1000), 0);    //aparecer con movimiento

    this.explotada = false;
    this.lanzada = true;
    this.consumida = false;
    this.tiempo = 0;
  }

  void cuentaAtras() {
    this.tiempo++;
    float delay1Fixed = (this.delay1*frameRate);
    if (((this.tiempo >= delay1Fixed-1) && (!this.explotada)) || this.caerDelMundo()) {
      this.explotar();
    }
    float delay2Fixed = (this.delay2*frameRate);
    if (((this.tiempo >= delay2Fixed-1) && (!this.consumida))) {
      this.consumida = true;
    }
  }

  void explotar() {
    if (!this.explotada) {
      if (this.lanzada) {
        explosion.play();
      }

      this.explotada = true;
      this.lanzada = false;
      this.tiempo = this.delay1*frameRate;

      this.getFBody().setSensor(true);
      this.getFBody().setStatic(true);      //--tira error con el Contact()
    }
  }

  void reset() {
    this.explotada = this.lanzada = this.consumida = false;
    this.tiempo = 0;
    this.getFBody().setStatic(true);
    this.getFBody().setPosition(-this.tam*2, -this.tam*2);
  }
}





//--------------------------------------------------------------------------------------------------------------------------------SPIDERMAN
class Spiderman extends Personaje {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  int IDLE = 0;
  int APUNTAR = 1;
  int SALTAR = 2;
  int COLGAR = 3;
  int CAER = 4;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Spiderman(float x, float y) {
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = this.posXog = x;                  //posición inicial
    this.posY = this.posYog = y;
    this.tam = 50;                //tamaño para la colisión

    this.vida = this.vidaMax = 3;      //máximo de vida

    this.delayGolpe = 3;                 //tiempo (en segundos) que tarda en poder recibir daño de nuevo
    this.tiempoGolpe = 0;

    this.sprite = IDLE;
    this.mirar = DER;

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    this.crearCuerpo(ConG, new FBox(this.tam, this.tam));
    this.getFBody().setFriction(100);
    this.getFBody().setDensity(0.25);
    this.getFBody().setRotatable(false);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    this.actualizarPos();        //actualizar posición

    push();
    if (cursorX < this.posX) {      //espejar imagen mirando al cursor
      this.mirar = IZQ;
    } else {
      this.mirar = DER;
    }
    if (this.golpeado) {      //enrojecer por el daño
      tint(0, 100, 100);
    }

    if (this.quieto()) {
      this.sprite = IDLE;
    }
    if (this.quieto() && tela.apuntando) {
      this.sprite = APUNTAR;
    }
    if ((tela.enganchado && !tela.colgado) || this.cayendo()) {
      this.sprite = SALTAR;
    }
    if (tela.colgado) {
      this.sprite = COLGAR;
    }
    float vx=0, vy=0;
    float delayFixed = this.delayGolpe*frameRate;            //sacudir un poco al recibir golpe
    if ((this.golpeado) && (this.tiempoGolpe <= delayFixed/4)) {
      vx = random(-5, 5);
      vy = random(-5, 5);
    }

    imagen(spidermanImg[this.sprite][this.mirar], this.posX+vx, this.posY+vy, this.tam*1.5);             //mostrar imagen

    imagen(spidermanVida[constrain(this.vida-1, 0, spidermanVida.length)], width*9/10+vx, height*0.5/10+vy, width*2/10);
    pop();

    if (debug) {
      push();                                        //mostrar vidas    //ESTO TENDRÍA QUE SER DE OTRA FORMA
      textSize(24);
      text(int(this.vida)+"/"+int(this.vidaMax), this.posX+50, this.posY-50);
      pop();
    }
  }

  //------------------------------------------------------------------------------------------ACCIONES
  void saltar() {
    this.getFBody().addImpulse(0, -1000);        //saltar para engancharse si está parado
  }

  void reset() {
    this.resetVidas();
    this.resetPos();
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
  boolean atravesable;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Plataforma(float x, float y, float tx, float ty, float r, boolean a) {      //FALTA AÑADIR UN PARÁMETRO PARA LA IMAGEN
    //------------------------------------------------------------------------------------------PROPIEDADES INICIALES
    this.posX = x;            //posición inicial
    this.posY = y;
    this.tamX = tx;            //tamaño para la colisión
    this.tamY = ty;
    this.rot = radians(r);      //rotación

    this.atravesable = a;

    this.plusIndex = plataformas.size();

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
    //rect(0, 0, this.tamX, this.tamY);        //ESTO TENDRÍA QUE SER ALGUNA IMAGEN
    pop();

    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("body: "+this.bodyIndex+"\nplat: "+this.plusIndex, this.posX, this.posY);      //mostrar índice
      pop();
    }
  }


  //------------------------------------------------------------------------------------------ACCIONES
  void cambiarContacto() {
    if (this.atravesable) {
      if (spiderman.posY < (this.posY-this.tamY/2)) {
        this.getFBody().setSensor(false);
      } else {
        this.getFBody().setSensor(true);
      }
    } else {
      this.getFBody().setSensor(false);
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

    this.plusIndex = ganchos.size();

    //------------------------------------------------------------------------------------------CUERPO FÍSICO
    crearCuerpo(SinG, new FCircle(1));
    this.getFBody().setStatic(true);
    this.getFBody().setSensor(true);
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("body: "+this.bodyIndex+"\ngan: "+this.plusIndex, this.posX, this.posY);        //mostrar índice

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
  boolean enganchado, colgado, apuntando;
  FDistanceJoint telaJoint;

  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Telarania() {
    this.enganchado = this.colgado = this.apuntando = false;
    distancias = new float[ganchos.size()];
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    if ((distancias[this.index] <= cursorD) && !this.enganchado) {    //indicar posible telaraña
      this.apuntando = true;
      push();
      stroke(360, 25);
      strokeWeight(5);
      strokeCap(SQUARE);
      line(ganchos.get(this.index).posX, ganchos.get(this.index).posY, spiderman.posX, spiderman.posY);
      pop();
    } else {
      this.apuntando = false;
    }
    if (this.enganchado) {            //mostrar telaraña lanzada
      this.apuntando = false;
      push();
      stroke(360);
      strokeWeight(5);
      strokeCap(SQUARE);
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
        lanzarTela.play();

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
        this.telaJoint.removeFromWorld();

        if (etapasTuto == 0) {
          etapasTuto = 1;        //avanzar tutorial
        }
      }

      this.enganchado = this.colgado = false;
    }
  }

  void actualizarJoint() {
    this.ubicarGanchos();

    if (this.enganchado && !this.colgado && (spiderman.puedeEnganchar())) {
      this.telaJoint = new FDistanceJoint(spiderman.getFBody(), ganchos.get(this.index).getFBody());
      this.telaJoint.setNoStroke();
      this.telaJoint.addToWorld(mundo);

      this.colgado = true;
    }
  }
}
