//--------------------------------------------------------------------------------------------------------------------------------BOTONES
class Boton {
  //------------------------------------------------------------------------------------------------------------DECLARACIÓN
  float posX, posY, tamX, tamY;
  int link;
  boolean clicable;
  PImage img;


  //------------------------------------------------------------------------------------------------------------CONSTRUCTOR
  Boton(float x, float y, int l) {    //(posX, posY, tamX, tamY, link)  FALTA PARÁMETRO PARA LA IMAGEN
    this.link = l;    //a dónde lleva
    this.img = botonesImg[this.link];

    this.posX = x;    //posición
    this.posY = y;
    this.tamX = this.img.width;    //tamaño
    this.tamY = this.img.height;

    this.clicable = false;
  }


  //------------------------------------------------------------------------------------------------------------MÉTODOS

  //------------------------------------------------------------------------------------------DIBUJAR
  void dibujar() {
    push();
    image(this.img, this.posX, this.posY);
    pop();

    if (debug) {
      push();
      fill(map(this.link, 0, 3, 0, 360), 50, 50);
      rect(this.posX, this.posY, this.tamX, this.tamY, this.tamY/2);
      pop();
    }
  }


  //------------------------------------------------------------------------------------------ACCIONES
  void habilitar() {
    boolean hoverX = ((cursorX > this.posX-this.tamX/2) && (cursorX < this.posX+this.tamX/2));
    boolean hoverY = ((cursorY > this.posY-this.tamY/2) && (cursorY < this.posY+this.tamY/2));
    if (hoverX && hoverY) {
      this.clicable = true;
    }
  }

  void clic() {
    if (this.clicable) {
      //clicBoton.play();
      
      pantalla = this.link;      //ir a la pantalla del botón y reiniciar juego
      etapasTuto = 0;

      tela.soltarJoint();
      spiderman.reset();
      duende.reset();
      for (int i=0; i<bombas.size(); i++) {
        bombas.get(i).explotar();
      }
    }

    this.clicable = false;
  }
}
