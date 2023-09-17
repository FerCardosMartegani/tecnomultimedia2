/*
 TP1 Comisión Lisandro - Fernando Cardos, Clara Rovarino, Elian Rodriguez
 */


//--------------------------------------------------------------------------------------------------------------------------------DECLARACIÓN

//------------------------------------------------------------------------------------------------------------FÍSICA
import fisica.*;
FWorld mundo;

//------------------------------------------------------------------------------------------CUERPOS CON GRAVEDAD
ArrayList<FBody> cuerposG;
Spiderman spiderman;
ArrayList<Bomba> bombas;

float gravedad;

//------------------------------------------------------------------------------------------CUERPOS SIN GRAVEDAD
ArrayList<FBody> cuerposSinG;
Duende duende;
ArrayList<Plataforma> plataformas;
ArrayList<Gancho> ganchos;

Telarania tela;

//------------------------------------------------------------------------------------------------------------CONTROL
int pantalla;
boolean debug, clic;
float cursorX, cursorY, cursorT, cursorD;

//------------------------------------------------------------------------------------------------------------IMÁGENES
PImage cursorImg, ganchoImg;
PImage[] spidermanImg = new PImage[1];
PImage[] duendeImg = new PImage[1];

//------------------------------------------------------------------------------------------------------------CONSTANTES/NOMBRES
int MENU = 0;
int JUEGO = 1;
int GANAR = 2;
int PERDER = 3;


//--------------------------------------------------------------------------------------------------------------------------------SETUP
void setup() {
  size(960, 720);
  colorMode(HSB, 360, 100, 100, 100);
  imageMode(CENTER);
  rectMode(CENTER);

  pantalla = JUEGO;      //ESTO DEBERÍA ESTAR EN EL MENU
  debug = false;          //ESTO DEBERÍA ESTAR EN FALSE

  cursorD = 50;        //distancia mínima entre el cursor y el gancho para hacer el joint
  cursorT = 75;        //tamaño del cursor

  //------------------------------------------------------------------------------------------------------------IMÁGENES
  cursorImg = loadImage("telaraña.png");
  spidermanImg[0] = loadImage("spidermanPlaceholder.png");
  duendeImg[0] = loadImage("duendePlaceholder.png");
  ganchoImg = loadImage("ganchoPlaceholder.png");

  //------------------------------------------------------------------------------------------------------------FÍSICA
  Fisica.init(this);
  mundo = new FWorld();
  mundo.setEdges();
  mundo.setGravity(0, 0);

  //------------------------------------------------------------------------------------------CUERPOS CON GRAVEDAD
  cuerposG = new ArrayList<FBody>();
  spiderman = new Spiderman();
  bombas = new ArrayList<Bomba>();

  //------------------------------------------------------------------------------------------CUERPOS SIN GRAVEDAD
  cuerposSinG = new ArrayList<FBody>();
  duende = new Duende();

  //------------------------------------------------------------------------PLATAFORMAS (posX, posY, tamX, tamY, rot)
  plataformas = new ArrayList<Plataforma>();
  plataformas.add(new Plataforma(width/2, height/2+100, 200, 50, 45));
  plataformas.add(new Plataforma(width*4/6, height-200, 200, 10, 0));

  plataformas.add(new Plataforma(spiderman.posX, spiderman.posY+50, 200, 10, 0));
  plataformas.add(new Plataforma(width-100, spiderman.posY+50, 50, 20, -60));

  //------------------------------------------------------------------------GANCHOS (posX, posY)
  ganchos = new ArrayList<Gancho>();
  ganchos.add(new Gancho(width*4/6, height/3));
  ganchos.add(new Gancho(width*2/6, height*2/4));

  tela = new Telarania();

  //------------------------------------------------------------------------PROPIEDADES GENERALES
  for (int i=0; i<cuerposG.size(); i++) {        //que no sean agarrables
    cuerposG.get(i).setGrabbable(false);
  }
  for (int i=0; i<cuerposSinG.size(); i++) {
    cuerposSinG.get(i).setGrabbable(false);
  }

  //------------------------------------------------------------------------------------------------------------OSC
  configurarOsc();
}


//--------------------------------------------------------------------------------------------------------------------------------DRAW
void draw() {
  background(180);

  calcularOsc();


  //------------------------------------------------------------------------------------------------------------PANTALLAS

  //------------------------------------------------------------------------------------------MENÚ
  if (pantalla == MENU) {
    background(45, 75, 75);    //**ACÁ TENDRÍA QUE ESTAR LA IMAGEN DEL FONDO
    push();
    textSize(64);
    textAlign(CENTER, CENTER);
    text("Spider-mano :0", width/2, height/2);
    pop();
  }
  //------------------------------------------------------------------------------------------JUEGO
  else if (pantalla == JUEGO) {
    background(200, 50, 50);    //**ACÁ TENDRÍA QUE ESTAR LA IMAGEN DEL FONDO

    mundo.step();
    mundo.draw();

    for (int i=0; i<cuerposG.size(); i++) {              //gravedad falsa (F=m*g)
      gravedad = (cuerposG.get(i).getMass() * 750);
      cuerposG.get(i).addForce(0, gravedad);
    }

    tela.actualizarJoint();
    tela.dibujar();

    spiderman.recuperar();
    spiderman.dibujar();

    duende.mover();
    duende.recuperar();
    duende.dibujar();

    for (int i=0; i<plataformas.size(); i++) {
      plataformas.get(i).dibujar();
    }
    for (int i=0; i<ganchos.size(); i++) {
      ganchos.get(i).dibujar();
    }
    for (int i=0; i<bombas.size(); i++) {
      bombas.get(i).dibujar();
      bombas.get(i).cuentaAtras();
    }
    golpeBomba();                                  //colisión con las bombas (con Contact() tiraba error)

    if (spiderman.vida <= 0) {        //perder cuando Spiderman se queda sin vidas
      pantalla=PERDER;
    }
    if (duende.vida <= 0) {        //ganar cuando el Duende se queda sin vidas
      pantalla=GANAR;
    }
  }
  //------------------------------------------------------------------------------------------GANAR
  else if (pantalla == GANAR) {
    background(230, 50, 50);
    push();
    textSize(64);
    text("UwU", width/2, height/2);
    pop();
  }
  //------------------------------------------------------------------------------------------PERDER
  else if (pantalla == PERDER) {
    background(0, 50, 50);
    push();
    textSize(64);
    text("F", width/2, height/2);
    pop();
  }


  //------------------------------------------------------------------------------------------------------------DIBUJOS GENERALES

  //------------------------------------------------------------------------------------------DIBUJAR CURSOR
  push();
  translate(cursorX, cursorY);
  rotate(radians(frameCount));
  tint(360);
  image(cursorImg, 0, 0, cursorT, cursorT);
  pop();

  //------------------------------------------------------------------------------------------DEBUG
  if (debug) {
    textAlign(LEFT, CENTER);
    textSize(20);
    text(pantalla, 25, 25);                                            //mostrar pantalla en pantalla (?

    for (int i=0; i<cuerposG.size(); i++) {                    //hacer visibles los FBody
      cuerposG.get(i).setStroke(0);
    }
    for (int i=0; i<cuerposSinG.size(); i++) {
      cuerposSinG.get(i).setStroke(0);
    }

    debugOsc();

    println("cursor: "+cursorX+" ; "+cursorY);                //mostrar coords del cursor
  } else {
    for (int i=0; i<cuerposG.size(); i++) {                //ocultar los FBody
      cuerposG.get(i).setNoStroke();
      cuerposG.get(i).setNoFill();
    }
    for (int i=0; i<cuerposSinG.size(); i++) {
      cuerposSinG.get(i).setNoStroke();
      cuerposSinG.get(i).setNoFill();
    }
  }
}

void imagen(PImage img, float x, float y, float ancho) {
  image(img, x, y, ancho, nuevoAlto(img, ancho));
}
float nuevoAlto(PImage img, float ancho) {    //mantener proporción de imagen
  return ancho*img.height/img.width;
}


//--------------------------------------------------------------------------------------------------------------------------------COLISIONES
void contactStarted(FContact contacto) {
  if (contactados(contacto, spiderman, duende) && !duende.golpeado) {            //colisión entre Spiderman y Duende
    println("golpe!");
    duende.recibirGolpe();
  }
  /*-------------------------------------------------tiraba error
   for (int i=0; i<bombas.size(); i++) {
   if (contactados(contacto, spiderman, bombas.get(i)) && !bombas.get(i).explotada) {            //colisión entre Spiderman y bomba
   println("boom!");
   bombas.get(i).explotar();
   }
   }
   */
}
void golpeBomba() {                                                                              //colisión entre Spiderman y bomba
  for (int i=0; i<bombas.size(); i++) {
    float dist = dist(bombas.get(i).posX, bombas.get(i).posY, spiderman.posX, spiderman.posY);
    float min = (bombas.get(i).tam + spiderman.tam);
    if (dist < min) {
      println("boom!");
      bombas.get(i).explotar();
      spiderman.recibirGolpe();
    }
  }
}
boolean contactados(FContact c, FBodyPlus c1, FBodyPlus c2) {      //función que simplifica las condiciones de colisión
  FBody cuerpo1 = c.getBody1();
  FBody cuerpo2 = c.getBody2();
  FBody plus1 = c1.getFBody();
  FBody plus2 = c2.getFBody();

  return (((cuerpo1 == plus1) && (cuerpo2 == plus2)) || ((cuerpo2 == plus1) && (cuerpo1 == plus2)));
}


//--------------------------------------------------------------------------------------------------------------------------------RESET
void reset() {
}


//--------------------------------------------------------------------------------------------------------------------------------DEBUG
void mousePressed() {
  tela.aplicarJoint();          //** ESTO TENDRÍA QUE ACTIVARSE CON EL OSC
}
void mouseReleased() {
  tela.soltarJoint();
}
void keyPressed() {
  if (key == ' ') {                  //ESPACIO para activar/desactivar el debug
    debug = !debug;
  }

  if (keyCode == LEFT) {            //FLECHAS IZQUIERDA/DERECHA para pasar entre pantallas
    pantalla--;
  }
  if (keyCode == RIGHT) {
    pantalla++;
  }
  pantalla = constrain(pantalla, 0, 3);
}
