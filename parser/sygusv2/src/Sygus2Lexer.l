/*
Copyright (c) 2013,
Abhishek Udupa,
Mukund Raghothaman,
The University of Pennsylvania

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

%{
    #include <utility>
    #include <vector>
    #include <SynthLib2ParserIFace.hpp>
    #define MAX_STRING_LEN 131072
    using namespace std;
    using namespace SynthLib2Parser;

    #include "SynthLib2Parser.tab.h"
    /* C includes, etc */
    extern long yylinenum;
    extern long yycolnum;
    char string_buffer[MAX_STRING_LEN];
    int string_buffer_index = 0;
%}

%option noyywrap

%s                      INITIAL
WS                      [ \t\f]
LETTER                  [a-zA-Z_]
UNDERSCORE              "_"
ZERO                    "0"
NONZERO                 [1-9]
DIGIT                   [0-9]
HEXDIGIT                {DIGIT}|[a-f]|[A-F]
BIT                     "0"|"1"
NUMERAL                 {ZERO} | {NONZERO}{DIGIT}+
DECIMAL                 {NUMERAL}"."{ZERO}*{NUMERAL}
HEXCONST                "#x"{HEXDIGIT}+
BINCONST                "#b"{BIT}+
REALCONST               (-?{DIGIT}+"."{DIGIT}+)
SYMBOLCC                [a-z]|[A-Z]|"_"|"+"|"-"|"*"|"&"|"|"|"!"|"~"|"<"|">"|"="|"/"|"%"|"?"|"."|"$"|"^"
SYMBOL                  {SYMBOLCC}({SYMBOLCC}|{DIGIT})*
STRINGCONST             "\""({SYMBOLCC}|{WS}|{DIGIT}|","|"("|")")*"\""
%%

{WS}                    { yycolnum++; }
{UNDERSCORE}            { yycolnum++; }
[\n]                    { yylinenum++; yycolnum = 0; }
";"                     { BEGIN linecomment; yycolnum += 1; }
<linecomment>\n         { BEGIN INITIAL; yylinenum++; yycolnum = 0; }
<linecomment>.          { yycolnum++; }
"declare-datatype"      { yycolnum += strlen(yytext); return TK_DECLARE_DATATYPE;}
"declare-datatypes"     { yycolnum += strlen(yytext); return TK_DECLARE_DATATYPES; }
"define-sort"           { yycolnum += strlen(yytext); return TK_DEFINE_SORT; }
"declare-sort"          { yycolnum += strlen(yytext); return TK_DECLARE_SORT; }
"define-fun"            { yycolnum += strlen(yytext); return TK_DEFINE_FUN; }
"declare-fun"           { yycolnum += strlen(yytext); return TK_DECLARE_FUN; }
"set-option"            { yycolnum += strlen(yytext); return TK_SET_OPTION;}
"set-feature"           { yycolnum += strlen(yytext); return TK_SET_FEATURE;}
"check-synth"           { yycolnum += strlen(yytext); return TK_CHECK_SYNTH; }
"declare-var"           { yycolnum += strlen(yytext); return TK_DECLARE_VAR; }
"synth-fun"             { yycolnum += strlen(yytext); return TK_SYNTH_FUN; }
"synth-inv"             { yycolnum += strlen(yytext); return TK_SYNTH_INV; }
"set-logic"             { yycolnum += strlen(yytext); return TK_SET_LOGIC; }
"constraint"            { yycolnum += strlen(yytext); return TK_CONSTRAINT; }
"inv-constraint"        { yycolnum += strlen(yytext); return TK_INV_CONSTRAINT; }
"("                     { yycolnum += strlen(yytext); return TK_LPAREN; }
")"                     { yycolnum += strlen(yytext); return TK_RPAREN; }
"BitVec"                { yycolnum += strlen(yytext); return TK_BV; }
"Array"                 { yycolnum += strlen(yytext); return TK_ARRAY; }
"Int"                   { yycolnum += strlen(yytext); return TK_INT; }
"Bool"                  { yycolnum += strlen(yytext); return TK_BOOL; }
"Real"                  { yycolnum += strlen(yytext); return TK_REAL; }
"exists"                { yycolnum += strlen(yytext); return TK_EXISTS; }
"forall"                { yycolnum += strlen(yytext); return TK_FORALL; }
"Constant"              { yycolnum += strlen(yytext); return TK_CONSTANT; }
"Variable"              { yycolnum += strlen(yytext); return TK_VARIABLE; }
"let"                   { yycolnum += strlen(yytext); return TK_LET; }
":"                     { yycolnum += strlen(yytext); return TK_COLON; }
"::"                    { yycolnum += strlen(yytext); return TK_DOUBLECOLON; }
"true"                  {
                            yylval.LexerString = new string(yytext);
                            yycolnum += strlen(yytext);
                            return TK_BOOL_CONST;
                        }
"false"                 {
                            yylval.LexerString = new string(yytext);
                            yycolnum += strlen(yytext);
                            return TK_BOOL_CONST;
                        }
{NUMERAL}               {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_NUMERAL;
                        }
{DECIMAL}               {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_DECIMAL;
                        }
{INTCONST}              {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_INT_LITERAL;
                        }
{REALCONST}             {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_REAL_LITERAL;
                        }
{HEXCONST}              {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_HEX_CONST;
                        }
{BINCONST}              {
                            yycolnum += strlen(yytext);
                            yylval.LexerString = new string(yytext);
                            return TK_BIN_CONST;
                        }
{STRINGCONST}           {
                            yycolnum += strlen(yytext);
                            string *SymbolVal = new string(yytext);
                            yylval.LexerString = SymbolVal;
                            return TK_STRING_LITERAL;
                        }
{SYMBOL}                {
                            yycolnum += strlen(yytext);
                            string *SymbolVal = new string(yytext);
                            yylval.LexerString = SymbolVal;
                            return TK_SYMBOL;
                        }
.                       { return TK_ERROR; }