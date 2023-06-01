class Dir_y_Vel {

  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor() {
    this.posX = 0;
    this.posY = 0;
    this.prevPosX;
    this.prevPosY;
    this.miDireccionX;
    this.miDireccionY;
    this.vel;
    this.miDireccionPolar;
  }


  //-------------------------------------------------------------------------------------CALCULADORA
  calcularTodo(mi_X, mi_Y) {
    this.prevPosX = this.posX;
    this.prevPosY = this.posY;
    this.posX = mi_X;
    this.posY = mi_Y;

    this.miDireccionX = this.posX - this.prevPosX;
    this.miDireccionY = this.posY - this.prevPosY;
    this.miDireccionPolar = degrees(atan2(this.posY - this.prevPosY, this.posX - this.prevPosX));

    this.vel = dist(this.posX, this.posY, this.prevPosX, this.prevPosY);
  }


  //-------------------------------------------------------------------------------------MÉTODOS GET
  velocidad() {
    return this.vel;
  }
  direccionX() {
    return this.miDireccionX;
  }
  direccionY() {
    return this.miDireccionY;
  }
  direccionPolar() {
    return this.miDireccionPolar;
  }

  
  //-------------------------------------------------------------------------------------DEBUGGER
  mostrarData() {
    push();
      textSize(24);
      fill(0);
      text("Velocidad: " + this.vel, 50, 50);
      text("Direccion X: " + this.miDireccionX, 50, 75);
      text("Direccion Y: " + this.miDireccionY, 50, 100);
      text("Direccion Polar: " + this.miDireccionPolar, 50, 125);
    pop();

    push();
      noFill();
      stroke(0);
      strokeWeight(3);
      translate(width / 2, height / 2);
      ellipse(0, 0, 100, 100);
      rotate(radians(this.miDireccionPolar));
      line(0, 0, this.vel * 2, 0);
    pop();
  }
}