%{
#include <stdio.h>
#include "TeaplAst.h"
extern A_pos pos;
extern A_program root;

extern int yylex(void);
extern "C"{
extern void yyerror(char *s); 
extern int  yywrap();
}

%}


// TODO:
// your parser

%union
{
    A_pos pos;

    A_program prog;
    A_programElement proge;
    A_programElementList progel;
    
    A_varDeclStmt vdst;
    A_varDecl vdl;
    A_varDeclList vdlList;

    A_varDef vdf;
    A_type tp;
    A_structDef sdf;
    A_rightVal rv;
    A_rightValList rvl;
    A_arithExpr arie;
    A_memberExpr member;
    A_indexExpr index;
    A_arrayExpr arr;
    A_exprUnit eu;
    A_boolUnit bu;

    A_fnDeclStmt fndst;
    A_paramDecl pdl;
    A_fnDecl fdl;
    A_fnDef fndef;
    A_codeBlockStmt cbst;
    A_codeBlockStmtList cbstl;
    A_assignStmt asst;
    A_leftVal lv;
    A_callStmt callst;
    A_fnCall fcall;
    A_returnStmt retst;
    A_ifStmt ifst;
    A_whileStmt wst;
    A_boolExpr ber;
    A_comExpr cmpe;


    A_tokenId tokenId;
    A_tokenNum tokenNum;
    int a;
}

// token的类
%token <tokenNum> NUM
%token <tokenId> ID
%token <pos> OP_ADD OP_SUB OP_MUL OP_DIV
%token <pos> B_AND B_OR
%token <pos> B_NOT
%token <pos> LT LE GT GE EQ NE
%token <pos> RET IF ELSE WHILE BREAK CONTINUE LET FN STRUCT INT ARROW SEMIC


%left SEMIC
%left ','
%left WHILE
%left IF
%left ELSE
%left ID
%right LET
%left '='
%left B_OR
%left B_AND
%left LT LE GT GE EQ NE
%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%right B_NOT
%right '['
%left ']'
%left '.'
%right '('
%left ')'


// 非终结符的类
%type <prog> program
%type <proge> programElement
%type <progel> programElementList
%type <vdst> varDeclStmt
%type <vdl> varDecl
%type <vdlList> varDeclList
%type <vdf> varDef
%type <tp> type
%type <sdf> structDef
%type <rv> rightVal
%type <rvl> rightValList
%type <arie> arithExpr
%type <eu> exprUnit
%type <bu> boolUnit
%type <member> memberExpr
%type <index> indexExpr
%type <arr> arrayExpr
%type <fndst> fnDeclStmt
%type <pdl> paramDecl
%type <fdl> fnDecl
%type <fndef> fnDef
%type <cbst> codeBlockStmt
%type <cbstl> codeBlockStmtList
%type <asst> assignStmt
%type <lv> leftVal
%type <callst> callStmt
%type <fcall> fnCall
%type <retst> retStmt
%type <ifst> ifStmt
%type <wst> whileStmt
%type <ber> boolExpr
%type <cmpe> comExpr

%start program

%%
//规则部分
program:
        programElementList
        {
            root = A_Program($1);
            $$ = A_Program($1);
        }
        ;
programElementList:
        programElement programElementList
        {
            $$ = A_ProgramElementList($1, $2);
        }
        |
        {
            $$ = NULL;
        }
        ;
programElement:
        SEMIC
        {
            $$ = A_ProgramNullStmt($1);
        }
        | varDeclStmt
        {
            $$ = A_ProgramVarDeclStmt($1->pos, $1);
        }
        | structDef
        {
            $$ = A_ProgramStructDef($1->pos, $1);
        }
        | fnDeclStmt
        {
            $$ = A_ProgramFnDeclStmt($1->pos, $1);
        }
        | fnDef
        {
            $$ = A_ProgramFnDef($1->pos, $1);
        }
        ;      
varDeclStmt:
        LET varDecl SEMIC
        {
            $$ = A_VarDeclStmt($1, $2);
        }
        | LET varDef SEMIC
        {
            $$ = A_VarDefStmt($1, $2);
        }
        ;
varDecl:
        ID ':' type
        {
            $$ = A_VarDecl_Scalar($1->pos, A_VarDeclScalar($1->pos, $1->id, $3));
        }
        | ID '[' NUM ']' ':' type
        {
            $$ = A_VarDecl_Array($1->pos, A_VarDeclArray($1->pos, $1->id, $3->num, $6));
        }
        ;
varDef: ID ':' type '=' rightVal
        {
            $$ = A_VarDef_Scalar($1->pos, A_VarDefScalar($1->pos, $1->id, $3, $5));
        }
        | ID '[' NUM ']' ':' type '=' '{' rightValList '}'
        {
            $$ = A_VarDef_Array($1->pos,A_VarDefArray($1->pos, $1->id, $3->num, $6, $9));
        }
        ;
type:   INT
        {
            $$ = A_NativeType($1, A_intTypeKind);
        }
        | ID
        {
            $$ = A_StructType($1->pos, $1->id);
        }
        ;  
structDef:
        STRUCT ID '{' varDeclList '}'
        {
            $$ = A_StructDef($1, $2->id, $4);
        }
        ;
varDeclList:
        {
            $$ = NULL;
        }
        | varDecl
        {
            $$ = A_VarDeclList($1, NULL);
        }
        | varDecl ',' varDeclList
        {
            $$ = A_VarDeclList($1, $3);
        }
        ;
rightVal:
        arithExpr
        {
            $$ = A_ArithExprRVal($1->pos, $1);
        }
        | boolExpr
        {
            $$ = A_BoolExprRVal($1->pos, $1);
        }
        ;
rightValList:
        rightVal ',' rightValList
        {
            $$ = A_RightValList($1, $3);
        }
        | rightVal
        {
            $$ = A_RightValList($1, NULL);
        }
        |
        {
            $$ = NULL;
        }
        ;
memberExpr:
        leftVal '.' ID
        {
            $$ = A_MemberExpr($1->pos, $1, $3->id);
        }
        ;
indexExpr:
        NUM
        {
            $$ = A_NumIndexExpr($1->pos, $1->num);
        }
        | ID
        {
            $$ = A_IdIndexExpr($1->pos, $1->id);
        }
        ;
arrayExpr:
        leftVal '[' indexExpr ']'
        {
            $$ = A_ArrayExpr($1->pos, $1, $3);
        }
        ;
exprUnit:
        NUM
        {
            $$ = A_NumExprUnit($1->pos, $1->num);
        }
        | ID
        {
            $$ = A_IdExprUnit($1->pos, $1->id);
        }
        | fnCall
        {
            $$ = A_CallExprUnit($1->pos, $1);
        }
        | '(' arithExpr ')'
        {
            $$ = A_ArithExprUnit($2->pos, $2);
        }
        | memberExpr
        {
            $$ = A_MemberExprUnit($1->pos, $1);
        }
        | arrayExpr
        {
            $$ = A_ArrayExprUnit($1->pos, $1);
        }
        | OP_SUB exprUnit
        {
            $$ = A_ArithUExprUnit($1, A_ArithUExpr($1, A_neg,$2));
        }
        ;
fnDecl: FN ID '(' paramDecl ')' 
        {
            $$ = A_FnDecl($1, $2->id, $4, NULL);
        } 
        | FN ID '(' paramDecl ')' ARROW type
        {
            $$ = A_FnDecl($1, $2->id, $4, $7);
        }
        ;
fnDeclStmt:
        fnDecl SEMIC
        {
            $$ = A_FnDeclStmt($1->pos, $1);
        }
        ;
paramDecl:
        varDeclList
        {
            $$ = A_ParamDecl($1);
        }
        ;
fnDef:  fnDecl '{' codeBlockStmtList '}'
        {
            $$ = A_FnDef($1->pos, $1, $3);
        }
        ;

arithExpr:
        arithExpr OP_ADD arithExpr
        {
            $$ = A_ArithBiOp_Expr($1->pos, A_ArithBiOpExpr($1->pos, A_add, $1, $3));
        }
        | arithExpr OP_SUB arithExpr
        {
            $$ = A_ArithBiOp_Expr($1->pos, A_ArithBiOpExpr($1->pos, A_sub, $1, $3));
        }
        | arithExpr OP_MUL arithExpr
        {
            $$ = A_ArithBiOp_Expr($1->pos, A_ArithBiOpExpr($1->pos, A_mul, $1, $3));
        }
        | arithExpr OP_DIV arithExpr
        {
            $$ = A_ArithBiOp_Expr($1->pos, A_ArithBiOpExpr($1->pos, A_div, $1, $3));
        }
        | exprUnit
        {
            $$ = A_ExprUnit($1->pos, $1);
        }
        ;
codeBlockStmtList:
        {
            $$ = NULL;
        }
        | codeBlockStmt codeBlockStmtList
        {
            $$ = A_CodeBlockStmtList($1, $2);
        }
        ;
codeBlockStmt:
        varDeclStmt
        {
            $$ = A_BlockVarDeclStmt($1->pos, $1);
        }
        | assignStmt
        {
            $$ = A_BlockAssignStmt($1->pos, $1);
        }
        | callStmt
        {
            $$ = A_BlockCallStmt($1->pos, $1);
        }
        | retStmt
        {
            $$ = A_BlockReturnStmt($1->pos, $1);
        }
        | ifStmt
        {
            $$ = A_BlockIfStmt($1->pos, $1);
        }
        | whileStmt
        {
            $$ = A_BlockWhileStmt($1->pos, $1);
        }
        | BREAK SEMIC
        {
            $$ = A_BlockBreakStmt($1);
        }
        | CONTINUE SEMIC
        {
            $$ = A_BlockContinueStmt($1);
        }
        | SEMIC
        {
            $$ = A_BlockNullStmt($1);
        }
        ;
assignStmt:
        leftVal '=' rightVal SEMIC
        {
            $$ = A_AssignStmt($1->pos, $1, $3);
        }
        ;
leftVal:ID
        {
            $$ = A_IdExprLVal($1->pos, $1->id);
        }
        | arrayExpr
        {
            $$ = A_ArrExprLVal($1->pos, $1);
        }
        | memberExpr
        {
            $$ = A_MemberExprLVal($1->pos, $1);
        }
        ;
callStmt:
        fnCall SEMIC
        {
            $$ = A_CallStmt($1->pos, $1);
        }
        ;
fnCall:
        ID '(' rightValList ')'
        {
            $$ = A_FnCall($1->pos, $1->id, $3);
        }
        ;

retStmt:
        RET rightVal SEMIC
        {
            $$ = A_ReturnStmt($1, $2);
        }
        | RET SEMIC
        {
            $$ = A_ReturnStmt($1, NULL);
        }
        ;
ifStmt: IF '(' boolExpr ')' '{' codeBlockStmtList '}'
        {
            $$ = A_IfStmt($1, $3, $6, NULL);
        }
        | IF '(' boolExpr ')' '{' codeBlockStmtList '}' ELSE '{' codeBlockStmtList '}' 
        {
            $$ = A_IfStmt($1, $3, $6, $10);
        }
        ;
whileStmt:
        WHILE '(' boolExpr ')' '{' codeBlockStmtList '}'
        {
            $$ = A_WhileStmt($1, $3, $6);
        }
        ;
boolExpr:
        boolExpr B_OR boolExpr
        {
            $$ = A_BoolBiOp_Expr($1->pos, A_BoolBiOpExpr($1->pos, A_or, $1, $3));
        }
        | boolExpr B_AND boolExpr
        {
            $$ = A_BoolBiOp_Expr($1->pos, A_BoolBiOpExpr($1->pos, A_and, $1, $3));        
        }
        | boolUnit
        {
            $$ = A_BoolExpr($1->pos, $1);
        }
        ;
boolUnit:
         comExpr 
        {
            $$ = A_ComExprUnit($1->pos, $1);
        }
        | '(' boolExpr ')' 
        {
            $$ = A_BoolExprUnit($2->pos, $2);
        }
        | B_NOT boolUnit
        {
            $$ = A_BoolUOpExprUnit($1, A_BoolUOpExpr($1, A_not, $2));
        }
        ;
comExpr: exprUnit GT exprUnit
        {
            $$ = A_ComExpr($1->pos, A_gt, $1, $3);
        }
        | exprUnit GE exprUnit
        {
            $$ = A_ComExpr($1->pos, A_ge, $1, $3);
        }
        | exprUnit LT exprUnit
        {
            $$ = A_ComExpr($1->pos, A_lt, $1, $3);
        }
        | exprUnit LE exprUnit
        {
            $$ = A_ComExpr($1->pos, A_le, $1, $3);
        }
        | exprUnit EQ exprUnit
        {
            $$ = A_ComExpr($1->pos, A_eq, $1, $3);
        }
        | exprUnit NE exprUnit
        {
            $$ = A_ComExpr($1->pos, A_ne, $1, $3);
        }
        ;

%%
//辅助函数
extern "C"{
void yyerror(char * s)
{
  fprintf(stderr, "%s\n",s);
}
int yywrap()
{
  return(1);
}
}


