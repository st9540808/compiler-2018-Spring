/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
    #include <ctype.h>

    struct entry {
        int index;
        const char *id;
        const char *type;
    };

    struct sym_table {
        struct entry *ent;
        int capacity;
        int size;
    };

    struct sym_table *table = NULL;
    char *declaredID = NULL;
    int line = 0;

	/* Symbol table function */
	void create_symbol();
	void insert_symbol();
	int lookup_symbol(const char *);
	void dump_symbol();
%}

/* Define regular expression label */
letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
number {digit}+
EOL [ \t\n]+$
ws [ \t]+
declaration "var"[ \t\n]+{id}[ \t\n]+(int|float32)
literal \"(\\.|[^"])*\"
type (int|float32)

%START VAR TYPE
/* Rules section */
%%

"if"                { printf("%s \t IF Keyword \n"); }
"else"              { printf("%s \t ELSE Keyword \n"); }
"for"               { printf("%s \t FOR Keyword \n"); }
"var"               { printf("%s \t Declaration \n", yytext); BEGIN VAR; }
<VAR>{id}           {
                        printf("'%s' \t Declared ID \n", yytext);
                        declaredID = strdup(yytext);
                        BEGIN TYPE;
                    }
<TYPE>{type}        {
                        printf("%s \t Type \n", yytext);
                        insert_symbol();
                    }
"\n"                { printf("%s \t Newline \n", "\\n"); line++; }
"+"                 { printf("%s \t Add \n", yytext); }
"-"                 { printf("%s \t Sub \n", yytext); }
"*"                 { printf("%s \t Mul \n", yytext); }
"/"                 { printf("%s \t Div \n", yytext); }
"%"                 { printf("%s \t Mod \n", yytext); }
"++"                { printf("%s \t Increment \n", yytext); }
"--"                { printf("%s \t Decrement \n", yytext); }
"="                 { printf("%s \t Assign \n", yytext); }
"+="                { printf("%s \t Add and Assign \n", yytext); }
"-="                { printf("%s \t Sub and Assign \n", yytext); }
"*="                { printf("%s \t Mul and Assign \n", yytext); }
"/="                { printf("%s \t Div and Assign \n", yytext); }
"%="                { printf("%s \t Mod and Assign \n", yytext); }
"<"                 { printf("%s \t Less than \n", yytext); }
">"                 { printf("%s \t Greater than \n", yytext); }
"<="                { printf("%s \t Less than or equal \n", yytext); }
">="                { printf("%s \t Greater than or equal \n", yytext); }
"=="                { printf("%s \t Equal \n", yytext); }
"!="                { printf("%s \t Not equal \n", yytext); }
"&&"                { printf("%s \t Logical and \n", yytext); }
"||"                { printf("%s \t Logical or \n", yytext); }
"!"                 { printf("%s \t Logical not \n", yytext); }
"("                 { printf("%s \t LB \n", yytext); }
")"                 { printf("%s \t RB \n", yytext); }
"{"                 { printf("%s \t LCB \n", yytext); }
"}"                 { printf("%s \t RCB \n", yytext); }
{number}            { printf("%s \t Number \n", yytext); }
{id}                { printf("%s \t ID \n", yytext); }
{id}/"("[^)]*")"    { 
                        char *funName = strdup(yytext);
                        for (int i = 0; funName[i] != '\0'; i++)
                            funName[i] = toupper(funName[i]);
                        printf("%s \t %s Function \n", yytext, funName);
                        free(funName);
                    }
{literal}           {
                        yytext[yyleng-1] = '\0';
                        printf("%c \t LQ \n", '"');
		                printf("%s \t String Literal \n", &yytext[1]);
                        printf("%c \t RQ \n", '"');
                    }
{ws}                {;}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

void create_symbol()
{
    if (!table) {
        table = malloc(sizeof(struct sym_table));
        table->capacity = 2;
        table->size = 1; // index 0 not used
        table->ent = calloc(table->capacity, sizeof(struct entry));
    }
}

void insert_symbol()
{
    if (!table) create_symbol();

    if (table->size + 1 > table->capacity) {
        int sz = sizeof(struct entry) * table->capacity;
        table->ent = realloc(table->ent, sz * 2);
        memset(&table->ent[table->capacity], 0, sz);
        table->capacity *= 2;
    }

    table->ent[table->size].id = declaredID;
    declaredID = NULL;

    table->ent[table->size].type = strdup(yytext);
    table->ent[table->size].index = table->size;
    table->size++;
}

int lookup_symbol(const char *str)
{
    for (int i = 1; i < table->size; i++) {
        if (strcmp(table->ent[i].id, str) == 0) {
            return table->ent[i].index;
        }
    }
    return 0;
}

void dump_symbol()
{
    if (!table) return;

    for (int i = 1; i < table->size; i++) {
        printf("%d %8s %12s\n", 
               table->ent[i].index, table->ent[i].id, table->ent[i].type);
        
        free((void *) table->ent[i].id);
        free((void *) table->ent[i].type);
    }

    free(table->ent);
    free(table);
}


int main(int argc, char *argv[])
{
	yyin = fopen(argv[1],"r");
    yylex();

	dump_symbol();
    printf("%d\n", line);

	return 0;
}
