#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/resource.h>
#include "../common.h"

int main(void) {
	char *buf = malloc(3);
	char *sgflt = buf + (10000000 * sizeof(char));
	struct rlimit rlim, rlim_old;
	rlim.rlim_cur = rlim.rlim_max = (rlim_t) 0;
	if (prlimit(0, RLIMIT_CORE, &rlim, &rlim_old) == -1)
		FATAL("prlimit:cpu failed\n");
	memcpy(sgflt, buf, 3);
}
