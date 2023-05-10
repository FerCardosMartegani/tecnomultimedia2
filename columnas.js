class Columna{

  //-------------------------------------------------------------------------------------CONSTRUCTOR
  constructor(){
    this.x1;    this.y1=0;
    this.x2;    this.y2=height;
    this.hue = random(300);
    this.saturacion;
  }

  //-------------------------------------------------------------------------------------METODOS
  dibujar(_x1, _x2, _longitud){
    this.x1=_x1;  this.x2=_x2;
    this.saturacion = constrain(100-_longitud, 25, 100);    //calcula la saturación según el tiempo que dura el sonido; si dura mucho, llega un momento donde deja de afectar.

    //probablemente nos metamos con algo de pinceles y usemos esta línea para orientar otra cosa que se dibuje por encima.
    //también es probable que cada columna contenga un arreglo de objetos de tipo manchita o algo similar

    push();                                                           //ejemplo de cómo sería la lógica de los colores
      strokeWeight(20);
      stroke(color(this.hue, this.saturacion*(1/4),  100*(3/3)));
      line(this.x1,this.y1, this.x2,(this.y2-this.y1)*(1/3));
      stroke(color(this.hue, 100*(2/4),  100*(2/3)));
      line(this.x1,(this.y2-this.y1)*(1/3),this.x2,(this.y2-this.y1)*(2/3));
      stroke(color(this.hue, this.saturacion*(3/4),  100*(1/3)));
      line(this.x1,(this.y2-this.y1)*(2/3), this.x2,(this.y2-this.y1)*(3/3));
    pop();
  }
}