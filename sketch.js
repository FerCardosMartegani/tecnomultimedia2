/*
TP1 PROTOTIPO - Rovarino, Vasquez, Cardos, Rodriguez
*/


//---------------------------------------------------------------------------------------------------CALIBRACIÓN
const maxAmplitud = 0.8;        //volumen máximo
const minAmplitud = 0.02;     //volumen mínimo

const maxFrecuencia = 500;    //frecuencia máxima
const minFrecuencia = 100;    //frecuencia mínima


//---------------------------------------------------------------------------------------------------DECLARACIÓN
let micro;    //objeto micrófono
let audioContext;    //motor de audio del navegador

//-------------------------------------------------------------------------------------controladores de estados
let haySonido, debug, reseted;

let amplitud, preAmplitud, varAmplitud;     //volumen del sonido

let frecuencia, preFrecuencia, varFrecuencia;       //frecuencia del sonido
const pichModel = 'https://cdn.jsdelivr.net/gh/ml5js/ml5-data-and-models/models/pitch-detection/crepe/';

let longitud, silencio;       //duración del sonido y del silencio

let columnas = [];           //objetos columna
let columnasFondo = [];
let cantidadColumnasCentro = 100;
let cantidadColumnasFondo;
const minColumnas = 35;
const maxColumnas = 90;

let PNGs = [];               //imágenes manchas de pintura
const cantidadImagenes = 4;


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
  audioContext = getAudioContext();
  micro = new p5.AudioIn();
  micro.start(startPitch);
  userStartAudio();

  amplitud=preAmplitud=varAmplitud=frecuencia=preFrecuencia=longitud=silencio=0;
  haySonido=debug=reseted=false;

  configInicial();
}


//---------------------------------------------------------------------------------------------------DRAW
function draw(){

  //-------------------------------------------------------------------------------------CALCULADORA
  amplitud = micro.getLevel();      //volumen del sonido
  amplitud = nf(amplitud, 2,4);
  amplitud = constrain(amplitud, minAmplitud, maxAmplitud);

  haySonido = amplitud > minAmplitud;   //hay sonido cuando hay volumen por encima del ruido de fondo

  frecuencia = lerp(frecuencia,preFrecuencia, 0.5);   //suavizar input de frecuencia
  frecuencia = nf(frecuencia, 4,1);
  frecuencia = constrain(frecuencia, minFrecuencia,maxFrecuencia);
  
  //if(abs(varAmplitud) > 0.01){ cantidadColumnasCentro+=round(varAmplitud*100); }
  cantidadColumnasCentro = map(lerp(amplitud,preAmplitud, 0.5), minAmplitud,maxAmplitud, minColumnas,maxColumnas);
 
  if(haySonido){
    //-------------------------------------------------------------------------COLUMNAS FONDO
    for(let i=0; i<cantidadColumnasFondo; i++){
      let xi = calcularColumna(0, i, cantidadColumnasFondo);
      let xf = calcularColumna(1, i, cantidadColumnasFondo);
      columnasFondo[i].recalcular(xi,xf);    //instanciar columnas (X inicial, X final, sólo primitivas)
    }

    //-------------------------------------------------------------------------COLUMNAS CENTRALES
    cantidadColumnasCentro = constrain(round(cantidadColumnasCentro), minColumnas,maxColumnas);
    for(let i=0; i<cantidadColumnasCentro; i++){
      let xi = calcularColumna(0, i, cantidadColumnasCentro);
      let xf = calcularColumna(1, i, cantidadColumnasCentro);
      columnas[i].recalcular(xi,xf);    //instanciar columnas (X inicial, X final, incluir imágenes)
    }

    preAmplitud = amplitud;
    preFrecuencia = frecuencia;

    longitud++;          //tiempo que lleva sonando el sonido
    silencio = 0;
    reseted = false;
  }else{
    longitud=0;
    silencio++;         //tiempo que lleva en silencio

    let resetDelay = 5;      //el lienzo se reinicia si hay un silencio prolongado
    if(silencio > frameRate()*resetDelay && !reseted){ configInicial(); }
  }  

  //-------------------------------------------------------------------------------------DIBUJO
  if(haySonido){
    clear();          //borrar dibujo anterior para no saturar la memoria
    background(360);
    for(let i=0; i<cantidadColumnasFondo; i++){
      columnasFondo[i].dibujar();                  //dibujar columnas
    }
    for(let i=0; i<cantidadColumnasCentro; i++){
      columnas[i].dibujar();                  //dibujar columnas
    }
  }

  //-------------------------------------------------------------------------------------DEBUG
  if(debug){
    push();
      fill(360,75); rectMode(CORNERS); rect(0,0, width,150);  //fondo para el debugger

      textSize(24); fill(0);                 //debugger sonido
      textAlign(RIGHT,CENTER);
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
  debug = !debug;
}


//---------------------------------------------------------------------------------------------------AJUSTAR PANTALLA
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}


//---------------------------------------------------------------------------------------------------REINICIO
function configInicial(){
  reseted = true;
  push();
    //fill(180, 25); noStroke();
    noFill(); stroke(360); strokeWeight(35);
    rectMode(CORNERS);
    rect(0,0, width,height);  //fondo para el debugger
  pop();

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


//---------------------------------------------------------------------------------------------------LIBRERÍA ml5
function startPitch() {
  pitch = ml5.pitchDetection(pichModel, audioContext , micro.stream, modelLoaded);
}
function modelLoaded() {
  getPitch();
}
function getPitch() {
  pitch.getPitch(function(err, frequency) {
    if (frequency) {
      frecuencia = frequency;
    } else {
    }
    getPitch();
  })
}