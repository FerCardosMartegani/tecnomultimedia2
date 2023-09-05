/**
 TP1 Comisión Lisandro - Fernando Cardos, Clara Rovarino, Elian Rodriguez, Luca Vasquez
 */


//--------------------------------------------------------------------------------------------------------------------------------DECLARACIÓN
//------------------------------------------------------------------------------------------------------------FÍSICA
import fisica.*;
FWorld mundo;

//------------------------------------------------------------------------------------------CUERPOS CON GRAVEDAD
ArrayList<FBody> cuerposG;
Spiderman spiderman;

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
  size(1200, 900);
  colorMode(HSB, 360, 100, 100, 100);
  imageMode(CENTER);
  rectMode(CENTER);

  pantalla = JUEGO;      //ESTO DEBERÍA ESTAR EN EL MENU
  debug = true;          //ESTO DEBERÍA ESTAR EN FALSE
  cursorD = 50;        //distancia mínima entre el cursor y el gancho para hacer el vínculo

  //------------------------------------------------------------------------------------------------------------IMÁGENES
  cursorImg = loadImage("telaraña.png");
  spidermanImg[0] = loadImage("spidermanPlaceholder.png");
  duendeImg[0] = loadImage("duendePlaceholder.png");
  ganchoImg = loadImage("ganchoPlaceholder.png");

  //------------------------------------------------------------------------------------------------------------FÍSICA
  Fisica.init(this);
  mundo = new FWorld();
  mundo.setEdges();

  //------------------------------------------------------------------------------------------CUERPOS CON GRAVEDAD
  cuerposG = new ArrayList<FBody>();
  spiderman = new Spiderman();

  //------------------------------------------------------------------------------------------CUERPOS SIN GRAVEDAD
  cuerposSinG = new ArrayList<FBody>();
  duende = new Duende();

  //------------------------------------------------------------------------PLATAFORMAS (posX, posY, tamX, tamY)
  plataformas = new ArrayList<Plataforma>();
  plataformas.add(new Plataforma(width/2, height/2+100, 200, 50));
  plataformas.get(0).rotar(45);
  plataformas.add(new Plataforma(width*4/6, height-200, 200, 10));
  plataformas.add(new Plataforma(width/2, height/3, 200, 10));

  //------------------------------------------------------------------------GANCHOS (posX, posY)
  ganchos = new ArrayList<Gancho>();
  ganchos.add(new Gancho(width*4/6, height/3));
  ganchos.add(new Gancho(width*2/6, height*2/4));

  //------------------------------------------------------------------------TELARAÑA
  tela = new Telarania();
}


//--------------------------------------------------------------------------------------------------------------------------------DRAW
void draw() {
  background(180);

  //------------------------------------------------------------------------------------------------------------CÁLCULOS GENERALES
  for (int i=0; i<cuerposG.size(); i++) {          //que no sean agarrables por las dudas
    cuerposG.get(i).setGrabbable(false);
  }
  for (int i=0; i<cuerposSinG.size(); i++) {
    cuerposSinG.get(i).setGrabbable(false);
  }

  //------------------------------------------------------------------------------------------ACTUALIZAR CURSOR
  cursorX = mouseX;
  cursorY = mouseY;
  cursorT = 75;                      //TAMAÑO DEL CURSOR


  //------------------------------------------------------------------------------------------------------------PANTALLAS
  //------------------------------------------------------------------------------------------MENÚ
  if (pantalla == MENU) {
    background(45, 75, 75);    //**ACÁ TENDRÍA QUE ESTAR LA IMAGEN DEL FONDO
  }
  //------------------------------------------------------------------------------------------JUEGO
  else if (pantalla == JUEGO) {
    background(200, 50, 50);    //**ACÁ TENDRÍA QUE ESTAR LA IMAGEN DEL FONDO

    mundo.step();
    mundo.draw();

    tela.actualizarJoint();
    tela.dibujar();

    spiderman.dibujar();
    
    duende.mover();
    duende.dibujar();

    for (int i=0; i<plataformas.size(); i++) {
      plataformas.get(i).dibujar();
    }
    for (int i=0; i<ganchos.size(); i++) {
      ganchos.get(i).dibujar();
    }
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
    text(pantalla, 25, 25);

    for (int i=0; i<cuerposG.size(); i++) {
      cuerposG.get(i).setStroke(0);
    }
    for (int i=0; i<cuerposSinG.size(); i++) {
      cuerposSinG.get(i).setStroke(0);
    }
    println("mouse: "+mouseX+" ; "+mouseY);
  } else {
    for (int i=0; i<cuerposG.size(); i++) {
      cuerposG.get(i).setNoStroke();
      cuerposG.get(i).setNoFill();
    }
    for (int i=0; i<cuerposSinG.size(); i++) {
      cuerposSinG.get(i).setNoStroke();
      cuerposSinG.get(i).setNoFill();
    }
  }
}

//--------------------------------------------------------------------------------------------------------------------------------COLISIONES
void contactStarted(FContact contacto){
  FBody cuerpo1 = contacto.getBody1();
  FBody cuerpo2 = contacto.getBody2();
  
  if(((cuerpo1 == spiderman.getFBody()) && (cuerpo2 == duende.getFBody())) || ((cuerpo2 == spiderman.getFBody()) && (cuerpo1 == duende.getFBody()))){
    println("golpe!");
  }
}


//--------------------------------------------------------------------------------------------------------------------------------FUNCIONES AUXILIARES
float nuevoAlto(PImage img, float ancho) {    //mantener proporción de imagen
  return ancho*img.height/img.width;
}


//--------------------------------------------------------------------------------------------------------------------------------DEBUG
void mouseClicked() {
  tela.aplicarJoint();          //** ESTO TENDRÍA QUE ACTIVARSE CON EL OSC 
}
void keyPressed() {
  if (key == ' ') {
    debug = !debug;
  }                  //ESPACIO para activar/desactivar el debug

  if (keyCode == LEFT) {
    pantalla--;
  }            //FLECHAS IZQUIERDA/DERECHA para pasar entre pantallas
  if (keyCode == RIGHT) {
    pantalla++;
  }
  pantalla = constrain(pantalla, 0, 3);
}
