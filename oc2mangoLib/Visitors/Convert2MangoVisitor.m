//
//  ConvertVisitor.m
//  oc2mangoLib
//
//  Created by Jiang on 2021/6/23.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import "Convert2MangoVisitor.h"
static NSString *convertBuffer = nil;
@implementation Convert2MangoVisitor
- (NSString *)convert:(ORNode *)node{
    convertBuffer = @"";
    [self visit:node];
    return convertBuffer;
}
- (void)visit:(ORNode *)node{
    AstVisitor_VisitNode(self, node);
    if (node.withSemicolon) {
        convertBuffer = [convertBuffer stringByAppendingString:@";"];
    }
}
- (void)visitEmptyNode:(ORNode *)node{
    convertBuffer = @"nil";
}
- (void)visitClassNode:(ORClassNode *)node{
    NSMutableString *content = [NSMutableString string];
    [content appendFormat:@"class %@:%@",node.className,node.superClassName];
    if (node.protocols.count > 0) {
        [content appendFormat:@"<%@>",[node.protocols componentsJoinedByString:@","]];
    }
    [content appendString:@"{\n"];
    for (ORPropertyNode *prop in node.properties) {
        [self visit:prop];
        [content appendString:convertBuffer];
    }
    for (ORMethodNode *imp in node.methods) {
        [self visit:imp];
        [content appendString:convertBuffer];
    }
    [content appendString:@"\n}\n"];
    convertBuffer = content;
}
- (void)visitTypeNode:(ORTypeNode *)node{
    if (node == nil) {
        convertBuffer = @"void ";
        return;
    }
    NSMutableString *result = [NSMutableString string];
    switch (node.type){
        case OCTypeUChar:
        case OCTypeUShort:
        case OCTypeUInt:
        case OCTypeULong:
        case OCTypeULongLong:
            [result appendString:@"uint"]; break;
        case OCTypeChar:
        case OCTypeShort:
        case OCTypeInt:
        case OCTypeLong:
        case OCTypeLongLong:
            [result appendString:@"int"]; break;
        case OCTypeDouble:
        case OCTypeFloat:
            [result appendString:@"double"]; break;
        case OCTypeVoid:
            [result appendString:@"void"]; break;
        case OCTypeSEL:
            [result appendString:@"SEL"]; break;
        case OCTypeClass:
            [result appendString:@"Class"]; break;
        case OCTypeBOOL:
            [result appendString:@"BOOL"]; break;
        case OCTypeObject:
            [result appendString:node.name]; break;
            
        case OCTypeStruct:
            [result appendString:node.name]; break;
            break;
        default:
            [result appendString:@"UnKnownType"];
            break;
    }
    [result appendString:@" "];
    convertBuffer = result;
}
- (void)visitPropertyNode:(ORPropertyNode *)node{
    NSString *propKeywords =  [node.keywords componentsJoinedByString:@","];
    [self visit:node.var];
    NSString *var = convertBuffer;
    convertBuffer = [NSString stringWithFormat:@"@property(%@)%@;\n",propKeywords, var];
}
- (void)visitMethodDeclNode:(ORMethodDeclNode *)node{
    NSString *methodName = @"";
    if (node.parameters.count == 0) {
        methodName = node.methodNames.firstObject;
    }else{
        NSMutableArray *list = [NSMutableArray array];
        
        for (int i = 0; i < node.parameters.count; i++) {
            ORDeclaratorNode *decl = node.parameters[i];
            NSString *varname = decl.var.varname;
            decl.var.varname = nil;
            [self visit:node.parameters[i]];
            [list addObject:[NSString stringWithFormat:@"%@:(%@)%@",
                             node.methodNames[i],
                             convertBuffer,
                             varname]];
             decl.var.varname = varname;
        }
        methodName = [list componentsJoinedByString:@" "];
    }
    [self visit:node.returnType];
    convertBuffer = [NSString stringWithFormat:@"%@(%@)%@",node.isClassMethod?@"+":@"-",convertBuffer,methodName];
}
- (void)visitMethodNode:(ORMethodNode *)node{
    [self visit:node.declare];
    NSString *decalre = convertBuffer.copy;
    [self visit:node.scopeImp];
    NSString *imp = convertBuffer.copy;
    convertBuffer = [NSString stringWithFormat:@"\n%@%@",decalre, imp];
}

int convert_indentationCont = 0;
- (void)visitBlockNode:(ORBlockNode *)node{
    NSMutableString *content = [NSMutableString string];
    convert_indentationCont++;
    [content appendString:@"{\n"];
    NSMutableString *tabs = [@"" mutableCopy];
    for (int i = 0; i < convert_indentationCont - 1; i++) {
        [tabs appendString:@"    "];
    }
    for (id statement in node.statements) {
        if ([statement isKindOfClass:[ORNode class]]) {
            [self visit:statement];
            [content appendFormat:@"%@    %@\n",tabs,convertBuffer];
        }
    }
    [content appendFormat:@"%@}",tabs];
    convert_indentationCont--;
    convertBuffer = content;
}
- (void)visitFunctionNode:(ORFunctionNode *)node{
    NSMutableString *content = [NSMutableString string];
    if (node.declare) {
        if (!node.declare.var.isBlock) {
            // void x(int y){ }
            [self visit:node.declare];
            [content appendFormat:@"%@", convertBuffer];
        }else{
            // ^void (int x){ }
            [self visit:node.declare];
            [content appendFormat:@"^%@", convertBuffer];
        }
    }
    [self visitBlockNode:node.scopeImp];
    [content appendString:convertBuffer];
    convertBuffer = content;
}
- (void)visitBinaryNode:(ORBinaryNode *)node{
    NSString *op = @"";
    switch (node.operatorType) {
        case BinaryOperatorAdd:
            op = @"+";
            break;
        case BinaryOperatorSub:
            op = @"-";
            break;
        case BinaryOperatorDiv:
            op = @"/";
            break;
        case BinaryOperatorMulti:
            op = @"*";
            break;
        case BinaryOperatorMod:
            op = @"%";
            break;
        case BinaryOperatorShiftLeft:
            op = @"<<";
            break;
        case BinaryOperatorShiftRight:
            op = @">>";
            break;
        case BinaryOperatorAnd:
            op = @"&";
            break;
        case BinaryOperatorOr:
            op = @"|";
            break;
        case BinaryOperatorXor:
            op = @"^";
            break;
        case BinaryOperatorLT:
            op = @"<";
            break;
        case BinaryOperatorGT:
            op = @">";
            break;
        case BinaryOperatorLE:
            op = @"<=";
            break;
        case BinaryOperatorGE:
            op = @">=";
            break;
        case BinaryOperatorNotEqual:
            op = @"!=";
            break;
        case BinaryOperatorEqual:
            op = @"==";
            break;
        case BinaryOperatorLOGIC_AND:
            op = @"&&";
            break;
        case BinaryOperatorLOGIC_OR:
            op = @"||";
            break;
    }
    [self visit:node.left];
    NSString *left = convertBuffer.copy;
    [self visit:node.right];
    NSString *right = convertBuffer.copy;
    convertBuffer = [NSString stringWithFormat:@"%@ %@ %@",left,op,right];
}
- (void)visitUnaryNode:(ORUnaryNode *)node{
    NSString *format = @"%@";
    switch (node.operatorType) {
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
    [self visit:node.value];
    convertBuffer = [NSString stringWithFormat:format,convertBuffer];
}
- (void)visitTernaryNode:(ORTernaryNode *)node{
    if (node.values.count == 1) {
        [self visit:node.expression];
        NSString *condition = convertBuffer.copy;
        [self visit:node.values.firstObject];
        NSString *value = convertBuffer.copy;
        convertBuffer = [NSString stringWithFormat:@"%@ ?: %@",condition,value];
    }else{
        [self visit:node.expression];
        NSString *condition = convertBuffer.copy;
        [self visit:node.values.firstObject];
        NSString *value1 = convertBuffer.copy;
        [self visit:node.values.lastObject];
        NSString *value2 = convertBuffer.copy;
        convertBuffer = [NSString stringWithFormat:@"%@ ? %@ : %@",condition, value1, value2];
    }
}
BOOL convert_is_left_value = true;
- (void)visitInitDeclaratorNode:(ORInitDeclaratorNode *)node{
    if (node.expression) {
        NSMutableString *str = [NSMutableString string];
        convert_is_left_value = true;
        [self visit:node.declarator];
        [str appendString:convertBuffer];
        convert_is_left_value = false;
        [str appendString:@" = "];
        [self visit:node.expression];
        [str appendString:convertBuffer];
        convertBuffer = str;
    }else{
        [self visit:node.declarator];
        convertBuffer = [NSString stringWithFormat:@"%@",convertBuffer];
    }
}
- (void)visitAssignNode:(ORAssignNode *)node{
    NSMutableString *str = [NSMutableString string];
    convert_is_left_value = true;
    [self visit:node.value];
    [str appendString:convertBuffer];
    convert_is_left_value = false;
    [str appendString:@" = "];
    [self visit:node.expression];
    [str appendString:convertBuffer];
    convertBuffer = str;
}
- (void)visitIntegerValue:(ORIntegerValue *)node{
    convertBuffer = [NSString stringWithFormat:@"%lld",node.value];
}
- (void)visitUIntegerValue:(ORUIntegerValue *)node{
    convertBuffer = [NSString stringWithFormat:@"%llu",node.value];
}
- (void)visitDoubleValue:(ORDoubleValue *)node{
    convertBuffer = [NSString stringWithFormat:@"%f",node.value];
}
- (void)visitBoolValue:(ORBoolValue *)node{
    convertBuffer = [NSString stringWithFormat:@"%@",node.value ? @"YES" : @"NO"];
}
- (void)visitValueNode:(ORValueNode *)node{
    switch (node.value_type){
        case OCValueSelector:
            convertBuffer = [NSString stringWithFormat:@"@selector(%@)",node.value];
            return;
        case OCValueVariable:
            convertBuffer = node.value;
            return;
        case OCValueSelf:
            convertBuffer =@"self";
            return;
        case OCValueSuper:
            convertBuffer = @"super";
            return;
            
        case OCValueString:
            convertBuffer = [NSString stringWithFormat:@"@\"%@\"",node.value?:@""];
            return;
        case OCValueCString:
            convertBuffer = [NSString stringWithFormat:@"\"%@\"",node.value?:@""];
            return;
        case OCValueProtocol:
            convertBuffer = [NSString stringWithFormat:@"@protocol(%@)",node.value];
            return;
        case OCValueDictionary:
        {
            NSMutableArray <NSMutableArray *>*keyValuePairs = node.value;
            NSMutableArray *pairs = [NSMutableArray array];
            for (NSMutableArray *keyValue in keyValuePairs) {
                [self visit:keyValue[0]];
                NSString *key = convertBuffer.copy;
                [self visit:keyValue[1]];
                NSString *value = convertBuffer.copy;
                [pairs addObject:[NSString stringWithFormat:@"%@:%@",key,value]];
            }
            convertBuffer =[NSString stringWithFormat:@"@{%@}",[pairs componentsJoinedByString:@","]];
            return;
        }
        case OCValueArray:{
            NSMutableArray *exps = node.value;
            NSMutableArray *elements = [NSMutableArray array];
            for (ORNode * exp in exps) {
                [self visit:exp];
                [elements addObject:convertBuffer];
            }
            convertBuffer = [NSString stringWithFormat:@"@[%@]",[elements componentsJoinedByString:@","]];
            return;
        }
        case OCValueNSNumber:{
            if ([node.value isKindOfClass:[NSString class]]) {
                convertBuffer =[NSString stringWithFormat:@"@(%@)",node.value];
            }
            if ([node.value isKindOfClass:[ORNode class]]) {
                [self visit:node.value];
                convertBuffer = [NSString stringWithFormat:@"@(%@)",convertBuffer];
            }
            return;
            
        }
        case OCValueNil:
            convertBuffer = @"nil";
            return;
        case OCValueNULL:
            convertBuffer = @"NULL";
            return;
    }
    convertBuffer = @"";
}
- (void)visitSubscriptNode:(ORSubscriptNode *)node{
    [self visit:node.caller];
    NSString *caller = convertBuffer.copy;
    [self visit:node.keyExp];
    NSString *key = convertBuffer.copy;
    convertBuffer = [NSString stringWithFormat:@"%@[%@]", caller, key];
}
- (void)visitFunctionCall:(ORFunctionCall *)node{
    // FIX: make.left.equalTo(superview.mas_left) to make.left.equalTo()(superview.mas_left)
    // FIX: x.left(a) to x.left()(a)
    [self visit:node.caller];
    NSString *caller = convertBuffer.copy;
    NSMutableArray *expList = [NSMutableArray array];
    for (ORNode *exp in node.expressions) {
        [self visit:exp];
        [expList addObject:convertBuffer];
    }
    NSString *exps = [expList componentsJoinedByString:@","];
    if ([node.caller isKindOfClass:[ORMethodCall class]] && [(ORMethodCall *)node.caller methodOperator]){
        convertBuffer = [NSString stringWithFormat:@"%@()(%@)",caller,exps];
        return;
    }
    convertBuffer = [NSString stringWithFormat:@"%@(%@)",caller,exps];
}
- (void)visitMethodCall:(ORMethodCall *)node{
    NSMutableString *methodName = node.selectorName;
    NSString *sel;
    if (node.values.count == 0) {
        if (node.methodOperator) {
            sel = [NSString stringWithFormat:@".%@",methodName];
        }else{
            sel = [NSString stringWithFormat:@".%@()",methodName];
        }
    }else{
        NSMutableArray *expList = [NSMutableArray array];
        for (ORNode *exp in node.values) {
            [self visit:exp];
            [expList addObject:convertBuffer];
        }
        sel = [NSString stringWithFormat:@".%@:(%@)",methodName,[expList componentsJoinedByString:@","]];
    }
    [self visit:node.caller];
    convertBuffer = [NSString stringWithFormat:@"%@%@",convertBuffer,sel];
}
- (void)visitIfStatement:(ORIfStatement *)node{
    NSString *content = @"";
    for (int i = 0; i < node.statements.count; i++) {
        ORIfStatement *sub = node.statements[i];
        if (i == 0) {
            [self visit:node.condition];
            NSString *condition = convertBuffer.copy;
            [self visit:node.scopeImp];
            condition = [NSString stringWithFormat:@"if(%@)%@",condition,convertBuffer];
        }else{
            if (!sub.condition) {
                [self visit:sub.scopeImp];
                content = [NSString stringWithFormat:@"%@else%@",content,convertBuffer];
            }else{
                [self visit:sub.condition];
                NSString *condition = convertBuffer.copy;
                [self visit:sub.scopeImp];
                content = [NSString stringWithFormat:@"%@else if(%@)%@",content,condition,convertBuffer];
            }
        }
    }
    convertBuffer = content;
}
- (void)visitWhileStatement:(ORWhileStatement *)node{
    NSMutableString *content = [NSMutableString string];
    [self visit:node.condition];
    [content appendFormat:@"while(%@)",convertBuffer];
    [self visit:node.scopeImp];
    [content appendString:convertBuffer];
    convertBuffer = content;
}
- (void)visitDoWhileStatement:(ORDoWhileStatement *)node{
    [self visit:node.condition];
    NSString *condition = convertBuffer.copy;
    [self visit:node.scopeImp];
    convertBuffer = [NSString stringWithFormat:@"do%@while(%@)",convertBuffer,condition];
}
- (void)visitSwitchStatement:(ORSwitchStatement *)node{
    [self visit:node.value];
    NSString *value = convertBuffer.copy;
    NSMutableString *content = [NSMutableString string];
    for (ORCaseStatement *caseState in node.cases) {
        [self visit:caseState];
        [content appendString:convertBuffer];
    }
    convertBuffer = [NSString stringWithFormat:@"switch(%@){\n%@}",value,content];
}
- (void)visitForStatement:(ORForStatement *)node{
    NSMutableString *content = [@"for (" mutableCopy];
    NSMutableArray *varList = [NSMutableArray array];
    for (ORNode *var in node.varExpressions) {
        [self visit:var];
        [varList addObject:convertBuffer];
    }
    [content appendFormat:@"%@; ",[varList componentsJoinedByString:@","]];
    [self visit:node.condition];
    [content appendFormat:@"%@; ",convertBuffer];
    NSMutableArray *expList = [NSMutableArray array];
    for (ORNode *exp in node.expressions) {
        [self visit:exp];
        [expList addObject:convertBuffer];
    }
    [content appendFormat:@"%@)",[expList componentsJoinedByString:@","]];
    [self visit:node.scopeImp];
    [content appendFormat:@"%@",convertBuffer];
    convertBuffer = content;
}
- (void)visitForInStatement:(ORForInStatement *)node{
    [self visit:node.expression];
    NSString *decl = convertBuffer.copy;
    [self visit:node.value];
    NSString *var = convertBuffer.copy;
    [self visit:node.scopeImp];
    convertBuffer = [NSString stringWithFormat:@"for (%@ in %@)%@",decl,var,convertBuffer];
}
- (void)visitControlStatNode:(ORControlStatNode *)node{
    switch (node.type) {
        case ORControlStatBreak:
            convertBuffer = @"break";
            return;
        case ORControlStatContinue:
            convertBuffer = @"continue";
            return;
        case ORControlStatReturn:
            [self visit:node.expression];
            convertBuffer = [NSString stringWithFormat:@"return %@",convertBuffer];
            return;
        default:
            break;
    }
}
- (void)visitVariableNode:(ORVariableNode *)node{
    NSMutableString *result = [@"" mutableCopy];
    for (int i = 0; i < node.ptCount; i++) {
        [result appendString:@"*"];
    }
    if (node.varname){
        [result appendString:node.varname];
    }
    convertBuffer = result;
}
- (void)visitFunctionDeclNode:(ORFunctionDeclNode *)node{
    if (convert_is_left_value && node.var.isBlock){
        if (node.var.varname == nil) {
            convertBuffer = @"Block";
            return;
        }
        convertBuffer = [NSString stringWithFormat:@"Block %@", node.var.varname];
        return;
    }else{
        NSMutableString *result = [@"" mutableCopy];
        [self visit:node.type];
        NSString *returnStr = convertBuffer.copy;
        [self visit:node.var];
        NSString *funcName = convertBuffer.copy;
        if (node.params.count > 0){
            NSMutableArray *exps = [NSMutableArray array];
            for (ORNode *param in node.params) {
                [self visit:param];
                [exps addObject:convertBuffer];
            }
            NSString *params = [exps componentsJoinedByString:@","];
            [result appendFormat:@"%@%@(%@)",returnStr,funcName,params];
        } else if (!node.var.isBlock){
            [result appendFormat:@"%@%@()",returnStr,funcName];
        } else if (node.var.isBlock){
            [result appendFormat:@"%@%@",returnStr,funcName];
        }
        convertBuffer = result;
        return;
    }
}
- (void)visitDeclaratorNode:(ORDeclaratorNode *)node{
    switch (node.type.type){
        case OCTypeUChar:
        case OCTypeUShort:
        case OCTypeUInt:
        case OCTypeULong:
        case OCTypeULongLong:
        case OCTypeChar:
        case OCTypeShort:
        case OCTypeInt:
        case OCTypeLong:
        case OCTypeFloat:
        case OCTypeDouble:
        case OCTypeBOOL:
        case OCTypeLongLong:{
            if (node.var.ptCount > 0){
                convertBuffer= [NSString stringWithFormat:@"Point %@",node.var.varname];
                return;
            }
            break;
        }
        default:
            break;
    }
    [self visit:node.type];
    NSString *nodeTypeString = convertBuffer.copy;
    NSString *type = node.type ? nodeTypeString : @"void ";
    [self visit:node.var];
    convertBuffer = [NSString stringWithFormat:@"%@%@",type,convertBuffer];
}

- (void)visitCArrayDeclNode:(nonnull ORCArrayDeclNode *)node {
    
}


- (void)visitCaseStatement:(nonnull ORCaseStatement *)node {
    NSMutableString * content = [NSMutableString string];
    if (node.value) {
        [self visit:node.value];
        NSString *condition = convertBuffer.copy;
        [self visit:node.scopeImp];
        [content appendFormat:@"case %@:%@\n",condition,convertBuffer];
    }else{
        [self visit:node.scopeImp];
        [content appendFormat:@"default:%@\n",convertBuffer];
    }
    convertBuffer = content;
}


- (void)visitEnumStatNode:(nonnull OREnumStatNode *)node {
    
}


- (void)visitProtocolNode:(nonnull ORProtocolNode *)node {
    
}


- (void)visitStructStatNode:(nonnull ORStructStatNode *)node {
    
}


- (void)visitTypedefStatNode:(nonnull ORTypedefStatNode *)node {
    
}


- (void)visitUnionStatNode:(nonnull ORUnionStatNode *)node {
    
}

@end
