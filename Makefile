INSTALL_DIR=~/bin
BIN_NAME=validate-localization
BUILD_DIR=.build
PM_DIR=.swiftpm
BUILD_PATH=$(BUILD_DIR)/release/$(BIN_NAME)

all: build install

test:
	@swift test

build:
	@swift build -c release

install:
	@cp -p  $(BUILD_PATH) $(INSTALL_DIR)/$(BIN_NAME)

clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf $(PM_DIR)

dependencies:
	@brew bundle

format:
	@swiftformat .
	@swiftlint autocorrect
	@swiftlint
