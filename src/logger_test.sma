#define VERSION_STRING "0.0.1"

#include <amxmodx>

#include "include/logger.inc"
#include "include/param_test_stocks.inc"

public plugin_init() {
    new Logger:logger = CreateLogger();
    Log(logger, LEVEL_SEVERE, "This is a %s", "test");
    DestroyLogger(logger);
}