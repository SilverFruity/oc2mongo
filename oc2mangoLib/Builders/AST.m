//
//  AST.m
//  oc2mangoLib
//
//  Created by Jiang on 2019/5/18.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import "AST.h"
#import <ORPatchFile/ORPatchFile.h>
ORClassNode *curClassNode = nil;
ORProtocolNode *curProtocolNode = nil;

NSArray *SupplementarySetArray(NSArray *source, NSArray *compared){
    NSMutableSet *sourceSet = [NSMutableSet setWithArray:source];
    NSMutableSet *compredSet = [NSMutableSet setWithArray:compared];
    [compredSet unionSet:sourceSet];
    [compredSet minusSet:sourceSet];
    return  compredSet.allObjects;
}
void handlePrivateVarDecls(NSArray *decls){
    if (curClassNode)
        [curClassNode.privateVariables addObjectsFromArray:decls];
}
void handlePropertyDecls(ORPropertyNode *node){
    if (curClassNode)
        [curClassNode.properties addObject:node];
    if (curProtocolNode)
        [curProtocolNode.properties addObject:node];
}
void handleMethodDecl(ORMethodDeclNode *node){
    if (curProtocolNode)
        [curProtocolNode.methods addObject:node];
}
void handleMethodImp(ORMethodNode *node){
    if (curClassNode)
        [curClassNode.methods addObject:node];
}
AST *GlobalAst = nil;
void classProrityDetect(AST *ast,ORClassNode *classNode, int *level){
    if ([classNode.superClassName isEqualToString:@"NSObject"] || NSClassFromString(classNode.superClassName) != nil) {
        return;
    }
    ORClassNode *superClass = ast.classCache[classNode.superClassName];
    if (superClass) {
        (*level)++;
    }else{
        return;
    }
    classProrityDetect(ast, superClass, level);
}
int startClassProrityDetect(AST *ast, ORClassNode *clazz){
    int prority = 0;
    classProrityDetect(ast, clazz, &prority);
    return prority;
}
@implementation AST
- (ORClassNode *)classForName:(NSString *)className{
    ORClassNode *classNode = self.classCache[className];
    if (!classNode) {
//        classNode = makeOCClass(className);
        [self.nodes addObject:classNode];
        self.classCache[className] = classNode;
    }
    return classNode;
}
- (nonnull ORProtocolNode *)protcolForName:(NSString *)protcolName{
    ORProtocolNode *protocol = self.protcolCache[protcolName];
    if (!protocol) {
//        protocol = makeORProtcol(protcolName);
        [self.nodes addObject:protocol];
        self.protcolCache[protcolName] = protocol;
    }
    return protocol;
}
- (instancetype)init
{
    self = [super init];
    self.classCache = [NSMutableDictionary dictionary];
    self.protcolCache = [NSMutableDictionary dictionary];
    self.nodes = [NSMutableArray array];
    self.globalStatements = [NSMutableArray array];
    return self;
}
- (void)addGlobalStatements:(id)objects{
    if ([objects isKindOfClass:[NSArray class]]) {
        [self.globalStatements addObjectsFromArray:objects];
        [self.nodes addObjectsFromArray:objects];
    }else{
        [self.globalStatements addObject:objects];
        [self.nodes addObject:objects];
    }
}
- (NSArray *)sortClasses{
    //TODO: 根据Class继承关系，进行排序
    NSMutableDictionary <NSString *, NSNumber *>*classProrityDict = [@{} mutableCopy];
    for (ORClassNode *clazz in self.classCache.allValues) {
        classProrityDict[clazz.className] = @(startClassProrityDetect(self,clazz));
    }
    NSArray *classes = self.classCache.allValues;
    classes = [classes sortedArrayUsingComparator:^NSComparisonResult(ORClassNode *obj1, ORClassNode *obj2) {
        return (NSComparisonResult)(classProrityDict[obj1.className].intValue > classProrityDict[obj2.className].intValue);
    }];
    return classes;
}
- (void)merge:(NSArray *)nodes{
    [nodes enumerateObjectsUsingBlock:^(ORNode *node, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([node isKindOfClass:[ORClassNode class]]) {
            ORClassNode *classNode = (ORClassNode *)node;
            ORClassNode *current = self.classCache[classNode.className];
            if (current) {
                [current merge:classNode key:@"privateVariables"];
                [current merge:classNode key:@"properties"];
                [current merge:classNode key:@"protocols"];
                [current merge:classNode key:@"methods"];
                if (!current.superClassName && classNode.superClassName) {
                    current.superClassName = classNode.superClassName;
                }
            }else{
                self.classCache[classNode.className] = node;
                [self.nodes addObject:node];
            }
        }else if([node isKindOfClass:[ORProtocolNode class]]){
            ORProtocolNode *protocolNode = (ORProtocolNode *)node;
            self.protcolCache[protocolNode.protcolName] = protocolNode;
            [self.nodes addObject:protocolNode];
        }else{
            [self addGlobalStatements:node];
        }
    }];
}
@end

