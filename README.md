
# Welcome to our Linux Port of _opentelemetry-swift_ #

This project is a fork of the _opentelemetry-swift_ (OTEL) reference implementation (which runs only on Apple operating
systems (MacOS, iOS, tvOS, et al.) that adds support for Linux distributions[^1]. The official _opentelemetry-swift_
project is restricted to Apple operating systems due to its dependency on several Apple-specific libraries; namely,
_os.log_ and _os.activity_. The latter is problematic for other platforms, in that it a) relies on Apple kernel support;
b) is poorly documented; and c) has no publicly available source code.

## Background ##

The reference implementation of _opentelemetry-swift_ employs Apple's _os.activity_ library to provide unique contexts
for each Span created, obviating the need to pass around unique identifiers among code modules. The result is a proper
collection of related spans that may be sent to various data collectors, and eventually data sources (eg. Tempo). To
affect the same behavior on Linux, this port employs Swift Tasks and TaskLocal variables. The _opentelemetry-swift_ API
has been extended using Swift constructs, which avoids breaking the reference document and API. Additionally, both the
SDK and API code has been refactored to abstract the underlying operating systems, allowing the library and its clients
to continue running within Apple environments, along with Linux.

Note: Once this port has been thoroughly exercised within PassiveLogic applications, a Gitlab Pull Request will be
submitted to the reference project's authors, with hopes that our solution will be accepted.

## Supported Linux Architectures ##

This port has been tested on both Ubuntu 20.04 LTS and 22.04 LTS; _arm64_ and _amd64_ processors, along with regression
tests on MacOS (arm64). Note that there is nothing Linux-distribution-specific about this port; thus, theoretically it
should run on any Linux version supporting Swift 5.8 or newer.

## Notable Changes ##

Apart from the refactoring effort, the central change for Linux occured with these OpenTelemetryApi source files:
- _OpenTelemetry.swift_: Refactored.
- _OpenTelemetryLinux.swift_: New file containing Linux-specific code.

For Linux, we have addressed the absence of _os.activity_ using Swift TaskLocal variables and its _withValue_
construct. All spans for every bound instance of the _activeSpan_ variable will be properly collected and related; each
separate task will have its own instance value of _activeSpan_.

To make our _optentelemetry-swift_ port simpler to use by developers, we created the
[Observability](https://gitlab.com/PassiveLogic/cloud/observability) library that provides a clean API for writing
tracing blocks, and hiding the implementation details.

## References ##

- The [opentelemetry-swift](https://github.com/open-telemetry/opentelemetry-swift) reference implementation.
- The PassiveLogic [Observability](https://gitlab.com/PassiveLogic/cloud/observability) library, a thin wrapper around
  _opentelemetry-swift_.

## Port Author ##

[David E. Young](bosshog@passivelogic.com)

[^1]: Development and testing has thus far been performed only on Ubuntu 20.04 LTS.
