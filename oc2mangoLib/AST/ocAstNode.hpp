//
//  AstNode.hpp
//  oc2mangoLib
//
//  Created by Jiang on 2021/7/26.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#ifndef AstNode_hpp
#define AstNode_hpp

#include <stdio.h>
#include <string>
#include <vector>
#include <tuple>
#import <ORPatchFile/OCTypeEncode.h>
#import <ORPatchFile/BinaryPatchHelper.h>

using namespace std;
typedef enum: uint32_t{
    ocDeclarationModifierBlock      = 1 << 0,
    ocDeclarationModifierStrong     = 1 << 1,
    ocDeclarationModifierWeak       = 1 << 2,
    ocDeclarationModifierStatic     = 1 << 3
}ocDeclarationModifier;

class Symbol{
    
};
class Scope{
    
};
class ocAstNode{
    int lineNumber;
    Symbol *symbol;
    Scope *scope;
public:
    vector <ocAstNode *> m_children;
    ocAstNode()
    {
        m_children = vector<ocAstNode *>();
    }
    void AddChild(ocAstNode *node)
    {
        if (node == NULL) return;
        m_children.push_back(node);
    }
    int NumChildren()
    {
        return (int)m_children.size();
    }
    ocAstNode* GetChild(int child)
    {
        if (child >= (int)m_children.size()) return nullptr;
        return m_children[child];
    }
};
class ocStmt: public ocAstNode
{
public:
    ocStmt(): ocAstNode(){
        
    }
};

class ocStmtsList: public ocStmt
{
    ocStmtsList(ocStmt *stmt): ocStmt(){
        AddChild(stmt);
    }
    void addNode(ocStmt *stmt){
        AddChild(stmt);
    }
    void addList(ocStmtsList *stmts){
        for (int ii=0; ii<stmts->NumChildren(); ii++)
        {
            AddChild( stmts->GetChild(ii) );
        }
    }
};

class ocDecl : public ocStmt
{
public:
    ocDecl() : ocStmt()
    {
    }
};

class ocDeclList: public ocStmtsList
{
    void AddNode(ocDecl *decl)
    {
        AddChild(decl);
    }
    ocDecl* GetDecl(int index)   { return (ocDecl*)GetChild(index); }
};

class ocTypeDecl: public ocDecl
{
public:
    ocTypeDecl(): ocDecl()
    {
        
    }
};




class StringNode:ocAstNode{
public:
    char *result;
    StringNode(char *value):ocAstNode(), result(value){
        
    }
};
class TypeNode: public ocAstNode{
public:
    OCType type;
    ocDeclarationModifier modifier;
    StringNode *typeName;
    TypeNode(OCType type, char *typeName, ocDeclarationModifier modifier = ocDeclarationModifierStrong): ocAstNode()
    {
        this->type = type;
        this->typeName = new StringNode(typeName);
        this->modifier = modifier;
    }
};
class VariableNode: public ocAstNode{
    StringNode *varname;
    bool isBlock;
    uint8_t ptCount;
public:
    VariableNode(char *varname, bool isBlock = false, uint8_t ptCount = 0): ocAstNode()
    {
        this->varname = new StringNode(varname);
        this->isBlock = isBlock;
        this->ptCount = ptCount;
    }
};
class DeclaratorNode: public ocAstNode{
    TypeNode *type;
    VariableNode *var;
public:
    DeclaratorNode(): ocAstNode() { }
    DeclaratorNode(TypeNode *type, VariableNode *var): ocAstNode()
    {
        this->type = type;
        this->var = var;
        AddChild(type);
        AddChild(var);
    }
};

class FunctionDeclNode: public DeclaratorNode{
    BOOL isMultiArgs;
    vector <DeclaratorNode *> params;
public:
    FunctionDeclNode(): DeclaratorNode()
    {
        
    }
};

//class CArrayDeclNode: DeclaratorNode{
//    CArrayDeclNode *prev;
//    AstNode *capacity;
//};

class BlockNode: public ocAstNode
{
    BlockNode(vector<ocAstNode *> list): ocAstNode() {
        m_children = list;
    };
    BlockNode(ocAstNode *node): ocAstNode() {
        AddChild(node);
    };
};
class OCDictionaryNode: public ocAstNode
{
public:
    vector<tuple<ocAstNode *,ocAstNode *>> container;
    OCDictionaryNode(): ocAstNode()
    {
        container = vector<tuple<ocAstNode *,ocAstNode *>>();
    }
    void addKeyValue(ocAstNode *key, ocAstNode *value)
    {
        container.push_back(tuple<ocAstNode *,ocAstNode *>(key,value));
    }
};
class OCArrayNode: public ocAstNode
{
    OCArrayNode(): ocAstNode() { };
};
typedef enum: uint32_t{
    OCValueSelf, // value: nil
    OCValueSuper, // value: nil
    OCValueNil, //  value: nil
    OCValueNULL //  value: nil
}OC_EMBED_VALUE_TYPE;

class ValueNode: ocAstNode
{
    OC_EMBED_VALUE_TYPE value_type;
    ValueNode(OC_EMBED_VALUE_TYPE type): ocAstNode()
    {
        value_type = type;
    }
};

typedef enum: uint32_t{
    OCValueVariable, // value: string
    OCValueSelector, // value: sel string
    OCValueProtocol, // value: String
    OCValueNSNumber, // value: Exp
    OCValueNSString, // value: string
    OCValueCString, // value: string
}OC_VALUE_TYPE;
class ConstStringValueNode: ocAstNode
{
    OC_VALUE_TYPE type;
    ConstStringValueNode(): ocAstNode(){
        
    }
};

typedef enum: uint32_t{
    ConstantInt,
    ConstantUInt,
    ConstantDouble,
    ConstantBool
}CONSTANT_VALUE_TYPE;

class ConstValueNode: ocAstNode{
    CONSTANT_VALUE_TYPE type;
    union {
        int64_t intValue;
        uint64_t uintValue;
        double doubleValue;
        bool boolValue;
    } value;
    ConstValueNode(int64_t int_val): ocAstNode()
    {
        
    }
    ConstValueNode(uint64_t uint_val): ocAstNode()
    {
        
    }
    ConstValueNode(bool bool_val): ocAstNode()
    {
        
    }
    ConstValueNode(double double_val): ocAstNode()
    {
        
    }
};
//兼容struct->field
typedef enum: uint8_t{
    MethodOpretorNone = 0,
    MethodOpretorDot,
    MethodOpretorArrow
}MethodOperatorType;

class MethodCall: ocAstNode{
    bool isStructRef;
    MethodOperatorType optr;
    ocAstNode * caller;
    StringNode *selector;
    vector <ocAstNode *> args;
public:
    MethodCall(): ocAstNode()
    {
        
    }
};

class FunctionCall: ocAstNode{
    ValueNode *caller;
    vector <ocAstNode *> args;
};


class FunctionNode: ocAstNode{
    FunctionDeclNode *declare;
    BlockNode *block;
};

class SubscriptNode: ocAstNode{
    ocAstNode * caller;
    ocAstNode * keyExp;
};

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

class AssignNode: ocAstNode{
    AssignOperatorType optr;
    ocAstNode * left;
    ocAstNode * right;
};

class InitDeclaratorNode: ocAstNode{
    DeclaratorNode *left;
    ocAstNode * right;
};

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
class UnaryNode: ocAstNode{
    UnaryOperatorType optr;
    ocAstNode * value;
};

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

class BinaryNode: ocAstNode
{
    BinaryOperatorType optr;
    ocAstNode *left;
    ocAstNode *right;
};


class TernaryNode: ocAstNode{
    ocAstNode * condition;
    vector<ocAstNode *> values;
};
// MARK: - Statement
class IfStatement: ocAstNode
{
    ocAstNode *condition;
    BlockNode *block;
    vector<ocAstNode *> statements;
};
class WhileStatement: ocAstNode
{
    ocAstNode * condition;
    BlockNode *block;
};

class DoWhileStatement: ocAstNode
{
    ocAstNode * condition;
    BlockNode *block;
};

class CaseStatement: ocAstNode
{
    ocAstNode * value;
    BlockNode *block;
};

class SwitchStatement: ocAstNode
{
    ocAstNode * value;
    vector <CaseStatement *> cases;
};

class ForStatement: ocAstNode
{
    vector <ocAstNode *> initials;
    ocAstNode * condition;
    vector <ocAstNode *> iters;
    BlockNode *block;
};

class ForInStatement: ocAstNode
{
    DeclaratorNode * item;
    ocAstNode * container;
    BlockNode *block;
};

typedef enum: uint32_t{
    ControlStatReturn,
    ControlStatBreak,
    ControlStatContinue
}ControlStateType;

class ControlStatNode: ocAstNode
{
    ControlStateType type;
    ocAstNode * value;
};


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
class PropertyNode: ocAstNode
{
    MFPropertyModifier modifier;
    DeclaratorNode * var;
public:
    PropertyNode(DeclaratorNode *var): ocAstNode()
    {
        this->var = var;
    }
};

class MethodDeclNode: ocAstNode
{
    bool isClassMethod;
    StringNode *selector;
    DeclaratorNode * returnType;
    vector <DeclaratorNode *> parameters;
public:
    MethodDeclNode(bool isClassMethod, DeclaratorNode *ret): ocAstNode()
    {
        this->isClassMethod = isClassMethod;
        returnType = ret;
    }
};

class MethodNode: ocAstNode
{
    MethodDeclNode * declare;
    BlockNode *block;
public:
    MethodNode(MethodDeclNode *decl, BlockNode *block): ocAstNode()
    {
        declare = decl;
        this->block = block;
    }
};

class ClassNode: ocAstNode
{
    StringNode *className;
    StringNode *superClassName;
    vector <StringNode *> protocols;
    vector <PropertyNode *> properties;
    vector <DeclaratorNode *> privateVars;
    vector <MethodNode *> methods;
public:
    ClassNode(char *name): ocAstNode()
    {
        className = new StringNode(name);
    }
};

class ocProtocolNode: ocAstNode
{
    StringNode * protcolName;
    vector <StringNode *> protocols;
    vector <PropertyNode *> properties;
    vector <MethodDeclNode *> methods;
public:
    ocProtocolNode(char *name): ocAstNode()
    {
        protcolName = new StringNode(name);
    }
};


class StructStatNode: ocAstNode
{
    StringNode *sturctName;
    vector <DeclaratorNode *> fields;
};

class UnionStatNode: ocAstNode
{
    StringNode *unionName;
    vector <DeclaratorNode*> fields;
};

class EnumStatNode: ocAstNode
{
    OCType valueType;
    StringNode *enumName;
    vector <ocAstNode *> fields;
};

class TypedefStatNode: ocAstNode
{
    ocAstNode *expression;
    StringNode *typeNewName;
};



#endif /* Node_hpp */
