GIDACalculateString
===================

Class to parse an input string and calculate its value. 
The string can contain numbers, `.`, `(`, `)`, `/`, `*`, `-`, and `+` symbols.
It also checks, that if the user adds a number, `.`, `(`, `)`, `/`, `*`, `-`, or `+` to a string, would that string be a valid string to calculate or not.

# Tasks

## Verification

+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString;  
+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString here:(NSRange)range;  

## Creation

+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString;  
+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString here:(NSRange)range;

## Solver

+(NSNumber *)solveString:(NSString *)string;

# Properties

### usingThis:addThis:
Check if adding a new string, at the end, to a previous string would create a valid expression.

+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString;

__Parameters__  
_string_  
Base string where you want to add.

_newString_  
String to check if adding it would create a correct expression.

__Return Value__  
`YES` if adding the _newString_ to _string_ would create a valid expression, otherwise `NO`

__Discussion__  
This assumes the _newString_ would be added at the end of _string_.


### usingThis:addThis:here
Check if adding a new string, at the specified location, to a previous string would create a valid expression.

+(BOOL)usingThis:(NSString *)string addThis:(NSString *)newString here:(NSRange)range;

__Parameters__  
_string_  
Base string where you want to add something.

_newString_  
String to check if adding it would create a correct expression.

_range_  
Range where string would be added.

__Return Value__  
`YES` if adding the _newString_ to _string_ would create a valid expression, otherwise `NO`

### stringFrom:withThis:  

+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString;
Add a new string to the end of a previous string.

__Parameters__
_string_  
Base string where you want to add.

_newString_  
String to check if adding it would create a correct expression.

__Return Value__  
A string with containing the previous string with the new string appended.

### stringFrom:withThis:here:  
Add a new string at the specified location to a previous string.

+(NSString *)stringFrom:(NSString *)string withThis:(NSString *)newString here:(NSRange)range;

__Parameters__  
_string_  
Base string where you want to add something.

_newString_  
String to check if adding it would create a correct expression.

_range_  
Range where string would be added.

__Return Value__ 
A string with containing the previous string with the new string in the specified location.

### solveString:  
Solve an mathematical expression.

+(NSNumber *)solveString:(NSString *)string;

__Parameters__  
_string_  
String containing the mathematical expression.

__Return Value__ 
A number with the result of the mathematical expression, nil if it is not a well formed expression.