#include "listaSimbolos.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>


struct PosicionListaRep {
  Simbolo dato;
  struct PosicionListaRep *sig;
};

struct ListaRep {
  PosicionLista cabecera;
  PosicionLista ultimo;
  int n;
};

typedef struct PosicionListaRep *NodoPtr;

Lista creaLS() {
  Lista nueva = malloc(sizeof(struct ListaRep));
  nueva->cabecera = malloc(sizeof(struct PosicionListaRep));
  nueva->cabecera->sig = NULL;
  nueva->ultimo = nueva->cabecera;
  nueva->n = 0;
  return nueva;
}

void liberaLS(Lista lista) {
  while (lista->cabecera != NULL) {
    NodoPtr borrar = lista->cabecera;
    lista->cabecera = borrar->sig;
    free(borrar);
  }
  free(lista);
}

void insertaLS(Lista lista, PosicionLista p, Simbolo s) {
  NodoPtr nuevo = malloc(sizeof(struct PosicionListaRep));
  nuevo->dato = s;
  nuevo->sig = p->sig;
  p->sig = nuevo;
  if (lista->ultimo == p) {
    lista->ultimo = nuevo;
  }
  (lista->n)++;
}

void suprimeLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  NodoPtr borrar = p->sig;
  p->sig = borrar->sig;
  if (lista->ultimo == borrar) {
    lista->ultimo = p;
  }
  free(borrar);
  (lista->n)--;
}

Simbolo recuperaLS(Lista lista, PosicionLista p) {
  //assert(p != lista->ultimo);
  return p->sig->dato;
}

PosicionLista buscaLS(Lista lista, char *nombre) {
  NodoPtr aux = lista->cabecera;
  while (aux->sig != NULL && strcmp(aux->sig->dato.nombre,nombre) != 0) {
    aux = aux->sig;
  }
  return aux;
}

void asignaLS(Lista lista, PosicionLista p, Simbolo s) {
  assert(p != lista->ultimo);
  p->sig->dato = s;
}

int longitudLS(Lista lista) {
  return lista->n;
}

PosicionLista inicioLS(Lista lista) {
  return lista->cabecera;
}

PosicionLista finalLS(Lista lista) {
  return lista->ultimo;
}

PosicionLista siguienteLS(Lista lista, PosicionLista p) {
  assert(p != lista->ultimo);
  return p->sig;
}




bool perteneceTablaS(char *nombre, Lista lista){
  bool success = false;
  PosicionLista pos = buscaLS(lista, nombre);
  
  if(pos != finalLS(lista) ){
      success = true;
      //    Simbolo aux = recuperaLS(l,p);
  }
  return success;
}

void anadeEntrada(char *nombre, Tipo t, Lista lista, int contadorCadena){
    PosicionLista posDondeInsertar = finalLS(lista);
    Simbolo s;
    s.nombre = nombre;
    s.tipo = t;
    if(s.tipo == STRING){
        s.valor = contadorCadena;
    }

    insertaLS(lista,posDondeInsertar, s);
}

bool esConstante(char *nombre, Lista lista){
  bool success = false;

  PosicionLista pos = buscaLS(lista, nombre);
  assert(pos!= NULL);
  Simbolo sim = recuperaLS(lista,pos);
  if(sim.tipo == CONSTANTE){
      success = true;
  }
  return success;
}


void imprimeTablaS(Lista lista){
  printf("Imprimiendo lista de %d simbolos\n",longitudLS(lista));
  PosicionLista p = inicioLS(lista);
  while (p != finalLS(lista)) {
    Simbolo aux = recuperaLS(lista,p);
    char *tipo;
    switch (aux.tipo) {
        case VARIABLE:
            tipo = "variable";
            printf("%s es %s\n",aux.nombre,tipo);
            break;
        case CONSTANTE:
            tipo = "constante";
            printf("%s es %s\n",aux.nombre,tipo);
            break;
        default:
            tipo = "cadena";
            printf("%s es %s%d\n",aux.nombre,tipo,aux.valor);

    }

    p = siguienteLS(lista,p);
  }
}

void seccionDatos(Lista lista){
    printf( "##################\n# Seccion de datos\n");
    printf("    .data\n");
    PosicionLista p = inicioLS(lista);
  
  //primero insertamos las cadenas
  printf("#Cadenas del programa\n");
  while (p != finalLS(lista)) {
    Simbolo aux = recuperaLS(lista,p);

    if (aux.tipo == STRING){
      printf("$str%d:\n", aux.valor);
      printf("    .asciiz %s\n", aux.nombre);
    }
    p = siguienteLS(lista,p);
  }
  
  //despues insertamos las variables y constantes
  printf("\n#Variables y constantes\n");
  p = inicioLS(lista);
  while (p != finalLS(lista)) {
    Simbolo aux = recuperaLS(lista,p);

    if (aux.tipo == VARIABLE || aux.tipo == CONSTANTE){
      printf("_%s:\n", aux.nombre);
      printf("    .word 0\n");
    }
    p = siguienteLS(lista,p);
  }
  printf("\n\n");

}











