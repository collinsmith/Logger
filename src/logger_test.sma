#define VERSION_STRING "0.0.1"

#include <amxmodx>

#include "include/logger_const.inc"
#include "include/param_test_stocks.inc"

native Logger:CreateLogger(const name[] = NULL_STRING);
native bool:DestroyLogger(&Logger:logger);
native Log(Logger:logger, level, const format[], any:...);


public plugin_init() {
    new Logger:logger = CreateLogger();
    Log(logger, LEVEL_SEVERE, "This is a %s", "test");
    DestroyLogger(logger);
}