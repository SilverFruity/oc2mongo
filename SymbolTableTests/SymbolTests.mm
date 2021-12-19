//
//  SymbolTests.m
//  oc2mangoLibTests
//
//  Created by Jiang on 2021/6/27.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <oc2mangoLib/oc2mangoLib.h>
#import <oc2mangoLib/ORFileSection.hpp>
#import <oc2mangoLib/ORFile.hpp>
#import <oc2mangoLib/ocScope.h>
#import <oc2mangoLib/ocSymbolTable.hpp>
#import "SymbolParser.h"
#import <string>
using namespace std;
@interface SymbolTests : XCTestCase
{
    NSString *source;
    SymbolParser *parser;
}
@end

@implementation SymbolTests

- (void)setUp {
    parser = [SymbolParser new];
}

- (void)tearDown {
    parser = nil;
}
struct ORPoint{
    double x;
    int y;
    double z;
};
- (void)testStruct{
    source = @"\
    struct ORPoint{\
      double x;\
      int y;\
      double z;\
    };\
    ";
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"ORPoint"];
    XCTAssert([symbol.decl isStruct]);
    XCTAssert(strcmp(symbol.decl.typeEncode, @encode(struct ORPoint)) == 0);
    ocScope *structScope = ((ORNode *)ast.nodes.lastObject).scope;
    ocDecl *decl = structScope[@"x"].decl;
    XCTAssert(decl.index == 0);
    XCTAssert(decl.size == 8);
    XCTAssert(decl.type == OCTypeDouble);
    decl = structScope[@"y"].decl;
    XCTAssert(decl.index == 8);
    XCTAssert(decl.size == 4);
    XCTAssert(decl.type == OCTypeInt);
    decl = structScope[@"z"].decl;
    XCTAssert(decl.index == 16);
    XCTAssert(decl.size == 8);
    XCTAssert(decl.type == OCTypeDouble);
    
}
union ORValue{
    char x;
    short y;
    int z;
};
- (void)testUnion{
    source = @" \
    union ORValue{\
        char x;\
        short y;\
        int z;\
    };"
    ;
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"ORValue"];
    XCTAssert([symbol.decl isUnion]);
    XCTAssert(strcmp(symbol.decl.typeEncode, @encode(union ORValue)) == 0);
    ocScope *unionScope = ((ORNode *)ast.nodes.lastObject).scope;
    ocDecl *decl = unionScope[@"x"].decl;
    XCTAssert(decl.index == 0);
    XCTAssert(decl.size == 1);
    XCTAssert(decl.type == OCTypeChar);
    decl = unionScope[@"y"].decl;
    XCTAssert(decl.index == 0);
    XCTAssert(decl.size == 2);
    XCTAssert(decl.type == OCTypeShort);
    decl = unionScope[@"z"].decl;
    XCTAssert(decl.index == 0);
    XCTAssert(decl.size == 4);
    XCTAssert(decl.type == OCTypeInt);
}
- (void)testFunction{
    source = @"\
    double func1(int a, int b);\
    double (*func2)(int a, int b);\
    double (^block)(int a, int b);\
    double funcImp(int a, int b){  }\
    ^double (int a, int b){\
    };\
    ";
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"func1"];
    XCTAssert(strcmp(symbol.decl.typeEncode?:"", "^?dii") == 0);
    symbol = ast.scope[@"func2"];
    XCTAssert(strcmp(symbol.decl.typeEncode?:"", "^?dii") == 0);
    symbol = ast.scope[@"block"];
    XCTAssert(strcmp(symbol.decl.typeEncode?:"", "@?dii") == 0);
    symbol = ast.scope[@"funcImp"];
    XCTAssert(strcmp(symbol.decl.typeEncode?:"", "^?dii") == 0);
    symbol = ((ORNode *)ast.nodes.lastObject).symbol;
    XCTAssert(strcmp(symbol.decl.typeEncode?:"", "@?dii") == 0);
    
}
- (void)testSimpleDeclarator{
    source = @"int a; double b;";
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"a"];
    XCTAssert(strcmp(symbol.decl.typeEncode, OCTypeStringInt) == 0);
    XCTAssert(symbol.decl.type == OCTypeInt);
    
    symbol = ast.scope[@"b"];
    XCTAssert(strcmp(symbol.decl.typeEncode, OCTypeStringDouble) == 0);
    XCTAssert(symbol.decl.type == OCTypeDouble);
    
//    ast.scope[@"b"];
}
- (void)testClass{
    source = @" \
    @interface TestClass: NSObject\
    @property(nonatomic, strong)id object;\
    @property(nonatomic, strong)NSString *string;\
    @property(nonatomic, strong)NSArray *array;\
    @end\
    @implementation TestClass\
    {\
        int a;\
        double b;\
        NSString *c;\
        void *d;\
    }\
    - (instancetype)initWithObject:(id)object{  }\
    + (instranceType)objectWithA:(int)a b:(double)b c:(NSString *)c d:(void **)d{ }\
    @end";
    AST *ast = [parser parseSource:source];
    ORClassNode *classNode = ast.nodes.firstObject;
    ocSymbol *symbol = classNode.scope[@"_object"];
    XCTAssert([symbol.decl.typeName isEqualToString:@"id"], @"%@",symbol.decl.typeName);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(symbol.decl.isIvar);
    
    symbol = classNode.scope[@"@object"];
    XCTAssert([symbol.decl.typeName isEqualToString:@"id"], @"%@",symbol.decl.typeName);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(symbol.decl.isProperty);
    XCTAssert(symbol.decl.propModifer && (MFPropertyModifierNonatomic | MFPropertyModifierMemStrong));
    
    symbol = classNode.scope[@"_string"];
    XCTAssert([symbol.decl.typeName isEqualToString:@"NSString"], @"%@",symbol.decl.typeName);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(strcmp(symbol.decl.typeEncode, "@") == 0);
    XCTAssert(symbol.decl.isIvar);
    
    symbol = classNode.scope[@"@string"];
    XCTAssert([symbol.decl.typeName isEqualToString:@"NSString"], @"%@",symbol.decl.typeName);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(symbol.decl.isProperty);
    XCTAssert(symbol.decl.propModifer && (MFPropertyModifierNonatomic | MFPropertyModifierMemStrong));
    
    symbol = classNode.scope[@"a"];
    XCTAssert(symbol.decl.type = OCTypeInt);
    XCTAssert(symbol.decl.isIvar);
    
    symbol = classNode.scope[@"b"];
    XCTAssert(symbol.decl.type = OCTypeDouble);
    XCTAssert(symbol.decl.isIvar);
    
    symbol = classNode.scope[@"d"];
    XCTAssert(symbol.decl.type = OCTypePointer);
    XCTAssert(symbol.decl.isIvar);
    
    symbol = classNode.scope[@"initWithObject:"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "@@:@") == 0, @"%s",symbol.decl.typeEncode);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(symbol.decl.isMethod);
    XCTAssert(symbol.decl.isClassMethod == NO);
    
    symbol = classNode.scope[@"objectWithA:b:c:d:"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "@@:id@^^v") == 0, @"%s",symbol.decl.typeEncode);
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert(symbol.decl.isMethod);
    XCTAssert(symbol.decl.isClassMethod);
    
    ORMethodNode *method = classNode.methods[0];
    symbol = method.scope[@"object"];
    XCTAssert(symbol.decl.type = OCTypeObject);
    XCTAssert([symbol.decl.typeName isEqualToString:@"id"], @"%@",symbol.decl.typeName);
    
    method = classNode.methods[1];
    symbol = method.scope[@"a"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "i") == 0);
    symbol = method.scope[@"b"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "d") == 0);
    symbol = method.scope[@"c"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "@") == 0);
    symbol = method.scope[@"d"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "^^v") == 0, @"%s", symbol.decl.typeEncode);
    
}
- (void)testClassDetect{
    source = @" \
    @interface TestClass: NSObject\
    @property(nonatomic, strong)id object;\
    @property(nonatomic, strong)NSString *string;\
    @property(nonatomic, strong)NSArray *array;\
    @end\
    @implementation TestClass\
    @end\
    void function(){\
        NSMutableArray *a;\
        [a addObject:@\"123\"];\
        NSSimulatorClass *b;\
        b.block();\
        NSSimulatorClass1 *c;\
        c.value = 1;\
        NSSimulatorClass2 *d;\
        int a = d.value;\
        [NSSimulatorClass3 new];\
    }\
    ";
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"NSString"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
    symbol = ast.scope[@"NSArray"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
    symbol = ast.scope[@"NSSimulatorClass"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
    symbol = ast.scope[@"NSSimulatorClass1"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
    symbol = ast.scope[@"NSSimulatorClass2"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
    symbol = ast.scope[@"NSSimulatorClass3"];
    XCTAssert(symbol.decl.type == OCTypeClass);
    XCTAssert(symbol.decl.isClassRef);
}
- (void)testCArraySymbol{
    source = @" \
    int* a[10][100];\
    int* b[c][d];\
    ";
    AST *ast = [parser parseSource:source];
    ocSymbol *symbol = ast.scope[@"a"];
    XCTAssert(strcmp(symbol.decl.typeEncode, @encode(int* [10][100])) == 0);
    symbol = ast.scope[@"b"];
    XCTAssert(strcmp(symbol.decl.typeEncode, "[%ld[%ld^i]]") == 0);
    
}
- (void)testStructFieldGet{
    source = @"\
    struct ORPoint{\
      double x;\
      int y;\
      double z;\
    };\
    ORPoint point;\
    point.x = 1.0;\
    ";
    AST *ast = [parser parseSource:source];
    ORMethodCall *call = ast.globalStatements.lastObject;
}
- (void)testCStringConstant {
    source = @"\
    \"123\"; \
    \"1234\"; \
    \"123\"; \
    ";
    AST *ast = [parser parseSource:source];
    
    ORSectionRecorderManager& manager = symbolTableRoot.recorder;
    ORValueNode *node1 = ast.nodes[0];
    XCTAssertTrue(node1.symbol.decl.index == 0);

    const char *string1 = manager.getString(node1.symbol.decl.index);
    XCTAssert(string(string1) == string([node1.value UTF8String]));
    
    ORValueNode *node2 = ast.nodes[1];
    const char *string2 = manager.getString(node2.symbol.decl.index);
    XCTAssert(string(string2) == string([node2.value UTF8String]));
    
    ORValueNode *node3 = ast.nodes[2];
    XCTAssert(node1.symbol.decl.index == node3.symbol.decl.index);
    
}
- (void)testCFStringConstant{
    source = @"\
    @\"123\"; \
    @\"1234\"; \
    @\"123\"; \
    ";
    AST *ast = [parser parseSource:source];
    ORSectionRecorderManager& manager = symbolTableRoot.recorder;

    ORValueNode *node1 = ast.nodes[0];
    XCTAssertTrue(node1.symbol.decl.index == 0);
    const char *str = manager.getString(manager.getCFString(node1.symbol.decl.index)->cstring.offset);
    XCTAssertTrue(strcmp(str, [node1.value UTF8String]) == 0);

    ORValueNode *node2 = ast.nodes[1];
    str = manager.getString(manager.getCFString(node2.symbol.decl.index)->cstring.offset);
    XCTAssertTrue(strcmp(str, [node2.value UTF8String]) == 0);

    ORValueNode *node3 = ast.nodes[2];
    XCTAssert(node1.symbol.decl.index == node3.symbol.decl.index);
}
- (void)testLinkedClassSection {
    source = @"\
    @class Test1, Test2; \
    @interface Test1: NSObject @end \
    @interface Test3: NSObject @end \
    [NSObject new];\
    ";
    AST *ast = [parser parseSource:source];
    ORSectionRecorderManager& manager = symbolTableRoot.recorder;
    struct ORLinkedClass *links = (struct ORLinkedClass *)manager.linkedClassRecorder.buffer;
    
    struct ORLinkedClass linked = links[0];
    
    XCTAssertTrue(strcmp(manager.getString(linked.class_name.offset), "Test1") == 0);

    linked = links[1];
    XCTAssertTrue(strcmp(manager.getString(linked.class_name.offset), "Test2") == 0);

    linked = links[2];
    XCTAssertTrue(strcmp(manager.getString(linked.class_name.offset), "NSObject") == 0);

    linked = links[3];
    XCTAssertTrue(strcmp(manager.getString(linked.class_name.offset), "Test3") == 0);

    ORMethodCall *call = ast.nodes[2];
    ORValueNode *value = (ORValueNode *)call.caller;
    linked = links[value.symbol.decl.index];
    XCTAssertTrue(strcmp(manager.getString(linked.class_name.offset), "NSObject") == 0);
    
}
- (void)testLinkedCFunctionSection {
    source = @"\
    struct CGRect { CGFloat x; CGFloat x; CGFloat width; CGFloat height; };\
    void NSLog(const char *str, ...); \
    CGRect CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height); \
    int a = CGRectMake(0,0,0,0);\
    ";
    AST *ast = [parser parseSource:source];
    ORSectionRecorderManager& manager = symbolTableRoot.recorder;
    ORDataRecorder &funcRecorder = symbolTableRoot.recorder.linkedCFunctionRecorder;
    XCTAssertTrue(funcRecorder.list_count == 2);
    struct ORLinkedCFunction *cfuncs = (struct ORLinkedCFunction *)funcRecorder.buffer;
    struct ORLinkedCFunction cfunc = cfuncs[0];
    XCTAssertTrue(strcmp(manager.getString(cfunc.function_name.offset), "NSLog") == 0);

    cfunc = cfuncs[1];
    XCTAssertTrue(strcmp(manager.getString(cfunc.function_name.offset), "CGRectMake") == 0);

    ORAssignNode *assignExp = ast.nodes[3];
    ORFunctionCall *call = (ORFunctionCall *)assignExp.expression;
    cfunc = cfuncs[call.symbol.decl.index];
    XCTAssertTrue(strcmp(manager.getString(cfunc.function_name.offset), "CGRectMake") == 0);
    XCTAssertTrue(strcmp(manager.getString(cfunc.type_encode.offset), "^?{CGRect=dddd}dddd") == 0);
}
- (void)testObjcClassSections {
    source = @" \
    char *str = \"123\";\
    @implementation TestClass1\
    @end\
    @interface TestClass: NSObject\
    @property(nonatomic, strong)id object;\
    @property(nonatomic, strong)NSString *string;\
    @property(nonatomic, strong)NSArray *array;\
    @end\
    @implementation TestClass\
    {\
        int a;\
        double b;\
        NSString *c;\
        void *d;\
        NSArray *_array;\
    }\
    - (instancetype)initWithObject:(id)object{  }\
    + (instranceType)objectWithA:(int)a b:(double)b c:(NSString *)c d:(void **)d{ }\
    @end";
    AST *ast = [parser parseSource:source];
    ORSectionRecorderManager& manager = symbolTableRoot.recorder;
    struct ORClassItem *classItem = manager.getClassItem(0);
    const char *className = manager.getString(classItem->class_name.offset);
    XCTAssert(strcmp(className, "TestClass1") == 0);
    classItem = manager.getClassItem(1);
    className = manager.getString(classItem->class_name.offset);
    XCTAssert(strcmp(className, "TestClass") == 0);
    XCTAssert(classItem->prop_list.count == 3);
    XCTAssert(classItem->instance_method_list.count == 1);
    XCTAssert(classItem->class_method_list.count == 1);
    // ivar 'array' is duplicate
    XCTAssert(classItem->ivar_list.count == 7);
    
    struct ORObjcProperty *prop = manager.getObjcProperty(classItem->prop_list.start_index);
    XCTAssert(strcmp(manager.getString(prop->property_name.offset), "object") == 0);
    
    prop = manager.getObjcProperty(classItem->prop_list.start_index + 1);
    XCTAssert(strcmp(manager.getString(prop->property_name.offset), "string") == 0);
    
    prop = manager.getObjcProperty(classItem->prop_list.start_index + 2);
    XCTAssert(strcmp(manager.getString(prop->property_name.offset), "array") == 0);
    
    struct ORObjcMethod *instanceMethod = manager.getObjcInstanceMethod(classItem->instance_method_list.start_index);
    XCTAssert(strcmp(manager.getString(instanceMethod->selector.offset), "initWithObject:") == 0);
    
    struct ORObjcMethod *classMethod = manager.getObjcClassMethod(classItem->class_method_list.start_index);
    XCTAssert(strcmp(manager.getString(classMethod->selector.offset), "objectWithA:b:c:d:") == 0);
    
}


@end