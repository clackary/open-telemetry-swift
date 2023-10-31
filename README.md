
# Welcome to the opentelemetry-swift for Linux Project #

This project is a fork of the _opentelementry-swift_ (OTEL) reference implmentation that runs only on Apple operating
systems (MacOS, iOS, watchOS, et al.)[^1]. For Linux, this port relies on a small C library that offers support for some
of the basic features of Apple's _os.activity_ library, upon which the reference Swift library relies heavily.

This port has been tested on both Ubuntu 20.04 LTS and 22.04 LTS; ARM64 and AMD64 architectures. In general,
_opentelemetry-swift-linux_ runs well, and seems to generate proper trace/span data for straightforward cases. What has
not been tested, and what will unlikely work, are complicated nestings of spans. What does "complicated" mean here? I've
no idea. Since there is no Linux analog to _os.activity_, I had to make an engineering guess as to what Linux currently
has that might provide OTEL what it needs. That code lives in the Libpl project, and is provided as a C library made
available in Debian packages.

## Future Work ##

I would like to locate and/or develop a robust replacement for the _os.activity_ capabilities, insofar as is necessary
for _opentelemetry-swift_ to run reliably on Linux. This will take quite a bit of research, possibly even exposing Linux
kernel capabilities not presently available. We shall see.

## Reference Implementation ##

For extensive documentation on the OTEL reference implementation for Swift, go [here](https://github.com/open-telemetry/opentelemetry-swift).

## References ##

- The [Libpl](https://github.com/youngde811/libpl) project.
- The [CLibpl](https://github.com/youngde811/CLibpl) project, which provides the ability to include the _libpl_ C
  library in Swift projects.

## Original Authors ##

The development team for [_opentelemetry-swift_](https://github.com/open-telemetry/opentelemetry-swift).

## Port Author ##

[David E. Young](youngde811@pobox.com)

[^1]: watchOS? Seriously?
