/*
TP1 Comisión Lisandro - Fernando Cardos, Clara Rovarino, Elian Rodriguez, Luca Vasquez
*/


//---------------------------------------------------------------------------------------------------TOCAR SI ALGO FALLA

//-------------------------------------------------------------------------------------CALIBRACIÓN
const maxAmplitud = 0.8;      //volumen máximo
const minAmplitud = 0.02;     //volumen mínimo

const maxFrecuencia = 500;    //frecuencia máxima
const minFrecuencia = 100;    //frecuencia mínima

//-------------------------------------------------------------------------------------RENDIMIENTO
const minColumnas = 35;      //mínimo de imágenes centrales (para que quede bonito)
const maxColumnas = 90;      //máximo de imágenes centrales (para que no explote la compu)

//-------------------------------------------------------------------------------------OPCIONAL
const resetDelayBase = 5;   //tiempo (en segundos) que debe durar el silencio para reiniciar


//---------------------------------------------------------------------------------------------------DECLARACIÓN
let micro, audioContext;    //objeto micrófono

let haySonido, debug, reseted;    //controladores de estados

let amplitud, amplitudCruda, preAmplitud, varAmplitud;     //volumen del sonido

let frecuencia, frecuenciaCruda, preFrecuencia, varFrecuencia;       //frecuencia del sonido
const pichModel = 'https://cdn.jsdelivr.net/gh/ml5js/ml5-data-and-models/models/pitch-detection/crepe/';

let longitud, silencio, resetDelay;       //manejo de tiempos

let columnas = [];           //objetos columna
let columnasFondo = [];
let cantidadColumnasCentro;
let cantidadColumnasFondo;

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

  resetDelay=amplitud=amplitudCruda=preAmplitud=varAmplitud=frecuencia=frecuenciaCruda=preFrecuencia=longitud=silencio=0;
  cantidadColumnasCentro=maxColumnas;
  haySonido=debug=reseted=false;

  configInicial();
}


//---------------------------------------------------------------------------------------------------DRAW
function draw(){

  //-------------------------------------------------------------------------------------CALCULADORA
  amplitudCruda = micro.getLevel();      //volumen del sonido
  amplitud = lerp(amplitudCruda,preAmplitud, 0.5);   //suavizar input de amplitud
  amplitud = constrain(amplitudCruda, minAmplitud, maxAmplitud);

  cantidadColumnasCentro = map(amplitud, minAmplitud,maxAmplitud, minColumnas,maxColumnas);    //a mayor amplitud, más columnas centrales

  frecuencia = lerp(frecuenciaCruda,preFrecuencia, 0.5);   //suavizar input de frecuencia
  frecuencia = constrain(frecuencia, minFrecuencia,maxFrecuencia);
 
  resetDelay = resetDelayBase*frameRate();    //tiempo que debe durar el silencio para reiniciar, ajustado al rendimiento del programa

  haySonido = amplitudCruda > minAmplitud;   //hay sonido cuando hay volumen por encima del ruido de fondo
  if(haySonido){
    //-------------------------------------------------------------------------COLUMNAS FONDO
    for(let i=0; i<cantidadColumnasFondo; i++){
      let xi = calcularColumna(0, i, cantidadColumnasFondo);
      let xf = calcularColumna(1, i, cantidadColumnasFondo);
      columnasFondo[i].recalcular(xi,xf);    //cambiar la curvatura de las columnas
    }

    //-------------------------------------------------------------------------COLUMNAS CENTRALES
    cantidadColumnasCentro = round(constrain(cantidadColumnasCentro, minColumnas,maxColumnas));
    for(let i=0; i<cantidadColumnasCentro; i++){
      let xi = calcularColumna(0, i, cantidadColumnasCentro);
      let xf = calcularColumna(1, i, cantidadColumnasCentro);
      columnas[i].recalcular(xi,xf);    //cambiar la curvatura de las columnas
    }

    preAmplitud = amplitud;       //guardar datos del último sonido
    preFrecuencia = frecuencia;

    longitud++;          //tiempo que lleva sonando el sonido
    silencio = 0;
    reseted = false;
  }else{
    longitud=0;
    silencio++;         //tiempo que lleva en silencio
    
    if(silencio > resetDelay && !reseted){ configInicial(); }   //el lienzo se reinicia si hay un silencio prolongado
  }  

  //-------------------------------------------------------------------------------------DIBUJO
  if(haySonido){
    clear();          //borrar dibujo anterior para no saturar la memoria (nos tiró ese error varias veces)
    background(360);
    for(let i=0; i<cantidadColumnasFondo; i++){
      columnasFondo[i].dibujar();                  //dibujar columnas del fondo
    }
    for(let i=0; i<cantidadColumnasCentro; i++){
      columnas[i].dibujar();                  //dibujar columnas centrales por encima del fondo
    }
  }

  //-------------------------------------------------------------------------------------DEBUG
  if(debug){
    push();
      fill(360,60); rectMode(CORNERS); rect(0,0, width,150);  //fondo para hacerlo más legible

      textSize(24); fill(0);

      textAlign(LEFT,CENTER);
      text("Frecuencia sin filtrar: " + frecuenciaCruda, 50,50);
      text("Amplitud sin filtrar: " + amplitudCruda, 50,75);
      text("Longitud: " + longitud, 50, 100);

      textAlign(RIGHT,CENTER);
      text("Frecuencia filtrada: " + nf(frecuencia, 4,1), width-50, 50);
      text("Amplitud filtrada: " + nf(amplitud, 2,4), width-50, 75);
      text("Tiempo en silencio: "+silencio+" / "+nf(round(resetDelay), 2,0), width-50, 100);
    pop();
  }
}


//---------------------------------------------------------------------------------------------------CLIC DEBUGGER
function mouseClicked(){
  debug = !debug;                  //el clic activa/desactiva la interfaz de debug
}


//---------------------------------------------------------------------------------------------------AJUSTAR PANTALLA
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);       //reacomodar el dibujo si cambia la ventana del sketch
  configInicial();
}


//---------------------------------------------------------------------------------------------------REINICIO
function configInicial(){       //crea las instancias de objetos columna
  reseted = true;
  push();
    noFill(); stroke(360); strokeWeight(35);
    rectMode(CORNERS);
    rect(0,0, width,height);  //"marco de foto"
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


//---------------------------------------------------------------------------------------------------CÁLCULOS DE COLUMNAS
function calcularColumna(modo, _i, cantidad){
  let distanciaEntreColumnas = (cantidad==cantidadColumnasFondo ? (cantidad-2)/5 : map(cantidad, minColumnas,maxColumnas, cantidad*1.25,cantidad/2));
  let posicionAlMedio = map(_i, 0,cantidad-1, -distanciaEntreColumnas,+distanciaEntreColumnas);
  let posicion = width/2+posicionAlMedio*(cantidad==cantidadColumnasFondo ? 100 : map(width, 0,1920, 0,15));
  let curvatura = (posicion-width/2)/2.5;

  if(modo==0){ return posicion+curvatura*map(frecuencia, minFrecuencia,maxFrecuencia, -1,1); }    //cambia el signo (posicion +/- curvatura) para que arriba y abajo se desplacen en direcciones opuestas
  if(modo==1){ return posicion-curvatura*map(frecuencia, minFrecuencia,maxFrecuencia, -1,1); }
}


//---------------------------------------------------------------------------------------------------FRECUENCIA CON ml5
function startPitch() {
  pitch = ml5.pitchDetection(pichModel, audioContext , micro.stream, modelLoaded);
}
function modelLoaded() {
  getPitch();
}
function getPitch() {
  pitch.getPitch(function(err, frequency) {
    if (frequency) {
      frecuenciaCruda = frequency;
    }
    getPitch();
  })
}