PREFIX = /usr
MANPREFIX = $(PREFIX)/share/man

CC = c99

CPPFLAGS = -D_POSIX_C_SOURCE=199309L
CFLAGS   =
LDFLAGS  = -s

CLOCK_HEADER_FILE != \
	if test -r /usr/include/bits/time.h; then \
		printf '%s\n' /usr/include/bits/time.h; \
	else \
		printf '%s\n' /usr/include/linux/time.h; \
	fi
