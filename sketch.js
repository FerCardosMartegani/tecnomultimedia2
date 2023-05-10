let cursor;     //objeto Dir_y_Vel
let columnas = [];    //objetos columna

let frecuencia, amplitud, longitud;   //variables de interacción
let debug = false;
let volumenMaximo = 800;  //máxima velocidad que buscamos en el cursor, próximamente el volumen más alto que podemos o esperamos registrar
let cantidadColumnas=5;   //cantidad de columnas a dibujar
let preLongitud=0;

function setup() {
  createCanvas(innerWidth, innerHeight);
  colorMode(HSB, 360, 100, 100, 100);

  cursor = new Dir_y_Vel();
  for(let i=0; i<cantidadColumnas; i++){
    columnas[i] = new Columna();
  }
}

function draw() {
  //-------------------------------------------------------------------------------------CALCULADORA
  cursor.calcularTodo(mouseX, mouseY);      //calcular datos del cursor

  if((pmouseX != mouseX) || (pmouseY != mouseY)){ longitud++; }else{ longitud=0; }    //tiempo que lleva moviéndose el cursor, próximamente duración del sonido

  //hacer que el programa se detenga cuando no haya sonido que registrar, para que la obra generada no desaparezca.
  if((longitud>0) && (frameCount%10==0)){    //reducir la rapidez de actualización de los datos para que no se borre la obra.

    preLongitud = longitud;
    amplitud = round(cursor.velocidad());    //velocidad del cursor, próximamente volumen del sonido 
    frecuencia = abs(cursor.direccionX())-abs(cursor.direccionY());   //si el cursor es más vertical (>0) u horizontal (<0), próximamente si el sonido es más agudo (>0) o grave (<0)

    if(amplitud!=0){
      let preCantidadColumnas = cantidadColumnas;
      cantidadColumnas=int(map(amplitud, 0,volumenMaximo, 5,20));     //recalcular la cantidad de columnas
      if(cantidadColumnas!=preCantidadColumnas){
        if(cantidadColumnas > preCantidadColumnas){
          for(let i=cantidadColumnas-preCantidadColumnas; i>0; i--){      //si subió el volumen, crear más columnas
            columnas.push(new Columna());
          }
        }else if(cantidadColumnas < preCantidadColumnas){
          for(let i=preCantidadColumnas-cantidadColumnas; i>0; i--){    //si bajó el volumen, eliminar columnas
            columnas.pop();
          }
        }
      }
    }
  }

  //-------------------------------------------------------------------------------------DIBUJO
  background(100);
  
  for(let i=0; i<cantidadColumnas; i++){
    let x1 = (width)*((i+1)/(cantidadColumnas+1));
    let x2 = (width)*((i+1)/(cantidadColumnas+1));
    columnas[i].dibujar(x1-frecuencia*(x1-width/2)/1000, x2+frecuencia*(x2-width/2)/1000, preLongitud);
    /*
    cálculo de la inclinación de los renglones:
    1- el punto inicial de cada columna es x1, calculado según el índice i (según qué columna es). Distribuye el espacio según la cantidad de columnas que hay, y le suma +1 tanto a i como a cantidadColumnas para que quede espacio a los costados.
    2- el punto final de cada columna es x2; se le aplica la misma operación que a x1.
    3- a x1 le resta frecuencia, cuyo signo depende de si el cursor se mueve más en vertical (+) u horizontal (-), haciendo que la línea se empiece a inclinar. Frecuencia es multiplicado por la distancia entre ese punto y el centro de la pantalla para que hacia cada lado se incline en un sentido opuesto. Esa multiplicación se divide por 1000 (calculado a ojo, a prueba y error) para mantenerlo en distancias razonables.
    4- a x2 se le aplica una cuenta similar que a x1 pero frecuencia está sumando en vez de restar, haciendo que siempre se incline hacia el otro lado que x1.
    5- preLongitud es para el color de las partes desaturadas.
    */
  }

  //-------------------------------------------------------------------------------------DEBUG
  if(debug){
    cursor.mostrarData();
    push();
      textSize(24);
      fill(0);
      textAlign(RIGHT,CENTER);
      text("Frecuencia: " + frecuencia, width-50, 50);
      text("Amplitud: " + amplitud, width-50, 75);
      text("Longitud: " + longitud, width-50, 100);
      text("Columnas: " + cantidadColumnas, width-50, 125);
    pop();
  }
}

//-------------------------------------------------------------------------------------ACTIVAR/DESACTIVAR DEBUGGER
function mouseClicked(){
  debug = !debug;
}