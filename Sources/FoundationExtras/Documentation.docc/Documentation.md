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

- ``Storage``

### Coding

- ``Coder``
- ``TypedCoder``

### Mapping

- ``From``
- ``TryFrom``
