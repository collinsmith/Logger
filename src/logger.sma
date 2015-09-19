#define VERSION_STRING "1.0.0"

#include <amxmodx>
#include <logger>

static g_MinVerbosityCvar;

public plugin_init() {
    register_plugin(
        .plugin_name = "Logger CVar Manager",
        .version = getBuildId(),
        .author = "Tirant");

    new defaultValue[32];
    num_to_str(any:DEFAULT_LOGGER_VERBOSITY, defaultValue, charsmax(defaultValue));

    g_MinVerbosityCvar = create_cvar(
        .name = "logger_min_verbosity",
        .string = defaultValue,
        .flags = FCVAR_NONE,
        .description = "Controls the minimum severity a message must have in \
                order to be logged across all loggers",
        .has_min = true,
        .min_val = float(any:Severity_None),
        .has_max = false);
    hook_cvar_change(g_MinVerbosityCvar, "onMinVerbosityCvarChanged");
}

getBuildId() {
    new buildId[32];
    formatex(buildId, charsmax(buildId), "%s.%s", VERSION_STRING, __DATE__);
    return buildId;
}

public onMinVerbosityCvarChanged(pcvar, const old_value[], const new_value[]) {
    assert pcvar == g_MinVerbosityCvar;
    LoggerSetVerbosity(All_Loggers, severity(str_to_num(new_value)));
}

