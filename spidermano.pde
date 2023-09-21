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
boolean debug, usarMouse;
int pantalla;
float tutorial, cursorX, cursorY, cursorT, cursorD;
Boton[] botones;


//------------------------------------------------------------------------------------------------------------IMÁGENES
PImage cursorImg, titulo, victoria, derrota;
PImage[] fondoImg, bombaImg, botonesImg, spidermanVida, duendeVida;
PImage[][] spidermanImg, duendeImg;

//------------------------------------------------------------------------------------------------------------CONSTANTES/NOMBRES
int MENU = 0;
int JUEGO = 1;
int TUTO = 2;
int REJUGAR = 3;
int GANAR = 4;
int PERDER = 5;


//--------------------------------------------------------------------------------------------------------------------------------SETUP
void setup() {
  size(960, 720);
  colorMode(HSB, 360, 100, 100, 100);
  imageMode(CENTER);
  rectMode(CENTER);

  //------------------------------------------------------------------------------------------------------------IMÁGENES
  cursorImg = loadImage("telaraña.png");
  titulo = loadImage("titulo.png");

  fondoImg = new PImage[2];
  for (int i=0; i<fondoImg.length; i++) {
    fondoImg[i] = loadImage("fondo"+i+".png");
  }

  victoria = loadImage("cartelGanar.png");
  derrota = loadImage("cartelPerder.png");

  botonesImg = new PImage[4];
  for (int i=0; i<botonesImg.length; i++) {
    botonesImg[i] = loadImage("boton"+i+".png");
  }

  spidermanImg = new PImage[5][2];
  for (int i=0; i<spidermanImg.length; i++) {
    for (int j=0; j<2; j++) {
      spidermanImg[i][j] = loadImage("spiderman"+i+"-"+j+".png");
    }
  }
  spidermanVida = new PImage[3];
  for (int i=0; i<spidermanVida.length; i++) {
    spidermanVida[i] = loadImage("spidermanVida"+i+".png");
  }

  duendeImg = new PImage[2][2];
  for (int i=0; i<duendeImg.length; i++) {
    for (int j=0; j<2; j++) {
      duendeImg[i][j] = loadImage("duende"+i+"-"+j+".png");
    }
  }
  duendeVida = new PImage[3];
  for (int i=0; i<duendeVida.length; i++) {
    duendeVida[i] = loadImage("duendeVida"+i+".png");
  }

  bombaImg = new PImage[2];
  for (int i=0; i<bombaImg.length; i++) {
    bombaImg[i] = loadImage("bomba"+i+".png");
  }

  //------------------------------------------------------------------------------------------------------------CONTROL
  pantalla = MENU;
  tutorial = 0;
  debug = usarMouse = false;

  cursorD = 50;        //distancia mínima entre el cursor y el gancho para hacer el joint
  cursorT = 75;        //tamaño del cursor

  botones = new Boton[4];      //Boton(posX, posY, tamX, tamY, link)
  botones[MENU] = new Boton(width*5/10, height*6/10, MENU);
  botones[JUEGO] = new Boton(width*7/10, height*8/10, JUEGO);
  botones[TUTO] = new Boton(width*3/10, height*8/10, TUTO);
  botones[REJUGAR] = new Boton(width*7/10, height*8/10, REJUGAR);

  //------------------------------------------------------------------------------------------------------------FÍSICA
  Fisica.init(this);
  mundo = new FWorld();
  mundo.setGravity(0, 0);

  //------------------------------------------------------------------------------------------CUERPOS CON GRAVEDAD
  cuerposG = new ArrayList<FBody>();
  spiderman = new Spiderman(width*5/10, height*8/10);        //SPIDERMAN (posX, posY)
  bombas = new ArrayList<Bomba>();

  //------------------------------------------------------------------------------------------CUERPOS SIN GRAVEDAD
  cuerposSinG = new ArrayList<FBody>();
  duende = new Duende(width*13/10, height/8);      //DUENDE VERDE (posX, posY)

  //------------------------------------------------------------------------PLATAFORMAS (posX, posY, tamX, tamY, rot, sensor)
  plataformas = new ArrayList<Plataforma>();

  plataformas.add(new Plataforma(width*0/10, height*5.5/10, width*1/10, height*10/10, 0, false));    //paredes
  plataformas.add(new Plataforma(width*10/10, height*5.5/10, width*1/10, height*10/10, 0, false));

  plataformas.add(new Plataforma(width*5/10, height*9.5/10, width*3/10, height*1/10, 0, false));      //centro
  plataformas.add(new Plataforma(width*6/10, height*5.5/10, width*1.5/10, height*0.5/10, 0, true));

  plataformas.add(new Plataforma(width*2/10, height*8/10, width*1.5/10, height*0.5/10, 0, true));      //izquierda
  plataformas.add(new Plataforma(width*1/10, height*5.5/10, width*1.5/10, height*0.5/10, 0, true));

  plataformas.add(new Plataforma(width*8/10, height*7.5/10, width*1.5/10, height*0.5/10, 0, true));    //derecha
  plataformas.add(new Plataforma(width*9/10, height*5/10, width*1.5/10, height*0.5/10, 0, true));

  //------------------------------------------------------------------------GANCHOS (posX, posY)
  ganchos = new ArrayList<Gancho>();

  ganchos.add(new Gancho(width*3/10, height*4/10));        //izquierda
  ganchos.add(new Gancho(width*1.5/10, height*1.5/10));

  ganchos.add(new Gancho(width*7/10, height*3/10));        //derecha
  ganchos.add(new Gancho(width*8.5/10, height*1.5/10));

  ganchos.add(new Gancho(width*5.5/10, height*1/10));      //centro

  tela = new Telarania();

  //------------------------------------------------------------------------PROPIEDADES GENERALES
  for (int i=0; i<cuerposG.size(); i++) {        //que no sean agarrables
    cuerposG.get(i).setGrabbable(false);
  }
  for (int i=0; i<cuerposSinG.size(); i++) {
    cuerposSinG.get(i).setGrabbable(false);
  }

  //------------------------------------------------------------------------------------------------------------OSC
  setupOsc();
}


//--------------------------------------------------------------------------------------------------------------------------------DRAW
void draw() {
  calcularOsc();

  //------------------------------------------------------------------------------------------------------------PANTALLAS
  image(fondoImg[constrain(pantalla, MENU, JUEGO)], width/2, height/2);

  //------------------------------------------------------------------------------------------MENÚ
  if (pantalla == MENU) {
    image(titulo, width/2, height*4/10);
  }
  //------------------------------------------------------------------------------------------JUEGO
  else if ((pantalla == JUEGO) || (pantalla == TUTO) || pantalla == REJUGAR) {
    if ((tutorial == 0.1) && (spiderman.quieto())) {
      pantalla = JUEGO;
    }

    mundo.step();
    mundo.draw();

    for (int i=0; i<cuerposG.size(); i++) {              //gravedad falsa (F=m*g)
      gravedad = (cuerposG.get(i).getMass() * 750);
      cuerposG.get(i).addForce(0, gravedad);
    }

    tela.actualizarJoint();            //telaraña
    tela.dibujar();

    for (int i=0; i<plataformas.size(); i++) {                 //plataformas
      plataformas.get(i).dibujar();
      plataformas.get(i).cambiarContacto();
    }
    for (int i=0; i<ganchos.size(); i++) {                       //ganchos
      ganchos.get(i).dibujar();
    }
    for (int i=0; i<bombas.size(); i++) {                       //bombas
      bombas.get(i).dibujar();
      bombas.get(i).cuentaAtras();
      golpeBomba(i);                                  //colisión con las bombas (con Contact() tiraba error)
    }

    spiderman.cooldown();            //spiderman
    spiderman.dibujar();

    if (pantalla != TUTO) {
      duende.dibujar();
      duende.mover();                      //duende verde
      duende.cooldown();
    }

    if (spiderman.caerDelMundo()) {        //si spideran se cae del mundo...
      if (pantalla == TUTO) {
        spiderman.reset();            //...en el tuto, respawnea.
        tutorial = 0;
      } else {
        spiderman.vida = 0;          //...en el juego, muere.
      }
    }
    if (spiderman.vida <= 0) {        //perder cuando Spiderman se queda sin vidas o se cae del mundo
      pantalla=PERDER;
    }

    if (duende.vida <= 0) {        //ganar cuando el Duende se queda sin vidas
      pantalla=GANAR;
    }
  }
  //------------------------------------------------------------------------------------------GANAR
  else if (pantalla == GANAR) {
    push();
    fill(115, 80, 80, 80);
    noStroke();
    rect(width/2, height/2, width, height);
    pop();
    image(victoria, width/2, height*3/10);

    botones[MENU].dibujar();
    botones[MENU].habilitar();

    botones[JUEGO].dibujar();
    botones[JUEGO].habilitar();

    botones[TUTO].dibujar();
    botones[TUTO].habilitar();
  }
  //------------------------------------------------------------------------------------------PERDER
  else if (pantalla == PERDER) {
    push();
    fill(0, 60, 60, 80);
    noStroke();
    rect(width/2, height/2, width, height);
    pop();
    image(derrota, width/2, height*3/10);

    botones[MENU].dibujar();
    botones[MENU].habilitar();

    botones[REJUGAR].dibujar();
    botones[REJUGAR].habilitar();

    botones[TUTO].dibujar();
    botones[TUTO].habilitar();
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
    textAlign(LEFT, CENTER);                            //mostrar datos en pantlla
    textSize(20);
    text("pantalla: "+pantalla+"      Handpose: "+!usarMouse, 25, 25);

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
   if (contactados(contacto, spiderman, bombas.get(i)) && !bombas.get(i).explotada) {            //colisión entre Spiderman y bomba (tiraba error)
   println("boom!");
   bombas.get(i).explotar();
   }
   }
   */
}
void golpeBomba(int i) {                                                                              //colisión entre Spiderman y bomba
  float dist = dist(bombas.get(i).posX, bombas.get(i).posY, spiderman.posX, spiderman.posY);
  float r = (bombas.get(i).tam + spiderman.tam/2);
  if (dist < r) {
    println("boom!");
    bombas.get(i).explotar();
    spiderman.recibirGolpe();
  }
}
boolean contactados(FContact c, FBodyPlus c1, FBodyPlus c2) {      //función que simplifica las condiciones de colisión
  FBody cuerpo1 = c.getBody1();
  FBody cuerpo2 = c.getBody2();
  FBody plus1 = c1.getFBody();
  FBody plus2 = c2.getFBody();

  return (((cuerpo1 == plus1) && (cuerpo2 == plus2)) || ((cuerpo2 == plus1) && (cuerpo1 == plus2)));
}


//--------------------------------------------------------------------------------------------------------------------------------EFECTO CLIC
void hacerClic() {
  if (pantalla == MENU) {
    pantalla = TUTO;
  }

  tela.aplicarJoint();    //enganchar telaraña

  for (int i=0; i<botones.length; i++) {      //pulsar botón
    botones[i].clic();
  }
}
void soltarClic() {
  tela.soltarJoint();      //soltar telaraña
}


//--------------------------------------------------------------------------------------------------------------------------------DEBUG
void mousePressed() {          //clic para enganchar la telaraña
  if (usarMouse) {
    hacerClic();
  }
}
void mouseReleased() {          //soltar clic para soltar la telaraña
  if (usarMouse) {
    soltarClic();
  }
}
void keyPressed() {
  if (key == ' ') {                  //ESPACIO para activar/desactivar el debug
    debug = !debug;
  }
  if (key == 'm') {                  //M para activar/desactivar el mouse
    usarMouse = !usarMouse;
  }

  if (keyCode == LEFT) {            //FLECHAS IZQUIERDA/DERECHA para pasar entre pantallas
    pantalla--;
  }
  if (keyCode == RIGHT) {
    pantalla++;
  }
  pantalla = constrain(pantalla, 0, 3);
}
