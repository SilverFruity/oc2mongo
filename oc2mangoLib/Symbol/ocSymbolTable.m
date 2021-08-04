//
//  ocSymbolTable.m
//  oc2mangoLib
//
//  Created by Jiang on 2021/6/24.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import "ocSymbolTable.h"
const ocSymbolTable * symbolTableRoot = nil;
@implementation ocSymbolTable
{
    NSMutableDictionary *constantCache;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        constants = (char *)malloc(sizeof(char));
        constantCache = [NSMutableDictionary dictionary];
        self.scope = [ocScope new];
    }
    return self;
}
- (ocSymbol *)insert:(ocSymbol *)symbol{
    ocSymbol *localSymbol = [self localLookup:symbol.name];
    if (localSymbol == nil) {
        ocSymbol *globalSymbol = [self lookup:symbol.name];
        if (globalSymbol == nil || globalSymbol != symbol) {
            [self.scope insert:symbol.name symbol:symbol];
        }else{
            symbol = [ocSymbol symbolWithName:symbol.name decl:nil];
            [self.scope insert:symbol.name symbol:symbol];
        }
    }
    return symbol;
}
- (ocSymbol *)insertRoot:(ocSymbol *)symbol{
    return [self insertRootWithName:symbol.name symbol:symbol];
}
- (ocSymbol *)insertRootWithName:(NSString *)name symbol:(ocSymbol *)symbol{
    ocScope *scope = self.scope;
    while (scope.parent != nil) {
        scope = scope.parent;
    }
    [scope insert:name symbol:symbol];
    return symbol;
}
- (ocSymbol *)lookup:(NSString *)name{
    if (name != nil && name.length == 0) {
        return nil;
    }
//    NSAssert(name != nil && name.length > 0, @"");
    ocScope *scope = self.scope;
    ocSymbol *symbol = nil;
    while (symbol == nil && scope != nil)
    {
        symbol = [scope lookup:name];
        scope = scope.parent;
    }
    return symbol;
}
- (ocSymbol *)localLookup:(NSString *)name{
    return [self.scope lookup:name];
}
- (ocScope *)increaseScope{
    ocScope *scope = [ocScope new];
    scope.parent = self.scope;
    self.scope = scope;
    return self.scope;
}
- (ocScope *)decreaseScope{
    self.scope = self.scope.parent;
    return self.scope;
}
- (void)addConstantSymbol:(ocSymbol *)symbol withKey:(id <NSCopying>)key{
    constantCache[key] = symbol;
}
- (ocSymbol *)getConstantSymbol:(NSString *)key{
    return constantCache[key];
}
@end
