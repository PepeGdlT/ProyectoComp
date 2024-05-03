%{
#include "listaCodigo.h"
#include "miniC.tab.h"
#include "listaSimbolos.h"
#include <stdlib.h>
#include <math.h>
void error_lexico();
int longitud_entero();
int longitud_id();
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+		   
escape		    [\n|\t]
%s		    COM_MUL

%option		    yylineno

%%
[ \n\t]+                                    ;
var                                         return VAR;
const                                       return CONST;
if                                          return IF;
else                                        return ELSE;
while                                       return WHILE;
print					                    return PRINT;
read                                        return READ;
do                                          return DO;

\"([^"\n]|\\.)*\"			    			{yylval.cadena=strdup(yytext);return CADENA;}
({letra}|_)({letra}|{digito}|_)*     	    return longitud_id();	
{entero}                                    return longitud_entero();

";"                                         return PUNCOM;
","                                         return COMMA;
"+"                                         return PLUSOP;
"-"                                         return MINUSOP;
"*"                                         return MULTOP;
"/"                                         return DIVOP;
"="                                         return ASSIGNOP;
"("                                         return APAREN;		
")"                                         return CPAREN;
"{"					                        return ALLAVE;
"}"					                        return CLLAVE;
">"											return GT;
"<"											return LT;
"!"											return DIST;

"//"(.*)[\n]                        	    ;
"/*"                    		            BEGIN COM_MUL;
<COM_MUL>[^*]*             		            ;
<COM_MUL>[*]+[^*/]*        	    	        ;
<COM_MUL>[*]+[/]           		            BEGIN 0;

[^[0-9]|[a-zA-Z]|[0-9]+|\n|\t] 	    	    {error_lexico();}

%%

void error_lexico()
{
	printf("Error en la linea %d carácter %s\n", yylineno, yytext);

}

int longitud_entero()
{
	if (atoll(yytext) > pow(2,31)){
		printf("Error longitud entero %s\n", yytext);
	}
	yylval.cadena=strdup(yytext);
	return INT;

}

int longitud_id()
{
	if (yyleng > 32){
		printf("\nError longitud identificador %s\n", yytext);
	}
	yylval.cadena=strdup(yytext);
	return ID;
}








