#include "listaCodigo.h"
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>



struct PosicionListaCRep {
  Operacion dato;
  struct PosicionListaCRep *sig;
};

struct ListaCRep {
  PosicionListaC cabecera;
  PosicionListaC ultimo;
  int n;
  char *res;
};

typedef struct PosicionListaCRep *NodoPtr;

ListaC creaLC() {
  ListaC nueva = malloc(sizeof(struct ListaCRep));
  nueva->cabecera = malloc(sizeof(struct PosicionListaCRep));
  nueva->cabecera->sig = NULL;
  nueva->ultimo = nueva->cabecera;
  nueva->n = 0;
  nueva->res = NULL;
  return nueva;
}

void liberaLC(ListaC codigo) {
  while (codigo->cabecera != NULL) {
    NodoPtr borrar = codigo->cabecera;
    codigo->cabecera = borrar->sig;
    free(borrar);
  }
  free(codigo);
}

void insertaLC(ListaC codigo, PosicionListaC p, Operacion o) {
  NodoPtr nuevo = malloc(sizeof(struct PosicionListaCRep));
  nuevo->dato = o;
  nuevo->sig = p->sig;
  p->sig = nuevo;
  if (codigo->ultimo == p) {
    codigo->ultimo = nuevo;
  }
  (codigo->n)++;
}

Operacion recuperaLC(ListaC codigo, PosicionListaC p) {
  assert(p != codigo->ultimo);
  return p->sig->dato;
}

PosicionListaC buscaLC(ListaC codigo, PosicionListaC p, char *clave, Campo campo) {
  NodoPtr aux = p;
  char *info;
  while (aux->sig != NULL) {
    switch (campo) {
      case OPERACION: 
        info = aux->sig->dato.op;
        break;
      case ARGUMENTO1:
        info = aux->sig->dato.arg1;
        break;
      case ARGUMENTO2:
        info = aux->sig->dato.arg2;
        break;
      case RESULTADO:
        info = aux->sig->dato.res;
        break;
    }
    if (info != NULL && !strcmp(info,clave)) break;
	  aux = aux->sig;
  }
  return aux;
}

void asignaLC(ListaC codigo, PosicionListaC p, Operacion o) {
  assert(p != codigo->ultimo);
  p->sig->dato = o;
}

int longitudLC(ListaC codigo) {
  return codigo->n;
}

PosicionListaC inicioLC(ListaC codigo) {
  return codigo->cabecera;
}

PosicionListaC finalLC(ListaC codigo) {
  return codigo->ultimo;
}

void concatenaLC(ListaC codigo1, ListaC codigo2) {
  NodoPtr aux = codigo2->cabecera;
  while (aux->sig != NULL) {
    insertaLC(codigo1,finalLC(codigo1),aux->sig->dato);
    aux = aux->sig;
  }
}

PosicionListaC siguienteLC(ListaC codigo, PosicionListaC p) {
  assert(p != codigo->ultimo);
  return p->sig;
}

void guardaResLC(ListaC codigo, char *res) {
  codigo->res = res;
}

/* Recupera el registro resultado de una lista de codigo */
char * recuperaResLC(ListaC codigo) {
  return codigo->res;
}

void imprimeTablaC(ListaC lista){
    //printf("Imprimiendo lista de %d codigo\n",longitudLC(lista));
    PosicionListaC p = inicioLC(lista);
    while(p != finalLC(lista)){
        Operacion aux = recuperaLC(lista,p);
        
        //comprobamos si el op es una etiqueta o el nombre de una instruccion
        if(strstr(aux.op, "$l") != NULL){
            //para las etiquetas
            printf("%s:",aux.op);
        }
        else{
          //para el resto
          printf("%s",aux.op);
        }
        
        if (aux.res != NULL) printf(" %s",aux.res);
        if (aux.arg1 != NULL) printf(",%s",aux.arg1);
        if (aux.arg2 != NULL) printf(",%s",aux.arg2);
        printf("\n");
        p = siguienteLC(lista,p);

    }
}

int buscaRegistroVacio(int *registros){
  for (int i = 0 ; i < 10 ; i = i + 1){
      if(registros[i] == 0){
          registros[i] = 1;
          //printf("cogido = %d\n", i);
          return i;
      }
  }

  return -1;
}

void liberaRegistro(int *registros, char indice){
    int indiceNumerico = indice - '0';
    //printf("liberado = %d\n", indiceNumerico);
    registros[indiceNumerico] = 0;
}

char* obtenerRegistro(int indiceRegistro) {
    char aux[32];
    sprintf(aux,"$t%d",indiceRegistro);
    return strdup(aux);
}

char *obtenerCadena(int contCadenas) {
    char aux[32];
    sprintf(aux,"$str%d",contCadenas);
    return strdup(aux);
}

char *agregarGuionBajo(char *cadena) {
    char *nueva_cadena = malloc(strlen(cadena) + 2);
    if (nueva_cadena == NULL) {
        return NULL;
    }
    strcpy(nueva_cadena, "_");
    strcat(nueva_cadena, cadena);

    return nueva_cadena;
}

void seccionTexto(){
  printf("    .text\n\n");
  printf("    .globl main\n");
  printf("main:\n");
  printf("# Aqui comienzan las instrucciones del programa\n");
}

void seccionFin(){
  printf("\n# Fin\n");
  printf("    li $v0, 10\n");
  printf("    syscall\n");
}



