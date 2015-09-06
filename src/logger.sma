#define VERSION_STRING "0.0.1"

#define INITIAL_LOGGERS_SIZE 4
#define LOGGER_FILENAMEFORMAT_LENGTH LOGGER_PATH_LENGTH
#define LOGGER_MESSAGEFORMAT_LENGTH 255
#define LOGGER_TIMESTAMPFORMAT_LENGTH 31
#define LOGGER_DATESTAMPFORMAT_LENGTH 31
#define LOGGER_PATH_LENGTH (PLATFORM_MAX_PATH-1)
#define LOGGER_FILENAME_LENGTH 31
#define LOGGER_FUNCTIONNAMEBUFFER_LENGTH 31
#define LOGGER_MESSAGEBUFFER_LENGTH 1023
#define BUFFER_LENGTH 1023

#include <amxmodx>
#include <file>
#include "include/logger_const.inc"
#include "include/string_stocks.inc"
#include "include/param_test_stocks.inc"

static const DEFAULT_FILENAME_FORMAT[] = "%filename_%date.log";
static const DEFAULT_MESSAGE_FORMAT[] = "%time %severity [%function] %message";
static const DEFAULT_DATESTAMP_FORMAT[] = "%Y-%m-%d";
static const DEFAULT_TIMESTAMP_FORMAT[] = "%H:%M:%S";

static timestampBufferLen;
static timestampBuffer[LOGGER_TIMESTAMPFORMAT_LENGTH+1];

static datestampBufferLen;
static datestampBuffer[LOGGER_DATESTAMPFORMAT_LENGTH+1];

static messageBufferLen;
static messageBuffer[LOGGER_MESSAGEBUFFER_LENGTH+1];

static pathBufferLen;
static pathBuffer[LOGGER_PATH_LENGTH+1];

static bufferLen;
static buffer[BUFFER_LENGTH+1];

static globalSeverity;
static numLoggers;
static Array:loggerFilenameFormats = Invalid_Array;
static Array:loggerMessageFormats = Invalid_Array;
static Array:loggerTimestampFormats = Invalid_Array;
static Array:loggerDatestampFormats = Invalid_Array;
static Array:loggerSeverities = Invalid_Array;
static Array:loggerFilePaths = Invalid_Array;

static Array:loggerFileNames = Invalid_Array;
static Array:loggerFilePointers = Invalid_Array;

public plugin_natives() {
    register_library("logger");

    register_native("CreateLogger", "CreateLogger", 0);
    register_native("DestroyLogger", "DestroyLogger", 0);

    register_native("LoggerGetMinSeverity", "LoggerGetMinSeverity", 0);
    register_native("LoggerSetMinSeverity", "LoggerSetMinSeverity", 0);

    register_native("LoggerLogSevere", "LoggerLogSevere", 0);
    register_native("LoggerLogWarning", "LoggerLogWarning", 0);
    register_native("LoggerLogInfo", "LoggerLogInfo", 0);
    register_native("LoggerLogDebug", "LoggerLogDebug", 0);

    register_native("LoggerLog", "LoggerLog", 0);

    state severity_all;
}

public plugin_init() {
    register_plugin(.plugin_name = "Logger",
        .version = getBuildId(),
        .author = "Tirant");
}

public plugin_end() {
    new len = ArraySize(loggerFilePointers);
    for (new i = 0; i < len; i++) {
        fclose(ArrayGetCell(loggerFilePointers, i));
    }
}

getBuildId() {
    new buildId[32];
    formatex(buildId, charsmax(buildId), "%s.%s", VERSION_STRING, __DATE__);
    return buildId;
}

initializeStructs() {
    if (loggerFilenameFormats == Invalid_Array) {
        loggerFilenameFormats = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_FILENAMEFORMAT_LENGTH+1);
    }

    if (loggerMessageFormats == Invalid_Array) {
        loggerMessageFormats = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_MESSAGEFORMAT_LENGTH+1);
    }

    if (loggerDatestampFormats == Invalid_Array) {
        loggerDatestampFormats = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_DATESTAMPFORMAT_LENGTH+1);
    }

    if (loggerTimestampFormats == Invalid_Array) {
        loggerTimestampFormats = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_TIMESTAMPFORMAT_LENGTH+1);
    }

    if (loggerSeverities == Invalid_Array) {
        loggerSeverities = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE);
    }

    if (loggerFilePaths == Invalid_Array) {
        loggerFilePaths = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_PATH_LENGTH+1);
    }

    if (loggerFileNames == Invalid_Array) {
        loggerFileNames = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE,
                .cellsize = LOGGER_FILENAME_LENGTH+1);
    }

    if (loggerFilePointers == Invalid_Array) {
        loggerFilePointers = ArrayCreate(
                .reserved = INITIAL_LOGGERS_SIZE);
    }
}

isValidLogger(Logger:logger) {
    return Invalid_Logger < logger
        && any:logger <= numLoggers
        && ArrayGetCell(loggerSeverities, convertLoggerToArrayIndex(logger))
            != SEVERITY_INVALID;
}

bool:isInvalidLoggerParam(const function[], Logger:logger) {
    if (isValidLogger(logger)) {
        return false;
    }

    log_error(
            AMX_ERR_NATIVE,
            "[%s] Invalid logger handle specified: %d",
            function,
            logger);
    return true;
}

bool:isValidLoggerSeverity(severity) {
    return SEVERITY_NONE < severity && severity < SEVERITY_ALL;
}

bool:isInvalidLoggerSeverityParam(const function[], severity) {
    if (isValidLoggerSeverity(severity)) {
        return false;
    }

    log_error(
            AMX_ERR_NATIVE,
            "[%s] Invalid logger severity specified: %d. \
                  Log levels should be between %d and %d (inclusive)",
            function,
            severity,
            SEVERITY_NONE,
            SEVERITY_ALL);
    return true;
}

getLoggerSeverity(Logger:logger) {
    assert isValidLogger(logger) || logger == All_Loggers;
    if (logger == All_Loggers) {
        return globalSeverity;
    }
    
    new loggerIndex = convertLoggerToArrayIndex(logger);
    return ArrayGetCell(loggerSeverities, loggerIndex);
}

setLoggerSeverity(Logger:logger, severity) {
    assert isValidLogger(logger) || logger == All_Loggers;
    assert isValidLoggerSeverity(severity);
    if (logger == All_Loggers) {
        new oldGlobalSeverity = getLoggerSeverity(logger);
        globalSeverity = severity;
        switch (globalSeverity) {
            case SEVERITY_NONE:    state severity_none;
            case SEVERITY_ERROR:   state severity_error;
            case SEVERITY_WARNING: state severity_warning;
            case SEVERITY_INFO:    state severity_info;
            case SEVERITY_DEBUG:   state severity_debug;
            case SEVERITY_ALL:     state severity_all;
        }
        return oldGlobalSeverity;
    }

    new oldLoggerSeverity = getLoggerSeverity(logger);
    new loggerIndex = convertLoggerToArrayIndex(logger);
    ArraySetCell(loggerSeverities, loggerIndex, severity);
    return oldLoggerSeverity;
}

convertLoggerToArrayIndex(Logger:logger) {
    return any:logger-1;
}

Logger:pushLogger(
        const filenameFormat[],
        const messageFormat[],
        const datestampFormat[],
        const timestampFormat[],
        severity = SEVERITY_WARNING,
        const path[],
        const filename[],
        file = 0) {
    assert !isStringEmpty(filenameFormat);
    assert !isStringEmpty(messageFormat);
    assert !isStringEmpty(datestampFormat);
    assert !isStringEmpty(timestampFormat);
    assert !isStringEmpty(path);
    assert !isStringEmpty(filename);
    assert !isValidLoggerSeverity(severity);
    new i = ArrayPushString(loggerFilenameFormats, filenameFormat);
    new j = ArrayPushString(loggerMessageFormats, messageFormat);
    new k = ArrayPushString(loggerDatestampFormats, datestampFormat);
    new l = ArrayPushString(loggerTimestampFormats, timestampFormat);
    new m = ArrayPushCell(loggerSeverities, severity);
    new n = ArrayPushString(loggerFilePaths, path);
    new o = ArrayPushString(loggerFileNames, path);
    new p = ArrayPushCell(loggerFilePointers, file);
    assert i == j
        && i == k
        && i == l
        && i == m
        && i == n
        && i == o
        && i == p;
    return Logger:(i+1);
}

clearLogger(Logger:logger) {
    assert isValidLogger(logger);
    new loggerIndex = convertLoggerToArrayIndex(logger);
    fclose(ArrayGetCell(loggerFilePointers, loggerIndex));
    ArraySetString(loggerFilenameFormats, loggerIndex, "");
    ArraySetString(loggerMessageFormats, loggerIndex, "");
    ArraySetString(loggerTimestampFormats, loggerIndex, "");
    ArraySetString(loggerDatestampFormats, loggerIndex, "");
    ArraySetCell(loggerSeverities, loggerIndex, SEVERITY_INVALID);
    ArraySetString(loggerFilePaths, loggerIndex, "");
    ArraySetString(loggerFileNames, loggerIndex, "");
    ArraySetCell(loggerFilePointers, loggerIndex, 0);
}

public Logger:CreateLogger(pluginId, numParams) {
    if (isInvalidNumberOfParams("CreateLogger", numParams, 6)) {
        return Invalid_Logger;
    }

    initializeStructs();

    new tempLen;

    new filenameFormat[LOGGER_FILENAMEFORMAT_LENGTH+1];
    get_string(1, filenameFormat, LOGGER_FILENAMEFORMAT_LENGTH);
    if (isStringEmpty(filenameFormat)) {
        tempLen = copy(filenameFormat, LOGGER_FILENAMEFORMAT_LENGTH, DEFAULT_FILENAME_FORMAT);
        filenameFormat[tempLen] = EOS;
    }

    new messageFormat[LOGGER_MESSAGEFORMAT_LENGTH+1];
    get_string(2, messageFormat, LOGGER_MESSAGEFORMAT_LENGTH);
    if (isStringEmpty(messageFormat)) {
        tempLen = copy(messageFormat, LOGGER_MESSAGEFORMAT_LENGTH, DEFAULT_MESSAGE_FORMAT);
        messageFormat[tempLen] = EOS;
    }

    new timestampFormat[LOGGER_TIMESTAMPFORMAT_LENGTH+1];
    tempLen = get_string(3, timestampFormat, LOGGER_TIMESTAMPFORMAT_LENGTH);
    if (isStringEmpty(timestampFormat)) {
        tempLen = copy(timestampFormat, LOGGER_TIMESTAMPFORMAT_LENGTH, DEFAULT_TIMESTAMP_FORMAT);
        timestampFormat[tempLen] = EOS;
    }

    new datestampFormat[LOGGER_DATESTAMPFORMAT_LENGTH+1];
    tempLen = get_string(4, datestampFormat, LOGGER_DATESTAMPFORMAT_LENGTH);
    if (isStringEmpty(datestampFormat)) {
        tempLen = copy(datestampFormat, LOGGER_DATESTAMPFORMAT_LENGTH, DEFAULT_DATESTAMP_FORMAT);
        datestampFormat[tempLen] = EOS;
    }

    new severity = get_param(5);
    if (isInvalidLoggerSeverityParam("CreateLogger", severity)) {
        return Invalid_Logger;
    }

    new path[LOGGER_PATH_LENGTH+1];
    tempLen = get_localinfo("amxx_logdir", path, LOGGER_PATH_LENGTH);
    tempLen += get_string(6, path[tempLen], LOGGER_PATH_LENGTH-tempLen);

    new filename[LOGGER_FILENAME_LENGTH+1];
    get_plugin(
            .index = pluginId,
            .filename = filename,
            .len1 = LOGGER_FILENAME_LENGTH);
    tempLen = strlen(filename)-5;
    filename[tempLen] = EOS;

    return pushLogger(filenameFormat, messageFormat, timestampFormat, datestampFormat, severity, path, filename);
}

public bool:DestroyLogger(pluginId, numParams) {
    if (isInvalidNumberOfParams("DestroyLogger", numParams, 1)) {
        return false;
    }

    new Logger:logger = Logger:get_param_byref(1);
    if (isValidLogger(logger)) {
        clearLogger(logger);
        set_param_byref(1, any:Invalid_Logger);
        return true;
    }

    return false;
}

public LoggerGetMinSeverity(pluginId, numParams) {
    if (isInvalidNumberOfParams("LoggerGetMinSeverity", numParams, 1)) {
        return SEVERITY_INVALID;
    }

    new Logger:logger = Logger:get_param(1);
    if (logger != All_Loggers && isInvalidLoggerParam("LoggerGetMinSeverity", logger)) {
        return SEVERITY_INVALID;
    }

    return getLoggerSeverity(logger);
}

public LoggerSetMinSeverity(pluginId, numParams) {
    if (isInvalidNumberOfParams("LoggerSetMinSeverity", numParams, 2)) {
        return SEVERITY_INVALID;
    }

    new Logger:logger = Logger:get_param(1);
    new severity = get_param(2);
    if (logger != All_Loggers && isInvalidLoggerParam("LoggerSetMinSeverity", logger)) {
        return SEVERITY_INVALID;
    }
    
    if (isInvalidLoggerSeverityParam("LoggerSetMinSeverity", severity)) {
        return SEVERITY_INVALID;
    }

    return setLoggerSeverity(logger, severity);
}

logError(pluginId, numParams, offs) {
#pragma unused pluginId, numParams
    if (isInvalidNumberOfParamsMin("LoggerLogError", numParams, 2)) {
        return;
    }

    log(pluginId, numParams, offs, Logger:get_param(1), SEVERITY_ERROR);
}

logWarning(pluginId, numParams, offs) {
#pragma unused pluginId, numParams
    if (isInvalidNumberOfParamsMin("LoggerLogWarning", numParams, 2)) {
        return;
    }

    log(pluginId, numParams, offs, Logger:get_param(1), SEVERITY_WARNING);
}

logInfo(pluginId, numParams, offs) {
#pragma unused pluginId, numParams
    if (isInvalidNumberOfParamsMin("LoggerLogInfo", numParams, 2)) {
        return;
    }

    log(pluginId, numParams, offs, Logger:get_param(1), SEVERITY_INFO);
}

logDebug(pluginId, numParams, offs) {
#pragma unused pluginId, numParams
    if (isInvalidNumberOfParamsMin("LoggerLogDebug", numParams, 2)) {
        return;
    }

    log(pluginId, numParams, offs, Logger:get_param(1), SEVERITY_DEBUG);
}

log(pluginId, numParams, offs, Logger:logger, severity) {
#pragma unused pluginId, numParams
    //new Logger:logger = Logger:get_param(1);
    if (isInvalidLoggerParam("logError", logger)) {
        return;
    }

    new index = convertLoggerToArrayIndex(logger);
    //new severity = get_param(2);
    new loggerSeverity = ArrayGetCell(loggerSeverities, index);
    if (!isValidLoggerSeverity(severity)
            || !isValidLoggerSeverity(loggerSeverity)
            || severity <= loggerSeverity) {
        return;
    }

    /*filenameBufferLen = ArrayGetString(
            loggerFileNames,
            index,
            filenameBuffer,
            LOGGER_FILENAME_LENGTH);
    filenameBuffer[filenameBufferLen] = EOS;*/
    
    bufferLen = ArrayGetString(
            loggerTimestampFormats,
            index,
            buffer,
            BUFFER_LENGTH);
    buffer[bufferLen] = EOS;

    timestampBufferLen = get_time(
            buffer,
            timestampBuffer,
            LOGGER_TIMESTAMPFORMAT_LENGTH);
    timestampBuffer[timestampBufferLen] = EOS;
    
    bufferLen = ArrayGetString(
            loggerDatestampFormats,
            index,
            buffer,
            BUFFER_LENGTH);
    buffer[bufferLen] = EOS;

    datestampBufferLen = get_time(
            buffer,
            datestampBuffer,
            LOGGER_DATESTAMPFORMAT_LENGTH);
    datestampBuffer[datestampBufferLen] = EOS;
    
    new trace = dbg_trace_begin(), line;
    new filenameBuffer[LOGGER_FILENAME_LENGTH+1];
    new functionNameBuffer[LOGGER_FUNCTIONNAMEBUFFER_LENGTH+1];
    dbg_trace_info(
            trace,
            line,
            functionNameBuffer,
            LOGGER_FUNCTIONNAMEBUFFER_LENGTH,
            filenameBuffer,
            LOGGER_FILENAME_LENGTH);
    
    messageBufferLen = ArrayGetString(
            loggerMessageFormats,
            index,
            messageBuffer,
            LOGGER_MESSAGEFORMAT_LENGTH);
    messageBuffer[messageBufferLen] = EOS;

    bufferLen = vdformat(buffer, BUFFER_LENGTH, 2+offs, 3+offs);
    buffer[bufferLen] = EOS;

    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%filename", filenameBuffer);
    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%time", timestampBuffer);
    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%date", datestampBuffer);
    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%function", functionNameBuffer);
    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%severity", SEVERITY[severity]);
    replace_all(messageBuffer, LOGGER_MESSAGEBUFFER_LENGTH, "%message", buffer);

    new file = ArrayGetCell(
            loggerFilePointers,
            index);

    if (file == 0) {
        pathBufferLen = ArrayGetString(
            loggerFilePaths,
            index,
            pathBuffer,
            LOGGER_PATH_LENGTH);
        pathBuffer[pathBufferLen] = EOS;
        
        if (pathBuffer[pathBufferLen-1] != '/') {
            pathBuffer[pathBufferLen++] = '/';
        }

        pathBufferLen += ArrayGetString(
            loggerFilenameFormats,
            index,
            pathBuffer[pathBufferLen],
            LOGGER_PATH_LENGTH-pathBufferLen);
        pathBuffer[pathBufferLen] = EOS;

        replace_all(pathBuffer, LOGGER_PATH_LENGTH, "%filename", filenameBuffer);
        replace_all(pathBuffer, LOGGER_PATH_LENGTH, "%date", datestampBuffer);

        file = fopen(pathBuffer, "a");
    }

    fputs(file, messageBuffer);
    fflush(file);
}

public LoggerLogError(pluginId, numParams, offs) <>                 ;
public LoggerLogError(pluginId, numParams, offs) <severity_none>    ;
public LoggerLogError(pluginId, numParams, offs) <severity_error>   logError(pluginId, numParams, offs);
public LoggerLogError(pluginId, numParams, offs) <severity_warning> logError(pluginId, numParams, offs);
public LoggerLogError(pluginId, numParams, offs) <severity_info>    logError(pluginId, numParams, offs);
public LoggerLogError(pluginId, numParams, offs) <severity_debug>   logError(pluginId, numParams, offs);
public LoggerLogError(pluginId, numParams, offs) <severity_all>     logError(pluginId, numParams, offs);

public LoggerLogWarning(pluginId, numParams, offs) <>                 ;
public LoggerLogWarning(pluginId, numParams, offs) <severity_none>    ;
public LoggerLogWarning(pluginId, numParams, offs) <severity_error>   ;
public LoggerLogWarning(pluginId, numParams, offs) <severity_warning> logWarning(pluginId, numParams, offs);
public LoggerLogWarning(pluginId, numParams, offs) <severity_info>    logWarning(pluginId, numParams, offs);
public LoggerLogWarning(pluginId, numParams, offs) <severity_debug>   logWarning(pluginId, numParams, offs);
public LoggerLogWarning(pluginId, numParams, offs) <severity_all>     logWarning(pluginId, numParams, offs);

public LoggerLogInfo(pluginId, numParams, offs) <>                 ;
public LoggerLogInfo(pluginId, numParams, offs) <severity_none>    ;
public LoggerLogInfo(pluginId, numParams, offs) <severity_error>   ;
public LoggerLogInfo(pluginId, numParams, offs) <severity_warning> ;
public LoggerLogInfo(pluginId, numParams, offs) <severity_info>    logInfo(pluginId, numParams, offs);
public LoggerLogInfo(pluginId, numParams, offs) <severity_debug>   logInfo(pluginId, numParams, offs);
public LoggerLogInfo(pluginId, numParams, offs) <severity_all>     logInfo(pluginId, numParams, offs);

public LoggerLogDebug(pluginId, numParams, offs) <>                 ;
public LoggerLogDebug(pluginId, numParams, offs) <severity_none>    ;
public LoggerLogDebug(pluginId, numParams, offs) <severity_error>   ;
public LoggerLogDebug(pluginId, numParams, offs) <severity_warning> ;
public LoggerLogDebug(pluginId, numParams, offs) <severity_info>    ;
public LoggerLogDebug(pluginId, numParams, offs) <severity_debug>   logDebug(pluginId, numParams, offs);
public LoggerLogDebug(pluginId, numParams, offs) <severity_all>     logDebug(pluginId, numParams, offs);

public LoggerLog(pluginId, numParams) {
    if (isInvalidNumberOfParamsMin("LoggerLog", numParams, 3)) {
        return;
    }

    switch (get_param(2)) {
        case SEVERITY_ERROR:   LoggerLogError(pluginId, numParams, 1);
        case SEVERITY_WARNING: LoggerLogWarning(pluginId, numParams, 1);
        case SEVERITY_INFO:    LoggerLogInfo(pluginId, numParams, 1);
        case SEVERITY_DEBUG:   LoggerLogDebug(pluginId, numParams, 1);
    }
}