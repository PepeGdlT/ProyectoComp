
%{
#include <stdio.h>
#include <string.h>
#include "listaSimbolos.h"
#include "listaCodigo.h"
Lista tablaSimb;
int contCadenas = 1;
Tipo tipo;
int registros[10] = {0,0,0,0,0,0,0,0,0,0};
void yyerror();
extern int yylex();
extern int yylineno;
extern char *yytext;
int contadorEtiquetas = 1;
char * obtenerEtiqueta();
%}

%expect 1 /*Conflicto desplazamiento/reduccion, donde se prefiere el desplazamiento, para la documentacion*/

%union{

char *cadena;
ListaC codigo;
}


%type <codigo> expression statement statement_list print_list read_list identifier identifier_list declarations print_item

%token VAR CONST IF ELSE WHILE PRINT READ PUNCOM COMMA ASSIGNOP APAREN CPAREN ALLAVE CLLAVE DO GT LT DIST

%token <cadena> CADENA ID INT
%left GT LT DIST ASSIGNOP 
%left PLUSOP MINUSOP
%left MULTOP DIVOP
%token UMENOS


%%

program : {tablaSimb=creaLS();}	ID APAREN CPAREN ALLAVE declarations statement_list CLLAVE 
    {
        seccionDatos(tablaSimb); 
        liberaLS(tablaSimb);
        
        
        seccionTexto();
        

        concatenaLC($6,$7);
        imprimeTablaC($6);
        seccionFin(); 
        liberaLC($7);
    }
	;

declarations: declarations VAR {tipo=VARIABLE;} identifier_list PUNCOM
    {
        $$ = $1;
        concatenaLC($$, $4);
        liberaLC($4);
    }
	| declarations CONST {tipo=CONSTANTE;} identifier_list PUNCOM
    {  
        $$ = $1;
        concatenaLC($$, $4);
        liberaLC($4);
    }
	| /*lambda*/ 
    {
        $$ = creaLC();
    }
	;

	
identifier_list:  identifier
    {
        $$ = $1;
    }
	| identifier_list COMMA identifier
    {
        $$ = $1;
        concatenaLC($$, $3);
        liberaLC($3);
    }
	;
identifier: ID
    {
        if (perteneceTablaS($1,tablaSimb) == false) anadeEntrada($1,tipo,tablaSimb,0);
        else printf("Identifier: Variable %s ya declarada \n",$1);

        $$ = creaLC();
    }
	| ID ASSIGNOP expression
	{
        if (perteneceTablaS($1,tablaSimb) == false) anadeEntrada($1,tipo,tablaSimb,0);
        else printf("Identifier: Variable %s ya declarada \n",$1);

        
        $$ = $3;
        Operacion oper;
        oper.op = "sw";
        char * res = recuperaResLC($3);
        oper.res = res;
        oper.arg1 = agregarGuionBajo($1);
        oper.arg2 = NULL;
        
        liberaRegistro(registros,res[2]);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
      
	}
	;
	
	
statement_list: statement_list statement 
    {
        $$ = $1;
        concatenaLC($$, $2); 
        liberaLC($2);
        
        //imprimeTablaC($$);
    }
	| /*lambda*/ 
    {
        $$ = creaLC(); 
    }
	;
	

statement: ID ASSIGNOP expression PUNCOM
    {
        if (perteneceTablaS($1,tablaSimb) == false) printf("Statement: Variable %s no declarada \n",$1);
        else if (esConstante($1,tablaSimb)) printf("Asignación a constante\n");



        $$=$3;
        Operacion oper;
        oper.op = "sw";
        oper.arg1 = agregarGuionBajo($1);
        oper.arg2 = NULL;
        char * res = recuperaResLC($3);
        oper.res = res;
        liberaRegistro(registros,res[2]);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);
 


    }
	| ALLAVE statement_list CLLAVE
    {
        $$ = $2;
    }
	| IF APAREN expression CPAREN statement ELSE statement
    {
            char * etiqueta1 = obtenerEtiqueta();
            char * etiqueta2 = obtenerEtiqueta();
            
            //codigo expression
            $$ = $3;
            char * res = recuperaResLC($3);
            Operacion oper;
            oper.op = "beqz";
            oper.res = res;
            oper.arg1 = etiqueta1; 
            oper.arg2 = NULL;
            
            liberaRegistro(registros, res[2]);
            guardaResLC($$, oper.res);
            insertaLC($$, finalLC($$), oper);
            

            //si no se da el salto, se ejecutan las instrucciones de $5  
            concatenaLC($$,$5);
            liberaLC($5);
            
            
            //brunch a la continuacion del codigo
            oper.op = "b";
            oper.res = etiqueta2;
            oper.arg1 = NULL;
            oper.arg2 = NULL;
            insertaLC($$, finalLC($$), oper);
            

            //etiqueta 1
            oper.op = etiqueta1;
            oper.res = NULL;
            oper.arg1 = NULL;
            oper.arg2 = NULL;
            insertaLC($$, finalLC($$), oper);
            

            //si se da el primer salto, se ejecutan las instrucciones de $7  
            concatenaLC($$,$7);
            oper.op = etiqueta2;
            oper.res = NULL;
            oper.arg1 = NULL;
            oper.arg2 = NULL;
            insertaLC($$, finalLC($$), oper);
            liberaLC($7);

    }
	| IF APAREN expression CPAREN statement     
    {
            $$ = $3;
            char * res = recuperaResLC($3);
            Operacion oper;
            oper.op = "beqz";
            oper.res = res;
            char * etiqueta = obtenerEtiqueta();
            oper.arg1 = etiqueta; 
            oper.arg2 = NULL;
            
            liberaRegistro(registros, res[2]);
            guardaResLC($$, oper.res);
            insertaLC($$, finalLC($$), oper);
            

            
            concatenaLC($$,$5);
            oper.op = etiqueta;
            oper.res = NULL;
            oper.arg1 = NULL;
            oper.arg2 = NULL;
            insertaLC($$, finalLC($$), oper);
            liberaLC($5);

    }
	| WHILE APAREN expression CPAREN statement 
    {
        char * etiqueta1 = obtenerEtiqueta();
        char * etiqueta2 = obtenerEtiqueta();

        $$ = creaLC();
        Operacion oper;
        
        //etiqueta1
        oper.op = etiqueta1;
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        insertaLC($$, finalLC($$), oper);


        //expression.codigo   
        concatenaLC($$, $3);
        char * res = recuperaResLC($3); 
        liberaLC($3);
        oper.op = "beqz";
        oper.res = res;
        oper.arg1 = etiqueta2; 
        oper.arg2 = NULL;
        
        liberaRegistro(registros, res[2]);    
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
    
        //statement.codigo etiqueta1   
        concatenaLC($$,$5);
        liberaLC($5); 


        //b etiqueta1
        oper.op = "b";
        oper.res = etiqueta1;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        insertaLC($$, finalLC($$), oper);
               
        
        //etiqueta2
        oper.op = etiqueta2;
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);
    }
	| PRINT APAREN print_list CPAREN PUNCOM
    {
        $$ = $3;
        //imprimeTablaC($$);
    }
	| READ APAREN read_list CPAREN PUNCOM
    {
        $$ = $3;
        //imprimeTablaC($$);
    }
	| DO statement WHILE APAREN expression CPAREN PUNCOM
        {
            char * etiqueta1 = obtenerEtiqueta();
            $$ = creaLC();
            Operacion oper;

            //etiqueta1
            oper.op = etiqueta1;
            oper.res = NULL;
            oper.arg1 = NULL;
            oper.arg2 = NULL;
            insertaLC($$, finalLC($$), oper);

            //statement.codigo
            concatenaLC($$, $2);
            liberaLC($2);

            //expression.codigo
            concatenaLC($$, $5);
            char * res = recuperaResLC($5);
            liberaLC($5);
            oper.op = "bnez";
            oper.res = res;
            oper.arg1 = etiqueta1;
            oper.arg2 = NULL;

            liberaRegistro(registros, res[2]);
            guardaResLC($$, oper.res);
            insertaLC($$, finalLC($$), oper);
        }
    ;

print_list: print_item
    {
        $$ = $1;
    }
	| print_list COMMA print_item
    {
        concatenaLC($1, $3);
        $$ = $1;
        liberaLC($3);

    }
	;
	
	
print_item: expression
    {
        $$ = $1;
        char * arg1 = recuperaResLC($1);
        Operacion oper;

        oper.op =  "move";
        oper.res = "$a0";
        oper.arg1 = arg1;
        oper.arg2 = NULL;
        liberaRegistro(registros, arg1[2]);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        
        
        oper.op =  "li";
        oper.res = "$v0";
        oper.arg1 = " 1";
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

        oper.op =  "syscall";
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

    }
	| CADENA
	{
        //parte de la seccion de datos
        $$ = creaLC();

        Operacion oper;
        oper.op =  "la";
        oper.res = "$a0";
        oper.arg1 = obtenerCadena(contCadenas);
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

            
        oper.op =  "li";
        oper.res = "$v0";
        oper.arg1 = " 4";
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

        oper.op =  "syscall";
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

        //parte de la seccion de datos
        anadeEntrada($1,STRING,tablaSimb,contCadenas++);



	}
	;
	
read_list : ID
      {
        if (perteneceTablaS($1,tablaSimb) == false) printf("Read_list: Variable %s no declarada \n",$1);
        else if (esConstante($1,tablaSimb)) printf("Asignación a constante\n");
       
        $$ = creaLC();
        
        Operacion oper;
        oper.op =  "li";
        oper.res = "$v0";
        oper.arg1 = " 5";
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);


        oper.op =  "syscall";
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper); 

        oper.op =  "sw";
        oper.res = "$v0";
        oper.arg1 = agregarGuionBajo($1);
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

      }
	  | read_list COMMA ID
	  {
        if (perteneceTablaS($3,tablaSimb) == false) printf("Read_list: Variable %s no declarada \n",$3);
        else if (esConstante($3,tablaSimb)) printf("Asignación a constante\n");

        $$ = $1;
        
        Operacion oper;
        oper.op =  "li";
        oper.res = "$v0";
        oper.arg1 = "5";
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);


        oper.op =  "syscall";
        oper.res = NULL;
        oper.arg1 = NULL;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper); 

        oper.op =  "sw";
        oper.res = "$v0";
        oper.arg1 = agregarGuionBajo($3);
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);

	  }
	  ;
	
expression:
    expression PLUSOP expression
    {
        concatenaLC($1, $3);
        $$ = $1;
        char* arg2 = recuperaResLC($3);
        liberaLC($3);
        Operacion oper;
        oper.op = "add";
        char* arg1 = recuperaResLC($1);
        oper.arg1 = arg1;
        liberaRegistro(registros, arg1[2]);
        oper.arg2 = arg2;
        liberaRegistro(registros, arg2[2]);
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);
    }
	| expression MINUSOP expression
	{
        concatenaLC($1, $3);
        $$ = $1;
        char* arg2 = recuperaResLC($3);
        liberaLC($3);
        Operacion oper;
        oper.op = "sub";
        char* arg1 = recuperaResLC($1);
        oper.arg1 = arg1;
        liberaRegistro(registros, arg1[2]);
        oper.arg2 = arg2;
        liberaRegistro(registros, arg2[2]);
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);
	}
	| expression MULTOP expression
	{
        concatenaLC($1, $3);
        $$ = $1;
        char* arg2 = recuperaResLC($3);
        liberaLC($3);
        Operacion oper;
        oper.op = "mul";
        char* arg1 = recuperaResLC($1);
        oper.arg1 = arg1;
        liberaRegistro(registros, arg1[2]);
        oper.arg2 = arg2;
        liberaRegistro(registros, arg2[2]);
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);
    }
	| expression DIVOP expression
	{
         concatenaLC($1, $3);
         $$ = $1;
         char* arg2 = recuperaResLC($3);
         liberaLC($3);
         Operacion oper;
         oper.op = "div";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);
	} 
    | expression GT expression         
    {
         concatenaLC($1, $3);
         $$ = $1;
         char* arg2 = recuperaResLC($3);
         liberaLC($3);
         Operacion oper;
         oper.op = "sgt";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);
    }
    | expression GT ASSIGNOP expression         
    {
          concatenaLC($1, $4);
         $$ = $1;
         char* arg2 = recuperaResLC($4);
         liberaLC($4);
         Operacion oper;
         oper.op = "sge";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);           
    }
    | expression LT  expression         
    {
         concatenaLC($1, $3);
         $$ = $1;
         char* arg2 = recuperaResLC($3);
         liberaLC($3);
         Operacion oper;
         oper.op = "slt";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);           
    }
    | expression LT ASSIGNOP expression         
    {
         concatenaLC($1, $4);
         $$ = $1;
         char* arg2 = recuperaResLC($4);
         liberaLC($4);
         Operacion oper;
         oper.op = "sle";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);            
    }
    | expression ASSIGNOP ASSIGNOP expression         
    {
         concatenaLC($1, $4);
         $$ = $1;
         char* arg2 = recuperaResLC($4);
         liberaLC($4);
         Operacion oper;
         oper.op = "seq";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);            
    }
    | expression DIST ASSIGNOP expression         
    {
         concatenaLC($1, $4);
         $$ = $1;
         char* arg2 = recuperaResLC($4);
         liberaLC($4);
         Operacion oper;
         oper.op = "sne";
         char* arg1 = recuperaResLC($1);
         oper.arg1 = arg1;
         liberaRegistro(registros, arg1[2]);
         oper.arg2 = arg2;
         liberaRegistro(registros, arg2[2]);
         int registroValido = buscaRegistroVacio(registros);
         oper.res = obtenerRegistro(registroValido);
         guardaResLC($$, oper.res);
         insertaLC($$, finalLC($$), oper);
         //imprimeTablaC($$);            
    }

	| MINUSOP expression
	{
        $$ = $2;
        Operacion oper;
        oper.op = "neg";
        char* arg1 = recuperaResLC($2);
        liberaRegistro(registros, arg1[2]);
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        oper.arg1 = arg1;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
        //imprimeTablaC($$);

	}
	| APAREN expression CPAREN
	{
        $$ = $2;
        //imprimeTablaC($$);

	}
	| ID
	{
        $$ = creaLC();
        Operacion oper;
        oper.op = "lw";
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        oper.arg1 = agregarGuionBajo($1);
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
    }
	| INT
	{
        $$ = creaLC();
        Operacion oper;
        oper.op = "li";
        int registroValido = buscaRegistroVacio(registros);
        oper.res = obtenerRegistro(registroValido);
        oper.arg1 = $1;
        oper.arg2 = NULL;
        guardaResLC($$, oper.res);
        insertaLC($$, finalLC($$), oper);
	}
	;
%%

char *obtenerEtiqueta() {
    char aux[32];
    sprintf(aux,"$l%d",contadorEtiquetas++);
    return strdup(aux);
}
void yyerror() {
	printf("Error sintactico en linea %d y token %s\n", yylineno, yytext);
}



