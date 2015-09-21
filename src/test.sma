#include <amxmodx>
#include <logger>

public plugin_init() {
    new Logger:logger = LoggerCreate();
    LoggerSetVerbosity(logger, Severity_Info);
    LoggerSetNameFormat(logger, "%i-%m");
    LoggerSetMessageFormat(logger, "[%5s] [%t] %n::%f %l");
    LoggerSetDateFormat(logger, "%Y-%m-%d");
    LoggerSetTimeFormat(logger, "%H:%M:%S");
    LoggerSetPathFormat(logger, "%n/%d");

    new temp[32];
    LoggerGetNameFormat(logger, temp, 31);
    server_print(temp);

    LoggerLogDebug(logger, false, "This is a debug message");
    LoggerLogInfo(logger, false, "This is an info message");
    LoggerLogWarn(logger, false, "This is a warn message");
    LoggerLogError(logger, false, "This is an error message");

    LoggerDestroy(logger);
}