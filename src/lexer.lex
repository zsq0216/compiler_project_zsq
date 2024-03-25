%{
#include <stdio.h>
#include <string.h>
#include "TeaplAst.h"
#include "y.tab.hpp"
extern int line, col;//WHY EXTERN?
int in_line_comment=0;
int in_comment=0;
int c;
int calc(char *s, int len);
%}


%%

" " {
    col++;
}
"\t" {
    col+=4;
}
"\n" {
    line++;
    col=1;
    in_line_comment = 0;
}
"//" {
    col+=2;
    if(!in_comment)
    in_line_comment = 1;
}
"*/" {
    col+=2;
    if(!in_line_comment)
    in_comment=0;
}
"/\*" {
    col+=2;
    if(!in_line_comment)
    in_comment=1;
}
"ret" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return RET;
}
"if" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return IF;
}
"else" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return ELSE;
}
"while" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return WHILE;
}
"break" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return BREAK;
}
"continue" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return CONTINUE;
}
"let" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return LET;
}
"fn" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return FN;
}
"struct" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return STRUCT;
}
"int" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return INT;
}
"->" {
    yylval.pos = A_Pos(line, col);
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return ARROW;
}
";" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return SEMIC;
}
">" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return GT;
}
">=" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return GE;
}
"<" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return LT;
}
"<=" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return LE;
}
"==" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return EQ;
}
"!=" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return NE;
}
"+" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return OP_ADD;
}
"-" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return OP_SUB;
}
"*" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return OP_MUL;
}
"/" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return OP_DIV;
}
"&&" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return B_AND;
}
"||" {
    yylval.pos = A_Pos(line, col);
    col+=2;
    if(!in_line_comment && !in_comment)
    return B_OR;
}
"!" {
    yylval.pos = A_Pos(line, col);
    col++;
    if(!in_line_comment && !in_comment)
    return B_NOT;
}
"(" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
")" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"[" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"]" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"{" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"}" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"." {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
":" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"," {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
"=" {
    c = yytext[0];
    col++;
    if(!in_line_comment && !in_comment)
    return(c);
}
[a-z_A-Z][a-z_A-Z0-9]* { 
    yylval.tokenId = A_TokenId(A_Pos(line, col), strdup(yytext));
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return ID;
}
[1-9][0-9]* {
    yylval.tokenNum = A_TokenNum(A_Pos(line, col), calc(yytext,yyleng));
    col+=yyleng;
    if(!in_line_comment && !in_comment)
    return NUM;
}
0 {
    yylval.tokenNum = A_TokenNum(A_Pos(line, col), 0);
    col++;
    if(!in_line_comment && !in_comment)
    return NUM;
}



%%

int calc(char *s, int len) {
    int ret = 0;
    for(int i = 0; i < len; i++)
        ret = ret * 10 + (s[i] - '0');
    return ret;
}
