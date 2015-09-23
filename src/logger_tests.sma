#include <amxmodx>
#include <logger>

public plugin_init() {
    new Logger:logger = LoggerCreate(/*
        Severity_Lowest,
        "%i-%m",
        "[%5v] [%t] %p::%f %m",
        "%Y-%m-%d",
        "%H:%M:%S",
        "%p/%d",
        "    %n::f : %l"*/);
    LoggerSetVerbosity(logger, Severity_Lowest);
    LoggerSetNameFormat(logger, "%i-%m");
    LoggerSetMessageFormat(logger, "[%5v] [%t] %p::%f %m");
    LoggerSetDateFormat(logger, "%Y-%m-%d");
    LoggerSetTimeFormat(logger, "%H:%M:%S");
    LoggerSetPathFormat(logger, "%p/%d");
    LoggerSetTraceFormat(logger, "    %n::%f : %l");

    LoggerLogDebug(logger, false, "This is a debug message");
    LoggerLogInfo(logger, false, "This is an info message");
    LoggerLogWarn(logger, true, "This is a warn message");
    LoggerLogError(logger, true, "This is an error message");

    LoggerDestroy(logger);
}