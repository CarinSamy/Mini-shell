
/*
 *
 * CS-413 Spring 98
 * shell.l: lexical analyzer for shell
 * You have to extend it.
 *
 */

%{
#include <string.h>
#include "y.tab.h"
%}

%%

\n {
    return NEWLINE;
}

[ \t]+ {
    // Ignore whitespace
}

">" {
    return GREAT;
}

"<" {
    return LESS;
}

">>" {
    return APPEND;
}

"|" {
    return PIPE;
}
"exit"	{	
	return EXIT_COMMAND;
	
	}  	

"&" {
    return AMPERSAND;
}
"&>>"	{
	return GGAMP;	
	}
"small"         {
	 return SMALL; 
	 }
[0-9]+ {
    // Example: To recognize integers, you can handle them here.
    yylval.string_val = strdup(yytext);
    return INT;
}

[^ <>|&\t\n][^ <>|&\t\n]*  {
		/* Assume that file names have only alpha chars */
		yylval.string_val = strdup(yytext);
		return WORD;
}

. {
    // Handle unrecognized characters as an error
    fprintf(stderr, "Unrecognized character: %s\n", yytext);
}

%%
int yywrap() {
    return 1;
}

