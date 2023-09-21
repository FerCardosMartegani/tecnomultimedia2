//--------------------------------------------------------------------------------------------------------------------------------DECLARACIÓN
import oscP5.*;
OscP5 receptor;
OscProperties propiedades;

float[][] dedoMedio, dedoAnular;
float[][] palma;
boolean gestoDeAgarre;

int nodoX = 0;
int nodoY = 1;
int nodoBase = 0;
int nodoPunta = 1;

float handposeWidth = 300;
float handpose0X = 100;
float handposeHeight = 350;
float handpose0Y = 150;

float palmaCentro = height*2;


//--------------------------------------------------------------------------------------------------------------------------------SETUP
void setupOsc() {
  receptor = new OscP5(this, 8008);

  dedoMedio = new float[2][2];    //nodo - coord
  dedoAnular = new float[2][2];
  palma = new float[2][2];

  gestoDeAgarre = false;
}


//--------------------------------------------------------------------------------------------------------------------------------CÁLCULOS
void calcularOsc() {
  if (!usarMouse) {
    cursorX = constrain(palma[nodoPunta][nodoX], 0, width);      //mover el cursor a la mano del usuario
    cursorY = constrain(palma[nodoPunta][nodoY], 0, height);

    if ((dedoMedio[nodoPunta][nodoY] > dedoMedio[nodoBase][nodoY]) || (dedoAnular[nodoPunta][nodoY] > dedoAnular[nodoBase][nodoY])) {
      if (!gestoDeAgarre) {
        hacerClic();                  //hacer "click" al hacer el gesto de Spiderman
        gestoDeAgarre = true;
      }
    } else {
      soltarClic();
      gestoDeAgarre = false;                    //soltar al abrir la mano
    }
  } else {
    cursorX = mouseX;                  //mover el cursor al mouse
    cursorY = mouseY;
  }
}


//--------------------------------------------------------------------------------------------------------------------------------DEBUG
void debugOsc() {
  push();
  fill(360);
  stroke(360);
  float tam = 20;

  ellipse(dedoAnular[nodoBase][nodoX], dedoAnular[nodoBase][nodoY], tam, tam);        //dibujar dedo anular
  ellipse(dedoAnular[nodoPunta][nodoX], dedoAnular[nodoPunta][nodoY], tam, tam);
  line(dedoAnular[nodoBase][nodoX], dedoAnular[nodoBase][nodoY], dedoAnular[nodoPunta][nodoX], dedoAnular[nodoPunta][nodoY]);

  ellipse(dedoMedio[nodoBase][nodoX], dedoMedio[nodoBase][nodoY], tam, tam);          //dibujar dedo medio
  ellipse(dedoMedio[nodoPunta][nodoX], dedoMedio[nodoPunta][nodoY], tam, tam);
  line(dedoMedio[nodoBase][nodoX], dedoMedio[nodoBase][nodoY], dedoMedio[nodoPunta][nodoX], dedoMedio[nodoPunta][nodoY]);

  ellipse(palma[nodoBase][nodoX], palma[nodoBase][nodoY], tam, tam);                    //dibujar palma
  ellipse(palma[nodoPunta][nodoX], palma[nodoPunta][nodoY], tam, tam);
  line(palma[nodoBase][nodoX], palma[nodoBase][nodoY], dedoAnular[nodoBase][nodoX], dedoAnular[nodoBase][nodoY]);
  line(palma[nodoBase][nodoX], palma[nodoBase][nodoY], dedoMedio[nodoBase][nodoX], dedoMedio[nodoBase][nodoY]);
  line(dedoAnular[nodoBase][nodoX], dedoAnular[nodoBase][nodoY], dedoMedio[nodoBase][nodoX], dedoMedio[nodoBase][nodoY]);
  pop();
}


//--------------------------------------------------------------------------------------------------------------------------------RECEPCIÓN
void oscEvent(OscMessage mensaje) {
  if (mensaje.addrPattern().equals("/annotations/palmBase")) {
    palma[nodoBase][nodoX] = getNodo(mensaje, nodoX);          //ubicar la palma
    palma[nodoBase][nodoY] = getNodo(mensaje, nodoY);
    
    palma[nodoPunta][nodoX] = palma[nodoBase][nodoX];
    palma[nodoPunta][nodoY] = palma[nodoBase][nodoY] - palmaCentro;
  }

  if (mensaje.addrPattern().equals("/annotations/ringFinger")) {
    dedoAnular[nodoBase][nodoX] = getNodo(mensaje, nodoX);        //ubicar la base del dedo anular
    dedoAnular[nodoBase][nodoY] = getNodo(mensaje, nodoY);

    dedoAnular[nodoPunta][nodoX] = getNodo(mensaje, nodoX+9);        //ubicar la punta del dedo anular
    dedoAnular[nodoPunta][nodoY] = getNodo(mensaje, nodoY+9);
  }

  if (mensaje.addrPattern().equals("/annotations/middleFinger")) {
    dedoMedio[nodoBase][nodoX] = getNodo(mensaje, nodoX);          //ubicar la base del dedo medio
    dedoMedio[nodoBase][nodoY] = getNodo(mensaje, nodoY);

    dedoMedio[nodoPunta][nodoX] = getNodo(mensaje, nodoX+9);          //ubicar la punta del dedo medio
    dedoMedio[nodoPunta][nodoY] = getNodo(mensaje, nodoY+9);
  }
}
float getNodo(OscMessage m, int p) {
  if (p%3 == 0) {
    return width-map(m.get(p).floatValue(), handpose0X, handposeWidth, 0, width);
  } else {
    return map(m.get(p).floatValue(), handpose0Y, handposeHeight, 0, height);
  }
}
