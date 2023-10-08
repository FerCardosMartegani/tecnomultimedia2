//--------------------------------------------------------------------------------------------------------------------------------DECLARACIÓN
import oscP5.*;
OscP5 receptor;
OscProperties propiedades;


//------------------------------------------------------------------------------------------------------------GUARDADO DE SEÑAL
float[][] dedoMedio, preMedio, dedoAnular, preAnular, dedoIndice, preIndice;
float[][] palma, prePalma;

int nodoX = 0;
int nodoY = 1;
int nodoBase = 0;
int nodoPunta = 1;

boolean gestoClic;

//------------------------------------------------------------------------------------------------------------FILTRADO DE SEÑAL
float handposeWidth = 300;          //márgenes para mapear la señal, sólo toma una limitada zona de la captura
float handpose0X = 100;
float handposeHeight = 350;
float handpose0Y = 150;

float palmaCentro = height*2;

float umbral = 20;


//--------------------------------------------------------------------------------------------------------------------------------SETUP
void setupOsc() {
  receptor = new OscP5(this, 8008);

  dedoMedio = new float[2][2];    //nodo - coord
  dedoAnular = new float[2][2];
  dedoIndice = new float[2][2];
  palma = new float[2][2];

  preMedio = new float[2][2];
  preAnular = new float[2][2];
  preIndice = new float[2][2];
  prePalma = new float[2][2];
}


//--------------------------------------------------------------------------------------------------------------------------------CÁLCULOS
void calcularOsc() {
  if (!usarMouse) {
    //------------------------------------------------------------------------------------------------------------CURSOR
    float ruidoCursor = dist(prePalma[nodoPunta][nodoX], prePalma[nodoPunta][nodoY], palma[nodoPunta][nodoX], palma[nodoPunta][nodoY]);
    float cambioCursor = dist(cursorX, cursorY, palma[nodoPunta][nodoX], palma[nodoPunta][nodoY]);
    if ((ruidoCursor > umbral) || (cambioCursor > umbral)) {
      cursorX = constrain(lerp(palma[nodoPunta][nodoX], prePalma[nodoPunta][nodoX], 0.5), 0, width);      //mover el cursor a la mano del usuario
      cursorY = constrain(lerp(palma[nodoPunta][nodoY], prePalma[nodoPunta][nodoY], 0.5), 0, height);
    }

    //------------------------------------------------------------------------------------------------------------GESTO DE SPIDERMAN
    float ruidoMedio = dist(preMedio[nodoPunta][nodoX], preMedio[nodoPunta][nodoY], dedoMedio[nodoPunta][nodoX], dedoMedio[nodoPunta][nodoY]);
    float ruidoAnular = dist(preAnular[nodoPunta][nodoX], preAnular[nodoPunta][nodoY], dedoAnular[nodoPunta][nodoX], dedoAnular[nodoPunta][nodoY]);
    float ruidoIndice = dist(preIndice[nodoPunta][nodoX], preIndice[nodoPunta][nodoY], dedoIndice[nodoPunta][nodoX], dedoIndice[nodoPunta][nodoY]);

    boolean dedoMedioAbajo = (dedoMedio[nodoPunta][nodoY] > dedoMedio[nodoBase][nodoY]);
    boolean dedoAnularAbajo = (dedoAnular[nodoPunta][nodoY] > dedoAnular[nodoBase][nodoY]);
    boolean dedoIndiceAbajo = (dedoIndice[nodoPunta][nodoY] > dedoIndice[nodoBase][nodoY]);
    if ((dedoMedioAbajo || dedoAnularAbajo) && !dedoIndiceAbajo) {
      if (!gestoClic) {
        hacerClic();                  //hacer "click" al hacer el gesto de Spiderman
        gestoClic = true;
      }
    } else if (!dedoMedioAbajo && !dedoAnularAbajo && !dedoIndiceAbajo) {
      if (gestoClic) {
        soltarClic();
        gestoClic = false;                    //soltar al abrir la mano
      }
    }

    //------------------------------------------------------------------------------------------------------------MEMORIA DEL FRAME ANTERIOR
    prePalma[nodoPunta][nodoX] = palma[nodoPunta][nodoX];
    prePalma[nodoPunta][nodoY] = palma[nodoPunta][nodoY];

    if (ruidoMedio > umbral) {
      preMedio[nodoPunta][nodoX] = dedoMedio[nodoPunta][nodoX];
      preMedio[nodoPunta][nodoY] = dedoMedio[nodoPunta][nodoY];
    }
    if (ruidoAnular > umbral) {
      preAnular[nodoPunta][nodoX] = dedoAnular[nodoPunta][nodoX];
      preAnular[nodoPunta][nodoY] = dedoAnular[nodoPunta][nodoY];
    }
    if (ruidoIndice > umbral) {
      preIndice[nodoPunta][nodoX] = dedoIndice[nodoPunta][nodoX];
      preIndice[nodoPunta][nodoY] = dedoIndice[nodoPunta][nodoY];
    }
  } else {
    cursorX = mouseX;                  //mover el cursor al mouse (para testear)
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

  if (mensaje.addrPattern().equals("/annotations/indexFinger")) {
    dedoIndice[nodoBase][nodoX] = getNodo(mensaje, nodoX+3);          //ubicar la base del dedo índice
    dedoIndice[nodoBase][nodoY] = getNodo(mensaje, nodoY+3);

    dedoIndice[nodoPunta][nodoX] = getNodo(mensaje, nodoX+9);          //ubicar la punta del dedo índice
    dedoIndice[nodoPunta][nodoY] = getNodo(mensaje, nodoY+9);
  }
}
float getNodo(OscMessage m, int p) {
  if (p%3 == 0) {
    return width-map(m.get(p).floatValue(), handpose0X, handposeWidth, 0, width);
  } else {
    return map(m.get(p).floatValue(), handpose0Y, handposeHeight, 0, height);
  }
}
