
/*
 * This is a needless library used to deceive Swift into allowing us to use getcontext() in
 * its basic, "returns once" form. This code is required just on Linux
 */

#include "libpl.h"

int
activity_create(ucontext_t *ucp) {
  return getcontext(ucp);
}
