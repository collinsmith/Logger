#include <amxmodx>

#define PATH_BUFFER_LENGTH (PLATFORM_MAX_PATH-1)

static const KEY_LOGNAMEFORMAT[] = "logger_lognameFormat";
static const KEY_MESSAGEFORMAT[] = "logger_messageFormat";
static const KEY_DATESTAMPFORMAT[] = "logger_datestampFormat";
static const KEY_TIMESTAMPFORMAT[] = "logger_timestampFormat";

public plugin_init() {
    register_plugin(.plugin_name = "Logger",
        .version = getBuildId(),
        .author = "Tirant");
}

Trie:toTrie(any:any) {
    return Trie:any;
}

Logger:toLogger(any:any) {
    return Logger:any;
}

Logger:createLogger(
        const nameFormat[],
        const messageFormat[],
        const datestampFormat[],
        const timestampFormat[],
        const minSeverity,
        const path[]) {
    Trie:trie = TrieCreate();
    TrieSetString(trie, KEY_NAMEFORMAT, nameFormat);
    TrieSetString(trie, KEY_MESSAGEFORMAT, messageFormat);
    TrieSetString(trie, KEY_DATESTAMPFORMAT, datestampFormat);
    TrieSetString(trie, KEY_TIMESTAMPFORMAT, timestampFormat);
    TrieSetCell(trie, KEY_MINSEVERITY, minSeverity);
    TrieSetString(trie, KEY_PATH, path);

    new pathBuffer[PATH_BUFFER_LENGTH+1];
    new pathBufferLen = copy(pathBuffer, PATH_BUFFER_LENGTH, path);
    if (pathBuffer[pathBufferLen] != '/' && nameFormat[0] != '/') {
        pathBuffer[pathBufferLen++] = '/';
    }

    pathBufferLen += copy(pathBuffer, PATH_BUFFER_LENGTH-pathBufferLen, nameFormat);
    replace_all(pathBuffer, PATH_BUFFER_LENGTH, "", "");
    replace_all(pathBuffer, PATH_BUFFER_LENGTH, "", "");

    new file = fopen(pathBuffer, "a");
    TrieSetCell(trie, KEY_FILEPOINTER, file);

    return toTrie(trie);
}

destroyLogger(Logger:logger) {
    Trie:trie = toTrie(logger);
    new file = TrieGetCell(trie, KEY_FILEPOINTER);
    if (file != 0) {
        fclose(file);
    }

    TrieDestroy(trie);
}