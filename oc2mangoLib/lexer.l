/* 不需要yywrap */
%option noyywrap yylineno
%{
    #include <Foundation/Foundation.h>
    #include "y.tab.h"
    #import "MakeDeclare.h"
    #import "Log.h"
    unsigned long yycolumn = 0;
    unsigned long yylen = 0;
    char linebuf[500];
    #define YY_USER_ACTION yycolumn += yyleng; yylen = yyleng;

    // 自定义输入源
    // 替换宏定义 YY_INPUT DriveData->项目名/*/*.yy.c 修改文件输入流
    #undef YY_INPUT
    #define YY_INPUT(buf, result, max_size) (result = string_input(buf, result,max_size))
    #define smaller(a, b) ((a) < (b) ? (a) : (b))
    #define larger(a, b) ((a) > (b) ? (a) : (b))
    char const *st_source_string;
    static unsigned long st_current_char_index;
    static unsigned long st_source_len;
    static unsigned long protocol_left;
    static unsigned long protocol_right;
    bool is_variable = false;
    void yy_set_source_string(char const *source)
    {
        yylineno = 0;
        st_source_string = source;
        st_current_char_index = 0;
        st_source_len = strlen(source);
    }
    static int string_input(char *buf, int need_len,int max_size)
    {
        unsigned long len = st_source_len - st_current_char_index;
        if(len <= 0){
            return 0;
        }
        len = smaller(len, max_size);
        strncpy(buf, &st_source_string[st_current_char_index], len);
        st_current_char_index += len;
        return (int)len;
    }
    unsigned long long str2Int(char *text){
        NSString *value = [NSString stringWithUTF8String:text];
        if ([value hasPrefix:@"0x"]) {
            return strtoull(value.UTF8String, NULL, 16);
        }else{
            return strtoull(value.UTF8String, NULL, 0);
        }
    }
    double str2double(char *text){
        return [NSString stringWithUTF8String:text].doubleValue;
    }
%}

%start C_COMMENT CC_COMMENT STRING_LITERAL_STATE POUNDKEY CHILD_COLLECTION_STATE POINT_STATE PROTOCOL_CHECK POINT_CHECK ASSING_POINT_CHECK
%%
<INITIAL>"#" { BEGIN POUNDKEY; }
<POUNDKEY>.* ;
<POUNDKEY>\n { BEGIN INITIAL; }
<INITIAL>"," { is_variable = false; return COMMA ;}
<INITIAL>";" { is_variable = false; return SEMICOLON; }
<INITIAL>"(" { is_variable = false; return LP; }
<INITIAL>")" { is_variable = false; return RP; }
<INITIAL>"[" { is_variable = false; return LB; }
<INITIAL>"]" { is_variable = false; return RB; }
<INITIAL>"{" { is_variable = false; return LC; }
<INITIAL>"}" { is_variable = false; return RC; }
<INITIAL>"." { return DOT; }
<INITIAL>"->" { return ARROW; }
<INITIAL>"@" { return AT; }
<INITIAL>"?" {return QUESTION; }
<INITIAL>":" { return COLON; }

<INITIAL>"==" {return EQ; }
<INITIAL>"!=" {return NE; }

<INITIAL>"<=" {return LE; }
<INITIAL>">" {return GT; }
<INITIAL>">=" {return GE; }   
<INITIAL>"&&" {return LOGIC_AND; }
<INITIAL>"||" {return LOGIC_OR; }
<INITIAL>"!" {return  NOT; }
<INITIAL>"~" {return TILDE; }

<INITIAL>"<<" {return SHIFTLEFT; }
<INITIAL>">>" {return SHIFTRIGHT; }
<INITIAL>"&" {return AND; }
<INITIAL>"|" {return OR; }
<INITIAL>"^" {is_variable = false; return POWER; }
<INITIAL>"-" {return SUB; }
<INITIAL>"+" {return ADD; }
<INITIAL>"/" {return DIV; }
<INITIAL>"%" {return MOD; }

<INITIAL>"=" { return ASSIGN; }
<INITIAL>"&=" {return AND_ASSIGN; }
<INITIAL>"|=" {return OR_ASSIGN; }
<INITIAL>"^=" {return POWER_ASSIGN; }
<INITIAL>"-=" {return SUB_ASSIGN; }
<INITIAL>"+=" {return ADD_ASSIGN; }
<INITIAL>"/=" {return DIV_ASSIGN; }
<INITIAL>"*=" {return ASTERISK_ASSIGN; }
<INITIAL>"%=" {return MOD_ASSIGN; }

<INITIAL>"++" { return INCREMENT; }
<INITIAL>"--" { return DECREMENT; }

<INITIAL>"@interface" { return INTERFACE; }
<INITIAL>"@implementation" { return IMPLEMENTATION; }
<INITIAL>"@protocol" { return PROTOCOL; }
<INITIAL>"@end" { return END; }
<INITIAL>"@class" { return CLASS_DECLARE; }

<INITIAL>"@property" return PROPERTY;
<INITIAL>"@dynamic" return DYNAMIC;
<INITIAL>"nonnull" return NONNULL;
<INITIAL>"nullable" return NULLABLE;


<INITIAL>"NS_ASSUME_NONNULL_BEGIN" ;
<INITIAL>"NS_ASSUME_NONNULL_END" ;
<INITIAL>"UI_APPEARANCE_SELECTOR" ;
<INITIAL>"IBInspectable" ;
<INITIAL>"extern" ;
<INITIAL>"const" ;
<INITIAL>"_Nonnull" ;
<INITIAL>"_Nullable" ;
<INITIAL>"__autoreleasing" ;
<INITIAL>"__block" ;
<INITIAL>"__bridge_transfer" ;
<INITIAL>"__bridge_retained" ;
<INITIAL>"__unused" ;
<INITIAL>"@required" ;
<INITIAL>"@optional" ;
<INITIAL>"@public" ;
<INITIAL>"@private" ;
<INITIAL>"@protected" ;

<INITIAL>"static" return STATIC;
<INITIAL>"__strong" return _STRONG;
<INITIAL>"__weak"  return _WEAK;
<INITIAL>"__bridge" return __BRIDGE ;


<INITIAL>"@selector\("[^()]*"\)" {yylval.identifier =(__bridge_retained void *)[NSString stringWithUTF8String:yytext];  return SELECTOR; }
<INITIAL>"SEL" { return _SEL; }
<INITIAL>"Class" { return _Class;}
<INITIAL>"BOOL" { return _BOOL; }
<INITIAL>"bool" { return _BOOL; }
<INITIAL>"void" { return _void; }
<INITIAL>"instancetype" { return _instancetype; }


<INITIAL>"return" { return _return; }
<INITIAL>"for" { return _for; }
<INITIAL>"in" { return _in; }
<INITIAL>"break" { return _break; }
<INITIAL>"continue" { return _continue; }
<INITIAL>"goto" { return _goto; }
<INITIAL>"if" { return IF; }
<INITIAL>"else" { return _else; }
<INITIAL>"do" { return _do; }
<INITIAL>"while" { return _while; }
<INITIAL>"switch" { return _switch; }
<INITIAL>"case" { return _case; }
<INITIAL>"default" { return _default; }
<INITIAL>"typedef" { return TYPEDEF;}
<INITIAL>"struct" { return _struct; }
<INITIAL>"union" { return _union; }
<INITIAL>"enum" { return _enum; }
<INITIAL>"NS_ENUM" { return NS_ENUM; }
<INITIAL>"NS_OPTIONS" { return NS_OPTIONS; }


<INITIAL>"self"  { is_variable = true; return _self; }
<INITIAL>"super" { is_variable = true; return _super; }
<INITIAL>"nil"   { is_variable = true; return _nil; }
<INITIAL>"NULL"  { is_variable = true; return _NULL; }
<INITIAL>"YES"   { is_variable = true; return _YES; }
<INITIAL>"NO"    { is_variable = true; return _NO; }

<INITIAL>"unsigned char"      { return _UCHAR; }
<INITIAL>"unsigned short"     { return _USHORT; }
<INITIAL>"unsigned int"       { return _UINT; }
<INITIAL>"unsigned long"      { return _ULONG; }
<INITIAL>"unsigned long long" { return _ULLONG; }
<INITIAL>"NSUInteger"         { return _ULLONG; }

<INITIAL>"sizeof"     { is_variable = true; return _sizeof; }
<INITIAL>"typeof"     { return TYPEOF; }
<INITIAL>"__typeof__" { return TYPEOF; }
<INITIAL>"__typeof"   { return TYPEOF; }

<INITIAL>"char"      { return _CHAR; }
<INITIAL>"id"        { return _id; }
<INITIAL>"..."       { return ELLIPSIS;}
<INITIAL>"short"     { return _SHORT; }
<INITIAL>"int"       { return _INT; }
<INITIAL>"long"      { return _LONG; }
<INITIAL>"long long" { return _LLONG; }
<INITIAL>"NSInteger" { return _LLONG; }

<INITIAL>"int8_t"   { return _CHAR; }
<INITIAL>"int16_t"  { return _SHORT; }
<INITIAL>"int32_t"  { return _INT; }
<INITIAL>"int64_t"  { return _LLONG; }

<INITIAL>"uint8"    { return _UCHAR; }
<INITIAL>"uint16"   { return _USHORT; }
<INITIAL>"uint32"   { return _UINT; }
<INITIAL>"uint64"   { return _ULLONG; }
<INITIAL>"uint8_t"  { return _UCHAR; }
<INITIAL>"uint16_t" { return _USHORT; }
<INITIAL>"uint32_t" { return _UINT; }
<INITIAL>"uint64_t" { return _ULLONG; }

<INITIAL>"size_t" { return _UINT; }

<INITIAL>"NSTimeInterval" {return _DOUBLE; }
<INITIAL>"double"   { return _DOUBLE; }
<INITIAL>"float"    { return _FLOAT; }
<INITIAL>"CGFloat"  { return _DOUBLE; }

<INITIAL>__attribute__[ ]*\(.*?\){2,} ;
<INITIAL>__attribute__[ ]*\(.*?\){2,} ;


<INITIAL>[A-Za-z_$][A-Za-z_$0-9]* {
    NSString *name = [NSString stringWithUTF8String:yytext];
    yylval.identifier =(__bridge_retained void *)name;
    return IDENTIFIER;
}

<INITIAL>[1-9][0-9]* {
    is_variable = true;
    yylval.intValue = str2Int(yytext);
    return INTETER_LITERAL;
}
<INITIAL>'.' {
    is_variable = true;
    char value = *(char *)(yytext + 1);
    yylval.identifier =(__bridge_retained void *)@(value).stringValue;
    return INTETER_LITERAL;
}
<INITIAL>"0"[xX][0-9a-fA-F]+ {
    is_variable = true;
    yylval.intValue = str2Int(yytext);
    return INTETER_LITERAL; 
}


<INITIAL>"0" {
    is_variable = true;
    yylval.intValue = 0;
    return INTETER_LITERAL; 
}


<INITIAL>[0-9]+\.[0-9]+ {
    is_variable = true;
    yylval.doubleValue = str2double(yytext);
    return DOUBLE_LITERAL; 
}
<INITIAL>[0-9]+\.[0-9]+f {
    is_variable = true;
    NSString *string = [NSString stringWithUTF8String:yytext];
    string = [string substringWithRange:NSMakeRange(0, [string length] - 1)];
    yylval.doubleValue = string.doubleValue;
    return DOUBLE_LITERAL;
}

<INITIAL>"<" {
    return LT;
}
<INITIAL><[A-Za-z_$][A-Za-z_$0-9]*[ ]*\**[ ]*[,<>] {
    yyless(0);
    BEGIN PROTOCOL_CHECK;
}
<PROTOCOL_CHECK>[A-Za-z_$][A-Za-z_$0-9]* {
    stringBufferAppendString(yytext);
};
<PROTOCOL_CHECK>"*" ;
<PROTOCOL_CHECK>"," {
    stringBufferAppendCharacter(yytext[0]);
};
<PROTOCOL_CHECK>" " ;
<PROTOCOL_CHECK>"<" {
    protocol_left += 1;
    startStringBuffer();
}
<PROTOCOL_CHECK>">" {
    protocol_right += 1;
    if (protocol_left == protocol_right){
        protocol_left = 0;
        protocol_right = 0;
        NSString *string = [NSString stringWithUTF8String:endStringBuffer()];
        yylval.identifier = (__bridge_retained void *)string;
        BEGIN INITIAL;
        return CHILD_COLLECTION;
    }
}
<INITIAL>"*" {
    if (is_variable == true) {
        is_variable = false;
        return ASTERISK;
    }
    is_variable = false;
    return POINT;
}

<INITIAL>\" {
startStringBuffer();
BEGIN STRING_LITERAL_STATE;
}

<INITIAL>[\t] ;
<INITIAL>[\n] ;

<INITIAL>"/*" {  BEGIN C_COMMENT; }
<INITIAL>"//" {  BEGIN CC_COMMENT; }
<INITIAL>. ;

<C_COMMENT>\n;
<C_COMMENT>. ;
<C_COMMENT>"*/"    { yycolumn = 0; BEGIN INITIAL; }
<C_COMMENT><<EOF>>   ;

<CC_COMMENT>.    ;
<CC_COMMENT>\n     { yycolumn = 0; BEGIN INITIAL; }
<CC_COMMENT><<EOF>> { BEGIN INITIAL; }


<STRING_LITERAL_STATE>\" {
    BEGIN  INITIAL;
    is_variable = true;
    NSString *string = [NSString stringWithUTF8String:endStringBuffer()];
    yylval.identifier = (__bridge_retained void *)string;
    return STRING_LITERAL;
}

<STRING_LITERAL_STATE>. { stringBufferAppendCharacter(yytext[0]); };


<STRING_LITERAL_STATE>\\\"  { stringBufferAppendCharacter('\"'); }
<STRING_LITERAL_STATE>\\n	{ stringBufferAppendCharacter('\n'); }
<STRING_LITERAL_STATE>\\t	{ stringBufferAppendCharacter('\t'); }
<STRING_LITERAL_STATE>\\\\	{ stringBufferAppendCharacter('\\'); }
<STRING_LITERAL_STATE>[\x81-\x9f\xe0-\xef][\x40-\x7e\x80-\xfc] {
	stringBufferAppendCharacter(yytext[0]);
    stringBufferAppendCharacter(yytext[1]);
}

<INITIAL>\n.* {
    strncpy(linebuf,yytext + 1,sizeof(linebuf));
    if(strlen(linebuf) > 0) yycolumn = 0;
    yyless(1);
}
%%