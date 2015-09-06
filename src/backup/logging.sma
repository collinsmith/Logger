#define VERSION_STRING "0.0.1"

#define BUFFER_LENGTH 1023
#define TIME_LENGTH 15

#include <amxmodx>
#include <file>

/*
states:

log_nothing
log_severe
log_warning
log_info
log_debug
*/

static const LOG_DATE_FORMAT[] = "%Y-%m-%d";
static const LOG_TIME_FORMAT[] = "%H:%M:%S";
static const LOG_MESSAGE_FORMAT[] = "[%s] %-6s %s";

static buffer[BUFFER_LENGTH+1];

static Logger:logger;
static level:severity;
static file;
static time[TIME_LENGTH+1];

static Array:loggerSeverities;

public plugin_init() {
    new buildId[32];
    formatex(buildId, charsmax(buildId), "%s.%s", VERSION_STRING, __DATE__);
    register_plugin(.plugin_name = "Logging",
        .version = buildId,
        .author = "Tirant");
}

logseverity(pluginId, numParams) {
    logger = Logger:get_param(1);
    severity = ArrayGetCell(loggerSeverities, toArrayIndex(logger));
    if (severity >= SEVERITY_ERROR) {
    }

    get_time(LOG_TIME_FORMAT, time, TIME_LENGTH);
    vdformat(buffer, BUFFER_LENGTH, 2, 3);
    fprintf(file, LOG_MESSAGE_FORMAT, time, LEVEL[LEVEL_ERROR], buffer);
}

logWarning(pluginId, numParams) {
}

logInfo(pluginId, numParams) {
}

logDebug(pluginId, numParams) {
}

public _LoggerLogError(pluginId, numParams) <log_error>   logError(pluginId, numParams);
public _LoggerLogError(pluginId, numParams) <log_warning> logError(pluginId, numParams);
public _LoggerLogError(pluginId, numParams) <log_info>    logError(pluginId, numParams);
public _LoggerLogError(pluginId, numParams) <log_debug>   logError(pluginId, numParams);
public _LoggerLogError(pluginId, numParams) <>            ;

public _LoggerLogWarning(pluginId, numParams) <log_error>   ;
public _LoggerLogWarning(pluginId, numParams) <log_warning> logWarning(pluginId, numParams);
public _LoggerLogWarning(pluginId, numParams) <log_info>    logWarning(pluginId, numParams);
public _LoggerLogWarning(pluginId, numParams) <log_debug>   logWarning(pluginId, numParams);
public _LoggerLogWarning(pluginId, numParams) <>            ;

public _LoggerLogInfo(pluginId, numParams) <log_error>   ;
public _LoggerLogInfo(pluginId, numParams) <log_warning> ;
public _LoggerLogInfo(pluginId, numParams) <log_info>    logInfo(pluginId, numParams);
public _LoggerLogInfo(pluginId, numParams) <log_debug>   logInfo(pluginId, numParams);
public _LoggerLogInfo(pluginId, numParams) <>            ;

public _LoggerLogDebug(pluginId, numParams) <log_error>   ;
public _LoggerLogDebug(pluginId, numParams) <log_warning> ;
public _LoggerLogDebug(pluginId, numParams) <log_info>    ;
public _LoggerLogDebug(pluginId, numParams) <log_debug>   logDebug(pluginId, numParams);
public _LoggerLogDebug(pluginId, numParams) <>            ;

logError2(pluginId, numParams) {
    vdformat(buffer, len, 1, 2);
}

logWarning2(pluginId, numParams) {
}

logInfo2(pluginId, numParams) {
}

logDebug2(pluginId, numParams) {
}

public _LoggerLog(pluginId, numParams) {
    switch (get_param(1)) {
        case SEVERITY_ERROR:   logError2(pluginId, numParams);
        case SEVERITY_WARNING: logWarning2(pluginId, numParams);
        case SEVERITY_INFO:    logInfo2(pluginId, numParams);
        case SEVERITY_DEBUG:   logDebug2(pluginId, numParams);
        default: log_error(AMX_ERR_NATIVE, "Invalid log level specified: %d", get_param(1));
    }
}

public _LoggerSetMinSeverity(pluginId, numParams) {
    switch (get_param(1)) {
        case SEVERITY_ERROR:   state severity_error;
        case SEVERITY_WARNING: state severity_warning;
        case SEVERITY_INFO:    state severity_info;
        case SEVERITY_DEBUG:   state severity_debug;
        default: log_error(AMX_ERR_NATIVE, "Invalid log level specified: %d", get_param(1));
    }
}

public Logger:CreateLogger(pluginId, numParams) {
    
}

public DestroyLogger(pluginId, numParams) {
    
}