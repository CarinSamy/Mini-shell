
%{
// Include necessary headers and declarations

extern "C" 
{
    int yylex();
    void yyerror (char const *s);
}

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>

#include "command.h"
%}

%token <string_val> WORD
%token NOTOKEN GREAT NEWLINE LESS APPEND PIPE AMPERSAND INT EXIT_COMMAND GGAMP SMALL
%union {
    char *string_val;
}

%%

goal: commands;

commands: command
        | commands command
        | commands PIPE command
        
        ;

command: EXIT_COMMAND NEWLINE {
        printf("\t Goodbye\n");
        exit(0);
    }
    | simple_command
    ;

simple_command:	
	pipe_command iobgmodifiers NEWLINE {
		printf("   Yacc: Execute command\n");
		Command::_currentCommand.execute();
	}
	| NEWLINE
	| error NEWLINE { yyerrok; }
	;
//command for pipe
pipe_command:
	pipe_command PIPE command_and_args
	| command_and_args
	;

command_and_args: command_word arg_list {
        Command::_currentCommand.insertSimpleCommand(Command::_currentSimpleCommand);
    }
    ;
iobgmodifiers:
	background_opt
	| iomodifier_opt
	| iobgmodifiers background_opt
	| background_opt iomodifier_opt
	;

arg_list: arg_list argument
        | /* can be empty */
        ;

argument: WORD {
        printf("   Yacc: insert argument \"%s\"\n", $1);
        Command::_currentSimpleCommand->insertArgument($1);
    }
    ;

command_word: WORD {
        printf("   Yacc: insert command \"%s\"\n", $1);
        Command::_currentSimpleCommand = new SimpleCommand();
        Command::_currentSimpleCommand->insertArgument($1);
    }
    ;

iomodifier_opt: GREAT WORD {
        printf("   Yacc: insert output \"%s\"\n", $2);
        Command::_currentCommand._outFile = $2;
    }
    | APPEND WORD {
        printf("   Yacc: append output \"%s\"\n", $2);
        Command::_currentCommand._outFile = $2;
        Command::_currentCommand._append = 1;
    }
    | GGAMP WORD {
        printf("   Yacc: append output and error to same file \"%s\"\n", $2);
        Command::_currentCommand._outFile = $2;
        Command::_currentCommand._errFile = $2;
        Command::_currentCommand._append = 1;
        Command::_currentCommand._freeonce = 1;
    }
    | /* can be empty */
    ;

iomodifier_ipt:
	SMALL WORD {
		printf("   Yacc: insert input \"%s\"\n", $2);
		Command::_currentCommand._inputFile = $2;
	}
	| /* can be empty */ 
	;
background_opt:
	 AMPERSAND	{
		printf ("	Yacc: insert background operation\n");
		Command::_currentCommand._background = 1;
	}
	;

%%
void yyerror(const char *s) {
    fprintf(stderr, "%s", s);
}

