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

public OnLoggerCreated(
        const Logger: logger,
        const Severity: verbosity,
        const name[],
        const nameFormat[],
        const msgFormat[],
        const dateFormat[],
        const timeFormat[],
        const pathFormat[],
        const traceFormat[]) {
    server_print("logger = %d", logger);
    server_print("verbosity = %d", verbosity);
    server_print("name = %s", name);
    server_print("nameFormat = %s", nameFormat);
    server_print("msgFormat = %s", msgFormat);
    server_print("dateFormat = %s", dateFormat);
    server_print("timeFormat = %s", timeFormat);
    server_print("pathFormat = %s", pathFormat);
    server_print("traceFormat = %s", traceFormat);
}