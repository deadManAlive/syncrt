ZIG := D:/scoop/main/shims/zig

build:
	$(ZIG) build -Doptimize=ReleaseFast --prefix build/windows
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-linux --prefix build/linux
	$(ZIG) build -Doptimize=ReleaseFast -Dtarget=x86_64-macos --prefix build/macos

