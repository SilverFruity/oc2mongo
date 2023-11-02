//
//  Convert.m
//  oc2mangoLib
//
//  Created by Jiang on 2019/5/18.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import "Convert.h"
#import "MakeDeclare.h"
@implementation Convert
- (NSString *)convert:(ORNode *)node{
    NSString *result = @"";
    if ([node isKindOfClass:[ORDeclareExpression class]]) {
        result = [self convertDeclareExp:(ORDeclareExpression *)node];
    }else if ([node isKindOfClass:[ORAssignExpression class]]) {
        result = [self convertAssginExp:(ORAssignExpression *)node];
    }else if ([node isKindOfClass:[ORValueExpression class]]){
        result = [self convertOCValue:(ORValueExpression *)node];
    }else if ([node isKindOfClass:[ORIntegerValue class]]){
        result = [self convertORIntegerValue:(ORIntegerValue *)node];
    }else if ([node isKindOfClass:[ORIntegerValue class]]){
        result = [self convertORUIntegerValue:(ORUIntegerValue *)node];
    }else if ([node isKindOfClass:[ORDoubleValue class]]){
        result = [self convertORDoubleValue:(ORDoubleValue *)node];
    }else if ([node isKindOfClass:[ORBoolValue class]]){
        result = [self convertORBoolValue:(ORBoolValue *)node];
    }else if ([node isKindOfClass:[ORBinaryExpression class]]){
        result = [self convertBinaryExp:(ORBinaryExpression *)node];
    }else if ([node isKindOfClass:[ORUnaryExpression class]]){
        result = [self convertUnaryExp:(ORUnaryExpression *)node];
    }else if ([node isKindOfClass:[ORTernaryExpression class]]){
        result = [self convertTernaryExp:(ORTernaryExpression *)node];
    }else if ([node isKindOfClass:[ORFunctionImp class]]){
        result = [self convertBlockImp:(ORFunctionImp *)node];
    }else if ([node isKindOfClass:[ORMethodCall class]]){
        result = [self convertOCMethodCall:(ORMethodCall *)node];
    }else if ([node isKindOfClass:[ORCFuncCall class]]){
        result = [self convertFunCall:(ORCFuncCall *)node];
    }else if ([node isKindOfClass:[ORSubscriptExpression class]]){
        result = [self convertSubscript:(ORSubscriptExpression *)node];
    } else if ([node isKindOfClass:[ORReturnStatement class]]) {
        result = [self convertReturnStatement:(ORReturnStatement *) node];
    } else if ([node isKindOfClass:[ORBreakStatement class]]) {
        result = [self convertBreakStatement:(ORBreakStatement *) node];
    } else if ([node isKindOfClass:[ORContinueStatement class]]) {
        result = [self convertContinueStatement:(ORContinueStatement *) node];
    }else if ([node isKindOfClass:[ORIfStatement class]]) {
        result = [self convertIfStatement:(ORIfStatement *) node];
    }else if([node isKindOfClass:[ORWhileStatement class]]){
        result = [self convertWhileStatement:(ORWhileStatement *) node];
    }else if([node isKindOfClass:[ORDoWhileStatement class]]){
        result = [self convertDoWhileStatement:(ORDoWhileStatement *) node];
    }else if ([node isKindOfClass:[ORSwitchStatement class]]) {
        result = [self convertSwitchStatement:(ORSwitchStatement *) node];
    } else if ([node isKindOfClass:[ORForStatement class]]) {
        result = [self convertForStatement:(ORForStatement *) node];
    } else if ([node isKindOfClass:[ORForInStatement class]]) {
        result = [self convertForInStatement:(ORForInStatement *) node];
    }else if ([node isKindOfClass:[ORClass class]]) {
        result = [self convertOCClass:(ORClass *)node];
    } else if ([node isKindOfClass:[ORTypeVarPair class]]) {
        result = [self convertTypeVarPair:(ORTypeVarPair *)node];
    } else if ([node isKindOfClass:[ORPropertyDeclare class]]) {
        result = [self convertPropertyDeclare:(ORPropertyDeclare *)node];
    } else if ([node isKindOfClass:[ORMethodDeclare class]]) {
        result = [self convertMethoDeclare:(ORMethodDeclare *)node];
    } else if ([node isKindOfClass:[ORTypedefExpressoin class]]) {
        result = [self convertTypedefExpression:(ORTypedefExpressoin *)node];
    } else if ([node isKindOfClass:[ORStructExpressoin class]]) {
        result = [self convertStructExpression:(ORStructExpressoin *)node];
    } else if ([node isKindOfClass:[ORUnionExpressoin class]]) {
        result = [self convertUnionExpression:(ORUnionExpressoin *)node];
    } else if ([node isKindOfClass:[OREnumExpressoin class]]) {
        result = [self convertEnumExpression:(OREnumExpressoin *)node];
    } else if ([node isKindOfClass:[ORProtocol class]]) {
        result = [self convertProtocol:(ORProtocol *)node];
    } else {
        NSAssert(NO, @"Unknown node type");
    }
    if (node.withSemicolon == YES) {
        result = [result stringByAppendingString:@";"];
    }
    return result;
}
- (NSString *)convertOCClass:(ORClass *)occlass{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"class %@:%@",occlass.className,occlass.superClassName];
    if (occlass.protocols.count > 0) {
        [content appendFormat:@"<%@>",[occlass.protocols componentsJoinedByString:@","]];
    }
    [content appendString:@"{\n"];
    for (ORPropertyDeclare *prop in occlass.properties) {
        [content appendString:[self convertPropertyDeclare:prop]];
    }
    for (ORMethodImplementation *imp in occlass.methods) {
        [content appendString:[self convertMethodImp:imp]];
    }
    [content appendString:@"\n}\n"];
    return content;
}

- (NSString *)convertTypeSpecial:(ORTypeSpecial *)typeSpecial{
    NSMutableString *result = [NSMutableString string];
    switch (typeSpecial.type){
        case TypeUChar:
        case TypeUShort:
        case TypeUInt:
        case TypeULong:
        case TypeULongLong:
            [result appendString:@"uint"]; break;
        case TypeChar:
        case TypeShort:
        case TypeInt:
        case TypeLong:
        case TypeLongLong:
            [result appendString:@"int"]; break;
        case TypeDouble:
        case TypeFloat:
            [result appendString:@"double"]; break;
        case TypeVoid:
            [result appendString:@"void"]; break;
        case TypeSEL:
            [result appendString:@"SEL"]; break;
        case TypeClass:
            [result appendString:@"Class"]; break;
        case TypeBOOL:
            [result appendString:@"BOOL"]; break;
        case TypeId:
            [result appendString:@"id"]; break;
        case TypeObject:
            [result appendString:typeSpecial.name]; break;
        case TypeBlock:
            [result appendString:@"Block"]; break;
            
        case TypeStruct:
            [result appendString:typeSpecial.name]; break;
            break;
        default:
            [result appendString:@"UnKnownType"];
            break;
    }
    [result appendString:@" "];
    
    return result;
}

- (NSString *)convertPropertyDeclare:(ORPropertyDeclare *)propertyDecl{
    
    return [NSString stringWithFormat:@"@property(%@)%@;\n",[propertyDecl.keywords componentsJoinedByString:@","],[self convertDeclareTypeVarPair:propertyDecl.var]];
    return @"";
}
- (NSString *)convertMethoDeclare:(ORMethodDeclare *)methodDecl{
    NSString *methodName = @"";
    if (methodDecl.parameterNames.count == 0) {
        methodName = methodDecl.methodNames.firstObject;
    }else{
        NSMutableArray *list = [NSMutableArray array];
        for (int i = 0; i < methodDecl.parameterNames.count; i++) {
            [list addObject:[NSString stringWithFormat:@"%@:(%@)%@",
                             methodDecl.methodNames[i],
                             [self convertDeclareTypeVarPair:methodDecl.parameterTypes[i]],
                             methodDecl.parameterNames[i]]];
        }
        methodName = [list componentsJoinedByString:@" "];
    }
    return [NSString stringWithFormat:@"%@(%@)%@",methodDecl.isClassMethod?@"+":@"-",[self convertDeclareTypeVarPair:methodDecl.returnType],methodName];
}
- (NSString *)convertMethodImp:(ORMethodImplementation *)methodImp{
    return [NSString stringWithFormat:@"\n%@%@",[self convertMethoDeclare:methodImp.declare],[self convertScopeImp:methodImp.scopeImp]];
}
- (NSString *)convertFuncDeclare:(ORFuncDeclare *)funcDecl{
    return [NSString stringWithFormat:@"%@%@",[self convertDeclareTypeVarPair:funcDecl.returnType],[self convertVariable:funcDecl.funVar]];;
}
int indentationCont = 0;
- (NSString *)convertScopeImp:(ORScopeImp *)imp{
    NSMutableString *content = [NSMutableString string];
    indentationCont++;
    [content appendString:@"{\n"];
    NSMutableString *tabs = [@"" mutableCopy];
    for (int i = 0; i < indentationCont - 1; i++) {
        [tabs appendString:@"    "];
    }
    for (id statement in imp.statements) {
        if ([statement isKindOfClass:[ORNode class]]) {
            [content appendFormat:@"%@    %@\n",tabs,[self convert:statement]];
        }
    }
    [content appendFormat:@"%@}",tabs];
    indentationCont--;
    return content;
}
- (NSString *)convertBlockImp:(ORFunctionImp *)imp{
    NSMutableString *content = [NSMutableString string];
    if (imp.declare) {
        if (!imp.declare.isBlockDeclare) {
            // void x(int y){ }
            [content appendFormat:@"%@", [self convertFuncDeclare:imp.declare]];
        }else{
            // ^void (int x){ }
            [content appendFormat:@"^%@", [self convertFuncDeclare:imp.declare]];
        }
    }
    [content appendString:[self convertScopeImp:imp.scopeImp]];
    return content;
}
- (NSString *)convertBinaryExp:(ORBinaryExpression *)exp{
    NSString *operator = @"";
    switch (exp.operatorType) {
        case BinaryOperatorAdd:
            operator = @"+";
            break;
        case BinaryOperatorSub:
            operator = @"-";
            break;
        case BinaryOperatorDiv:
            operator = @"/";
            break;
        case BinaryOperatorMulti:
            operator = @"*";
            break;
        case BinaryOperatorMod:
            operator = @"%";
            break;
        case BinaryOperatorShiftLeft:
            operator = @"<<";
            break;
        case BinaryOperatorShiftRight:
            operator = @">>";
            break;
        case BinaryOperatorAnd:
            operator = @"&";
            break;
        case BinaryOperatorOr:
            operator = @"|";
            break;
        case BinaryOperatorXor:
            operator = @"^";
            break;
        case BinaryOperatorLT:
            operator = @"<";
            break;
        case BinaryOperatorGT:
            operator = @">";
            break;
        case BinaryOperatorLE:
            operator = @"<=";
            break;
        case BinaryOperatorGE:
            operator = @">=";
            break;
        case BinaryOperatorNotEqual:
            operator = @"!=";
            break;
        case BinaryOperatorEqual:
            operator = @"==";
            break;
        case BinaryOperatorLOGIC_AND:
            operator = @"&&";
            break;
        case BinaryOperatorLOGIC_OR:
            operator = @"||";
            break;
    }
    return [NSString stringWithFormat:@"%@ %@ %@",[self convert:exp.left],operator,[self convert:exp.right]];
}
- (NSString *)convertUnaryExp:(ORUnaryExpression *)exp{
    NSString *format = @"%@";
    switch (exp.operatorType) {
            
        case UnaryOperatorIncrementSuffix:
            format = @"%@++";
            break;
        case UnaryOperatorDecrementSuffix:
            format = @"%@--";
            break;
        case UnaryOperatorIncrementPrefix:
            format = @"++%@";
            break;
        case UnaryOperatorDecrementPrefix:
            format = @"--%@";
            break;
        case UnaryOperatorNot:
            format = @"!%@";
            break;
        case UnaryOperatorNegative:
            format = @"-%@";
            break;
        case UnaryOperatorBiteNot:
            format = @"-%@";
            break;
        case UnaryOperatorSizeOf:
            format = @"~%@";
            break;
        case UnaryOperatorAdressPoint:
            format = @"&%@";
            break;
        case UnaryOperatorAdressValue:
            format = @"*%@";
            break;
    }
    return [NSString stringWithFormat:format,[self convert:exp.value]];
}
- (NSString *)convertTernaryExp:(ORTernaryExpression *)exp{
    if (exp.values.count == 1) {
        return [NSString stringWithFormat:@"%@ ?: %@",[self convert:exp.expression],[self convert:exp.values.firstObject]];
    }else{
        return [NSString stringWithFormat:@"%@ ? %@ : %@",[self convert:exp.expression],[self convert:exp.values.firstObject],[self convert:exp.values.lastObject]];
    }
}
- (NSString *)convertDeclareExp:(ORDeclareExpression *)exp{
    if (exp.expression) {
        return [NSString stringWithFormat:@"%@ = %@",[self convertDeclareTypeVarPair:exp.pair],[self convert:exp.expression]];
    }else{
        return [NSString stringWithFormat:@"%@",[self convertDeclareTypeVarPair:exp.pair]];
    }
    return @"";
}
- (NSString *)convertAssginExp:(ORAssignExpression *)exp{
    NSString *operator = @"=";
    return [NSString stringWithFormat:@"%@ %@ %@",[self convert:exp.value],operator,[self convert:exp.expression]];
}
- (NSString *)convertORIntegerValue:(ORIntegerValue *)value{
    return [NSString stringWithFormat:@"%lld",value.value];
}
- (NSString *)convertORUIntegerValue:(ORUIntegerValue *)value{
    return [NSString stringWithFormat:@"%llu",value.value];
}
- (NSString *)convertORDoubleValue:(ORDoubleValue *)value{
    return [NSString stringWithFormat:@"%f",value.value];
}
- (NSString *)convertORBoolValue:(ORBoolValue *)value{
    return [NSString stringWithFormat:@"%@",value.value ? @"YES" : @"NO"];
}
- (NSString *)convertOCValue:(ORValueExpression *)value{
    switch (value.value_type){
        case OCValueSelector:
            return [NSString stringWithFormat:@"@selector(%@)",value.value];
        case OCValueVariable:
            return value.value;
        case OCValueSelf:
            return @"self";
        case OCValueSuper:
            return @"super";
            
        case OCValueString:
            return [NSString stringWithFormat:@"@\"%@\"",value.value?:@""];
        case OCValueCString:
            return [NSString stringWithFormat:@"\"%@\"",value.value?:@""];
        case OCValueProtocol:
            return [NSString stringWithFormat:@"@protocol(%@)",value.value];
        case OCValueDictionary:
        {
            NSMutableArray <NSMutableArray *>*keyValuePairs = value.value;
            NSMutableArray *pairs = [NSMutableArray array];
            for (NSMutableArray *keyValue in keyValuePairs) {
                [pairs addObject:[NSString stringWithFormat:@"%@:%@",[self convert:keyValue[0]],[self convert:keyValue[1]]]];
            }
            return [NSString stringWithFormat:@"@{%@}",[pairs componentsJoinedByString:@","]];
        }
        case OCValueArray:{
            NSMutableArray *exps = value.value;
            NSMutableArray *elements = [NSMutableArray array];
            for (ORNode * exp in exps) {
                [elements addObject:[self convert:exp]];
            }
            return [NSString stringWithFormat:@"@[%@]",[elements componentsJoinedByString:@","]];
        }
        case OCValueNSNumber:{
            if ([value.value isKindOfClass:[NSString class]]) {
                return [NSString stringWithFormat:@"@(%@)",value.value];
            }
            if ([value.value isKindOfClass:[ORNode class]]) {
                return [NSString stringWithFormat:@"@(%@)",[self convert:value.value]];
            }
        }
        case OCValueNil:
            return @"nil";
        case OCValueNULL:
            return @"NULL";
    }
    return @"";
}
- (NSString *)convertSubscript:(ORSubscriptExpression *)collection{
    return [NSString stringWithFormat:@"%@[%@]",[self convert:collection.caller],[self convert:collection.keyExp]];
}
- (NSString *)convertFunCall:(ORCFuncCall *)call{
    // FIX: make.left.equalTo(superview.mas_left) to make.left.equalTo()(superview.mas_left)
    // FIX: x.left(a) to x.left()(a)
    if ([call.caller isKindOfClass:[ORMethodCall class]] && [(ORMethodCall *)call.caller methodOperator]){
        return [NSString stringWithFormat:@"%@()(%@)",[self convert:call.caller],[self convertExpressionList:call.expressions]];
    }
    return [NSString stringWithFormat:@"%@(%@)",[self convert:call.caller],[self convertExpressionList:call.expressions]];
}
- (NSString *)convertOCMethodCall:(ORMethodCall *)call{
    NSMutableString *methodName = [[call.names componentsJoinedByString:@":"] mutableCopy];
    NSString *sel;
    if (call.values.count == 0) {
        if (call.methodOperator) {
            sel = [NSString stringWithFormat:@".%@",methodName];
        }else{
            sel = [NSString stringWithFormat:@".%@()",methodName];
        }
    }else{
        sel = [NSString stringWithFormat:@".%@:(%@)",methodName,[self convertExpressionList:call.values]];
    }
    return [NSString stringWithFormat:@"%@%@",[self convert:call.caller],sel];
}
- (NSString *)convertIfStatement:(ORIfStatement *)statement{
    NSString *content = @"";
    while (statement.last) {
        if (!statement.condition) {
            content = [NSString stringWithFormat:@"%@else%@",content,[self convertScopeImp:statement.scopeImp]];
        }else{
            content = [NSString stringWithFormat:@"else if(%@)%@%@",[self convert:statement.condition],[self convertScopeImp:statement.scopeImp],content];
        }
        statement = statement.last;
    }
    content = [NSString stringWithFormat:@"if(%@)%@%@",[self convert:statement.condition],[self convertScopeImp:statement.scopeImp],content];
    return content;
}
- (NSString *)convertWhileStatement:(ORWhileStatement *)statement{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"while(%@)",[self convert:statement.condition]];
    [content appendString:[self convertScopeImp:statement.scopeImp]];
    return content;
}
- (NSString *)convertDoWhileStatement:(ORDoWhileStatement *)statement{
    return [NSString stringWithFormat:@"do%@while(%@)",[self convertScopeImp:statement.scopeImp],[self convert:statement.condition]];
}
- (NSString *)convertSwitchStatement:(ORSwitchStatement *)statement{
    return [NSString stringWithFormat:@"switch(%@){\n%@}",[self convert:statement.value],[self convertCaseStatements:statement.cases]];
}
- (NSString *)convertCaseStatements:(NSArray *)cases{
    NSMutableString *content = [NSMutableString string];
    for (ORCaseStatement *statement in cases) {
        if (statement.value) {
            [content appendFormat:@"case %@:%@\n",[self convert:statement.value],[self convertScopeImp:statement.scopeImp]];
        }else{
            [content appendFormat:@"default:%@\n",[self convertScopeImp:statement.scopeImp]];
        }
    }
    return content;
}
- (NSString *)convertForStatement:(ORForStatement *)statement{
    NSMutableString *content = [@"for (" mutableCopy];
    [content appendFormat:@"%@; ",[self convertExpressionList:statement.varExpressions]];
    [content appendFormat:@"%@; ",[self convert:statement.condition]];
    [content appendFormat:@"%@)",[self convertExpressionList:statement.expressions]];
    [content appendFormat:@"%@",[self convertScopeImp:statement.scopeImp]];
    return content;
}
- (NSString *)convertForInStatement:(ORForInStatement *)statement{
    return [NSString stringWithFormat:@"for (%@ in %@)%@",[self convertDeclareExp:statement.expression],[self convert:statement.value],[self convertScopeImp:statement.scopeImp]];
}
- (NSString *)convertReturnStatement:(ORReturnStatement *)statement{
    return [NSString stringWithFormat:@"return %@",[self convert:statement.expression]];
}
- (NSString *)convertBreakStatement:(ORBreakStatement *) statement{
    return @"break";
}
- (NSString *)convertContinueStatement:(ORContinueStatement *) statement{
    return @"continue";
}
- (NSString * )convertExpressionList:(NSArray *)list{    
    NSMutableArray *array = [NSMutableArray array];
    for (ORNode * exp in list){
        [array addObject:[self convert:exp]];
    }
    return [array componentsJoinedByString:@","];
}
- (NSString *)convertVariable:(ORVariable *)var{
    NSMutableString *result = [@"" mutableCopy];
    for (int i = 0; i < var.ptCount; i++) {
        [result appendString:@"*"];
    }
    if ([var isKindOfClass:[ORFuncVariable class]]) {
        ORFuncVariable *funVar = (ORFuncVariable *)var;
        if (funVar.pairs.count > 0){
            if (funVar.varname) {
                [result appendFormat:@"%@(%@)",funVar.varname,[self convertDeclareTypeVarPairs:funVar.pairs]];
            }else{
                [result appendFormat:@"(%@)",[self convertDeclareTypeVarPairs:funVar.pairs]];
            }
        } else if (!funVar.isBlock){
            [result appendFormat:@"%@()",funVar.varname];
        }
    }else if (var.varname){
        [result appendString:var.varname];
    }
    return result;
}
- (NSString *)convertTypeVarPair:(ORTypeVarPair *)pair{
    NSString *type = pair.type ? [self convertTypeSpecial:pair.type] : @"void ";
    return [NSString stringWithFormat:@"%@%@",type,[self convertVariable:pair.var]];
}
- (NSString *)convertDeclareTypeVarPair:(ORTypeVarPair *)pair{
    if ([pair.var isKindOfClass:[ORFuncVariable class]]){
        if (pair.var.isBlock){
            if (pair.var.varname == nil) {
                return @"Block";
            }
            return [NSString stringWithFormat:@"Block %@", pair.var.varname];
        }else{
            return [NSString stringWithFormat:@"Point %@", pair.var.varname];
        }
    }else{
        switch (pair.type.type){
            case TypeUChar:
            case TypeUShort:
            case TypeUInt:
            case TypeULong:
            case TypeULongLong:
            case TypeChar:
            case TypeShort:
            case TypeInt:
            case TypeLong:
            case TypeFloat:
            case TypeDouble:
            case TypeBOOL:
            case TypeLongLong:{
                if (pair.var.ptCount > 0){
                    return [NSString stringWithFormat:@"Point %@",pair.var.varname];
                }
                break;
            }
            default:
                break;
        }
    }
    return [self convertTypeVarPair:pair];
}
- (NSString *)convertDeclareTypeVarPairs:(NSArray *)list{
    NSMutableArray *array = [NSMutableArray array];
    for (ORTypeVarPair * pair in list){
        [array addObject:[self convertDeclareTypeVarPair:pair]];
    }
    return [array componentsJoinedByString:@","];
}

- (NSString *)convertTypedefExpression:(ORTypedefExpressoin *)expression{
    NSString *content = [NSString stringWithFormat:@"typedef %@", [self convert:expression.expression]];
    if ([expression.expression isKindOfClass:[OREnumExpressoin class]]) {
        content = [content stringByAppendingFormat:@" %@", expression.typeNewName];
    }
    return content;
}

- (NSString *)convertStructExpression:(ORStructExpressoin *)expression{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"struct %@ {\n", expression.sturctName];
    for (ORDeclareExpression *node in expression.fields) {
        [content appendFormat:@"\t%@;\n", [self convert:node]];
    }
    [content appendString:@"}"];
    return content;
}

- (NSString *)convertUnionExpression:(ORUnionExpressoin *)expression{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"union %@ {\n", expression.unionName];
    for (ORDeclareExpression *node in expression.fields) {
        [content appendFormat:@"\t%@;\n", [self convert:node]];
    }
    [content appendString:@"}"];
    return content;
}

- (NSString *)convertEnumExpression:(OREnumExpressoin *)expression{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"enum %@{\n", expression.enumName];
    for (ORNode *node in expression.fields) {
        [content appendFormat:@"\t%@,\n", [self convert:node]];
    }
    [content appendString:@"}"];
    return content;
}

- (NSString *)convertProtocol:(ORProtocol *)protocol{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"protocol %@ ", protocol.protcolName];
    if (protocol.protocols.count > 0) {
        [content appendFormat:@"<%@>", [protocol.protocols componentsJoinedByString:@","]];
    }
    [content appendString:@"{\n"];
    for (ORPropertyDeclare *prop in protocol.properties) {
        [content appendString:[self convert:prop]];
    }
    for (ORMethodDeclare *imp in protocol.methods) {
        [content appendFormat:@"\n%@", [self convert:imp]];
    }
    [content appendString:@"\n}\n"];
    return content;
}
@end
