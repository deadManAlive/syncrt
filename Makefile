ZIG := D:/scoop/main/shims/zig
TAR := C:/Windows/System32/tar

zip: build
	$(TAR) -czvf build/windows.tar.gz build/windows
	$(TAR) -czvf build/linux.tar.gz build/linux
	$(TAR) -czvf build/macos.tar.gz build/macos

build: $(wildcard src/*.zig)
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-windows --prefix build/windows
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-linux --prefix build/linux
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-macos --prefix build/macos

