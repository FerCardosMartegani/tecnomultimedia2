//--------------------------------------------------------------------------------------------------------------------------------DECLARACIÓN
import oscP5.*;
OscP5 receptor;
OscProperties propiedades;

float[][] dedoMedio, dedoAnular;
boolean gestoDeAgarre;

int nodoX = 0;
int nodoY = 1;
int nodoBase = 0;
int nodoPunta = 1;

float handposeWidth = 300;
float handpose0X = 100;
float handposeHeight = 350;
float handpose0Y = 150;


//--------------------------------------------------------------------------------------------------------------------------------SETUP
void configurarOsc() {
  receptor = new OscP5(this, 8008);

  dedoMedio = new float[2][2];    //nodo - coord
  dedoAnular = new float[2][2];

  gestoDeAgarre = false;
}


//--------------------------------------------------------------------------------------------------------------------------------CÁLCULOS
void calcularOsc() {
  cursorX = constrain(dedoMedio[nodoBase][nodoX], 0, width);      //mover el cursor a la mano del usuario
  cursorY = constrain(dedoMedio[nodoBase][nodoY], 0, height);

  if ((dedoMedio[nodoPunta][nodoY] > dedoMedio[nodoBase][nodoY]) || (dedoAnular[nodoPunta][nodoY] > dedoAnular[nodoBase][nodoY])) {
    if (!gestoDeAgarre) {
      tela.aplicarJoint();                  //hacer "click" al hacer el gesto de Spiderman
      gestoDeAgarre = true;
    }
  } else {
    tela.soltarJoint();
    gestoDeAgarre = false;                    //soltar al abrir la mano
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
  pop();
}


//--------------------------------------------------------------------------------------------------------------------------------RECEPCIÓN
void oscEvent(OscMessage mensaje) {
  if (mensaje.addrPattern().equals("/annotations/ringFinger")) {
    dedoAnular[nodoBase][nodoX] = getNodo(mensaje, 0, nodoX);        //ubicar la base del dedo anular
    dedoAnular[nodoBase][nodoY] = getNodo(mensaje, 1, nodoY);

    dedoAnular[nodoPunta][nodoX] = getNodo(mensaje, 9, nodoX);        //ubicar la punta del dedo anular
    dedoAnular[nodoPunta][nodoY] = getNodo(mensaje, 10, nodoY);
  }

  if (mensaje.addrPattern().equals("/annotations/middleFinger")) {
    dedoMedio[nodoBase][nodoX] = getNodo(mensaje, 0, nodoX);          //ubicar la base del dedo medio
    dedoMedio[nodoBase][nodoY] = getNodo(mensaje, 1, nodoY);

    dedoMedio[nodoPunta][nodoX] = getNodo(mensaje, 9, nodoX);          //ubicar la punta del dedo medio
    dedoMedio[nodoPunta][nodoY] = getNodo(mensaje, 10, nodoY);
  }
}
float getNodo(OscMessage m, int i, int p) {
  if (p == nodoX) {
    return width-map(m.get(i).floatValue(), handpose0X, handposeWidth, 0, width);
  } else {
    return map(m.get(i).floatValue(), handpose0Y, handposeHeight, 0, height);
  }
}
