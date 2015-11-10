# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


# The package path prefix, if you want to install to another root, set DESTDIR to that root.
PREFIX = /usr
# The binary path excluding prefix.
BIN = /bin
# The resource path excluding prefix.
DATA = /share
# The binary path including prefix.
BINDIR = $(PREFIX)$(BIN)
# The resource path including prefix.
DATADIR = $(PREFIX)$(DATA)
# The generic documentation path including prefix
DOCDIR = $(DATADIR)/doc
# The info manual documentation path including prefix
INFODIR = $(DATADIR)/info
# The man page documentation path including prefix
MANDIR = $(DATADIR)/man
# The license base path including prefix.
LICENSEDIR = $(DATADIR)/licenses


# The name of the package as it should be installed.
PKGNAME = sleep-until
# The name of the command as it should be installed.
COMMAND = sleep-until


# The https://github.com/maandree/gpp command.
GPP = gpp


WARN = -Wall -Wextra -pedantic -Wdouble-promotion -Wformat=2 -Winit-self -Wmissing-include-dirs      \
       -Wtrampolines -Wmissing-prototypes -Wmissing-declarations -Wnested-externs                    \
       -Wno-variadic-macros -Wsync-nand -Wunsafe-loop-optimizations -Wcast-align                     \
       -Wdeclaration-after-statement -Wundef -Wbad-function-cast -Wwrite-strings -Wlogical-op        \
       -Wstrict-prototypes -Wold-style-definition -Wpacked -Wvector-operation-performance            \
       -Wunsuffixed-float-constants -Wsuggest-attribute=const -Wsuggest-attribute=noreturn           \
       -Wsuggest-attribute=format -Wnormalized=nfkc -Wshadow -Wredundant-decls -Winline -Wcast-qual  \
       -Wsign-conversion -Wstrict-overflow=5 -Wconversion -Wsuggest-attribute=pure -Wswitch-default  \
       -Wstrict-aliasing=1 -fstrict-overflow -Wfloat-equal -Wpadded -Waggregate-return               \
       -Wtraditional-conversion
STD = -std=c99
OPTIMISE = -O2
FLAGS = $(WARN) $(STD) $(OPTIMISE) -D_POSIX_C_SOURCE=199309L


# Build rules.

.PHONY: default
default: command info shell

.PHONY: all
all: command doc shell

# Build rules for the command.

.PHONY: command
command: bin/sleep-until

bin/sleep-until: obj/sleep-until.o
	@mkdir -p bin
	$(CC) $(FLAGS) -o $@ $^ $(LDFLAGS)

obj/sleep-until.o: obj/sleep-until.c
	$(CC) $(FLAGS) -c -o $@ $< $(CFLAGS) $(CPPFLAGS)

obj/sleep-until.c: src/sleep-until.c
	@mkdir -p obj
	$(GPP) -s '$$' -i $< -o $@

# Build rules for documentation.

.PHONY: doc
doc: info pdf dvi ps

.PHONY: info
info: bin/sleep-until.info
bin/%.info: doc/info/%.texinfo doc/info/fdl.texinfo
	@mkdir -p bin
	makeinfo $<
	mv $*.info $@

.PHONY: pdf
pdf: bin/sleep-until.pdf
bin/%.pdf: doc/info/%.texinfo doc/info/fdl.texinfo
	@mkdir -p obj/pdf bin
	cd obj/pdf ; yes X | texi2pdf ../../$< < /dev/null
	mv obj/pdf/$*.pdf $@

.PHONY: dvi
dvi: bin/sleep-until.dvi
bin/%.dvi: doc/info/%.texinfo doc/info/fdl.texinfo
	@mkdir -p obj/dvi bin
	cd obj/dvi ; yes X | $(TEXI2DVI) ../../$< < /dev/null
	mv obj/dvi/$*.dvi $@

.PHONY: ps
ps: bin/sleep-until.ps
bin/%.ps: doc/info/%.texinfo doc/info/fdl.texinfo
	@mkdir -p obj/ps bin
	cd obj/ps ; yes X | texi2pdf --ps ../../$< < /dev/null
	mv obj/ps/$*.ps $@

# Build rules for shell auto-completion.

.PHONY: shell
shell: bash zsh fish

.PHONY: bash
bash: bin/sleep-until.bash
bin/sleep-until.bash: src/completion
	@mkdir -p bin
	auto-auto-complete bash --output $@ --source $<

.PHONY: zsh
zsh: bin/sleep-until.zsh
bin/sleep-until.zsh: src/completion
	@mkdir -p bin
	auto-auto-complete zsh --output $@ --source $<

.PHONY: fish
fish: bin/sleep-until.fish
bin/sleep-until.fish: src/completion
	@mkdir -p bin
	auto-auto-complete fish --output $@ --source $<


# Install rules.

.PHONY: install
install: install-base install-info install-man install-shell

.PHONY: install
install-all: install-base install-doc install-shell

# Install base rules.

.PHONY: install-base
install-base: install-command install-copyright

.PHONY: install-command
install-command: bin/sleep-until
	install -dm755 -- "$(DESTDIR)$(BINDIR)"
	install -m755 $< -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"

.PHONY: install-copyright
install-copyright: install-copying install-license

.PHONY: install-copying
install-copying:
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 COPYING -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"

.PHONY: install-license
install-license:
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 LICENSE -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"

# Install documentation.

.PHONY: install-doc
install-doc: install-info install-pdf install-ps install-dvi install-man

.PHONY: install-info
install-info: bin/sleep-until.info
	install -dm755 -- "$(DESTDIR)$(INFODIR)"
	install -m644 $< -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"

.PHONY: install-pdf
install-pdf: bin/sleep-until.pdf
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 $< -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"

.PHONY: install-ps
install-ps: bin/sleep-until.ps
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 $< -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"

.PHONY: install-dvi
install-dvi: bin/sleep-until.dvi
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 $< -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"

.PHONY: install-man
install-man:
	install -dm755 -- "$(DESTDIR)$(MANDIR)/man1"
	install -m644 doc/man/sleep-until.1 -- "$(DESTDIR)$(MANDIR)/man1/$(COMMAND).1"

# Install shell auto-completion.

.PHONY: install-shell
install-shell: install-bash install-zsh install-fish

.PHONY: install-bash
install-bash: bin/sleep-until.bash
	install -dm755 -- "$(DESTDIR)$(DATADIR)/bash-completion/completions"
	install -m644 $< -- "$(DESTDIR)$(DATADIR)/bash-completion/completions/$(COMMAND)"

.PHONY: install-zsh
install-zsh: bin/sleep-until.zsh
	install -dm755 -- "$(DESTDIR)$(DATADIR)/zsh/site-functions"
	install -m644 $< -- "$(DESTDIR)$(DATADIR)/zsh/site-functions/_$(COMMAND)"

.PHONY: install-fish
install-fish: bin/sleep-until.fish
	install -dm755 -- "$(DESTDIR)$(DATADIR)/fish/completions"
	install -m644 $< -- "$(DESTDIR)$(DATADIR)/fish/completions/$(COMMAND).fish"


# Uninstall rules.

.PHONY: uninstall
uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rmdir -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	-rm -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"
	-rm -- "$(DESTDIR)$(MANDIR)/man1/$(COMMAND).1"
	-rm -- "$(DESTDIR)$(DATADIR)/fish/completions/$(COMMAND).fish"
	-rmdir -- "$(DESTDIR)$(DATADIR)/fish/completions"
	-rmdir -- "$(DESTDIR)$(DATADIR)/fish"
	-rm -- "$(DESTDIR)$(DATADIR)/zsh/site-functions/_$(COMMAND)"
	-rmdir -- "$(DESTDIR)$(DATADIR)/zsh/site-functions"
	-rmdir -- "$(DESTDIR)$(DATADIR)/zsh"
	-rm -- "$(DESTDIR)$(DATADIR)/bash-completion/completions/$(COMMAND)"
	-rmdir -- "$(DESTDIR)$(DATADIR)/bash-completion/completions"
	-rmdir -- "$(DESTDIR)$(DATADIR)/bash-completion"


# Clean rules.

.PHONY: clean
clean:
	-rm -rf obj bin

