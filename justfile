# X_eTaL-libraries tasks. Recipes call scripts/*.sh, which hold the
# logic and work without just too. `just` alone lists the recipes.

set positional-arguments

# List the recipes
default:
    @just --list

# Snapshot a committed ref of ../X_eTaL into vendor/xetal/ (default HEAD); commit it on its own
vendor ref="HEAD":
    scripts/vendor-xetal.sh "$1"

# Build the vendored xetal CLI into target/xetal/
xetal:
    @scripts/build-xetal.sh

# The vendored X_eTaL: what was vendored (VENDORED) and the binary's version
xetal-version:
    @cat vendor/xetal/VENDORED
    @"$(scripts/build-xetal.sh)" --version | head -1

# Evaluate an expression with the vendored xetal, lib/ on XETAL_PATH: just eval "'+ r_/ 1 2 3"
eval expr:
    @XETAL_PATH=lib "$(scripts/build-xetal.sh)" eval --ascii -e "$1"

# Check the vendored X_eTaL: the CLI builds, answers and imports a standard library
check-vendor:
    scripts/check-vendor.sh

# The libraries: name, recommended alias, what it is
libs:
    @scripts/libs.py table | column -t -s "$(printf '\t')"

# The directory to put on XETAL_PATH: export XETAL_PATH="$(just path)"
path:
    @echo "{{justfile_directory()}}/lib"

# Start a library from templates/: just new-lib Strings t: "text functions"
new-lib name alias summary:
    scripts/new-lib.sh "$1" "$2" "$3"

# Run a library's test programs (or one): just run Strings basics
run name prog="":
    @scripts/run-lib.sh "$1" ${2:+"$2"}

# The same as a notebook: each statement drawn, then its output
show name prog="":
    @scripts/run-lib.sh --echo "$1" ${2:+"$2"}

# The exported names and their types: just types Strings
types name:
    @"$(scripts/build-xetal.sh)" type "lib/$1.xtl"

# Test every library: pinned types, goldens, completeness
test:
    scripts/test-libs.sh

# Test one library: just test-lib Strings
test-lib name:
    scripts/test-libs.sh "$1"

# Rewrite one library's expected outputs and types from its tests (review the diff!)
bless name:
    XETAL_BLESS=1 scripts/test-libs.sh "$1"

# The full pre-commit gate
gate:
    scripts/gate.sh

# Show the agentrail saga state and the current step
status:
    agentrail status

# Open the saga plan
plan:
    @cat docs/plan.md
