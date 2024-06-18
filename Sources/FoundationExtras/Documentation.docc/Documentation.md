# ``FoundationExtras``

Useful extensions to the Foundation framework.

## Overview

This library comes with a couple of tools that are often needed during app development on Apple's
platforms. It extends various existing types and also introduces new tools for:
    
- Caching
- Persistence
- Coding
- Mapping

## Topics

### Caching

The library comes with a ``Cache`` Protocol and two cache implementations ``MemoryCache`` and
``FileCache``. As the names suggest, `MemoryCache` is volatile and keeps its content in main
memory. `FileCache` stores its values into the temp directory. Both caches don't make any
guarantees about the lifetimes of their contained values.

- ``Cache``

### Persistence

A simple persistence layer is defined by the ``Storage`` protocol. It defines very basic operations
to store and retrieve data. The library comes with two conformances ``MemoryStorage`` and 
``FileStorage``. `MemoryStorage` stores its content into main memory wheres `FileStorage` writes
its content to disk. Therefore, anything stored into `MemoryStorage` will be lost after termination
of the executable. The `Storage` protocol enforces the implementations to be thread-safe, which
allows them to be shared accross boundaries of concurrent contexts.

- ``Storage``

### Coding

A ``Coder`` consolidates the concept of an Encoder and a Decoder into a single object. Conformances
of a coder can there perform both encoding and decoding operations, where the encoded type for both
operations is the same. The library also comes with the type-erasing wrapper ``AnyCoder`` to
abstract over the concrete coder type.

Just like `Coder` ``TypedCoder`` specifies a coder that enforces both the input and the output type
of the encode operation and vice versa for the decoding operation.

- ``Coder``
- ``TypedCoder``

### Mapping

To provide an umbrella for cohesive mapping operations, ``From`` and ``TryFrom`` act as two traits
for any kind of mapping.

- ``From``
- ``TryFrom``
