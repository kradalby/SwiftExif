generate:
	swift test --generate-linuxmain
	make fmt

build:
	swift build -c debug --sanitize=thread

build-release:
	swift build --configuration release

test:
	swift test

dev:
	swift package generate-xcodeproj

upgrade:
	echo "Not implemented"

clean:
	rm -rf .build

reinstall:
	echo "Not implemented"

lint:
	swiftlint
	# swiftformat --lint Sources

fmt:
	swiftlint autocorrect
	swift-format --recursive --in-place Sources/ Package.swift

run: build
	./.build/x86_64-apple-macosx/debug/exiftest

reset-lsp:
	swift package reset
	swift package update
	killall sourcekit-lsp

