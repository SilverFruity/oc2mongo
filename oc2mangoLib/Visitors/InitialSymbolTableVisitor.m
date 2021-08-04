//
//  InitialSymbolVisitor.m
//  oc2mangoLib
//
//  Created by Jiang on 2021/6/25.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import "InitialSymbolTableVisitor.h"
#import "ocHandleTypeEncode.h"

static unsigned long or_mem_offset = 0;
static unsigned long or_const_offset = 0;
static BOOL is_return_declarator = NO;

static const char *typeEncodeForDeclaratorNode(ORDeclaratorNode * node);
static const char *typeEncodeWithSearchSymbolTable(ORDeclaratorNode *node){
    ORTypeNode *typeSpecial = node.type;
    ORVariableNode *var = node.var;
    OCType type = typeSpecial.type;
    ocSymbol *symbol = [symbolTableRoot lookup:typeSpecial.name];
    char encoding[128] = { 0 };
    const char *suffixEncode = "";
    if (symbol) {
        suffixEncode = symbol.decl.typeEncode;
        assert(suffixEncode != NULL);
        type = symbol.decl.type;
        if (symbol.decl->isClassRef) {
            suffixEncode = OCTypeStringObject;
            type = OCTypeObject;
        }
    }else{
        #define CaseTypeEncoding(type)\
        case OCType##type: suffixEncode = OCTypeString##type; break;
        switch (type) {
            case OCTypeChar:
            {
                if (var.ptCount > 0)
                    strcat(encoding, OCTypeStringCString);
                else
                    strcat(encoding, OCTypeStringChar);
                break;
            }
                CaseTypeEncoding(Int)
                CaseTypeEncoding(Short)
                CaseTypeEncoding(Long)
                CaseTypeEncoding(LongLong)
                CaseTypeEncoding(UChar)
                CaseTypeEncoding(UInt)
                CaseTypeEncoding(UShort)
                CaseTypeEncoding(ULong)
                CaseTypeEncoding(ULongLong)
                CaseTypeEncoding(Float)
                CaseTypeEncoding(Double)
                CaseTypeEncoding(BOOL)
                CaseTypeEncoding(Object)
                CaseTypeEncoding(Class)
                CaseTypeEncoding(SEL)
                CaseTypeEncoding(Void)
            default:
                break;
        }
        #undef CaseTypeEncoding
    }
    NSInteger tmpPtCount = var.ptCount;
    if (tmpPtCount == 0 && TypeEncodeCharIsBaseType(type)) {
        char typeEncode[2] = { (char)type, '\0' };
        return strdup(typeEncode);
    }
    while (tmpPtCount > 0) {
        if (type == OCTypeChar && tmpPtCount == 1) {
            break;
        }
        if (type == OCTypeObject && tmpPtCount == 1) {
            break;
        }
        strcat(encoding, "^");
        tmpPtCount--;
    }
    strcat(encoding, suffixEncode);
    strcat(encoding, "\0");
    return [NSString stringWithFormat:@"%s",encoding].UTF8String;
}

static const char *cArrayTypeEncode(ORCArrayDeclNode *node){
    // for xx a[];
    if ([(ORIntegerValue *)node.capacity value] == 0) {
        const char *result = typeEncodeWithSearchSymbolTable(node);
        size_t result_len = strlen(result);
        size_t buffer_len = result_len + 2;
        char buffer[buffer_len];
        memset(buffer, 0, buffer_len);
        buffer[0] = '^';
        memcpy(buffer + 1, result, result_len);
        return [NSString stringWithFormat:@"%s",buffer].UTF8String;;
    }
    ORCArrayDeclNode *tmp = node;
    NSMutableArray *nodes = [NSMutableArray array];
    while (tmp) {
        [nodes insertObject:tmp atIndex:0];
        tmp = tmp.prev;
    }
    char result[100] = {0};
    char buffer[50]  = {0};
    char rights[20]  = {0};
    for (int i = 0; i < nodes.count; i++) {
        ORCArrayDeclNode *item = nodes[i];
        if (item.capacity.isConst) {
            sprintf(buffer, "[%ld", [item.capacity integerValue]);
        }else if(item.capacity){
            memset(buffer, 0, strlen(buffer));
            strcpy(buffer, "[%ld");
        }
        strcat(result, buffer);
        if (i != nodes.count - 1) {
            strcat(rights, "]");
        }else{
            sprintf(buffer, "%s]", typeEncodeForDeclaratorNode([ORDeclaratorNode copyFromDecl:item]));
            strcat(result, buffer);
        }
    }
    strcat(result, rights);
    return [NSString stringWithFormat:@"%s",result].UTF8String;
}
static const char *functionTypeEncode(ORFunctionDeclNode *node){
    char signature [128] = { 0 };
    // 函数 void (int, int) TypEncode 签名: ^?vii
    // Block void (^)(int, int) TypEncode 签名: @?v@ii
    
    ORDeclaratorNode *returnNode = [ORDeclaratorNode copyFromDecl:node];
    if(node.var.isBlock){
        // block
        strcat(signature, "@?");
    }else{
        // function
        // 针对 void func(void); 其ptCount默认为1，当作函数指针处理
        strcat(signature, "^?");
    }
    strcat(signature, typeEncodeForDeclaratorNode(returnNode));
    for (ORDeclaratorNode *param in node.params) {
        strcat(signature, typeEncodeForDeclaratorNode(param));
    }
    return [NSString stringWithFormat:@"%s",signature].UTF8String;;
}

static const char *typeEncodeForDeclaratorNode(ORDeclaratorNode * node){
    if (node.nodeType == AstEnumCArrayDeclNode){
        ORCArrayDeclNode *arrayNode = (ORCArrayDeclNode *)node;
        return cArrayTypeEncode(arrayNode);
    }else if (node.nodeType == AstEnumFunctionDeclNode){
        ORFunctionDeclNode *functionNode = (ORFunctionDeclNode *)node;
        return functionTypeEncode(functionNode);
    }
    return typeEncodeWithSearchSymbolTable(node);
}

@implementation InitialSymbolTableVisitor
- (instancetype)init
{
    self = [super init];
    symbolTableRoot = [ocSymbolTable new];
    internalFunctionTable = [NSMutableDictionary dictionary];
    return self;
}
- (void)visit:(nonnull ORNode *)node {
    AstVisitor_VisitNode(self, node);
}

#pragma mark - Function
- (void)visitBlockNode:(nonnull ORBlockNode *)node {
    for (ORNode *state in node.statements) {
        [self visit:state];
    }
}
- (void)visitFunctionDeclNode:(nonnull ORFunctionDeclNode *)node {
//    const char *signature = typeEncodeForDeclaratorNode(node);
//    ocDecl *decl = [ocDecl new];
//    decl.typeEncode = signature;
//    // Return Type Name，使用函数的返回值信息，作为函数的符号类型
//    decl.typeName = node.type.name;
//    NSAssert(node.var.varname.length > 0, @"");
//    // 针对正常的函数实现，在函数作用域的上一级作用域注册该函数的信息
//    ocSymbol *symbol = [ocSymbol symbolWithName:node.var.varname decl:decl];
//    [symbolTableRoot insert:symbol];
}

- (void)visitFunctionNode:(nonnull ORFunctionNode *)node {
    or_mem_offset = 0;
    ocDecl *decl = [ocDecl new];
    decl.typeEncode = typeEncodeForDeclaratorNode(node.declare);;
    // Return Type Name，使用函数的返回值信息，作为函数的符号类型
    decl.typeName = node.declare.type.name;
    NSString *functionName = node.declare.var.varname;
    
    internalFunctionTable[functionName] = node;
    
    // 针对正常的函数实现，在函数作用域的上一级作用域注册该函数的信息
    if (functionName.length != 0){
        ocSymbol *symbol = [ocSymbol symbolWithName:functionName decl:decl];
        [symbolTableRoot insert:symbol];
    }
    
    //包括匿名函数，自己持有签名信息
    node.symbol = [ocSymbol symbolWithName:nil decl:decl];
    
    is_return_declarator = YES;
    [self visit:[ORDeclaratorNode copyFromDecl:node.declare]];
    is_return_declarator = NO;
    
    [symbolTableRoot increaseScope];
    // 在函数实现的作用域中添加参数的符号信息
    for (ORNode *param in node.declare.params) {
        [self visit:param];
    }
    [self visit:node.scopeImp];
    
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
    
    or_mem_offset = 0;
}

#pragma mark - Class

- (void)visitProtocolNode:(nonnull ORProtocolNode *)node {

}
- (void)visitPropertyNode:(nonnull ORPropertyNode *)node {
    ocDecl *propDecl = [ocDecl new];
    propDecl.typeEncode = typeEncodeForDeclaratorNode(node.var);
    propDecl.typeName = node.var.type.name;
    propDecl->isProperty = YES;
    propDecl.propModifer = node.modifier;
    ocSymbol *propSymbol = [ocSymbol symbolWithName:[NSString stringWithFormat:@"@%@",node.var.var.varname] decl:propDecl];
    node.symbol = propSymbol;
    [symbolTableRoot insert:propSymbol];
    
    // 不使用assing的类型可以确定为NSObject的子类，向根符号表注册类符号
    MFPropertyModifier modifer = (MFPropertyModifier)(propDecl.propModifer & MFPropertyModifierMemMask);
    if (modifer != MFPropertyModifierMemAssign) {
        ocDecl *classDecl = [ocDecl new];
        classDecl.typeName = node.var.type.name;
        classDecl.typeEncode = OCTypeStringClass;
        classDecl->isClassRef = YES;
        ocSymbol *symbol = [ocSymbol symbolWithName:classDecl.typeName decl:classDecl];
        [symbolTableRoot insertRoot:symbol];
    }
    is_return_declarator = YES;
    [self visit:node.var];
    is_return_declarator = NO;
    ocDecl *ivarDecl = [ocDecl new];
    ivarDecl.typeEncode = propDecl.typeEncode;
    ivarDecl.typeName = propDecl.typeName;
    ivarDecl->isIvar = YES;
    ocSymbol *ivarSymbol = [ocSymbol symbolWithName:[NSString stringWithFormat:@"_%@",node.var.var.varname] decl:ivarDecl];
    [symbolTableRoot insert:ivarSymbol];
}
- (void)visitMethodDeclNode:(nonnull ORMethodDeclNode *)node {
    is_return_declarator = YES;
    [self visit:node.returnType];
    is_return_declarator = NO;
    //向method作用域注册参数符号
    //第一个参数为self或super
    ocDecl *selfDecl = [ocDecl new];
    selfDecl.typeName = @"id";
    selfDecl.typeEncode = OCTypeStringObject;
    selfDecl.offset = or_mem_offset;
    selfDecl->isSelf = YES;
    ocSymbol * selfSymbol = [ocSymbol symbolWithName:@"self" decl:selfDecl];
    
    ocDecl *superDecl = [ocDecl new];
    superDecl.typeName = @"id";
    superDecl.typeEncode = OCTypeStringObject;
    superDecl.offset = or_mem_offset;
    superDecl->isSuper = YES;
    ocSymbol * superSymbol = [ocSymbol symbolWithName:@"super" decl:superDecl];
    [symbolTableRoot insert:selfSymbol];
    [symbolTableRoot insert:superSymbol];
    
    or_mem_offset += MAX(selfDecl.size, 8);

    //第二个参数为sel
    ocDecl *selDecl = [ocDecl new];
    selDecl.typeName = @"SEL";
    selDecl.typeEncode = OCTypeStringSEL;
    selDecl.offset = or_mem_offset;
    ocSymbol * selSymbol = [ocSymbol symbolWithName:@"sel" decl:selDecl];
    [symbolTableRoot insert:selSymbol];
    or_mem_offset += MAX(selDecl.size, 8);
    
    for (int i = 0; i < node.parameters.count; i++) {
        [self visit:node.parameters[i]];
    }
}
- (void)visitMethodNode:(nonnull ORMethodNode *)node {
    
    or_mem_offset = 0;
    
    //生成 method 签名信息
    char methodTypeEncode[256] = { 0 };
    const char *returnTypeEncode = typeEncodeForDeclaratorNode(node.declare.returnType);
    strcat(methodTypeEncode, returnTypeEncode);
    strcat(methodTypeEncode, OCTypeStringObject);
    strcat(methodTypeEncode, OCTypeStringSEL);
    for (ORDeclaratorNode *param in node.declare.parameters) {
        strcat(methodTypeEncode, typeEncodeForDeclaratorNode(param));
    }
    
    ocDecl *methodDecl = [ocDecl new];
    methodDecl.typeEncode = methodTypeEncode;
    methodDecl.size = sizeOfTypeEncode(returnTypeEncode);
    methodDecl->isMethod = YES;
    methodDecl->isClassMethod = node.declare.isClassMethod;
    
    //向Class作用域添加Method的符号信息
    ocSymbol *symbol = [ocSymbol new];
    symbol.decl = methodDecl;
    symbol.name = node.declare.selectorName;
    [symbolTableRoot insert:symbol];
    node.symbol = symbol;
    
    [symbolTableRoot increaseScope];
    [self visit:node.declare];
    [self visit:node.scopeImp];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
    
    or_mem_offset = 0;
}

- (void)visitClassNode:(nonnull ORClassNode *)node {
//    ocDecl *classDecl = [ocDecl new];
//    classDecl.typeName = node.className;
//    classDecl.typeEncode = OCTypeStringObject;
//    ocSymbol *symbol = [ocSymbol symbolWithName:node.className decl:classDecl];
//    [symbolTableRoot insertRoot:symbol];
    
    ocDecl *classRefDecl = [ocDecl new];
    classRefDecl.typeName = node.className;
    classRefDecl.typeEncode = OCTypeStringClass;
    classRefDecl->isClassRef = YES;
    ocSymbol *classRefSymbol = [ocSymbol symbolWithName:node.className decl:classRefDecl];
    [symbolTableRoot insertRoot:classRefSymbol];
    
    [symbolTableRoot increaseScope];
        
    for (ORPropertyNode *prop in node.properties) {
        [self visit:prop];
    }
    for (ORDeclaratorNode *ivar in node.privateVariables) {
        ocDecl *ivarDecl = [ocDecl new];
        ivarDecl.typeEncode = typeEncodeForDeclaratorNode(ivar);
        ivarDecl.typeName = ivar.type.name;
        ivarDecl->isIvar = YES;
        ocSymbol *ivarSymbol = [ocSymbol symbolWithName:ivar.var.varname decl:ivarDecl];
        [symbolTableRoot insert:ivarSymbol];
    }
    // 所有 method 的父作用域是 Class 作用域
    for (ORMethodNode *method in node.methods) {
        [self visitMethodNode:method];
    }
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
    
}

- (void)visitControlStatNode:(nonnull ORControlStatNode *)node {
    [self visit:node.expression];
}

#pragma mark - ConstValue
- (ocSymbol *)createConstantSymbol:(const char *)typeEncode value:(void *)value cacheKey:(id)key{
    ocSymbol *symbol = [symbolTableRoot getConstantSymbol:(id <NSCopying>)key];
    if (symbol) {
        return symbol;
    }
    ocDecl *decl = [ocDecl new];
    decl.typeEncode = typeEncode;
    decl.offset = or_const_offset;
    decl->isConstant = YES;
    BOOL is_string_constant = [key isKindOfClass:[NSString class]];
    if (is_string_constant) {
        decl.size = strlen((char *)value) + 1;
    }
    symbol = [ocSymbol symbolWithName:nil decl:decl];
    or_const_offset += decl.size;
    symbolTableRoot->constants_size = or_const_offset;
    symbolTableRoot->constants = (char *)realloc(symbolTableRoot->constants, sizeof(unichar) * symbolTableRoot->constants_size);
    memcpy(symbolTableRoot->constants + decl.offset, value, decl.size);
    if (is_string_constant) {
        memcpy(symbolTableRoot->constants + decl.offset + decl.size - 1, "\0", 1);
    }
    [symbolTableRoot addConstantSymbol:symbol withKey:key];
    
    return symbol;
}

- (void)visitValueNode:(nonnull ORValueNode *)node {
    switch (node.value_type) {
        case OCValueSelf:
            node.symbol = [symbolTableRoot lookup:@"self"];
            break;
        case OCValueSuper:
            node.symbol = [symbolTableRoot lookup:@"super"];
            break;
        case OCValueVariable:
        {
            ocSymbol *symbol = [symbolTableRoot lookup:node.value];
            // NSObject *a = nil;
            // b = a.xxx;
            // a.xxx = b;
            // [[a xxx] yyy];
            // b = a.xxx();
            // 找到 a 的类型 NSObject，并注册为Class
            if (symbol.decl.isStruct == NO
                && symbol.decl.isFunction == NO
                && (symbol == nil || symbol.decl.isObject )) {
                ocDecl *classDecl = [ocDecl new];
                if (symbol == nil) {
                    classDecl.typeName = node.value;
                }else{
                    classDecl.typeName = symbol.decl.typeName;
                }
                classDecl.typeEncode = OCTypeStringClass;
                classDecl->isClassRef = YES;
                ocSymbol *classSymbol = [ocSymbol symbolWithName:classDecl.typeName decl:classDecl];
                [symbolTableRoot insertRoot:classSymbol];
                if (symbol == nil) {
                    node.symbol = classSymbol;
                }else{
                    node.symbol = symbol;
                }
                break;
            }
            node.symbol = symbol;
            break;
        }
        case OCValueNSNumber:
        {
            [self visit:node.value];
            break;
        }
        case OCValueDictionary:
        {
            NSMutableArray *exps = node.value;
            for (NSMutableArray <ORNode *>*kv in exps) {
                ORNode *keyExp = kv.firstObject;
                ORNode *valueExp = kv.lastObject;
                [self visit:keyExp];
                [self visit:valueExp];
            }
            break;
        }
        case OCValueArray:
        {
            NSMutableArray *exps = node.value;
            for (ORNode *exp in exps) {
                [self visit:exp];
            }
            break;
        }
        case OCValueProtocol:
        {
            NSString *value = node.value;
            node.symbol = [self createConstantSymbol:OCTypeStringCString value:(void *)value.UTF8String cacheKey:value];
            break;
        }
        case OCValueSelector:
        {
            NSString *value = node.value;
            node.symbol = [self createConstantSymbol:OCTypeStringSEL value:(void *)value.UTF8String cacheKey:value];
            break;
        }
        case OCValueString:
        {
            NSString *value = node.value;
            node.symbol = [self createConstantSymbol:OCTypeStringCString value:(void *)value.UTF8String cacheKey:value];
            break;
        }
        case OCValueCString:
        {
            NSString *value = node.value;
            node.symbol = [self createConstantSymbol:OCTypeStringCString value:(void *)value.UTF8String cacheKey:value];
            break;
        }
        default:
            break;
    }
}
- (void)visitBoolValue:(nonnull ORBoolValue *)node {
    BOOL value = node.value;
    node.symbol = [self createConstantSymbol:OCTypeStringBOOL value:&value cacheKey:@(node.value)];
}
- (void)visitIntegerValue:(nonnull ORIntegerValue *)node {
    int64_t value = node.value;
    node.symbol = [self createConstantSymbol:OCTypeStringLongLong value:&value cacheKey:@(node.value)];
}
- (void)visitUIntegerValue:(nonnull ORUIntegerValue *)node {
    uint64_t value = node.value;
    node.symbol = [self createConstantSymbol:OCTypeStringULongLong value:&value cacheKey:@(node.value)];
}
- (void)visitDoubleValue:(nonnull ORDoubleValue *)node {
    double value = node.value;
    node.symbol = [self createConstantSymbol:OCTypeStringDouble value:&value cacheKey:@(node.value)];
}
- (void)visitEmptyNode:(nonnull ORNode *)node {
    
}
#pragma mark - Control Flow
- (void)visitIfStatement:(nonnull ORIfStatement *)node {
    for (ORIfStatement *sub in node.statements) {
        if (!sub.condition) {
            [self visit:sub.scopeImp];
        }else{
            [self visit:sub.condition];
            [self visit:sub.scopeImp];
        }
    }
}
- (void)visitWhileStatement:(nonnull ORWhileStatement *)node {
    [symbolTableRoot increaseScope];
    [self visit:node.condition];
    [self visit:node.scopeImp];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}

- (void)visitDoWhileStatement:(nonnull ORDoWhileStatement *)node {
    [symbolTableRoot increaseScope];
    [self visit:node.scopeImp];
    [self visit:node.condition];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}

- (void)visitForStatement:(nonnull ORForStatement *)node {
    [symbolTableRoot increaseScope];
    for (ORNode *exp in node.expressions) {
        [self visit:exp];
    }
    [self visit:node.condition];
    [self visit:node.scopeImp];
    [symbolTableRoot decreaseScope];
}

- (void)visitForInStatement:(nonnull ORForInStatement *)node {
    [symbolTableRoot increaseScope];
    [self visit:node.expression];
    [self visit:node.value];
    [self visit:node.scopeImp];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}

- (void)visitSwitchStatement:(nonnull ORSwitchStatement *)node {
    [self visit:node.value];
    for (ORNode *caseState in node.cases) {
        [self visit:caseState];
    }
}

- (void)visitCaseStatement:(nonnull ORCaseStatement *)node {
    [symbolTableRoot increaseScope];
    [self visit:node.scopeImp];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}
#pragma mark -  Major New Symbols
- (void)visitTypeNode:(nonnull ORTypeNode *)node {
    
}

- (void)visitVariableNode:(nonnull ORVariableNode *)node {
    
}

- (void)visitDeclaratorNode:(nonnull ORDeclaratorNode *)node {
    ocDecl *decl = [ocDecl new];
    decl.typeName = node.type.name;
    decl.typeEncode = typeEncodeForDeclaratorNode(node);
    node.symbol = [ocSymbol symbolWithName:node.var.varname decl:decl];
    if (is_return_declarator) {
        return;
    }
    [symbolTableRoot insert:node.symbol];
    decl.offset = or_mem_offset;
    or_mem_offset += MAX(decl.size, 8);
}
- (void)visitInitDeclaratorNode:(nonnull ORInitDeclaratorNode *)node {
    [self visit:node.declarator];
    [self visit:node.expression];
}
- (void)visitCArrayDeclNode:(nonnull ORCArrayDeclNode *)node {
    ocDecl *decl = [ocDecl new];
    decl.typeName = @"CArray";
    const char *typeEncode = typeEncodeForDeclaratorNode(node);
    if (*typeEncode == OCTypeArray) {
        BOOL isDynamicCArray = NO;
        const char *tmp = typeEncode;
        while (*tmp != '\0') {
            if (*tmp == '%') {
                isDynamicCArray = YES;
                break;
            }
            tmp = tmp + 1;
        }
        decl->isDynamicCArray = YES;
    }
    decl.typeEncode = typeEncode;
    ocSymbol * symbol = [ocSymbol symbolWithName:node.var.varname decl:decl];
    [symbolTableRoot insert:symbol];
}

NSUInteger momeryLayoutAlignment(NSUInteger offset, NSUInteger size, NSUInteger align){
    size = MIN(size, align); // 在参数对齐数和默认对齐数取小
    if (offset % size != 0) {
        offset = ((offset + size - 1) / size) * size;
    }
    return offset;
}
- (void)visitStructStatNode:(nonnull ORStructStatNode *)node {
    // 展开 struct 内部的符号表作用域
    [symbolTableRoot increaseScope];
    
    NSMutableString *typeEncode = [@"{" mutableCopy];
    [typeEncode appendString:node.sturctName];
    [typeEncode appendString:@"="];
    NSUInteger structAlignment = 8;
    ocDecl *lastDecl = nil;
    NSMutableArray *keys = [NSMutableArray array];
    for (ORDeclaratorNode *exp in node.fields) {
        NSString *typeName = exp.type.name;
        ocSymbol *symbol = [symbolTableRoot lookup:typeName];
        const char *fieldEncode = symbol ? symbol.decl.typeEncode : typeEncodeForDeclaratorNode(exp);
        [typeEncode appendFormat:@"%s",fieldEncode];
        
        //向StructNode的作用域中注册参数类型以及内存偏移量
        ocDecl * decl;
        if (symbol.decl && symbol.decl.isStruct) {
            ocComposeDecl *cdecl = [ocComposeDecl new];
            cdecl.typeEncode = fieldEncode;
            cdecl.typeName = typeName;
            cdecl.fielsScope = [(ocComposeDecl *)symbol.decl fielsScope];
            decl = cdecl;
        }else{
            decl = [ocDecl new];
            decl.typeEncode = fieldEncode;
            decl.typeName = typeName;
        }
        [keys addObject:exp.var.varname];
        // 内存对齐
        decl.offset = momeryLayoutAlignment(lastDecl.offset + lastDecl.size, decl.size, structAlignment);;
        lastDecl = decl;
        ocSymbol *fieldSymbol = [ocSymbol symbolWithName:exp.var.varname decl:decl];
        [symbolTableRoot insert:fieldSymbol];
    }
    NSUInteger offset = momeryLayoutAlignment(lastDecl.offset + lastDecl.size, structAlignment, structAlignment);
    [typeEncode appendString:@"}"];
    // 根符号表注册struct
    ocComposeDecl *decl = [ocComposeDecl new];
    decl.typeEncode = typeEncode.UTF8String;
    decl.typeName = node.sturctName;
    decl.keys = keys;
    // 将作用域中的符号信息交给struct的字段符号表持有
    decl.fielsScope = symbolTableRoot.scope;
    // 默认内存对齐值(8)时，NSGetSizeAndAlignment的值和offset的值应该相同
    assert(structAlignment == 8 && decl.size == offset);
    decl.size = offset;
    ocSymbol *symbol = [ocSymbol symbolWithName:node.sturctName decl:decl];
    [symbolTableRoot insertRoot:symbol];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}

- (void)visitUnionStatNode:(nonnull ORUnionStatNode *)node {
    [symbolTableRoot increaseScope];
    
    NSMutableString *typeEncode = [@"(" mutableCopy];
    [typeEncode appendString:node.unionName];
    [typeEncode appendString:@"="];
    
    NSMutableArray *keys = [NSMutableArray array];
    for (ORDeclaratorNode *exp in node.fields) {
        NSString *typeName = exp.type.name;
        ocSymbol *symbol = [symbolTableRoot lookup:typeName];
        const char *fieldEncode = symbol ? symbol.decl.typeEncode : typeEncodeForDeclaratorNode(exp);
        [typeEncode appendFormat:@"%s",fieldEncode];
        
        //向Uinon的作用域中注册参数类型
        ocDecl * decl = [ocDecl new];
        decl.typeEncode = fieldEncode;
        decl.typeName = typeName;
        ocSymbol *fieldSymbol = [ocSymbol symbolWithName:exp.var.varname decl:decl];
        [keys addObject:exp.var.varname];
        [symbolTableRoot insert:fieldSymbol];
    }
    [typeEncode appendString:@")"];
    
    // 根符号表注册union
    ocComposeDecl *decl = [ocComposeDecl new];
    decl.typeEncode = typeEncode.UTF8String;
    decl.typeName = node.unionName;
    decl.fielsScope = symbolTableRoot.scope;
    decl.keys = keys;
    ocSymbol *symbol = [ocSymbol symbolWithName:node.unionName decl:decl];
    [symbolTableRoot insertRoot:symbol];
    node.scope = symbolTableRoot.scope;
    [symbolTableRoot decreaseScope];
}
- (void)visitEnumStatNode:(nonnull OREnumStatNode *)node {
    ocDecl *decl = [ocDecl new];
    char type = node.valueType;
    decl.typeEncode = &type;
    decl.typeName = node.enumName;
    ocSymbol *symbol = [ocSymbol symbolWithName:node.enumName decl:decl];
    [symbolTableRoot insertRoot:symbol];
    for (ORNode *exp in node.fields) {
        if (exp.nodeType == AstEnumAssignNode) {
            ORAssignNode *assignExp = (ORAssignNode *)exp;
            [symbolTableRoot insertRootWithName:[(ORValueNode *)assignExp.expression value] symbol:symbol];
        }else if (exp.nodeType == AstEnumValueNode){
            [symbolTableRoot insertRootWithName:[(ORValueNode *)exp value] symbol:symbol];
        }
    }
}
- (void)visitTypedefStatNode:(nonnull ORTypedefStatNode *)node {
    switch (node.nodeType) {
        case AstEnumDeclaratorNode:
        case AstEnumFunctionDeclNode:
        case AstEnumCArrayDeclNode:
        {
            ORDeclaratorNode *declarator = (ORDeclaratorNode *)node.expression;
            [self visit:declarator];
            ocSymbol *symbol = [symbolTableRoot lookup:declarator.var.varname];
            [symbolTableRoot insertRootWithName:node.typeNewName symbol:symbol];
            break;
        }
        case AstEnumStructStatNode:
        {
            ORStructStatNode *structNode = (ORStructStatNode *)node;
            [self visit:structNode];
            ocSymbol *symbol = [symbolTableRoot lookup:structNode.sturctName];
            [symbolTableRoot insertRootWithName:node.typeNewName symbol:symbol];
            break;
        }
        case AstEnumEnumStatNode:
        {
            OREnumStatNode *enumNode = (OREnumStatNode *)node;
            [self visit:enumNode];
            ocSymbol *symbol = [symbolTableRoot lookup:enumNode.enumName];
            [symbolTableRoot insertRootWithName:node.typeNewName symbol:symbol];
            break;
        }
        case AstEnumUnionStatNode:
        {
            ORUnionStatNode *unionNode = (ORUnionStatNode *)node.expression;
            [self visit:unionNode];
            ocSymbol *symbol = [symbolTableRoot lookup:unionNode.unionName];
            [symbolTableRoot insertRootWithName:node.typeNewName symbol:symbol];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Operation Exp
- (void)visitFunctionCall:(nonnull ORFunctionCall *)node {
    [self visit:node.caller];
    if (node.caller.nodeType == AstEnumValueNode) {
        ORNode *impNode = internalFunctionTable[[node.caller value]];
        ocSymbol *symbol = [ocSymbol symbolWithName:nil decl:nil];
        symbol->_bbimp = impNode;
        node.symbol = symbol;
    }
    for (ORNode *arg in node.expressions) {
        [self visit:arg];
    }
}

- (void)visitMethodCall:(nonnull ORMethodCall *)node {
    [self visit:node.caller];
    if (node.caller.symbol.decl.isStruct || node.caller.symbol.decl.isUnion) {
        ocComposeDecl *composeDecl = (ocComposeDecl *)[symbolTableRoot lookup:node.caller.symbol.decl.typeName].decl;
        ocDecl *beforeDecl = node.caller.symbol.decl;
        NSString *fieldName = node.selectorName;
        ocDecl *fieldDecl = composeDecl.fielsScope[fieldName].decl;
        ocDecl *expDecl = [ocDecl declWithTypeEncode:fieldDecl.typeEncode];
        expDecl.offset = beforeDecl.offset + fieldDecl.offset;
        expDecl.typeName = fieldDecl.typeName;
        node.symbol = [ocSymbol symbolWithName:fieldName decl:expDecl];
        node.isStructRef = YES;
    }
    for (ORNode *arg in node.values) {
        [self visit:arg];
    }
}

- (void)visitAssignNode:(nonnull ORAssignNode *)node {
    [self visit:node.value];
    [self visit:node.expression];
}

- (void)visitBinaryNode:(nonnull ORBinaryNode *)node {
    [self visit:node.left];
    [self visit:node.right];
}

- (void)visitSubscriptNode:(nonnull ORSubscriptNode *)node {
    [self visit:node.caller];
    [self visit:node.keyExp];
}

- (void)visitTernaryNode:(nonnull ORTernaryNode *)node {
    [self visit:node.expression];
    for (ORNode *value in node.values) {
        [self visit:value];
    }
}
- (void)visitUnaryNode:(nonnull ORUnaryNode *)node {
    [self visit:node.value];
}



@end
