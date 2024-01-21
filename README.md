
# Welcome to our Linux Port of _open-telemetry-swift_ #

This project is a fork of the _open-telemetry-swift_ (OTEL) reference implementation, which runs only on Apple operating
systems (MacOS, iOS, tvOS, et al.). This port adds support for Linux distributions[^1]. The official _open-telemetry-swift_
project is restricted to Apple operating systems due to its dependency on several Apple-specific libraries; namely,
_os.log_ and _os.activity_. The latter is problematic for other platforms, in that it a) relies on Apple kernel support;
b) is poorly documented; and c) has no publicly available source code. However, the original OTEL project has an open
feature issue for Linux support, and it is our intention to submit a PR once we have confirmed this work's stability.

## Background ##

The reference implementation of _open-telemetry-swift_ employs Apple's _os.activity_ library to provide unique contexts
for each Span created, obviating the need to pass around unique identifiers among code modules. The result is a proper
collection of related spans that may be sent to various data collectors, and eventually data sources (eg. Tempo).

Unfortunately, the _os.activity_ library was intended for use by Apple developers when debugging code via logging; it is
considered beta software and not intended for other applications. Regardless, to affect similar behavior on Linux, this
port employs Swift's new structured concurrency model; notably Tasks and TaskLocal variables. The _open-telemetry-swift_
API has been adapted to use these Swift constructs internally, which avoids breaking the reference document and
the client-visible API. Additionally, both the SDK and API code have been refactored to abstract the underlying
operating systems, allowing the library and its clients to continue running within Apple environments, along with Linux.

Note: As mentioned above, once this port has been thoroughly exercised within PassiveLogic applications, a GitHub Pull
Request (PR) will be submitted to the reference project's authors, with hopes that our solution will be accepted.

## Supported Linux Architectures ##

This port has been tested on both Ubuntu 20.04 LTS and 22.04 LTS; _arm64_ and _amd64_ processors, along with regression
tests on MacOS (arm64). Note that there is nothing Linux-distribution-specific about this port; thus, theoretically it
should run on any Linux version supporting Swift 5.8 or newer.

## Notable Changes ##

Apart from the refactoring effort, the central changes for Linux occured with these OpenTelemetryApi source files:
- _OpenTelemetry.swift_: Refactored.
- _OpenTelemetryLinux.swift_: New file containing Linux-specific code.

In addition, a number of other source files were slightly modified to work with the new abstractions. Also, some modules
in _OpenTelemetrySdk_ were originally written using _os.log_, requiring conditional compilation for them as well.

For Linux, we have addressed the absence of _os.activity_ using Swift's structured concurrency model; in particular
TaskLocal variables and their _withValue_ construct. All spans for every bound instance of the _activeSpan_ variable
will be properly collected and related; each separate task will have its own instance value of _activeSpan_.

To make our _open-telemetry-swift_ port simpler to use by developers, we created the
[Observability](https://gitlab.com/PassiveLogic/cloud/observability) library that provides a clean API for writing
tracing blocks, and hiding the implementation details. See that repository's home page for documentation and usage
examples.

## Update on MacOS and Linux Work

Recently, we decided to integrate the behavior of _open-telemetry-swift_ on MacOS with its Linux implementation. In
other words, the code for both operating systems now employs structured concurrency. This eliminates all dependencies on
_os.activity_ and _os.log_ for those platforms. Other Apple-specific devices (tvOS, watchOS, etc.) are ignored. The code
specific to those things remain conditionally compiled in the _open-telemetry-swift_ source code.

## References ##

- The [opentelemetry-swift](https://github.com/open-telemetry/opentelemetry-swift) reference implementation.
- The PassiveLogic [Observability](https://gitlab.com/PassiveLogic/cloud/observability) library, a thin wrapper around
  _opentelemetry-swift_.

## Port Author ##

[David E. Young](bosshog@passivelogic.com)

[^1]: Development and testing has thus far been performed only on Ubuntu 20.04 LTS.
