//
//  MakeDeclare.h
//  oc2mango
//
//  Created by Jiang on 2019/4/21.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//


#import "ocAstNode.hpp"

void startStringBuffer(void);
char *endStringBuffer(void);
void stringBufferAppendCharacter(char chr);
void stringBufferAppendString(char *str);

NSMutableArray *makeMutableArray(id object);
