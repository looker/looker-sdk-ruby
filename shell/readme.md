# [Looker](http://looker.com/) SDK Ruby Shell

The Looker SDK Shell allows you to call and experiment with Looker SDK APIs
in a [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) interactive command-line environment.

### SDK Shell Setup
```bash
$ cd looker-sdk/shell
$ bundle install
```

### Running the Shell
```bash
$ ruby shell.rb
```
The Looker SDK Shell expects to find Looker API authentication credentials in
a .netrc file in the current directory. See the [Looker SDK readme](../readme.md) for details
on setting up your .netrc file.
