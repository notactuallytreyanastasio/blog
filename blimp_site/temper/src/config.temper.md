# The site's Temper

The parts of the site written in Temper rather than Blimp. `build.sh` compiles
this library with the Blimp backend into `_build/temper.blimp` and puts it
first in every program it builds, so the rest of the site calls what is
exported here as if it were Blimp: a Temper `export let trim(...)` is a Blimp
`def trim(...)`, name for name.

One sub-directory per module. Each module's exports share the site's one flat
namespace with every `src/*.blimp` file and with temper-core, whose names all
start `temper_` or `u8_`.

    export let name = "site";
