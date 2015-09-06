#if defined _string_stocks_included
    #endinput
#endif
#define _string_stocks_included

#include <string>

#define isStringEmpty(%1)\
    (%1[0] == EOS)