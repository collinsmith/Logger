#if defined _logging_included
    #endinput
#endif
#define _logging_included

/*******************************************************************************
 * NATIVES
 ******************************************************************************/

LoggerLogSevere(Logger:logger, const format[], any:...);
LoggerLogWarning(Logger:logger, const format[], any:...);
LoggerLogInfo(Logger:logger, const format[], any:...);
LoggerLogDebug(Logger:logger, const format[], any:...);

LoggerLog(Logger:logger, level:level, const format[], any:...);