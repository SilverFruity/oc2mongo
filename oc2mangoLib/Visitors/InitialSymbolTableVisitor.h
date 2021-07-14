//
//  InitialSymbolVisitor.h
//  oc2mangoLib
//
//  Created by Jiang on 2021/6/25.
//  Copyright © 2021 SilverFruity. All rights reserved.
//

#import <ORPatchFile/ORPatchFile.h>
#import "ocSymbolTable.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *AnonymousBlockSignature;

@interface InitialSymbolTableVisitor : NSObject <AstVisitor>
{
    NSMutableDictionary <NSString *, ORNode *>*internalFunctionTable;
}
@end

NS_ASSUME_NONNULL_END
