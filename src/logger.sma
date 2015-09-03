#define VERSION_STRING "0.0.1"

#define INITIAL_LOGGER_SIZE 4

#define LOGGER_FILE_LENGTH 63

#include <amxmodx>

#include "include/logger_const.inc"
#include "include/param_test_stocks.inc"

#define BUFFER_LENGTH 1023
static buffer[BUFFER_LENGTH+1];
static filename[LOGGER_FILE_LENGTH+1];
static Logger:currentLogger = Invalid_Logger;

static numLoggers = 0;
static Array:loggerFiles = Invalid_Array;
static Array:loggerLevels = Invalid_Array;

public plugin_natives() {
    register_library("logger");

    register_native("SetLogging", "_SetLogging", 0);
    register_native("IsLoggingEnabled", "_IsLoggingEnabled", 0);

    register_native("CreateLogger", "_CreateLogger", 0);
    register_native("DestroyLogger", "_DestroyLogger", 0);

    register_native("LoggerSetLevel", "_LoggerSetLevel", 0);
    register_native("LoggerGetLevel", "_LoggerGetLevel", 0);
    register_native("LoggerGetFile", "_LoggerGetFile", 0);

    register_native("Log", "_Log", 0);

    state logging;
}

isValidLogger(Logger:logger) {
    return Invalid_Logger < logger
            && any:logger <= numLoggers
            && ArrayGetCell(loggerLevels, convertLoggerToIndex(logger)) != LEVEL_INVALID;
}

bool:isInvalidLoggerParam(const function[], Logger:logger) {
    if (isValidLogger(logger)) {
        return false;
    }

    log_error(
            AMX_ERR_NATIVE,
            "[%s] Invalid logger specified: %d",
            function,
            logger);
    return true;
}

isValidLoggerLevel(level) {
    return LEVEL_NONE <= level && level <= LEVEL_ALL;
}

bool:isInvalidLoggerLevelParam(const function[], level) {
    if (isValidLoggerLevel(level)) {
        return false;
    }

    log_error(
            AMX_ERR_NATIVE,
            "[%s] Invalid logger level specified: %d. \
                  Log levels should be between %d and %d (inclusive)",
            function,
            level,
            LEVEL_NONE,
            LEVEL_ALL);
    return true;
}

convertLoggerToIndex(Logger:logger) {
    assert isValidLogger(logger);
    return any:logger-1;
}

getLoggerLevel(Logger:logger) {
    assert isValidLogger(logger);
    new loggerIndex = convertLoggerToIndex(logger);
    return ArrayGetCell(loggerLevels, loggerIndex);
}

setLoggerLevel(Logger:logger, level) {
    assert isValidLogger(logger);
    assert isValidLoggerLevel(level);
    new oldLoggerLevel = getLoggerLevel(logger);
    new loggerIndex = convertLoggerToIndex(logger);
    ArraySetCell(loggerLevels, loggerIndex, level);
    return oldLoggerLevel;
}

public bool:_SetLogging(pluginId, numParams) <not_logging> {
    if (isInvalidNumberOfParams("_SetLogging", numParams, 1)) {
        return false;
    }

    new bool:logging = bool:get_param(1);
    if (logging) {
        state logging;
    }

    return false;
}

public bool:_SetLogging(pluginId, numParams) <logging> {
    if (isInvalidNumberOfParams("_SetLogging", numParams, 1)) {
        return true;
    }

    new bool:logging = bool:get_param(1);
    if (!logging) {
        state not_logging;
    }

    return true;
}

public bool:_IsLoggingEnabled(pluginId, numParams) <not_logging> {
    if (isInvalidNumberOfParams("_IsLoggingEnabled", numParams, 0)) {
        return false;
    }

    return false;
}

public bool:_IsLoggingEnabled(pluginId, numParams) <logging> {
    if (isInvalidNumberOfParams("_IsLoggingEnabled", numParams, 0)) {
        return true;
    }

    return true;
}

public Logger:_CreateLogger(pluginId, numParams) {
    if (isInvalidNumberOfParams("_CreateLogger", numParams, 1)) {
        return Invalid_Logger;
    }

    new szTime[16];
    get_time("%Y-%m-%d", szTime, charsmax(szTime));

    new filename[32], len1;
    len1 = get_string(1, filename, 31);
    if (len1 > 0) {
        filename[len1] = EOS;
    } else {
        get_plugin(.index = pluginId, .filename = filename, .len1 = 31);
        filename[strlen(filename)-5] = EOS;
    }

    new loggerFile[LOGGER_FILE_LENGTH+1];
    formatex(loggerFile, LOGGER_FILE_LENGTH, "%s_%s.log", filename, szTime);
    
    if (loggerFiles == Invalid_Array) {
        loggerFiles = ArrayCreate(LOGGER_FILE_LENGTH+1, INITIAL_LOGGER_SIZE);
    }
    
    if (loggerLevels == Invalid_Array) {
        loggerLevels = ArrayCreate(1, INITIAL_LOGGER_SIZE);
    }

    new Logger:logger = Logger:(ArrayPushString(loggerFiles, loggerFile)+1);
    ArrayPushCell(loggerLevels, LEVEL_WARNING);
    currentLogger = logger;
    numLoggers++;
    return logger;
}

public bool:_DestroyLogger(pluginId, numParams) {
    if (isInvalidNumberOfParams("_DestroyLogger", numParams, 1)) {
        return false;
    }

    new Logger:logger = Logger:get_param_byref(1);
    if (isValidLogger(logger)) {
        new loggerIndex = convertLoggerToIndex(logger);
        ArraySetString(loggerFiles, loggerIndex, "<DELETED>");
        ArraySetCell(loggerLevels, loggerIndex, LEVEL_INVALID);
        set_param_byref(1, any:Invalid_Logger);
        return true;
    }

    return false;
}

public _LoggerSetLevel(pluginId, numParams) {
    if (isInvalidNumberOfParams("_LoggerSetLevel", numParams, 2)) {
        return LEVEL_INVALID;
    }

    new Logger:logger = Logger:get_param(1);
    if (isInvalidLoggerParam("_LoggerSetLevel", logger)) {
        return LEVEL_INVALID;
    }

    new level = get_param(2);
    if (isInvalidLoggerLevelParam("_LoggerSetLevel", level)) {
        return LEVEL_INVALID;
    }

    return setLoggerLevel(logger, level);
}

public _LoggerGetLevel(pluginId, numParams) {
    if (isInvalidNumberOfParams("_LoggerGetLevel", numParams, 1)) {
        return LEVEL_INVALID;
    }

    new Logger:logger = Logger:get_param(1);
    if (isInvalidLoggerParam("_LoggerGetLevel", logger)) {
        return LEVEL_INVALID;
    }

    return getLoggerLevel(logger);
}

public _LoggerGetFile(pluginId, numParams) {
    if (isInvalidNumberOfParams("_LoggerGetFile", numParams, 3)) {
        return -1;
    }

    new Logger:logger = Logger:get_param(1);
    if (isInvalidLoggerParam("_LoggerGetFile", logger)) {
        return -1;
    }

    new loggerIndex = convertLoggerToIndex(logger);
    new filenameLen = ArrayGetString(loggerFiles, loggerIndex, filename, LOGGER_FILE_LENGTH);
    filename[filenameLen] = EOS;
    currentLogger = logger;
    return set_string(2, filename, get_param(3));
}

public _Log(pluginId, numParams) <> {
}

public _Log(pluginId, numParams) <logging> {
    if (isInvalidNumberOfParamsMin("_Log", numParams, 3)) {
        return;
    }

    new Logger:logger = Logger:get_param(1);
    if (isInvalidLoggerParam("_Log", logger)) {
        return;
    }

    new loggerIndex = convertLoggerToIndex(logger);

    new level = get_param(2);
    if (level < 0 || ArrayGetCell(loggerLevels, loggerIndex) < level) {
       return;
    }

    new bufferLen = formatex(buffer, BUFFER_LENGTH, "[%s] ", LEVEL[level]);
    bufferLen += vdformat(buffer[bufferLen], BUFFER_LENGTH, 3, 4);
    buffer[bufferLen] = EOS;

    if (currentLogger != logger) {
        new filenameLen = ArrayGetString(loggerFiles, loggerIndex, filename, LOGGER_FILE_LENGTH);
        filename[filenameLen] = EOS;
        currentLogger = logger;
    }

    log_to_file(filename, buffer);
}