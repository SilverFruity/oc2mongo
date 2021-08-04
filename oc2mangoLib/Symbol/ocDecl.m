//
//  ocDecl.m
//  oc2mangoLib
//
//  Created by APPLE on 2021/6/25.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import "ocDecl.h"
#import "ocHandleTypeEncode.h"

@implementation ocDecl
- (instancetype)init
{
    self = [super init];
    if (self) {
        _alignment = 8;
        _typeEncode = NULL;
        _offset = 0;
    }
    return self;
}
+ (instancetype)declWithTypeEncode:(const char *)typeEncode{
    ocDecl *decl = [ocDecl new];
    decl.typeEncode = typeEncode;
    return decl;
}
- (void)setTypeEncode:(const char *)typeEncoding{
    if (_typeEncode != NULL) {
        free((void *)_typeEncode);
        _typeEncode = NULL;
    }
    _typeEncode = strdup(typeEncoding);
    if (typeEncoding != NULL && isDynamicCArray == NO) {
        NSUInteger size = 0, alignment = 0;
        NSGetSizeAndAlignment(typeEncoding, &size, &alignment);
        _size = size;
        _alignment = alignment;
        if (self.isBlock || self.isFunction) {
            // @?x | ^?x, 取x
            _type = (OCType)_typeEncode[2];
        }else{
            _type = (OCType)*typeEncoding;
        }
    }
}

- (BOOL)isStruct{
    return _type == OCTypeStruct;
}
- (BOOL)isUnion{
    return _type == OCTypeUnion;
}
- (BOOL)isCArray{
    return _type == OCTypeArray;
}
- (BOOL)isObject{
    return _type == OCTypeObject && self.isBlock == NO;
}
- (BOOL)isBlock{
    if (strlen(_typeEncode) < 2) return NO;
    return _typeEncode[0] == OCTypeObject && _typeEncode[1] == OCTypeUnknown;
}
- (BOOL)isDynamicCArray{
    return isDynamicCArray;
}
- (BOOL)isFunction{
    if (strlen(_typeEncode) < 2) return NO;
    return _typeEncode[0] == OCTypePointer && _typeEncode[1] == OCTypeUnknown;
}
- (BOOL)isProperty{
    return isProperty;
}
- (BOOL)isIvar{
    return isIvar;
}
- (BOOL)isMethod{
    return isMethod;
}
- (BOOL)isClassMethod{
    return isClassMethod;
}
- (void)dealloc
{
    if (_typeEncode != NULL) {
        free((void *)_typeEncode);
        _typeEncode = NULL;
    }
}
- (BOOL)isConstant{
    return isConstant;
}
- (BOOL)isClassRef{
    return isClassRef;
}
@end

@implementation ocComposeDecl

@end
