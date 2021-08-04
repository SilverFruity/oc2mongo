//
//  MakeDeclare.m
//  oc2mango
//
//  Created by Jiang on 2019/4/21.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

#import "MakeDeclare.hpp"


static NSMutableString *buffer = nil;
static char *string_buffer = NULL;
static int string_buffer_index = 0;
static int string_buffer_size = 0;
#define STRING_BUFFER_ALLOC_SIZE 256;
void startStringBuffer(void){
    string_buffer_index = 0;
}
char *endStringBuffer(void){
    stringBufferAppendCharacter('\0');
    size_t strLen = strlen(string_buffer);
    char *str = (char *)malloc(strLen + 1);
    strcpy(str, string_buffer);
    free(string_buffer);
    string_buffer = NULL;
    string_buffer_index = 0;
    string_buffer_size = 0;
    return str;
}
void stringBufferAppendCharacter(char chr){
    if (string_buffer_index >= string_buffer_size) {
        string_buffer_size +=  STRING_BUFFER_ALLOC_SIZE;
        string_buffer = (char *)realloc(string_buffer, string_buffer_size);
    }
    string_buffer[string_buffer_index] = chr;
    string_buffer_index++;
}
void stringBufferAppendString(char *str){
    size_t len = strlen(str);
    if (string_buffer_index + len > string_buffer_size) {
         string_buffer_size +=  STRING_BUFFER_ALLOC_SIZE;
         string_buffer = (char *)realloc(string_buffer, string_buffer_size);
    }
    strncpy(string_buffer+string_buffer_index, str, len);
    string_buffer_index += len;
}
NSMutableArray *makeMutableArray(id object){
    __autoreleasing NSMutableArray *array = [NSMutableArray array];
    if (object) {
        [array addObject:object];
    }
    return array;
}
