# cduce-sample
A Sample minimal project using the OCaml and CDuce compiler to build a small OCaml program using CDuce to validate some XML document against an XMLSchema.

## Environment set-up

The setup assumes a Unix machine (preferably Linux but MacOS or WSL should work
as well).

### Installing OCaml via OPAM

#### Install `opam`
Install [`opam`](https://opam.ocaml.org/) by downloading the binary from [the github release page](https://github.com/ocaml/opam/releases/tag/2.2.1).

Be sure that `opam` is *not* already installed by your distribution and, copy the binary as root to `/usr/bin` and
make it executable:
```shell
# chmod +x opam
```
The reason to choose `/usr/bin` over the traditional `/usr/local/bin` is that on recent releases of Ubuntu (24.04) the `apparmor` security module prevents `opam` sandboxing from working correctly by default, so an exception for the program `/usr/bin/opam` is shipped with Ubuntu, which will not activate for an `opam` program located elsewhere.

#### Install `ocaml`

As a regular user, do:
```shell
$ opam init
```
this will initialize `opam` for the user and create an initial switch containing the most recent version of the OCaml compiler (5.2.0). If some dependencies are missing (e.g. a C compiler), `opam` will ask to install the missing system dependencies (which require admin priviledge) or abort the installation so that the dependencies can be installed. This works best for popular Linux distribution such as Debian/Ubuntu or Fedora.

At the end `opam` asks whether it should update the `~/.profile` file to set-up the shell, answer `yes`.

Once the switch is installed, create a new switch for the `4.14.2` version of the compiler.

```shell
$ opam switch create 4.14.2
```

Once the switch is created, check that the current version of OCaml is indeed 4.14.2:
```shell
$ ocamlc --version
4.14.2
```
If `ocamlc` is not found, ensure that `~/.profile` is sourced
from the `~/.bashrc` file, or alterntively copy line:
```shell
test -r '/home/kim/.opam/opam-init/init.sh' && . '/home/kim/.opam/opam-init/init.sh' > /dev/null 2> /dev/null || true
```
to you `~/.bashrc` file (all the above should be on a single line). We can then install CDuce's dependencies:
```shell
$ opam install conf-libssl dune js_of_ocaml-compiler \
     js_of_ocaml-ppx markup menhir menhirLib ocaml \
     ocaml-compiler-libs ocaml-expat ocamlfind ocamlnet \
     ocurl odoc pxp sedlex zarith zarith_stubs_js
```
Again, if a C dependency, for instance `libssl`, is needed, opam will give the option to install it or to pause the installation of opam packages to install this dependency (this requires administration privilege, opam appropriately calls `sudo` to install the C dependencies via the distribution).

### Installing CDuce

The easiest way ton install CDuce is by cloning the `git` repository, switching to the branch to test, and compile it using opam. We use the `dev` since it contains the polymorphic version of CDuce and better bindings with OCaml.

```shell
$ git clone https://gitlab.math.univ-paris-diderot.fr/cduce/cduce.git
$ cd cduce
$ git checkout dev
```

(recall that the current opam switch should be `4.14.2`).

Once this is done, one can install CDuce in the current switch. From the top of the `cduce` directory:
```shell
$ opam pin .
```
Answer yes to all questions. After compilation and installation, the CDuce compiler and tools as well as the libraries are available in the 4.14.2 switch, namely in
`~/.opam/4.14.2/bin`, which is automatically added to `$PATH`
```shell
$ cduce --version
CDuce, version poly-devel-306-g06d5323
Using OCaml 4.14.2 compiler
Supported features:
- netclient: Load external URLs with netclient
- pxp: PXP XML parser
- netstring: Load HTML document with netstring
- system: System calls
- curl: Load external URLs with curl
- expat: Expat XML parser
- ocaml: OCaml interface
- markup: Markup.ml XML and HTML parser
```

## Sample programs

There are three sample programs, all compiled by typing `make`.
The details of the compilation steps are explained in the [`Makefile`](Makefile).

1. [`cduce_simple.cd`](cduce_simple.cd) consits of two files, both in pure CDuce or using builtin OCaml functions that are directly callable from the CDuce toplevel. The resulting "executable" is `cduce_simple.cdo` which must be run with `cduce --run cduce_simple.cdo`.
2. [`cduce_main.cd`](cduce_main.cd) is a variant that calls arbitrary OCaml code which comes from an external library. To do so, CDuce code is embedded in OCaml files and all are compiled and linked together, giving a native executable (which embeds the CDuce interpreter).
3. [`ocaml_main.ml`](ocaml_main.ml) Same as above but the main code is in OCaml. It shows how to write an OCaml interface which describes how CDuce functions are exported as OCaml functions.

The procedure is almost the same as the one described in the [CDuce User
Guide](https://www.cduce.org/manual_interfacewithocaml.html), except that the
cduce package to link against is now called `cduce.lib` instead of `cduce`.
