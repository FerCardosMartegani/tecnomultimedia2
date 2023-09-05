//--------------------------------------------------------------------------------------------------------------------------------DUENDE
class Duende {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tam, direc, vida, vidaMax, margen;
  int index;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Duende() {
    this.posX = width/2;
    this.posY = height/8;
    this.tam = 75;
    this.margen = width/8;
    this.direc = +1;
    
    this.vida = this.vidaMax = 100;
    
    cuerposSinG.add(new FCircle(this.tam));
    this.index = cuerposSinG.size()-1;
    this.getFBody().setPosition(this.posX, this.posY);
    
    mundo.add(getFBody());
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    this.posX = this.getFBody().getX();
    this.posY = this.getFBody().getY();

    push();
    float nuevoAncho = this.tam*1.5;
    image(duendeImg[0], this.posX, this.posY, nuevoAncho, nuevoAlto(duendeImg[0], nuevoAncho));
    pop();
  }
  
  void mover(){
    this.getFBody().addForce(0,mundo.getGravity().y);
    
    this.getFBody().setVelocity(this.direc*200, 0);
    if((this.posX < 0+this.margen) || (this.posX > width-this.margen)){
      this.direc = -this.direc;      
    }
  }
  
  FBody getFBody() {
    return cuerposSinG.get(this.index);
  }
}


//--------------------------------------------------------------------------------------------------------------------------------SPIDERMAN
class Spiderman {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tam, vida, vidaMax;
  int index;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Spiderman() {
    this.posX = width/2;
    this.posY = height/4;
    this.tam = 50;
    
    this.vida = this.vidaMax = 100;

    cuerposG.add(new FBox(this.tam, this.tam));
    this.index = cuerposG.size()-1;
    this.getFBody().setName("Spiderman");
    this.getFBody().setPosition(this.posX, this.posY);
    this.getFBody().setFriction(100);

    mundo.add(getFBody());
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    this.posX = this.getFBody().getX();
    this.posY = this.getFBody().getY();

    push();
    float nuevoAncho = this.tam*1.5;
    image(spidermanImg[0], this.posX, this.posY, nuevoAncho, nuevoAlto(spidermanImg[0], nuevoAncho));
    pop();
  }

  void saltar() {
    this.getFBody().addImpulse(0, -2000);        //saltar para engancharse si está parado
  }

  FBody getFBody() {
    return cuerposG.get(this.index);
  }
  boolean cayendo() {
    return ((this.getFBody().getVelocityY()) > 1);      //si ya dejó de saltar, está parado o cayendo
  }
  boolean quieto() {
    return (abs(this.getFBody().getVelocityY()) < 1);      //si ya dejó de saltar, está parado o cayendo
  }
  boolean puedeEnganchar() {
    return (this.quieto() || this.cayendo());      //si está quieto o cayendo, se puede enganchar
  }
}


//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Plataforma {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tamX, tamY, rot;
  int index;
  PImage img;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Plataforma(float x, float y, float tx, float ty) {      //FALTA AÑADIR UN PARÁMETRO PARA LA IMAGEN
    this.posX = x;
    this.posY = y;
    this.tamX = tx;
    this.tamY = ty;
    this.rot = radians(0);
    //this.img = i;


    cuerposSinG.add(new FBox(this.tamX, this.tamY));
    this.index = cuerposSinG.size()-1;
    cuerposSinG.get(this.index).setPosition(this.posX, this.posY);
    cuerposSinG.get(this.index).setStatic(true);

    mundo.add(cuerposSinG.get(this.index));
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    push();
    translate(this.posX, this.posY);
    rotate(this.rot);
    fill(360, 25);
    rect(0, 0, this.tamX, this.tamY);        //ESTO TENDRÍA QUE SER ALGUNA IMAGEN
    pop();

    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("p: "+this.index, this.posX, this.posY);    //mostrar índice
      pop();
    }
  }

  void rotar(float r) {
    push();
    this.rot = radians(r);
    cuerposSinG.get(this.index).setRotation(this.rot);
    pop();
  }

  FBody getFBody() {
    return cuerposG.get(this.index);
  }
}


//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Gancho {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY;
  int index;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Gancho(float x, float y) {
    this.posX = x;
    this.posY = y;

    cuerposSinG.add(new FCircle(10));
    this.index = cuerposSinG.size()-1;
    cuerposSinG.get(this.index).setPosition(this.posX, this.posY);
    cuerposSinG.get(this.index).setStatic(true);

    mundo.add(cuerposSinG.get(this.index));
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
    push();
    float ancho = 50;
    image(ganchoImg, this.posX, this.posY, ancho, nuevoAlto(ganchoImg, ancho));
    pop();

    if (debug) {
      push();
      fill(0);
      textAlign(CENTER, CENTER);
      text("g: "+this.index, this.posX, this.posY);    //mostrar índice

      noFill();
      ellipse(this.posX, this.posY, cursorD*2, cursorD*2);
      pop();
    }
  }

  FBody getFBody() {
    return cuerposSinG.get(this.index);
  }
}


//--------------------------------------------------------------------------------------------------------------------------------BOMBAS
class Bomba {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY;
  int index;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Bomba() {
    //...
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS
  void dibujar() {
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
