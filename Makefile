all: cduce_simple.cdo cduce_main.exe ocaml_main.exe


# simple compilation of a CDuce file with no dependency

val_mod.cdo:	val_mod.cd
	cduce --compile val_mod.cd

# cduce_simple.cd depends on val_mod being typed and compiled,
# so it will look for val_mod.cdo in the current directory and
# in any path given by the -I flag

cduce_simple.cdo: cduce_simple.cd val_mod.cdo
	cduce --compile cduce_simple.cd

# Once compiled, the code can be run with
# cduce --run ./cduce_simple.cdo


###### Creating CDuce code that calls arbitrary OCaml code

# To call OCaml code from arbitrary libraries, here we
# use ANSITerminal, which should first be installed from opam
# opam install ANSITerminal ocamlfind
# Now :
# val_mod.cdo which does not use any extra feature is compiled
# as earlier (rule above)
# cduce_main.cdo needs to know the type of the external OCaml
# functions. To this, it must load OCaml .cmi files (compiled interfaces)
# the ocamlfind utility can display the path of such files for a given
# library, we just have to put -I and give it to CDuce


cduce_main.cdo:	cduce_main.cd val_mod.cdo
	cduce --compile cduce_main.cd -I `ocamlfind query ANSITerminal`


# Now we need to mix OCaml and CDuce code. The solution is to transform
# .cdo files into proper OCaml modules and link them together to
# form an executable
# Again we can use ocamlfind to ease the process
# ocamlfind ocamlopt : call the ocaml native compiler through ocamlfind
#  -c : we compile a single file
#  -package cduce.lib : this file depends on the cduce runtime (only)
#  -pp "cduce --mlstub" -impl val_mod.cdo :
#  compile val_mod.cdo as if it where a .ml file (implementation). The
#  .ml is obtained from the val_mod.cdo by calling 'cduce --mlstub' as
#  a pre-processor.

val_mod.cmx:    val_mod.cdo
	ocamlfind ocamlopt -c \
	-package cduce.lib \
     -pp "cduce --mlstub" -impl val_mod.cdo

# Same as above, but depends on the ANSITerminal package too
cduce_main.cmx: cduce_main.cdo
	ocamlfind ocamlopt -c \
    -package cduce.lib,ANSITerminal -linkpkg \
     -pp "cduce --mlstub" -impl cduce_main.cdo

# We call with -o and all the .cmx we have produced to build the final
# executable

cduce_main.exe: cduce_main.cmx val_mod.cmx
	ocamlfind ocamlopt -o cduce_main.exe \
     -package cduce.lib,ANSITerminal -linkpkg \
	 val_mod.cmx cduce_main.cmx


######### Calling CDuce from OCaml

# Here, we just use OCaml to provide our main executable.
# The program ocaml_main.ml calls the CDuce function
# validate_extract from the val_exp.cd module. The latter is
# juste a copy of val_mod.cd it comes together with an OCaml
# interface val_exp.mli which we must compile before hand. This
# ocaml interface says which value from the CDuce code we must
# export and with which type.

val_exp.cmi: val_exp.mli
	ocamlfind ocamlopt -c val_exp.mli

val_exp.cdo: val_exp.cd
	cduce --compile val_exp.cd

val_exp.cmx: val_exp.cmi val_exp.cdo
	ocamlfind ocamlopt -c  \
     -package cduce.lib \
	-pp "cduce --mlstub" -impl val_exp.cdo

ocaml_main.cmx: val_exp.cmx ocaml_main.ml
	ocamlfind ocamlopt -c  \
     -package cduce.lib,ANSITerminal \
	 ocaml_main.ml

ocaml_main.exe: ocaml_main.cmx val_exp.cmx
	ocamlfind ocamlopt -o ocaml_main.exe  \
     -package cduce.lib,ANSITerminal -linkpkg \
	 val_exp.cmx ocaml_main.cmx

clean:
	rm -f *.cmi *.cmo *.cmx *.o *.cdo *.exe
