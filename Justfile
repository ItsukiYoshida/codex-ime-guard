build:
    swift build -c release --package-path platforms/macos

fmt:
    swift format format --configuration platforms/macos/.swift-format --in-place --recursive platforms/macos/Package.swift platforms/macos/Sources

lint: lint-swift lint-plist

lint-swift:
    swift format lint --configuration platforms/macos/.swift-format --strict --recursive platforms/macos/Package.swift platforms/macos/Sources

check: lint build

install:
    ./scripts/install.sh

uninstall:
    ./scripts/uninstall.sh

lint-plist:
    plutil -lint platforms/macos/resources/Info.plist platforms/macos/templates/launch-agent.plist

clean:
    swift package --package-path platforms/macos clean
