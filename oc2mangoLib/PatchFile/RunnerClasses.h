//
//  ORunner.h
//  MangoFix
//
//  Created by Jiang on 2020/4/26.
//  Copyright © 2020 yongpengliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BinaryPatchHelper.h"
#import "OCTypeEncode.h"

NS_ASSUME_NONNULL_BEGIN
@class ocSymbol, ocScope;
// MARK: - Node
@interface ORNode: NSObject
@property (nonatomic, assign)AstEnum nodeType;
@property (nonatomic, assign)BOOL withSemicolon;
@property (nonatomic, weak)ORNode *parentNode;
@property (nonatomic, strong)ocScope *scope;
@property (nonatomic, strong)ocSymbol *symbol;
- (BOOL)isConst;
- (NSInteger)integerValue;
+ (id)copyWithNode:(ORNode *)node;
@end

typedef enum: uint32_t{
    DeclarationModifierBlock      = 1 << 0,
    DeclarationModifierStrong     = 1 << 1,
    DeclarationModifierWeak       = 1 << 2,
    DeclarationModifierStatic     = 1 << 3
}DeclarationModifier;

@interface ORTypeNode: ORNode
@property (nonatomic, assign)OCType type;
@property (nonatomic, assign)DeclarationModifier modifier;
@property (nonatomic, nullable, copy) NSString * name;
+ (instancetype)specialWithType:(OCType)type name:(nullable NSString *)name;
@end


@interface ORVariableNode: ORNode
@property (nonatomic, assign) BOOL isBlock;
@property (nonatomic, assign) uint8_t ptCount;
@property (nonatomic, nullable, copy) NSString * varname;
@end

@interface ORDeclaratorNode: ORNode
@property (nonatomic, strong)ORTypeNode *type;
@property (nonatomic, strong)ORVariableNode *var;
+ (instancetype)copyFromDecl:(ORDeclaratorNode *)decl;
@end

@interface ORFunctionDeclNode: ORDeclaratorNode
@property(nonatomic,assign) BOOL isMultiArgs;
@property(nonatomic,strong) NSMutableArray <ORDeclaratorNode *> *params;
@end

@interface ORCArrayDeclNode: ORDeclaratorNode
@property (nonatomic,strong)ORCArrayDeclNode *prev;
@property (nonatomic,strong)ORNode *capacity;
@end

@interface ORBlockNode: ORNode
@property(nonatomic,strong) NSMutableArray* statements;
- (void)addStatements:(id)statements;
- (void)copyFromImp:(ORBlockNode *)imp;
@end

typedef enum: uint32_t{
    OCValueVariable, // value: NSString
    OCValueSelf, // value: nil
    OCValueSuper, // value: nil
    OCValueSelector, // value: sel NSString
    OCValueProtocol, // value: String
    OCValueDictionary, // value: Exp Array
    OCValueArray, // value: Exp Array
    OCValueNSNumber, // value: Exp
    OCValueString, // value: NSString
    OCValueCString, // value: NSString
    OCValueNil, //  value: nil
    OCValueNULL, //  value: nil
    OCValueClass
}OC_VALUE_TYPE;

@interface ORValueNode: ORNode
@property (nonatomic,assign)OC_VALUE_TYPE value_type;
@property (nonatomic,strong)id value;
@end

@interface ORIntegerValue: ORNode
@property (nonatomic, assign)int64_t value;
@end

@interface ORUIntegerValue: ORNode
@property (nonatomic, assign)uint64_t value;
@end

@interface ORDoubleValue: ORNode
@property (nonatomic, assign)double value;
@end

@interface ORBoolValue: ORNode
@property (nonatomic, assign)BOOL value;
@end

//兼容struct->field
typedef enum: uint8_t{
    MethodOpretorNone = 0,
    MethodOpretorDot,
    MethodOpretorArrow
}MethodOperatorType;

@interface ORMethodCall: ORNode
@property (nonatomic, assign)uint8_t methodOperator; //MethodOperatorType
@property (nonatomic, assign)BOOL isAssignedValue;
@property (nonatomic, strong)ORNode * caller;
@property (nonatomic, strong)NSMutableArray *names;
@property (nonatomic, strong)NSMutableArray <ORNode *> *values;
- (NSString *)selectorName;
@end

@interface ORFunctionCall: ORNode
@property (nonatomic, strong)ORNode *caller;
@property (nonatomic, strong)NSMutableArray <ORNode *>*expressions;
@end


@interface ORFunctionNode: ORNode
@property(nonatomic,strong) ORFunctionDeclNode *declare;
@property(nonatomic,strong) ORBlockNode *scopeImp;
- (instancetype)convertToNormalFunctionImp;
- (BOOL)isBlockImp;
@end

@interface ORSubscriptNode: ORNode
@property (nonatomic, strong)ORNode * caller;
@property (nonatomic, strong)ORNode * keyExp;
@end

typedef enum: uint32_t{
    AssignOperatorAssign,
    AssignOperatorAssignAnd,
    AssignOperatorAssignOr,
    AssignOperatorAssignXor,
    AssignOperatorAssignAdd,
    AssignOperatorAssignSub,
    AssignOperatorAssignDiv,
    AssignOperatorAssignMuti,
    AssignOperatorAssignMod,
    AssignOperatorAssignShiftLeft,
    AssignOperatorAssignShiftRight
}AssignOperatorType;

@interface ORAssignNode: ORNode
@property (nonatomic,assign)AssignOperatorType assignType;
@property (nonatomic,strong)ORNode * value;
@property (nonatomic,strong)ORNode * expression;
- (nullable NSString *)varname;
@end

@interface ORInitDeclaratorNode: ORNode
@property (nonatomic,strong)ORDeclaratorNode *declarator;
@property (nonatomic,strong, nullable)ORNode * expression;
@end

typedef enum: uint32_t{
    UnaryOperatorIncrementSuffix,
    UnaryOperatorDecrementSuffix,
    UnaryOperatorIncrementPrefix,
    UnaryOperatorDecrementPrefix,
    UnaryOperatorNot,
    UnaryOperatorNegative,
    UnaryOperatorBiteNot,
    UnaryOperatorSizeOf,
    UnaryOperatorAdressPoint,
    UnaryOperatorAdressValue
}UnaryOperatorType;
@interface ORUnaryNode: ORNode
@property (nonatomic,assign)UnaryOperatorType operatorType;
@property (nonatomic,strong)ORNode * value;
@end

typedef enum: uint32_t{
    BinaryOperatorAdd,
    BinaryOperatorSub,
    BinaryOperatorDiv,
    BinaryOperatorMulti,
    BinaryOperatorMod,
    BinaryOperatorShiftLeft,
    BinaryOperatorShiftRight,
    BinaryOperatorAnd,
    BinaryOperatorOr,
    BinaryOperatorXor,
    BinaryOperatorLT,
    BinaryOperatorGT,
    BinaryOperatorLE,
    BinaryOperatorGE,
    BinaryOperatorNotEqual,
    BinaryOperatorEqual,
    BinaryOperatorLOGIC_AND,
    BinaryOperatorLOGIC_OR
}BinaryOperatorType;

@interface ORBinaryNode: ORNode
@property (nonatomic,assign)BinaryOperatorType operatorType;
@property (nonatomic,strong)ORNode * left;
@property (nonatomic,strong)ORNode * right;
@end

@interface ORTernaryNode: ORNode
@property (nonatomic,strong)ORNode * expression;
@property (nonatomic,strong)NSMutableArray <ORNode *>*values;
@end
// MARK: - Statement
@interface ORIfStatement: ORNode
@property (nonatomic,strong,nullable)ORNode * condition;
@property (nonatomic,strong,nullable)ORIfStatement * last;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

@interface ORWhileStatement: ORNode
@property (nonatomic,strong,nullable)ORNode * condition;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

@interface ORDoWhileStatement: ORNode
@property (nonatomic,strong,nullable)ORNode * condition;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

@interface ORCaseStatement: ORNode
@property (nonatomic,strong)ORNode * value;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

@interface ORSwitchStatement: ORNode
@property (nonatomic,strong)ORNode * value;
@property (nonatomic,strong)NSMutableArray <ORCaseStatement *>*cases;
@end

@interface ORForStatement: ORNode
@property (nonatomic,strong)NSMutableArray <ORNode *>*varExpressions;
@property (nonatomic,strong)ORNode * condition;
@property (nonatomic,strong)NSMutableArray <ORNode *>* expressions;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

@interface ORForInStatement: ORNode
@property (nonatomic,strong)ORNode * expression;
@property (nonatomic,strong)ORNode * value;
@property (nonatomic, strong, nullable)ORBlockNode *scopeImp;
@end

typedef enum: uint32_t{
    ORControlStatReturn,
    ORControlStatBreak,
    ORControlStatContinue
}ORControlStateType;

@interface ORControlStatNode: ORNode
@property (nonatomic,assign)NSUInteger type;
@property (nonatomic,strong)ORNode * expression;
@end


// MARK: - Class
typedef enum: uint32_t{
    MFPropertyModifierMemStrong = 0x00,
    MFPropertyModifierMemWeak = 0x01,
    MFPropertyModifierMemCopy = 0x2,
    MFPropertyModifierMemAssign = 0x03,
    MFPropertyModifierMemMask = 0x0F,
    
    MFPropertyModifierAtomic = 0x00,
    MFPropertyModifierNonatomic =  0x10,
    MFPropertyModifierAtomicMask = 0xF0
}MFPropertyModifier;
@interface ORPropertyNode: ORNode
@property(nonatomic, assign, readonly) MFPropertyModifier modifier;
@property(nonatomic,strong) NSMutableArray *keywords;
@property(nonatomic,strong) ORDeclaratorNode * var;
@end

@interface ORMethodDeclNode: ORNode
@property(nonatomic,assign) BOOL isClassMethod;
@property(nonatomic,strong) ORDeclaratorNode * returnType;
@property(nonatomic,strong) NSMutableArray *methodNames;
@property(nonatomic,strong) NSMutableArray <ORDeclaratorNode *>*parameters;
- (NSString *)selectorName;
@end

@interface ORMethodNode: ORNode
@property (nonatomic,strong) ORMethodDeclNode * declare;
@property (nonatomic,strong) ORBlockNode *scopeImp;
@end

@interface ORClassNode: ORNode
@property (nonatomic,copy)NSString *className;
@property (nonatomic,copy)NSString *superClassName;
@property (nonatomic,strong)NSMutableArray <NSString *>*protocols;
@property (nonatomic,strong)NSMutableArray <ORPropertyNode *>*properties;
@property (nonatomic,strong)NSMutableArray <ORDeclaratorNode *>*privateVariables;
@property (nonatomic,strong)NSMutableArray <ORMethodNode *>*methods;
+ (instancetype)classNodeWithClassName:(NSString *)className;
- (void)merge:(ORClassNode *)target key:(NSString *)key;
@end

@interface ORProtocolNode: ORNode
@property (nonatomic,copy)NSString *protcolName;
@property (nonatomic,strong,nullable)NSMutableArray <NSString *>*protocols;
@property (nonatomic,strong)NSMutableArray <ORPropertyNode *>*properties;
@property (nonatomic,strong)NSMutableArray <ORMethodDeclNode *>*methods;
+ (instancetype)protcolWithProtcolName:(NSString *)protcolName;
@end


@interface ORStructStatNode: ORNode
@property (nonatomic,copy)NSString *sturctName;
@property (nonatomic,strong)NSMutableArray <ORDeclaratorNode*>*fields;
@end

@interface ORUnionStatNode: ORNode
@property (nonatomic,copy)NSString *unionName;
@property (nonatomic,strong)NSMutableArray <ORDeclaratorNode*>*fields;
@end

@interface OREnumStatNode: ORNode
@property (nonatomic,assign)OCType valueType;
@property (nonatomic,copy)NSString *enumName;
@property (nonatomic,strong)NSMutableArray *fields;
@end

@interface ORTypedefStatNode: ORNode
@property (nonatomic,strong)ORNode *expression;
@property (nonatomic,copy)NSString *typeNewName;
@end



NS_ASSUME_NONNULL_END
