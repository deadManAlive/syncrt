ZIG := D:/scoop/main/shims/zig
TAR := C:/Windows/System32/tar

build: $(wildcard src/*.zig)
	$(ZIG) build -Doptimize=Debug

build-opt: $(wildcard src/*.zig)
	$(ZIG) build -Doptimize=ReleaseFast

# `zig build test` seems broken @ 0.11.0-dev.2399+d92b5fcfb
test: build
	$(ZIG) test ./src/main.zig

zip: build-all
	$(TAR) -czvf build/windows.tar.gz build/windows
	$(TAR) -czvf build/linux.tar.gz build/linux
	$(TAR) -czvf build/macos.tar.gz build/macos

build-all: $(wildcard src/*.zig)
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-windows --prefix build/windows
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-linux --prefix build/linux
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-macos --prefix build/macos

