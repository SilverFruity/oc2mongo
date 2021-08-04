



%{
//#define YYDEBUG 1
//#define YYERROR_VERBOSE
#include <stdlib.h>
#include <iostream>
#include "ocAstNode.hpp"
#include "Log.h"
%}

%locations
%error-verbose

%union{
    char *   string;
    int64_t  int_val;
    uint64_t uint_val;
    double   double_val;
    bool     bool_val;
    
    ocAstNode *node;

}
%{
extern int yylex(void);
extern void yyerror(const char *s);
extern bool is_variable;
%}
%token STATIC _STRONG _WEAK _BLOCK _AUTORELEASE NONNULL NULLABLE
%token IF ENDIF IFDEF IFNDEF UNDEF IMPORT INCLUDE  TILDE
%token PROPERTY RETURN BREAK CONTINUE GOTO ELSE  WHILE DO IN FOR CASE SWITCH DEFAULT TYPEOF _sizeof
%token QUESTION UNION STRUCT ENUM NS_ENUM NS_OPTIONS INTERFACE IMPLEMENTATION PROTOCOL END
%token COMMA COLON SEMICOLON  LP RP LB RB LC RC DOT AT PS ARROW
%token EQ NE LT LE GT GE LOGIC_AND LOGIC_OR NOT AND OR POWER SUB ADD DIV ASTERISK AND_ASSIGN OR_ASSIGN POWER_ASSIGN SUB_ASSIGN ADD_ASSIGN DIV_ASSIGN ASTERISK_ASSIGN INCREMENT DECREMENT
%token SHIFTLEFT SHIFTRIGHT MOD ASSIGN MOD_ASSIGN
%token CLASS ID VOID _BOOL _SEL _CHAR _SHORT _INT _LONG _LLONG  _UCHAR _USHORT _UINT _ULONG  _ULLONG DOUBLE _FLOAT CLASS_DECLARE
%token SELF SUPER _nil _NULL BOOL_VAL

%token <object> IDENTIFIER STRING_LITERAL SELECTOR
%token <identifier> TYPEDEF ELLIPSIS CHILD_COLLECTION POINT

%token <intValue> INTETER_LITERAL
%token <doubleValue> DOUBLE_LITERAL

//%type <intValue> pointer pointer_optional
//%type <uIntValue> assign_operator unary_operator declaration_modifier declaration_modifier_opt
//
//%type  <identifier> global_define
//
//%type  <object>
//parameter_declaration
//declarator_type
//parameter_list
//CHILD_COLLECTION_OPTIONAL
//declare_left_attribute
//
//%type <object>
//start_class_interface
//class_interface
//start_protocol_declare
//protocol_declare
//class_name
//class_name_suffix
//start_class_implementation
//class_implementation
//class_content
//class_content_list
//method_declare
//class_property_type
//class_property_declare
//property_list
//END
//
//%type  <object>
//objc_method_call_pramameters
//objc_method_call
//primary_expression
//numerical_value_type
//oc_block_imp
//statement_list
//expression_list
//unary_expression
//postfix_expression
//
//%type <object>
//ast_block_imp
//expression_stats
//if_statement // if / else if / else
//while_statement // while(){}
//dowhile_statement // do{}while()
//case_statement   // case:
//case_statement_list
//switch_statement // switch(){}
//for_statement    // for(;;;){}
//forin_statement  // for( in ) {}
//control_statement // return / break / continue
//
//%type <object>
//expression
//expression_opt
//assign_expression
//ternary_expression
//logic_or_expression
//multiplication_expression
//additive_expression
//bite_shift_expression
//equality_expression
//bite_and_expression
//bite_xor_expression
//relational_expression
//bite_or_expression
//logic_and_expression
//dict_entrys
//for_statement_var_list
//
//%type <object>
//declaration
//init_declarator_list
//init_declarator
//declarator
//declarator_optional
//direct_declarator
//direct_declarator_optional
//block_parameters_optinal
//declarator_type_opt
//
//%type <object>
//union_declare
//struct_field_list
//struct_declare
//enum_field_list
//enum_declare
//typedef_declare
%%
//
compile_util: /*empty*/
//| definition_list
;
//definition_list: definition
//| definition_list definition
//;
//definition:
//global_define
//| class_interface
//| protocol_declare
//| class_implementation
//| control_statement
//{
//    [GlobalAst addGlobalStatements:$1];
//}
//;
//global_define:
//expression_stats
//{
//    [GlobalAst addGlobalStatements:$1];
//}
//| CLASS_DECLARE for_statement_var_list SEMICOLON
//| PROTOCOL IDENTIFIER SEMICOLON
//| declarator_type declarator ast_block_imp
//{
//    ORFunctionDeclNode *declare = $2;
//    declare.type = $1;
//    [GlobalAst addGlobalStatements:makeFunctionNode(declare, $3)];
//}
//| struct_declare SEMICOLON
//{
//    [GlobalAst addGlobalStatements:$1];
//}
//| union_declare SEMICOLON
//{
//    [GlobalAst addGlobalStatements:$1];
//}
//| enum_declare SEMICOLON
//{
//    [GlobalAst addGlobalStatements:$1];
//}
//| TYPEDEF typedef_declare SEMICOLON
//{
//    [GlobalAst addGlobalStatements:$2];
//}
//;
//
//struct_declare:
//STRUCT IDENTIFIER LC struct_field_list RC
//{
//    $$ = makeStructExp($2, $4);
//}
//;
//
//union_declare:
//UNION IDENTIFIER LC struct_field_list RC
//{
//    $$ = makeUnionExp($2, $4);
//}
//;
//
//struct_field_list:
//declaration SEMICOLON
//{
//    $$ = $1;
//}
//| struct_field_list declaration SEMICOLON
//{
//    [(NSMutableArray *)$1 addObjectsFromArray:$2];
//    $$ = $1;
//}
//;
//enum_declare:
//NS_ENUM LP declarator_type COMMA IDENTIFIER RP enum_declare
//{
//    OREnumStatNode *exp = $7;
//    exp.enumName = $5;
//    exp.valueType = [(ORTypeNode *) $3 type];
//    $$ = exp;
//}
//| NS_OPTIONS LP declarator_type COMMA IDENTIFIER RP enum_declare
//{
//    OREnumStatNode *exp = $7;
//    exp.enumName = $5;
//    exp.valueType =  [(ORTypeNode *) $3 type];
//    $$ = exp;
//}
//| ENUM IDENTIFIER enum_declare
//{
//    OREnumStatNode *exp = $3;
//    exp.enumName = $2;
//    $$ = exp;
//}
//| ENUM enum_declare
//{
//    $$ = $2;
//}
//| LC enum_field_list RC
//{
//    $$ = makeEnumExp(@"",makeTypeNode(OCTypeInt), $2);
//}
//| COLON declarator_type LC enum_field_list RC
//{
//    $$ = makeEnumExp(@"",$2, $4);
//}
//;
//
//enum_field_list:
//expression
//{
//    $$ = makeMutableArray($1);
//}
//| enum_field_list COMMA expression
//{
//    [$1 addObject:$3];
//}
//;
//
//
//typedef_declare:
//declarator_type declarator
//{
//    ORDeclaratorNode *pair = $2;
//    pair.type = $1;
//    $$ = makeTypedefExp(pair, pair.var.varname);
//}
////for NS_ENUM NS_OPTIONS
//| enum_declare
//{
//    $$ = makeTypedefExp($1, @"");
//}
//| enum_declare IDENTIFIER
//{
//    $$ = makeTypedefExp($1, $2);
//}
//| struct_declare IDENTIFIER
//{
//    $$ = makeTypedefExp($1, $2);
//}
//;
//
//IDENTIFIER_OPT:
//| IDENTIFIER
//;
//
//start_protocol_declare:
//PROTOCOL IDENTIFIER
//{
//    curProtocolNode = [GlobalAst protcolForName:$2];
//}
//protocol_declare:
//start_protocol_declare CHILD_COLLECTION_OPTIONAL class_content_list END
//{
//    if ($2 != nil){
//        NSArray *protocols = [$2 componentsSeparatedByString:@","];
//        curProtocolNode.protocols = [protocols mutableCopy];
//    }
//}
//;
//class_name_suffix:
//{
//    __autoreleasing id object = @"";
//    $$ = object;
//}
//| DOT IDENTIFIER
//{
//    __autoreleasing id object = [NSString stringWithFormat:@".%@", $2];
//    $$ = object;
//}
//;
//
//class_name: IDENTIFIER class_name_suffix
//{
//    __autoreleasing id object = [NSString stringWithFormat:@"%@%@", $1, $2];
//    $$ = object;
//}
//;
//
//start_class_interface:
//INTERFACE class_name
//{
//    curClassNode = [GlobalAst classForName:$2];
//    $$ = curClassNode;
//}
//;
//
//class_interface:
//start_class_interface COLON IDENTIFIER CHILD_COLLECTION_OPTIONAL class_private_ivars_opt class_content_list END
//{
//    curClassNode.superClassName = $3;
//    NSArray *protocols = [$4 componentsSeparatedByString:@","];
//    curClassNode.protocols = [protocols mutableCopy];
//}
//// category
//| start_class_interface LP IDENTIFIER_OPT RP CHILD_COLLECTION_OPTIONAL class_content_list END
//{
//    NSArray *protocols = [$5 componentsSeparatedByString:@","];
//    curClassNode.protocols = [protocols mutableCopy];
//}
//;
//
//start_class_implementation:
//IMPLEMENTATION class_name
//{
//    curClassNode = [GlobalAst classForName:$2];
//    $$ = curClassNode;
//}
//// category
//| start_class_implementation LP IDENTIFIER RP
//;
//
//class_implementation:
//start_class_implementation class_private_ivars_opt class_imp_content END
//;
//
//class_imp_content:
//| class_content_list
//| global_define
//;
//
//class_content_list:
//| class_content
//| class_content_list class_content
//
//class_private_ivars_opt:
//| ast_block_imp
//{
//    handlePrivateVarDecls([$1 statements]);
//}
//;
//
//class_content:
//PROPERTY class_property_declare parameter_declaration SEMICOLON
//{
//    handlePropertyDecls(makePropertyDeclare($2, $3));
//}
//| method_declare SEMICOLON
//{
//    handleMethodDecl($1);
//}
//| method_declare ast_block_imp
//{
//    handleMethodImp(makeMethodImplementation($1, $2));
//}
//;
//
//
//class_property_type:
//  IDENTIFIER
//| NONNULL
//| NULLABLE
//;
//
//property_list:
//class_property_type
//{
//    $$ = makeMutableArray($1);
//}
//| property_list COMMA class_property_type
//{
//    [$1 addObject:$3];
//}
//;
//
//class_property_declare:
//{
//    $$ = makeMutableArray(nil);
//}
//| LP property_list RP
//{
//    $$ = $2;
//}
//
//declare_left_attribute:
//| NONNULL
//| NULLABLE
//;
//method_declare:
//SUB LP parameter_declaration RP
//{
//    ORDeclaratorNode *declare = $3;
//    $$ = makeMethodDeclare(NO,declare);
//}
//| ADD LP parameter_declaration RP
//{
//    ORDeclaratorNode *declare = $3;
//    $$ = makeMethodDeclare(YES,declare);
//}
//| method_declare IDENTIFIER
//{
//    ORMethodDeclNode *method = $$;
//    [method.methodNames addObject: $2];
//    $$ = method;
//}
//| method_declare IDENTIFIER COLON LP parameter_declaration RP IDENTIFIER
//{
//    ORDeclaratorNode *pair = $5;
//    ORMethodDeclNode *method = $$;
//    [method.methodNames addObject: $2];
//    pair.var.varname = $7;
//    [method.parameters addObject:pair];
//    $$ = method;
//}
//;
//
//objc_method_call_pramameters:
//IDENTIFIER
//{
//    __autoreleasing NSArray *array = @[makeMutableArray($1),makeMutableArray(nil)];
//    $$ = array;
//}
//| IDENTIFIER COLON expression_list
//{
//    __autoreleasing NSArray *array = @[makeMutableArray($1), $3];
//    $$ = array;
//}
//| objc_method_call_pramameters IDENTIFIER COLON expression_list
//{
//    NSArray *array = $1;
//    NSMutableArray *names = array[0];
//    NSMutableArray *values = array[1];
//    [names addObject:$2];
//    [values addObjectsFromArray:$4];
//    $$ = array;
//}
//;
//
//objc_method_call:
// LB IDENTIFIER objc_method_call_pramameters RB
//{
//     ORMethodCall *methodcall = makeMethodCall();
//     methodcall.caller =  makeValue(OCValueVariable,$2);
//     NSArray *params = $3;
//     methodcall.values = params[1];
//     NSMutableArray *names = params[0];
//     if(methodcall.values.count > 0){
//         [names addObject:@""];
//     }
//     methodcall.selectorName = [names componentsJoinedByString:@":"];
//     $$ = methodcall;
//}
//| LB postfix_expression objc_method_call_pramameters RB
//{
//     ORMethodCall *methodcall = makeMethodCall();
//     ORValueNode *caller = $2;
//     methodcall.caller =  caller;
//     NSArray *params = $3;
//     methodcall.values = params[1];
//     NSMutableArray *names = params[0];
//     if(methodcall.values.count > 0){
//         [names addObject:@""];
//     }
//     methodcall.selectorName = [names componentsJoinedByString:@":"];
//     $$ = methodcall;
//}
//;
//block_parameters_optinal:
//{
//    $$ = makeMutableArray(nil);
//}
//| LP parameter_list RP
//{
//    $$ = $2;
//}
//;
//declarator_type_opt:
//{
//    $$ = makeTypeNode(OCTypeVoid);
//}
//| declarator_type
//
//oc_block_imp:
////^returnType(optional) parameters(optional){ }
//POWER declarator_type_opt pointer_optional block_parameters_optinal ast_block_imp
//{
//    ORFunctionDeclNode *declare = makeFunctionDeclNode();
//    declare.type = $2;
//    declare.var = makeVarNode(nil,$3);
//    declare.params = $4;
//    declare.var.isBlock = YES;
//    $$ = makeFunctionNode(declare, $5);;
//}
//;
//
//
//expression: assign_expression;
//expression_opt:
//{
//    $$ = nil;
//}
//| expression;
//
//expression_stats:
//expression SEMICOLON
//{
//    ORNode *node =  $1;
//    node.withSemicolon = YES;
//    $$ = node;
//}
//| declaration SEMICOLON
//{
//    NSArray *declares =  $1;
//    for (ORNode* node in declares){
//        node.withSemicolon = YES;
//    }
//    $$ = declares;
//}
//| RETURN expression_opt SEMICOLON
//{
//    ORNode *node = makeControlStatement(ORControlStatReturn,$2);
//    node.withSemicolon = YES;
//    $$ = node;
//}
//| BREAK SEMICOLON
//{
//    ORNode *node = makeControlStatement(ORControlStatBreak, nil);
//    node.withSemicolon = YES;
//    $$ = node;
//}
//| CONTINUE SEMICOLON
//{
//    ORNode *node = makeControlStatement(ORControlStatContinue, nil);
//    node.withSemicolon = YES;
//    $$ = node;
//}
//;
//
//if_statement:
//IF LP expression RP expression_stats
//{
//    ORIfStatement *header = makeIfStatement(nil, nil);
//    [header.statements addObject: makeIfStatement($3, makeScopeImp($5))];
//    $$ = header;
//}
//| IF LP expression RP ast_block_imp
//{
//    ORIfStatement *header = makeIfStatement(nil, nil);
//    [header.statements addObject: makeIfStatement($3, $5)];
//    $$ = header;
//}
//| if_statement ELSE IF LP expression RP expression_stats
//{
//    ORIfStatement *header = $1;
//    [header.statements addObject: makeIfStatement( $5, makeScopeImp($7))];
//    $$  = $1;
//}
//| if_statement ELSE IF LP expression RP ast_block_imp
//{
//    ORIfStatement *header = $1;
//    [header.statements addObject: makeIfStatement($5, $7)];
//    $$  = $1;
//}
//| if_statement ELSE expression_stats
//{
//    ORIfStatement *header = $1;
//    [header.statements addObject: makeIfStatement(nil, makeScopeImp($3))];
//    $$  = $1;
//}
//| if_statement ELSE ast_block_imp
//{
//    ORIfStatement *header = $1;
//    [header.statements addObject: makeIfStatement(nil, $3)];
//    $$  = $1;
//}
//;
//
//dowhile_statement:
//DO ast_block_imp WHILE LP expression RP
//{
//    $$ = makeDoWhileStatement($5,$2);
//}
//;
//while_statement:
//WHILE LP expression RP ast_block_imp
//{
//    $$ = makeWhileStatement($3, $5);
//}
//;
//
//case_statement:
//CASE unary_expression COLON
//{
//    $$ = makeCaseStatement($2);
//}
//| DEFAULT COLON
//{
//    $$ = makeCaseStatement(nil);
//}
//| case_statement expression_stats
//{
//    [[$1 scopeImp] addStatements:$2];
//}
//| case_statement ast_block_imp
//{
//    [$1 setScopeImp:$2];
//}
//;
//case_statement_list:
//{
//    $$ = makeMutableArray(nil);
//}
//| case_statement_list case_statement
//{
//    [$1 addObject: $2];
//}
//;
//switch_statement:
// SWITCH LP expression RP LC case_statement_list RC
// {
//     ORSwitchStatement *statement = makeSwitchStatement( $3);
//     statement.cases = $6;
//     $$ = statement;
// }
//;
//
//for_statement_var_list:
//| primary_expression
//{
//    $$ = makeMutableArray($1);
//}
//| for_statement_var_list COMMA primary_expression
//{
//    [$1 addObject: $3];
//}
//
//for_statement: FOR LP declaration SEMICOLON expression SEMICOLON expression_list RP ast_block_imp
//{
//    ORForStatement* statement = makeForStatement($9);
//    statement.varExpressions = $3;
//    statement.condition = $5;
//    statement.expressions = $7;
//    $$ = statement;
//}
//|  FOR LP for_statement_var_list SEMICOLON expression SEMICOLON expression_list RP ast_block_imp
//{
//   ORForStatement* statement = makeForStatement($9);
//   statement.varExpressions = $3;
//   statement.condition = $5;
//   statement.expressions = $7;
//   $$ = statement;
//}
//;
//
//forin_statement: FOR LP declaration IN expression RP ast_block_imp
//{
//    ORForInStatement * statement = makeForInStatement($7);
//    NSArray *exps = $3;
//    statement.expression = exps[0];
//    statement.value = $5;
//    $$ = statement;
//}
//;
//
//
//control_statement:
//if_statement
//| switch_statement
//| while_statement
//| dowhile_statement
//| for_statement
//| forin_statement
//;
//
//ast_block_imp:
//LC  {
//
//} statement_list RC {
//    ORBlockNode *node = makeScopeImp();
//    node.statements = $3;
//    $$ = node;
//}
//;
//
//statement_list:
//{
//    $$ = makeMutableArray(nil);
//}
//| statement_list expression_stats
//{
//    if([$2 isKindOfClass:[NSArray class]]){
//        [$1 addObjectsFromArray:$2];
//    }else{
//        [$1 addObject:$2];
//    }
//}
//| statement_list control_statement
//{
//    [$1 addObject:$2];
//}
//;
//
//
//expression_list:
//{
//    $$ = makeMutableArray(nil);
//}
//| expression
//{
//    $$ = makeMutableArray($1);
//}
//| expression_list COMMA expression
//{
//    [$1 addObject: $3];
//}
//;
//
//assign_operator:
//ASSIGN
//{
//    $$ = AssignOperatorAssign;
//}
//| AND_ASSIGN
//{
//    $$ = AssignOperatorAssignAnd;
//}
//| OR_ASSIGN
//{
//    $$ = AssignOperatorAssignOr;
//}
//| POWER_ASSIGN
//{
//    $$ = AssignOperatorAssignXor;
//}
//| ADD_ASSIGN
//{
//    $$ = AssignOperatorAssignAdd;
//}
//| SUB_ASSIGN
//{
//    $$ = AssignOperatorAssignSub;
//}
//| DIV_ASSIGN
//{
//    $$ = AssignOperatorAssignDiv;
//}
//| ASTERISK_ASSIGN
//{
//    $$ = AssignOperatorAssignMuti;
//}
//| MOD_ASSIGN
//{
//    $$ = AssignOperatorAssignMod;
//}
//;
//
//// = /= %= /= *=  -= += <<= >>= &= ^= |=
//assign_expression: ternary_expression
//| unary_expression assign_operator assign_expression
//{
//    ORAssignNode *expression = makeAssignExpression($2);
//    expression.expression =  $3;
//    expression.value = $1;
//    $$ = expression;
//}
//;
//
//// ?:
//ternary_expression: logic_or_expression
//| logic_or_expression QUESTION ternary_expression COLON ternary_expression
//{
//    ORTernaryNode *expression = makeTernaryExpression();
//    expression.expression = $1;
//    [expression.values addObject:$3];
//    [expression.values addObject:$5];
//    $$ = expression;
//}
//| logic_or_expression QUESTION COLON ternary_expression
//{
//    ORTernaryNode *expression = makeTernaryExpression();
//    expression.expression = $1;
//    [expression.values addObject:$4];
//    $$ = expression;
//}
//;
//
//
//// ||
//logic_or_expression: logic_and_expression
//| logic_or_expression LOGIC_OR logic_or_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorLOGIC_OR, $1, $3);
//}
//;
//
//// &&
//logic_and_expression: bite_or_expression
//| logic_and_expression LOGIC_AND bite_or_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorLOGIC_AND, $1, $3);
//}
//;
//// |
//bite_or_expression: bite_xor_expression
//| bite_or_expression OR bite_xor_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorOr, $1, $3);
//}
//;
//// ^
//bite_xor_expression: bite_and_expression
//| bite_xor_expression POWER bite_and_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorXor, $1, $3);
//}
//;
//
//// &
//bite_and_expression: equality_expression
//| bite_and_expression AND equality_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorAnd, $1, $3);
//}
//;
//
//// == !=
//equality_expression: relational_expression
//| equality_expression EQ relational_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorEqual, $1, $3);
//}
//| equality_expression NE relational_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorNotEqual, $1, $3);
//}
//;
//// < <= > >=
//relational_expression: bite_shift_expression
//| relational_expression LT bite_shift_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorLT, $1, $3);;
//}
//| relational_expression LE bite_shift_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorLE, $1, $3);
//}
//| relational_expression GT bite_shift_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorGT, $1, $3);
//}
//| relational_expression GE bite_shift_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorGE, $1, $3);
//}
//;
//// >> <<
//bite_shift_expression: additive_expression
//| bite_shift_expression SHIFTLEFT additive_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorShiftLeft, $1, $3);
//}
//| bite_shift_expression SHIFTRIGHT additive_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorShiftRight, $1, $3);
//}
//;
//// + -
//additive_expression: multiplication_expression
//| additive_expression ADD multiplication_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorAdd, $1, $3);
//}
//| additive_expression SUB multiplication_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorSub, $1, $3);
//}
//;
//
//// * / %
//multiplication_expression: unary_expression
//| multiplication_expression ASTERISK unary_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorMulti, $1, $3);
//}
//| multiplication_expression DIV unary_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorDiv, $1, $3);
//}
//| multiplication_expression MOD unary_expression
//{
//    $$ = makeBinaryExpression(BinaryOperatorMod, $1, $3);
//}
//;
//
//// !x -x *x &x ~x sizof(x) x++ x-- ++x --x
//unary_expression: postfix_expression
//| unary_operator unary_expression
//{
//    $$ = makeUnaryExpression($1, $2);;
//}
//| _sizeof unary_expression
//{
//    $$ = makeUnaryExpression(UnaryOperatorSizeOf, $2);
//}
//| INCREMENT unary_expression
//{
//    $$ = makeUnaryExpression(UnaryOperatorIncrementPrefix, $2);
//}
//| DECREMENT unary_expression
//{
//    $$ = makeUnaryExpression(UnaryOperatorDecrementPrefix, $2);
//}
//;
//
//unary_operator:
//AND
//{
//    $$ = UnaryOperatorAdressPoint;
//}
//| ASTERISK
//{
//    $$ = UnaryOperatorAdressValue;
//}
//| POINT
//{
//    $$ = UnaryOperatorAdressValue;
//}
//| SUB
//{
//    $$ = UnaryOperatorNegative;
//}
//| TILDE
//{
//    $$ = UnaryOperatorBiteNot;
//}
//| NOT
//{
//    $$ = UnaryOperatorNot;
//}
//;
//
//
//
//postfix_expression: primary_expression
//| postfix_expression INCREMENT
//{
//    $$ = makeUnaryExpression(UnaryOperatorIncrementSuffix, $1);
//}
//| postfix_expression DECREMENT
//{
//    $$ = makeUnaryExpression(UnaryOperatorDecrementSuffix, $1);
//}
//| postfix_expression DOT IDENTIFIER
//{
//    is_variable = true;
//    ORMethodCall *methodcall = makeMethodCall();
//    methodcall.caller =  $1;
//    methodcall.methodOperator = MethodOpretorDot;
//    methodcall.selectorName = $3;
//    $$ = methodcall;
//}
//| postfix_expression ARROW IDENTIFIER
//{
//    ORMethodCall *methodcall = makeMethodCall();
//    methodcall.caller =  $1;
//    methodcall.methodOperator = MethodOpretorArrow;
//    methodcall.selectorName = $3;
//    $$ = methodcall;
//}
//| postfix_expression LP expression_list RP
//{
//    is_variable = true;
//    $$ = makeFuncCall( $1,  $3);
//}
//| postfix_expression LB expression RB
//{
//    $$ = makeSubscriptNode($1, $3);
//}
//| LP declarator_type declarator_optional RP postfix_expression
//{
//    $$ = $5;
//}
//| LP declarator_type declarator_optional RP postfix_expression
//{
//    $$ = $5;
//}
//;
//
//numerical_value_type:
//INTETER_LITERAL
//{
//    $$ = makeIntegerValue($1);
//}
//| DOUBLE_LITERAL
//{
//    $$ = makeDoubleValue($1);
//}
//;
//dict_entrys:
//{
//    $$ = makeMutableArray(nil);
//}
//| dict_entrys expression COLON expression
//{
//    [$1 addObject:@[$2,$4]];
//    $$ = $1;
//}
//| dict_entrys COMMA
//{
//    $$ = $1;
//}
//;
//
//
//primary_expression:
//IDENTIFIER
//{
//    is_variable = true;
//    $$ = makeValue(OCValueVariable, $1);
//}
//| SELF
//{
//    $$ = makeValue(OCValueSelf);
//}
//| SUPER
//{
//    $$ = makeValue(OCValueSuper);
//}
//| objc_method_call
//{
//    is_variable = true;
//    $$ = $1;
//}
//| LP expression RP
//{
//    is_variable = true;
//    $$ = $2;
//}
//| AT LC dict_entrys RC
//{
//    $$ = makeValue(OCValueDictionary,$3);
//}
//| AT LB expression_list RB
//{
//    $$ = makeValue(OCValueArray,$3);
//}
//| AT LP expression RP
//{
//    $$ = makeValue(OCValueNSNumber,$3);
//}
//| AT numerical_value_type
//{
//    $$ = makeValue(OCValueNSNumber,$2);
//}
//| AT STRING_LITERAL
//{
//    $$ = makeValue(OCValueString,$2);
//}
//| SELECTOR
//{
//    NSString *sel = $1;
//    NSString *selector = [sel substringWithRange:NSMakeRange(10, sel.length - 11)];
//    $$ = makeValue(OCValueSelector,selector);
//}
//| PROTOCOL LP IDENTIFIER RP
//{
//    $$ = makeValue(OCValueProtocol,$3);
//}
//| STRING_LITERAL
//{
//    $$ = makeValue(OCValueCString,$1);
//}
//| oc_block_imp
//| numerical_value_type
//| _nil
//{
//    $$ = makeValue(OCValueNil);
//}
//| _NULL
//{
//    $$ = makeValue(OCValueNULL);
//}
//| _YES
//{
//    $$ = makeBoolValue(YES);
//}
//| _NO
//{
//    $$ = makeBoolValue(NO);
//}
//;
//
//;
//declaration_modifier_opt:
//| declaration_modifier
//;
//
//declaration_modifier: _WEAK
//{
//    $$ = DeclarationModifierWeak;
//}
//| _STRONG
//{
//    $$ = DeclarationModifierStrong;
//}
//| STATIC
//{
//    $$ = DeclarationModifierStatic;
//}
//;
//
//declaration:
//declaration_modifier declarator_type init_declarator_list
//{
//    NSMutableArray *array = $3;
//    for (id declare in array){
//        if ([declare isKindOfClass:[ORInitDeclaratorNode class]]){
//            [declare declarator].type = $2;
//            [declare declarator].type.modifier = $1;
//        }else{
//            [(ORDeclaratorNode *)declare setType:$2];
//            [[(ORDeclaratorNode *)declare type] setModifier:$1];
//        }
//    }
//    $$ = array;
//}
//| declarator_type init_declarator_list
//{
//    NSMutableArray *array = $2;
//    for (id declare in array){
//        if ([declare isKindOfClass:[ORInitDeclaratorNode class]]){
//            [declare declarator].type = $1;
//        }else{
//            [(ORDeclaratorNode *)declare setType:$1];
//        }
//    }
//    $$ = array;
//}
//;
//init_declarator_list:
//init_declarator
//{
//    $$ = makeMutableArray($1);
//}
//| init_declarator_list COMMA init_declarator
//{
//    [$1 addObject: $3];
//    $$ = $1;
//}
//;
//
//init_declarator:
//declarator
//{
//    $$ = $1;
//}
//| declarator ASSIGN expression
//{
//    $$ = makeInitDeclaratorNode($1, $3);
//}
//;
//
//
//declarator_optional:
//{
//    $$ = makeDeclaratorNode(nil, makeVarNode(nil));
//}
//| declarator
//;
//
//declarator:
//direct_declarator
//| POWER direct_declarator_optional
//{
//    ORDeclaratorNode *decl = $2;
//    decl.var.isBlock = YES;
//    $$ = decl;
//}
//| pointer direct_declarator_optional
//{
//    ORDeclaratorNode *decl = $2;
//    decl.var.ptCount = $1;
//    $$ = decl;
//}
//
//;
//
//direct_declarator_optional:
//{
//    $$ = makeDeclaratorNode(nil, makeVarNode(nil));
//}
//| direct_declarator
//;
//
//direct_declarator:
//IDENTIFIER
//{
//    $$ = makeDeclaratorNode(nil, makeVarNode($1));
//}
//| declarator LP parameter_list RP
//{
//    ORFunctionDeclNode *funcDecl = [ORFunctionDeclNode copyFromDecl:$1];
//    NSMutableArray *pairs = $3;
//    if ([pairs lastObject] == [NSNull null]) {
//        funcDecl.isMultiArgs = YES;
//        [pairs removeLastObject];
//    }
//    funcDecl.params = pairs;
//    $$ = funcDecl;
//}
//| LP declarator RP LP parameter_list RP
//{
//    /*
//     为函数指针声明单独处理: void (*a)(void); void (**a)(void);，将其ptCount置为0.
//     原因: 在签名声明时，ptCount的值，将与 void *a(void); 签名冲突
//     理想的签名结果： void (**a)(void)的签名应为: ^^?vv, void *a(void)签名应为: ^?^vv
//     目前的语法树结构无法正确处理此问题，所以统一将函数声明的签名同一处理为 ^? 开头，不处理指针个数
//     目前的签名结果: void (**a)(void) -> ^?vv  void *a(void) -> ^?^vv
//     */
//    ORFunctionDeclNode *funcDecl = [ORFunctionDeclNode copyFromDecl:$2];
//    funcDecl.var.ptCount = 0;
//    NSMutableArray *pairs = $5;
//    if ([pairs lastObject] == [NSNull null]) {
//        funcDecl.isMultiArgs = YES;
//        [pairs removeLastObject];
//    }
//    funcDecl.params = pairs;
//    $$ = funcDecl;
//}
//| direct_declarator LB expression_opt RB
//{
//    ORDeclaratorNode *node = $1;
//    if ($3 == NULL){
//        node.var.ptCount += 1;
//        $$ = node;
//    }else{
//        ORCArrayDeclNode *arrayVar = [ORCArrayDeclNode copyFromDecl:node];
//        arrayVar.capacity = $3;
//        $$ = arrayVar;
//   }
//}
//;
//
//
//pointer:
//POINT
//{
//    $$ = 1;
//}
//| POINT pointer
//{
//   $$ = $2 + 1;
//}
//;
//pointer_optional:
//{
//    $$ = 0;
//}
//| pointer;
//
//parameter_list: /* empty */
//{
//    $$ = makeMutableArray(nil);
//}
//| parameter_declaration
//{
//    $$ = makeMutableArray($1);
//}
//| parameter_list COMMA parameter_declaration
//{
//    [$1 addObject: $3];
//}
//| parameter_list COMMA ELLIPSIS
//{
//    [$1 addObject:[NSNull null]];
//    $$ = $1;
//}
//;
//
//parameter_declaration:
//declare_left_attribute declarator_type declarator_optional
//{
//    ORDeclaratorNode *node = $3;
//    node.type = $2;
//    $$ = node;
//};
//
//parameter_declaration_optional:
//| parameter_declaration
//;
//
//CHILD_COLLECTION_OPTIONAL:
//{
//    $$ = nil;
//}
//| CHILD_COLLECTION;
//
//declarator_type:
//IDENTIFIER CHILD_COLLECTION_OPTIONAL
//{
//    $$ = makeTypeNode(OCTypeObject, $1);
//}
//| STRUCT IDENTIFIER
//{
//    $$ = makeTypeNode(OCTypeStruct, $2);
//}
//| UNION IDENTIFIER
//{
//    $$ = makeTypeNode(OCTypeUnion, $2);
//}
//| ID CHILD_COLLECTION_OPTIONAL
//{
//    $$ = makeTypeNode(OCTypeObject,@"id");
//}
//| TYPEOF LP expression RP
//{
//    $$ = makeTypeNode(OCTypeObject,@"typeof");
//}
//| _UCHAR
//{
//    $$ = makeTypeNode(OCTypeUChar);
//}
//| _USHORT
//{
//    $$ = makeTypeNode(OCTypeUShort);
//}
//| _UINT
//{
//    $$ = makeTypeNode(OCTypeUInt);
//}
//| _ULONG
//{
//    $$ = makeTypeNode(OCTypeULong);
//}
//| _ULLONG
//{
//    $$ = makeTypeNode(OCTypeULongLong);
//}
//| _CHAR
//{
//    $$ = makeTypeNode(OCTypeChar);
//}
//| _SHORT
//{
//    $$ = makeTypeNode(OCTypeShort);
//}
//| _INT
//{
//    $$ = makeTypeNode(OCTypeInt);
//}
//| _LONG
//{
//    $$ = makeTypeNode(OCTypeLong);
//}
//| _LLONG
//{
//    $$ = makeTypeNode(OCTypeLongLong);
//}
//| DOUBLE
//{
//    $$ = makeTypeNode(OCTypeDouble);
//}
//| _FLOAT
//{
//    $$ = makeTypeNode(OCTypeFloat);
//}
//| CLASS
//{
//    $$ = makeTypeNode(OCTypeClass);
//}
//| _BOOL
//{
//    $$ = makeTypeNode(OCTypeBOOL);
//}
//| _SEL
//{
//    $$ = makeTypeNode(OCTypeSEL);
//}
//| VOID
//{
//    $$ = makeTypeNode(OCTypeVoid);
//}
//;

%%
    
void yyerror(const char *s){
//    extern unsigned long yylineno , yycolumn , yylen;
//    extern char linebuf[500];
//    extern char *yytext;
//    NSMutableString *str = [NSMutableString string];
//    for (int i = 0; i < yycolumn - yylen; i++){
//        [str appendString:@" "];
//    }
//    for (int i = 0; i < yylen; i++){
//        [str appendString:@"^"];
//    }
//    NSString *errorInfo = [NSString stringWithFormat:@"\n------yyerror------\nline: %lu\n%s\n%@\nerror: %s\n-------------------\n",yylineno + 1,linebuf,str,s];
//    OCParser.error = errorInfo;
}
