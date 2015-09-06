#if defined _logger_const_included
    #endinput
#endif
#define _logger_const_included

#include <amxconst>

#define LEVEL_INVALID -1
#define LEVEL_NONE    0
#define LEVEL_ALL     LEVEL_DEBUG

#define LEVEL_SEVERE  1
#define LEVEL_WARNING 2
#define LEVEL_INFO    3
#define LEVEL_DEBUG   4

stock const LEVEL[][] = {
    "",
    "SEVERE",
    "WARN",
    "INFO",
    "DEBUG",
};

enum Logger {
    Invalid_Logger
};