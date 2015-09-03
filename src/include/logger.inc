#if defined _logger_included
    #endinput
#endif
#define _logger_included

#include "include/logger_const.inc"

/**
 * Enables logging across all Loggers.
 * 
 * @return The previous value of logging, i.e., {@code true} if logging was
 *         enabled, otherwise {@code false}.
 * 
 * @see #SetLogging(b);
 */
stock bool:EnableLogging() {
    return SetLogging(true);
}

/**
 * Disables logging across all Loggers.
 * 
 * @return The previous value of logging, i.e., {@code true} if logging was
 *         enabled, otherwise {@code false}.
 * 
 * @see #SetLogging(b);
 */
stock bool:DisableLogging() {
    return SetLogging(false);
}

/**
 * Enables or disables logging accross all Logger instances. This native
 * effectively changes the state of the plugin to ignore incoming {@link
 * #Log(logger,level,format[],any:...)} calls, thus nothing will be logged by
 * this module. This native does not effect the individual Logger levels of
 * each individual Logger.
 * 
 * @return The previous value of logging, i.e., {@code true} if logging was
 *         enabled, otherwise {@code false}.
 * 
 * @see #EnableLogging();
 * @see #DisableLogging();
 * @see #IsLoggingEnabled();
 */
native bool:SetLogging(bool:b);

/**
 * Returns whether or not logging is currently enabled by this module.
 * 
 * @return {@literal true} if Loggers are in a loggable state, otherwise
 *         {@literal false}
 * 
 * @see #SetLogging(b);
 */
native bool:IsLoggingEnabled();

/**
 * Creates a new Logger and returns a handle to it. Loggers can be removed from
 * memory using {@link #DestroyLogger(logger)}.
 * 
 * @param name Name of the the Logger, will be used when creating log files. If
 *                 {@param name} is equal to {@literal ""} then the plugin
 *                 filename of the plugin calling this native will be used.
 * 
 * @return A handle to the created Logger, or {@code Invalid_Logger} in the
 *         event that there is a problem creating the Logger.
 * 
 * @see #DestroyLogger(logger);
 */
native Logger:CreateLogger(const name[] = NULL_STRING);

/**
 * Destroys a Logger and sets the passed reference to {@code Invalid_Logger}.
 * This will not delete the log files created by the Logger, only remove cached
 * values from memory, preventing it from being used unless another handle has
 * been created using {@link #CreateLogger(name[])}.
 * 
 * @param logger Logger to destroy
 * 
 * @see #CreateLogger(name[]);
 */
native bool:DestroyLogger(&Logger:logger);

/**
 * Changes the current logging level of a specified Logger to the given value
 * and returns the previous logging level.
 * 
 * @param logger Logger to change the logging level for
 * @param level  Logging level to change Logger to. Messages which are attempted
 *                   to be logged must be less than this value. Valid values for
 *                   this parameter are {@code LEVEL_NONE}, {@code LEVEL_ALL},
 *                   {@code LEVEL_SEVERE}, {@code LEVEL_WARNING}, {@code
 *                   LEVEL_INFO} or {@code LEVEL_DEBUG}. For more details on
 *                   the kinds of messages these logging levels are meant for,
 *                   see the documentation within logger_const.inc
 * 
 * @return The previous logging level for the specified Logger, or {@code
 *         LEVEL_INVALID} if an error occured.
 * 
 * @error When an invalid Logger handle or logging level is passed.
 */
native LoggerSetLevel(Logger:logger, level);

/**
 * Retrieves the current logging level of a specified logger.
 * 
 * @param logger Logger to retrieve the logging level for
 * 
 * @return The current logging level of the specified Logger, or {@code
 *         LEVEL_INVALID} if an error occured.
 * 
 * @error When an invalid Logger handle or logging level is passed.
 */
native LoggerGetLevel(Logger:logger);

/**
 * Copies the current path to the file which the specified Logger is using to
 * log messages.
 * 
 * @param logger Logger to retrieve the log file path for
 * @param name   Array to copy the path into
 * @param len    Max number of bytes to copy
 * 
 * @return The total number of bytes copied or {@literal -1} if an error
 *         occurred
 * 
 * @error If an invalid Logger handle is passed
 */
native LoggerGetFile(Logger:logger, name[], len);

/**
 * Logs a level into the specified Loggers log file with the given level
 * (severity) if that level is less than or equal to the current logging level
 * of the Logger and logging is currently enabled.
 * 
 * @note This native will not return any meaningful value as to whether or not
 *       the passed message was actually logged. The reason for this is that
 *       the current server configuration either has logging disabled, or the
 *       severity of this message was not sufficiently noteworthy enough to be
 *       logged (i.e., severe enough).
 * 
 * @param logger Logger to send the log message to
 * @param level  Severity of this log message. Valid values for this parameter
 *                   are {@code LEVEL_NONE}, {@code LEVEL_ALL}, {@code
 *                   LEVEL_SEVERE}, {@code LEVEL_WARNING}, {@code LEVEL_INFO} or
 *                   {@code LEVEL_DEBUG}. For more details on the kinds of
 *                   messages these logging levels are meant for, see the
 *                   documentation within logger_const.inc
 * @param format Message format for the log message
 * 
 * @error If an invalid Logger handle is passed
 */
native Log(Logger:logger, level, const format[], any:...);