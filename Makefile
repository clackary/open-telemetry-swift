
# This Makefile may be used to build our fork of opentelemetry-swift for Linux. You may also use it
# on MacOS if you prefer the approach over Xcode (I do).

# The Linux port of opentelemetry-swift contains a bit of C, used to construct a small shared library
# that wraps the libc getcontext() function. This is required because Swift believes that in every use
# case, getcontext() will return twice (a la setjmp()/longjmp()), when in fact it returns just once (as
# would any normal function) the way we use it. So Swift prohibits the compilation of any code referencing
# the getcontext symbol.

# If this Makefile gets any more difficult to manage between MacOS and Linux, we should split it into two
# separate, OS-specific files.

uname := $(shell uname)

SWIFTC_FLAGS += --configuration debug -Xswiftc -g
SWIFT := swift

SRCDIR := Sources/libpl
INCDIR := $(SRCDIR)/include
LIBDIR := ./lib

CC := gcc
CFLAGS := -ansi -pedantic -Wall -Werror -g -I$(INCDIR) -fPIC

SRC := $(wildcard $(SRCDIR)/*.c)
OBJ := $(SRC:$(SRCDIR)/%.c=$(LIBDIR)/%.o)

LIBNAME := $(LIBDIR)/libpl.so
LDFLAGS := -L.
LDLIBS := -l$(...)

.PHONY: all clean ctags etags libpl realclean reset resolve update

$(info Building for: [${uname}])

ifeq ($(uname), Linux)
all: libpl opentelemetry
else
all: opentelemetry
endif

libpl: $(LIBDIR) $(LIBNAME)

$(LIBNAME): LDFLAGS += -shared
$(LIBNAME): $(OBJ)
	$(CC) $(LDFLAGS) $^ -o $@

$(LIBDIR):
	@mkdir -p $@
$(LIBDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

opentelemetry: SWIFTC_FLAGS+=--configuration debug -Xswiftc -g
opentelemetry:
	${SWIFT} build $(SWIFTC_FLAGS) $(SWIFT_FLAGS) -Xlinker -L$(LIBDIR)

update: resolve
	$(SWIFT) package update

resolve:
	$(SWIFT) package resolve

ctags:
	ctags -R --languages=swift .

etags:
	etags -R --languages=swift .

reset:
	$(SWIFT) package reset

clean:
	$(SWIFT) package clean
	@rm -rf lib

# NB: Be careful with the realclean target on MacOS, as it will affect your other local Swift project caching.

ifeq ($(uname), Darwin)
realclean: clean
	@rm -rf .build
	@rm -rf ~/Library/Caches/org.swift.swiftpm
	@rm -rf ~/Library/org.swift.swiftpm
else
realclean: clean
	@rm -rf .build
endif
