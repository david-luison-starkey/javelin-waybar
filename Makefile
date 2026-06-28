.PHONY: all build check run dev install-bin install-patched docs
BIN := $(HOME)/.local/bin/javelin-waybar

all: check build run

build:
	@command dune build ./bin/main.exe

check:
	@command dune test

run: build
	# ocaml-hidapi binding links libusb, which can't read usage pages
	# without USB-device permissions (every usage_page returns 0x0000).
	# Uses LD_PRELOAD to force hidraw resolution over libusb.
	LD_PRELOAD=libhidapi-hidraw.so.0 ./_build/default/bin/main.exe

dev: 
	-pkill -x javelin-waybar
	LD_PRELOAD=libhidapi-hidraw.so.0 dune exec --watch ./bin/main.exe

install-bin:
	@command dune build --profile release ./bin/main.exe
	@command install -Dm755 ./_build/default/bin/main.exe $(BIN)

install-patched: install-bin
	@command -v patchelf >/dev/null || { echo "patchelf required"; false; }
	@patchelf --replace-needed libhidapi-libusb.so.0 libhidapi-hidraw.so.0 $(BIN)
	@ldd $(BIN) | grep -q libhidapi-hidraw.so.0 || { echo "patch failed, hidraw not linked"; false; }

docs:
	@command dune build @doc
	@xdg-open http://localhost:8000
	@python -m http.server --directory ./_build/default/_doc/_html 8000 
