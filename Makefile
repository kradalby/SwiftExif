build:
	swift build -c debug --sanitize=thread

build-release:
	swift build --configuration release

test:
	swift test

clean:
	rm -rf .build

lint:
	swiftlint

fmt:
	swiftlint autocorrect
	swift-format --recursive --in-place Sources/ Package.swift

reset-lsp:
	swift package reset
	swift package update
	killall sourcekit-lsp
