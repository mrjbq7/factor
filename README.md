Factor
======

The Factor programming language

Getting started
---------------

If you are reading this README file, you either downloaded a binary
package, or checked out Factor sources from the GIT repository.

* [Learning Factor](http://concatenative.org/wiki/view/Factor/Learning)
* [System requirements](http://concatenative.org/wiki/view/Factor/Requirements)
* [Building Factor from source](http://concatenative.org/wiki/view/Factor/Building%20Factor) (don't do this if you're using a binary package)

To run Factor:

* Windows: Double-click `factor.exe`, or run `.\factor.com` in a command prompt
* Mac OS X: Double-click `Factor.app` or run `open Factor.app` in a Terminal
* Unix: Run `./factor` in a shell

Documentation
-------------

The Factor environment includes extensive reference documentation and a
short "cookbook" to help you get started. The best way to read the
documentation is in the UI; press F1 in the UI listener to open the help
browser tool. You can also [browse the documentation
online](http://docs.factorcode.org).

Command line usage
------------------

Factor supports a number of command line switches. To read command line
usage documentation, enter the following in the UI listener:

    "command-line" about

Source organization
-------------------

The Factor source tree is organized as follows:

* `build-support/` - scripts used for compiling Factor (not present in binary packages)
* `vm/` - Factor VM source code (not present in binary packages)
* `core/` - Factor core library
* `basis/` - Factor basis library, compiler, tools
* `extra/` - more libraries and applications
* `misc/` - editor modes, icons, etc
* `unmaintained/` - unmaintained contributions, please help!

Community
---------

Factor developers meet in the `#concatenative` channel on
[irc.freenode.net](http://freenode.net). Drop by if you want to discuss
anything related to Factor or language design in general.

* [Factor homepage](http://factorcode.org)
* [Concatenative languages wiki](http://concatenative.org)

Have fun!
