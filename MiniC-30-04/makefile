miniC: main.c miniC.tab.c lex.yy.c miniC.tab.h listaSimbolos.c listaCodigo.h listaCodigo.c
	gcc lex.yy.c main.c listaSimbolos.c listaCodigo.c miniC.tab.c -lfl -o miniC
miniC.tab.c miniC.tab.h: miniC.y
	bison -d -v miniC.y
lex.yy.c: miniC.l
	flex miniC.l
limpia:
	rm lex.yy.c miniC.tab.c miniC.tab.h miniC.output miniC miniC.exe
run: 
	./miniC p
