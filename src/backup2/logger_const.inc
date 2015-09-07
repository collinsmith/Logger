#if defined _logger_const_included
    #endinput
#endif
#define _logger_const_included

#include <amxconst>

stock const KEY_NAMEFORMAT[] = "nameFormat";
stock const KEY_MESSAGEFORMAT[] = "messageFormat";
stock const KEY_DATESTAMPFORMAT[] = "datestampFormat";
stock const KEY_TIMESTAMPFORMAT[] = "timestampFormat";
stock const KEY_MINSEVERITY[] = "minSeverity";
stock const KEY_PATH[] = "path";
stock const KEY_FILEPOINTER[] = "filePointer";

enum {
    SEVERITY_INVALID = -1,
    
    SEVERITY_NONE    =  0,

    SEVERITY_ERROR   =  1,
    SEVERITY_WARNING,
    SEVERITY_INFO,
    SEVERITY_DEBUG,
    
    SEVERITY_ALL,
}

stock const SEVERITY[][] = {
    "",      // SEVERITY_NONE

    "ERROR", // SEVERITY_ERROR
    "WARN",  // SEVERITY_WARNING
    "INFO",  // SEVERITY_INFO
    "DEBUG", // SEVERITY_DEBUG

    "",      // SEVERITY_ALL
};

enum Logger {
    All_Loggers = -1,
    Invalid_Logger
};