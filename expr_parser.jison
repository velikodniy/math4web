%lex

%%
\s+				{}
[0-9]+(("."|",")[0-9]+)?\b   	{return 'NUMBER';}
"*"                   		{return '*';}
"/"                   		{return '/';}
"-"                   		{return '-';}
"+"                   		{return '+';}
"^"                   		{return '^';}
"("                   		{return '(';}
")"                   		{return ')';}
"PI"                  		{return 'PI';}
"E"                   		{return 'E';}
"sqrt"				{return 'SQRT';}
"sin"				{return 'SIN';}
<<EOF>>               		{return 'EOF';}
[a-z]				{return 'VARIABLE';}

/lex

%start expression

%{
	function pstrip(s) {
		 return s.replace(/^\\left\((.*)\\right\)$/, '$1');
	}
%}

%%

expression
	: expr EOF		{return $1;}
	;

expr
	: term			{$$ = $1;}
	| expr '+' term		{$$ = $1 + '+' + $3;}
	| expr '-' term		{$$ = $1 + '-' + $3;}
	;
	
term
	: factor		{$$ = $1;}
	| term '*' factor	{$$ = $1 + ' \\cdot ' + $3;}
	| term factorx		{$$ = $1 + ' \\cdot ' + $2;}
	| term '/' factor	{$$ = '\\frac{' + pstrip($1) + '}{' + pstrip($3) + '}';}
	;


factor
	: factorx		{$$ = $1;}
	| '-' factor		{$$ = '-' + $2;}
	| '+' factor		{$$ = '+' + $2;}
	;

factorx
	: primary		{$$ = $1;}
	| primary '^' factorx	{$$ = '{' + $1 + '}^{' + $3 + '}';}
	;

primary
	: '(' expr ')' 		{$$ = '\\left({' + $2 + '}\\right)';}
	| efun			{$$ = $1;}
	| lit			{$$ = $1;}
	;

lit
	: num			{$$ = $1;}
	| var			{$$ = $1;}
	;

efun
	: fun '(' expr ')'	{$$ = $1 + '{' + $3 + '}';}
	| fun lit		{$$ = $1 + '{' + $2 + '}';}
	| fun efun		{$$ = $1 + $2;}
	;

fun
	: SQRT			{$$ = '\\sqrt';}
	| SIN			{$$ = '\\sin';}
	;

num
	: NUMBER		{$$ = yytext.replace(/\.|,/g, '{,}');}
	;

var
	: E			{$$ = '\\mathrm{e}';}
	| PI			{$$ = '\\pi';}
	| VARIABLE		{$$ = yytext;}
	;