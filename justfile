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

# Evaluate an expression with the vendored xetal, every library on XETAL_PATH: just eval "'+ r_/ 1 2 3"
eval expr:
    @scripts/xt eval --ascii -e "$1"

# Check the vendored X_eTaL: the CLI builds, answers and imports a standard library
check-vendor:
    scripts/check-vendor.sh

# The libraries: name, recommended alias, what it is
libs:
    @scripts/libs.py table | column -t -s "$(printf '\t')"

# The directories to put on XETAL_PATH: export XETAL_PATH="$(just path)"
path:
    @scripts/libs.py path

# Start a library from templates/Library: just new-lib Lists q: "list functions"
new-lib name alias summary:
    scripts/new-lib.sh "$1" "$2" "$3"

# Run a library's test programs (or one): just run Strings search
run name prog="":
    @scripts/run-lib.sh "$1" ${2:+"$2"}

# Run a library's demos (or one): just demo Strings word-count
demo name prog="":
    @scripts/run-lib.sh --demos "$1" ${2:+"$2"}

# A demo or test as a notebook, each statement then its output: just show Strings word-count
show name prog="":
    @scripts/run-lib.sh --echo --demos "$1" ${2:+"$2"}

# A demo's macro calls and what each became (xetal expand): just expand Statistics heights
expand name prog:
    @scripts/expand.py "libs/$1/demos/${2%.xtl}.xtl"

# The same, the whole program with the changes marked
expand-all name prog:
    @scripts/expand.py --all "libs/$1/demos/${2%.xtl}.xtl"

# The exported names and their types: just types Strings
types name:
    @scripts/xt type "libs/$1/src/$1.xtl"

# Test every library with reg-rs: pinned types, test programs, demos
test:
    scripts/test-libs.sh

# Test one library: just test-lib Strings
test-lib name:
    scripts/test-libs.sh "$1"

# Create missing baselines and accept new output for one library (review the diff!)
bless name:
    XETAL_BLESS=1 scripts/test-libs.sh "$1"

# Build the live demo into pages/ (committed; the Pages workflow publishes it)
pages:
    scripts/build-pages.sh

# Serve the live demo, rebuilt on change: http://127.0.0.1:8459/
serve port="8459":
    cd site && trunk serve --port {{port}} --address 127.0.0.1

# Serve the built pages/ as GitHub Pages will: http://127.0.0.1:8459/X_eTaL-libraries/
serve-pages port="8459":
    scripts/serve-pages.sh "$1"

# Where X_eTaL stands on our asks: its saga queue, each ask in its HEAD and in the vendored copy
upstream:
    @scripts/upstream.sh

# Run every ask's repro with the vendored xetal: which are still open
asks:
    @scripts/asks.sh

# The same against X_eTaL's committed HEAD, or any committed ref (a lane's branch): just asks-upstream origin/pr/macros-example
asks-upstream ref="HEAD":
    @scripts/asks.sh --upstream "$1"

# American spellings only: every tracked file we own, British forms flagged
spelling:
    @scripts/check-spelling.py

# The full pre-commit gate
gate:
    scripts/gate.sh

# Show the agentrail saga state and the current step
status:
    agentrail status

# Open the saga plan
plan:
    @cat docs/plan.md
