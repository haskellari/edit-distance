# Edit Distance Algorithms

[![Build Status](https://travis-ci.org/phadej/edit-distance.svg?branch=master)](https://travis-ci.org/phadej/edit-distance)
[![Hackage](https://img.shields.io/hackage/v/edit-distance.svg)](http://hackage.haskell.org/package/edit-distance)

## Installing

To just install the library:

```
cabal configure
cabal build
cabal install
```

## Description

Edit distances algorithms for fuzzy matching. Specifically, this library provides:

* [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)
* [Restricted Damerau-Levenshtein distance":http://en.wikipedia.org/wiki/Damerau-Levenshtein_distance)

They have been fairly heavily optimized. Indeed, for situations where one of
the strings is under 64 characters long we use a rather neat "bit vector"
algorithm: see [the authors paper](http://www.cs.uta.fi/~helmu/pubs/psc02.pdf)
and [the associated errata](http://www.cs.uta.fi/~helmu/pubs/PSCerr.html) for
more information. The algorithms _could_ be faster, but they aren't yet slow
enough to force us into improving the situation.

## Example

```hs
Text.EditDistance> levenshteinDistance defaultEditCosts "witch" "kitsch"
2
```


## Links

- [Hackage](http://hackage.haskell.org/package/edit-distance)
- [GitHub](http://github.com/phadej/edit-distance)
- [Original gitHub](http://github.com/batterseapower/edit-distance)
