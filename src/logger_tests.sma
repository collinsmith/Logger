#include <amxmodx>
#include <logger>

public plugin_init() {
    new Logger:logger = LoggerCreate();
    LoggerSetVerbosity(logger, Severity_Lowest);
    LoggerSetNameFormat(logger, "%i-%m");
    LoggerSetMessageFormat(logger, "[%5v] [%t] %p::%f - %s");
    LoggerSetDateFormat(logger, "%Y-%m-%d");
    LoggerSetTimeFormat(logger, "%H:%M:%S");
    LoggerSetPathFormat(logger, "%p/%d");
    LoggerSetTraceFormat(logger, "    %n::%f : %l");

    LoggerLogDebug(logger, "This is a debug message");
    LoggerLogInfo(logger, "This is an info message");
    LoggerLogWarn(logger, "This is a warn message");
    LoggerLogError(logger, "This is an error message");

    LoggerDestroy(logger);
}