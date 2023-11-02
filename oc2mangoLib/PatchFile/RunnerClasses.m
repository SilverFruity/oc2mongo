//
//  ORunner.m
//  MangoFix
//
//  Created by Jiang on 2020/4/26.
//  Copyright © 2020 yongpengliang. All rights reserved.
//

#import "RunnerClasses.h"
@implementation ORNode
+ (id)copyWithNode:(ORNode *)node{
    ORVariable *new = [[[self class] alloc] init];
    new.nodeType = node.nodeType;
    new.parentNode = node.parentNode;
    new.withSemicolon = node.withSemicolon;
    return new;
}
@end

@implementation ORTypeSpecial
+ (instancetype)specialWithType:(TypeKind)type name:(NSString *)name{
    ORTypeSpecial *s = [ORTypeSpecial new];
    s.type = type;
    s.name = name;
    return s;
}
@end
@implementation ORVariable
+ (instancetype)copyFromVar:(ORVariable *)var{
    ORVariable *new = [self copyWithNode:var];
    new.ptCount = var.ptCount;
    new.varname = var.varname;
    new.isBlock = var.isBlock;
    return new;
}
@end
@implementation ORTypeVarPair
- (NSUInteger)hash{
    return [self.var.varname hash];
}
- (BOOL)isEqual:(id)object{
    return [self hash] == [object hash];
}
@end
@implementation ORFuncVariable
- (instancetype)copy{
    ORFuncVariable *var = [ORFuncVariable copyFromVar:self];
    var.pairs = self.pairs;
    return var;
}
@end
@implementation ORFuncDeclare
- (instancetype)copy{
    ORFuncDeclare *declare = [ORFuncDeclare copyWithNode:self];
    declare.funVar = [self.funVar copy];
    declare.returnType = self.returnType;
    return declare;
}
- (BOOL)isBlockDeclare{
    return self.funVar.isBlock;
}
@end

@implementation ORValueExpression
@end

@implementation ORIntegerValue
@end

@implementation ORUIntegerValue
@end

@implementation ORDoubleValue
@end

@implementation ORBoolValue
@end

@interface ORMethodCall()
@property (nonatomic, copy)NSString *selectorName;
@end
@implementation ORMethodCall
- (NSString *)selectorName{
    if (_selectorName == nil){
        NSMutableArray *names = [self.names mutableCopy];
        if (self.values.count >= 1){
            [names addObject:@""];
        }
        _selectorName = [names componentsJoinedByString:@":"];
    }
    return _selectorName;
}
@end
@implementation ORCFuncCall
@end

@implementation ORScopeImp
- (instancetype)init
{
    self = [super init];
    self.statements = [NSMutableArray array];
    return self;
}
- (void)addStatements:(id)statements{
    if ([statements isKindOfClass:[NSArray class]]) {
        [self.statements addObjectsFromArray:statements];
    }else{
        [self.statements addObject:statements];
    }
}
@end

@implementation ORFunctionImp
- (instancetype)convertToNormalFunctionImp{
    ORFunctionImp *imp = [ORFunctionImp copyWithNode:self];
    imp.declare = [self.declare copy];
    imp.scopeImp = self.scopeImp;
    imp.declare.funVar.isBlock = NO;
    return imp;
}
- (BOOL)isBlockImp{
    return self.declare.funVar.isBlock;
}
@end
@implementation ORSubscriptExpression
@end
@implementation ORAssignExpression
- (NSString *)varname{
    if ([self.value isKindOfClass:[ORValueExpression class]]) {
        return [(ORValueExpression *)self.value value];
    }
    return nil;
}
@end
@implementation ORDeclareExpression
@end
@implementation ORUnaryExpression
@end
@implementation ORBinaryExpression
@end
@implementation ORTernaryExpression
- (instancetype)init
{
    self = [super init];
    self.values = [NSMutableArray array];
    return self;
}
@end

@implementation ORIfStatement
@end
@implementation ORWhileStatement
@end
@implementation ORDoWhileStatement
@end
@implementation ORCaseStatement
@end
@implementation ORSwitchStatement
- (instancetype)init
{
    self = [super init];
    self.cases = [NSMutableArray array];
    return self;
}
@end
@implementation ORForStatement
@end
@implementation ORForInStatement
@end
@implementation ORReturnStatement
@end
@implementation ORBreakStatement
@end
@implementation ORContinueStatement
@end
@implementation ORPropertyDeclare
- (MFPropertyModifier)modifier{
    NSDictionary *cache = @{
        @"strong":@(MFPropertyModifierMemStrong),
        @"weak":@(MFPropertyModifierMemWeak),
        @"copy":@(MFPropertyModifierMemCopy),
        @"assign":@(MFPropertyModifierMemAssign),
        @"nonatomic":@(MFPropertyModifierNonatomic),
        @"atomic":@(MFPropertyModifierAtomic)
    };
    uint32_t value = 0;
    for (NSString *keyword in self.keywords) {
        NSNumber *keywordValue = cache[keyword];
        if (keywordValue) {
            value = value | keywordValue.unsignedIntValue;
        }
    }
    return value;
}
- (NSUInteger)hash{
    return [self.var hash];
}
- (BOOL)isEqual:(ORPropertyDeclare *)object{
    return [self hash] == [object hash];
}
@end
@interface ORMethodDeclare()
@property (nonatomic, copy)NSString *selectorName;
@end
@implementation ORMethodDeclare
- (NSString *)selectorName{
    if (_selectorName == nil){
        NSMutableArray *names = [self.methodNames mutableCopy];
        if (self.parameterNames.count >= 1){
            [names addObject:@""];
        }
        _selectorName = [names componentsJoinedByString:@":"];
    }
    return _selectorName;
}
@end
@implementation ORMethodImplementation
{
    Class _classNode;
}
- (NSUInteger)hash{
    return [[self.declare selectorName] stringByAppendingFormat:@"%d",self.declare.isClassMethod].hash;
}
- (BOOL)isEqual:(id)object{
    return [self hash] == [object hash];
}
- (void)setClassNode:(Class)classNode {
    _classNode = classNode;
}
- (Class)classNode {
    return _classNode;
}
@end
@implementation ORClass
+ (instancetype)classWithClassName:(NSString *)className{
    ORClass *class = [ORClass new];
    class.className = className;
    return class;
}
- (instancetype)init
{
    self = [super init];
    self.properties  = [NSMutableArray array];
    self.privateVariables = [NSMutableArray array];
    self.properties = [NSMutableArray array];
    self.methods = [NSMutableArray array];
    
    return self;
}
- (void)merge:(ORClass *)target key:(nonnull NSString *)key{
    NSMutableSet *sourceSet = [NSMutableSet setWithArray:[self valueForKey:key]];
    NSMutableSet *comparedSet = [NSMutableSet setWithArray:[target valueForKey:key]];
    [comparedSet unionSet:sourceSet];
    [comparedSet minusSet:sourceSet];
    NSMutableArray *array = [self valueForKey:key];
    [array addObjectsFromArray:comparedSet.allObjects];
}
@end
@implementation ORProtocol
+ (instancetype)protcolWithProtcolName:(NSString *)protcolName{
    ORProtocol *protcol = [ORProtocol new];
    protcol.protcolName = protcolName;
    return protcol;
}
- (instancetype)init
{
    self = [super init];
    self.protocols  = [NSMutableArray array];
    self.properties = [NSMutableArray array];
    self.methods = [NSMutableArray array];
    return self;
}
@end

@implementation ORStructExpressoin

@end

@implementation ORUnionExpressoin

@end

@implementation OREnumExpressoin

@end

@implementation ORTypedefExpressoin

@end

@implementation ORCArrayVariable
+ (instancetype)copyFromVar:(ORVariable *)var{
    ORCArrayVariable *array  = [super copyFromVar:var];
    if ([var isKindOfClass:[ORCArrayVariable class]]) {
        array.prev = (ORCArrayVariable *)var;
    }
    return array;
}
@end
