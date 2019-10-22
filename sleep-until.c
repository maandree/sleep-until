/* See LICENSE file for copyright and license details. */
#include <sys/timerfd.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


int
main(int argc, char *argv[])
{
	char *argv0;
	char float_part[10];
	struct itimerspec value;
	struct itimerspec largest_value;
	int i, fd = -1, clocks = 0;
	uint64_t overrun;
	int clockid = CLOCK_REALTIME;
	const char *clockstr = "CLOCK_REALTIME";
	char *p1, *p2, excess;
	size_t len;

	argv0 = *argv++, argc--;
	if (*argv && **argv == '-') {
		if (argv[0][1] == '-' && !argv[0][2]) {
			argv++, argc--;
		} else {
			fprintf(stderr, "usage: %s [clock | timepoint] ...", argv0);
			return 1;
		}
	}

	if (!argc)
		return 0;

	memset(&value, 0, sizeof(value));
	float_part[9] = '\0';
	for (i = 0; i < argc; i++) {
		p1 = argv[i];

		if (strstr(p1, "CLOCK_") != p1)
			goto parse_time;
#define X(C)\
		else if (!strcmp(p1, #C))\
			clockid = C, clockstr = #C;
#include "clocks.h"
#undef X
		else
			clockid = -1, clockstr = "invalid";
		clocks++;
		continue;

	parse_time:
		if ((p2 = strchr(p1, '.')))
			*p2++ = '\0';

		value.it_value.tv_sec = (time_t)atoll(p1);

		if (p2) {
			len = strlen(p2);
			memset(float_part, '0', 9 * sizeof(char));
			excess = len > 9 ? p2[9] : '0';
			len = len > 9 ? 9 : len;
			memcpy(float_part + 9 - len, p2, len * sizeof(char));
			value.it_value.tv_nsec = atol(float_part);
			if ((excess >= '5') && (value.it_value.tv_nsec++ == 999999999L))
				value.it_value.tv_nsec = 0, value.it_value.tv_sec++;
		}

		if (i == clocks)
			largest_value = value;
		else if (value.it_value.tv_sec > largest_value.it_value.tv_sec)
			largest_value = value;
		else if (value.it_value.tv_sec == largest_value.it_value.tv_sec)
			if (value.it_value.tv_nsec > largest_value.it_value.tv_nsec)
				largest_value = value;
	}

	if (clocks == argc)
		return 0;

	fd = timerfd_create(clockid, 0);
	if (fd < 0)
		goto fail;
	if (timerfd_settime(fd, TFD_TIMER_ABSTIME, &largest_value, NULL))
		goto fail;

	if (clock_gettime(clockid, &(value.it_value)) == 0)
		fprintf(stderr, "%s: sleeping until %lli.%09li (current time: %lli.%09li, clock: %s)\n",
		        argv0, (long long int)(largest_value.it_value.tv_sec), largest_value.it_value.tv_nsec,
		        (long long int)(value.it_value.tv_sec), value.it_value.tv_nsec, clockstr);
  
	for (;;) {
		if (clock_gettime(clockid, &(value.it_value)))
			goto fail;
		if (value.it_value.tv_sec > largest_value.it_value.tv_sec)
			break;
		if (value.it_value.tv_sec == largest_value.it_value.tv_sec)
			if (value.it_value.tv_nsec >= largest_value.it_value.tv_nsec)
				break;
		if (read(fd, &overrun, (size_t)8) < 8) {
			if (errno == EINTR)
				continue;
			goto fail;
		}
	}

	close(fd);
	return 0;

fail:
	perror(argv0);
	if (fd >= 0)
		close(fd);
	return 1;
}
