.POSIX:

CONFIGFILE = config.mk
include $(CONFIGFILE)

all: base shell
base: sleep-until
shell: bash zsh fish
bash: sleep-until.bash
zsh: sleep-until.zsh
fish: sleep-until.fish

clocks.h:
	sed -n 's/^[ \t]*#[ \t]*define[ \t][ \t]*\(CLOCK_[^ \t]*\).*$$/X(\1)/p' < /usr/include/bits/time.h > $@

sleep-until.o: sleep-until.c clocks.h
	$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

sleep-until: sleep-until.o
	$(CC) -o $@ sleep-until.o $(LDFLAGS)

sleep-until.bash: completion
	auto-auto-complete bash --output $@ --source $<

sleep-until.zsh: completion
	auto-auto-complete zsh --output $@ --source $<

sleep-until.fish: completion
	auto-auto-complete fish --output $@ --source $<

install: install-base install-shell
install-shell: install-bash install-zsh install-fish

install-base: sleep-until
	mkdir -p -- "$(DESTDIR)$(PREFIX)/bin"
	mkdir -p -- "$(DESTDIR)$(MANPREFIX)/man1"
	cp -- sleep-until "$(DESTDIR)$(PREFIX)/bin"
	cp -- sleep-until.1 "$(DESTDIR)$(MANPREFIX)/man1"

install-bash: sleep-until.bash
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/bash-completion/completions"
	cp -- sleep-until.bash "$(DESTDIR)$(PREFIX)/share/bash-completion/completions/sleep-until"

install-zsh: sleep-until.zsh
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/zsh/site-functions"
	cp -- sleep-until.zsh "$(DESTDIR)$(PREFIX)/share/zsh/site-functions/_sleep-until"

install-fish: sleep-until.fish
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/fish/completions"
	cp -- sleep-until.fish "$(DESTDIR)$(PREFIX)/share/fish/completions/sleep-until.fish"

uninstall:
	-rm -f -- "$(DESTDIR)$(BINDIR)/sleep-until"
	-rm -f -- "$(DESTDIR)$(MANPREFIX)/man1/sleep-until.1"
	-rm -f -- "$(DESTDIR)$(PREFIX)/share/fish/completions/sleep-until.fish"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/fish/completions"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/fish"
	-rm -f -- "$(DESTDIR)$(PREFIX)/share/zsh/site-functions/_sleep-until"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/zsh/site-functions"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/zsh"
	-rm -f -- "$(DESTDIR)$(PREFIX)/share/bash-completion/completions/sleep-until"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/bash-completion/completions"
	-rmdir -- "$(DESTDIR)$(PREFIX)/share/bash-completion"

clean:
	-rm -f -- sleep-until *.o clocks.h *.bash *.zsh *.fish

.PHONY: all base shell bash zsh fish install install-base install-shell install-base install-zsh install-fish uninstall clean
