
# This Makefile may be used to build our fork of opentelemetry-swift for Linux. You may also use it
# on MacOS if you prefer the approach over Xcode (I do).

PROJECT_NAME="opentelemetry-swift-Package"

uname := $(shell uname)

SWIFTC_FLAGS += --configuration debug -Xswiftc -g
SWIFT := swift

CC := gcc
CFLAGS := -ansi -pedantic -Wall -W -Werror -g -fPIC

SRCDIR := Sources/libpl
INCDIR := $(SRCDIR)/include
LIBDIR := ./lib

SRC :=  $(wildcard $(SRCDIR)/*.c)
OBJ := $(SRC:$(SRCDIR)/%.c=$(SRCDIR)/%.o)

LIBNAME := libpl.so
LDFLAGS :=  -L.
LDLIBS  :=  -l$(...)

.PHONY: build clean realclean reset etags ctags

$(info Building for: [${uname}])

$(LIBNAME): CFLAGS += -fPIC
$(LIBNAME): LDFLAGS += -shared
$(LIBNAME): $(OBJ)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(SRCDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -I $(INCDIR) -o $@ -c $<

$(LIBDIR):
	@mkdir -p $@

opentelemetry: SWIFTC_FLAGS+=--configuration debug -Xswiftc -g
opentelemetry:
	${SWIFT} build $(SWIFTC_FLAGS) $(SWIFT_FLAGS) -Xlinker -L$(LIBDIR)
