#if defined _logger_included
    #endinput
#endif
#define _logger_included

#include <amxconst>

/*******************************************************************************
 * NATIVES
 ******************************************************************************/

native Logger:LoggerCreate(
        const filenameFormat[] = NULL_STRING,
        const messsageFormat[] = NULL_STRING,
        const datestampFormat[] = NULL_STRING,
        const timestampFormat[] = NULL_STRING,
        const severity = SEVERITY_WARNING,
        const path[] = NULL_STRING);
native bool:LoggerDestroy(&Logger:logger);

native LoggerGetMinSeverity(Logger:logger = All_Loggers);
native LoggerSetMinSeverity(Logger:logger = All_Loggers, severity);

native LoggerLogError(Logger:logger, const format[], any:...);
native LoggerLogWarning(Logger:logger, const format[], any:...);
native LoggerLogInfo(Logger:logger, const format[], any:...);
native LoggerLogDebug(Logger:logger, const format[], any:...);

native LoggerLog(Logger:logger, severity, const format[], any:...);