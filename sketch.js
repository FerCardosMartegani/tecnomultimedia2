/*
TP1 PROTOTIPO - Rovarino, Vasquez, Cardos, Rodriguez
*/


//---------------------------------------------------------------------------------------------------DECLARACIÓN
let cursor;     //objeto Dir_y_Vel

let amplitud;     //volumen del sonido
let maxAmplitud;
let minAmplitud;
let preAmplitud;
let varAmplitud;

let frecuencia;       //frecuencia del sonido
let maxFrecuencia=1000;
let minFrecuencia=-maxFrecuencia;
let preFrecuencia;

let longitud;       //duración del sonido

let columnas = [];           //objetos columna
let columnasFondo = [];
let cantidadColumnasCentro = 100;    //columnas centrales
let cantidadColumnasFondo;
let margenColumnas;          //columnas ocultas iniciales, cambiará con el volumen
const minColumnas = 35;
const maxColumnas = 100;

let PNGs = [];               //imágenes manchas de pintura
const cantidadImagenes = 3;

let dibujado = false;   //si ya se dibujó o no (para evitar refresh innecesario)
let debug = false;      //activar-desactivar interfaz de debug


//---------------------------------------------------------------------------------------------------PRELOAD
function preload(){
  for(let i=0; i<cantidadImagenes; i++){
    PNGs[i] = loadImage("./data/mancha"+i+".png");    //cargar PNGs de manchas
  }
}


//---------------------------------------------------------------------------------------------------SETUP
function setup(){
  createCanvas(innerWidth, innerHeight);
  colorMode(HSB, 360, 100, 100, 100);
  angleMode(DEGREES);
  imageMode(CENTER);

  //-------------------------------------------------------------------------------------SONIDO
  cursor = new Dir_y_Vel();
  amplitud=preAmplitud=varAmplitud=frecuencia=preFrecuencia=longitud=0;

  //-------------------------------------------------------------------------------------COLUMNAS DEL FONDO
  cantidadColumnasFondo = map(width, 0,1920, 0,90);    //cantidad de columnas de fondo según el ancho de pantalla
  for(let i=0; i<cantidadColumnasFondo; i++){
    let xi = calcularColumna(0, i, cantidadColumnasFondo);
    let xf = calcularColumna(1, i, cantidadColumnasFondo);
    columnasFondo[i] = new Columna(xi,xf, false);    //instanciar columnas (X inicial, X final, sólo primitivas)
  }

  //-------------------------------------------------------------------------------------COLUMNAS CENTRALES
  cantidadColumnasCentro = constrain(cantidadColumnasCentro, minColumnas,maxColumnas);   //seguro para que no cargue demasiadas imágenes
  for(let i=0; i<cantidadColumnasCentro; i++){
    let xi = calcularColumna(0, i, cantidadColumnasCentro);
    let xf = calcularColumna(1, i, cantidadColumnasCentro);
    columnas[i] = new Columna(xi,xf, true);    //instanciar columnas (X inicial, X final, incluir imágenes)
  }
}


//---------------------------------------------------------------------------------------------------DRAW
function draw(){

  //-------------------------------------------------------------------------------------CALCULADORA
  cursor.calcularTodo(mouseX, mouseY);      //calcular datos del cursor
  amplitud = round(cursor.velocidad());    //velocidad del cursor, próximamente volumen del sonido 
  if((pmouseX != mouseX) || (pmouseY != mouseY)){ longitud++; }else{ longitud=0; }    //tiempo que lleva moviéndose el cursor, próximamente duración del sonido
  frecuencia = abs(cursor.direccionX())-abs(cursor.direccionY());   //si el cursor es más vertical (>0) u horizontal (<0), próximamente si el sonido es más agudo (>0) o grave (<0)
  frecuencia = constrain(frecuencia, minFrecuencia,maxFrecuencia);

  varAmplitud = amplitud-preAmplitud;
  if(abs(varAmplitud) > 40){ cantidadColumnasCentro+=round(varAmplitud/50); }
  
  if(longitud>0){
    //-------------------------------------------------------------------------COLUMNAS FONDO
    for(let i=0; i<cantidadColumnasFondo; i++){
      let xi = calcularColumna(0, i, cantidadColumnasFondo);
      let xf = calcularColumna(1, i, cantidadColumnasFondo);
      columnasFondo[i].recalcular(xi,xf);    //instanciar columnas (X inicial, X final, sólo primitivas)
    }

    //-------------------------------------------------------------------------COLUMNAS CENTRALES
    cantidadColumnasCentro = constrain(cantidadColumnasCentro, minColumnas,maxColumnas);
    for(let i=0; i<cantidadColumnasCentro; i++){
      let xi = calcularColumna(0, i, cantidadColumnasCentro);
      let xf = calcularColumna(1, i, cantidadColumnasCentro);
      columnas[i].recalcular(xi,xf);    //instanciar columnas (X inicial, X final, incluir imágenes)
    }

    //sólo actualizar el dibujo si no hubo un descenso demasiado brusco del volumen, para que se guarde la pintura generada
    if((varAmplitud) > -75){ dibujado = false; }

    preAmplitud = amplitud;
  }

  //-------------------------------------------------------------------------------------DIBUJO
  if(!dibujado){
    clear();          //borrar dibujo anterior para no saturar la memoria
    background(360);
    for(let i=0; i<cantidadColumnasFondo; i++){
      columnasFondo[i].dibujar();                  //dibujar columnas
    }
    for(let i=0; i<cantidadColumnasCentro; i++){
      columnas[i].dibujar();                  //dibujar columnas
    }

    dibujado = true;  //evitar que el dibujo se refresce si no hubo cambios
  }

  //-------------------------------------------------------------------------------------DEBUG
  if(debug){
    push();
      fill(360,75); rectMode(CORNERS); rect(0,0, width,150);  //fondo para el debugger

      cursor.mostrarData();   //debugger del Dir_y_Vel

      textSize(24); fill(0); textAlign(RIGHT,CENTER);       //debugger sonido
      text("Frecuencia: " + frecuencia, width-50, 50);
      text("Amplitud: " + amplitud, width-50, 75);
      text("Longitud: " + longitud, width-50, 100);
      text("Columnas: " + cantidadColumnasCentro, width-50, 125);
    pop();
  }
}


//---------------------------------------------------------------------------------------------------CÁLCULOS DE COLUMNAS
function calcularColumna(modo, _i, cantidad){
  let distanciaEntreColumnas = (cantidad==cantidadColumnasFondo ? (cantidad-2)/5 : map(cantidad, minColumnas,maxColumnas, cantidad*1.25,cantidad/2));
  let posicionAlMedio = map(_i, 0,cantidad-1, -distanciaEntreColumnas,+distanciaEntreColumnas);
  let posicion = width/2+posicionAlMedio*(cantidad==cantidadColumnasFondo ? 100 : map(width, 0,1920, 0,15));
  let curvatura = (posicion-width/2)/2.5;

  if(modo==0){ return posicion+curvatura*map(frecuencia, minFrecuencia,maxFrecuencia, -1,1); }
  if(modo==1){ return posicion-curvatura*map(frecuencia, minFrecuencia,maxFrecuencia, -1,1); }
}


//---------------------------------------------------------------------------------------------------CLIC DEBUGGER
function mouseClicked(){
  dibujado=false;
  debug = !debug;
}