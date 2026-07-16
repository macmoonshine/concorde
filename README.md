# Concorde XCFramework

A build wrapper that compiles the [Concorde TSP Solver](https://www.math.uwaterloo.ca/tsp/concorde.html) and [QSopt](https://www.math.uwaterloo.ca/~bico/qsopt/) linear programming solver into a single Apple XCFramework (`Concorde.xcframework`) for use in Swift projects via Swift Package Manager's binary target.

## About

[Concorde](https://www.math.uwaterloo.ca/tsp/concorde.html) is a computer code for the symmetric traveling salesman problem (TSP) and some related network optimization problems. The code is written in the ANSI C programming language and contains over 700 callable functions. Concorde's TSP solver has been used to obtain the optimal solutions to all 110 of the TSPLIB instances, the largest having 85,900 cities.

[QSopt](https://www.math.uwaterloo.ca/~bico/qsopt/) is a linear programming solver that provides a callable function library for use within applications such as the traveling salesman problem or mixed-integer programming. Concorde uses QSopt as its LP solving backend.

## Licensing

- **Concorde** is available for **academic research use**. For other uses, contact [William Cook](mailto:bico@uwaterloo.ca?subject=Concorde) for licensing options.
- **QSopt** usage is subject to the terms provided by its authors. See the [QSopt page](https://www.math.uwaterloo.ca/~bico/qsopt/) for details.

See the [Concorde licensing page](https://www.math.uwaterloo.ca/tsp/concorde.html) and [QSopt page](https://www.math.uwaterloo.ca/~bico/qsopt/) for full license conditions.

## Usage

### Swift Package Manager

Add the binary target to your `Package.swift`:

```swift
.binaryTarget(
    name: "Concorde",
    url: "https://github.com/macmoonshine/concorde/releases/download/v0.9.0/Concorde.xcframework.zip",
    checksum: "..."
)
```

Replace the checksum value with the contents of [`Concorde.xcframework.cksum`](https://github.com/macmoonshine/concorde/releases/download/v0.9.0/Concorde.xcframework.cksum) from the corresponding release.

Then import in your Swift code:

```swift
import Concorde
```

## Building from Source

Requires `make` and a C compiler.

```bash
make all
```

This will:

1. Download the Concorde source code (`co031219.tgz`) and QSopt precompiled binaries.
2. Compile Concorde with QSopt into a single static library (`libconcorde_complete.a`).
3. Package the result as `Concorde.xcframework`.

## Acknowledgments

- David Applegate, Robert Bixby, Vasek Chvatal, and William Cook — authors of Concorde.
- David Applegate, William Cook, Sanjeeb Dash, and Monika Mevenkamp — authors of QSopt.
- Research supported by Office of Naval Research Grant N00014-03-1-0040 and National Science Foundation Grant CMMI-0726370.

## License

This packaging project is licensed under the [Apache License, Version 2.0](LICENSE).
