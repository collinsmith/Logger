#if defined _path_stocks_included
    #endinput
#endif
#define _path_stocks_included

stock const PATH_SEPARATOR = '/';

stock path_get(dst[], len, const first[], ...) {
    new tempLen = copy(dst, len, first);
    new ch = dst[tempLen-1];

    new numArgs = numargs();
    for (new i = 4; i < numArgs; i++) {
        if (ch != PATH_SEPARATOR) {
            if (len <= tempLen) {
                return tempLen;
            }

            dst[tempLen++] = PATH_SEPARATOR;
        }

        for (new j = 0, ch = getarg(i, j); ch != EOS; ch = getarg(i, ++j)) {
            if (len <= tempLen) {
                return tempLen;
            }

            dst[tempLen++] = ch;
        }
    }
}