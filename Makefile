# Simplified Makefile for qrcode
# - Place compiled binaries into $(DIST_DIR) directly
# - Build targets create $(DIST_DIR) if necessary (order-only dependency)
# - Simple packaging that archives the distributed files
SHELL := /bin/sh

# Configurable variables (override on the make command line if needed)
BINARY_NAME ?= qrcode
GO ?= go
CGO ?= 0
LD_FLAGS ?= -s -w
DIST_DIR ?= dist

# Output filenames (placed inside $(DIST_DIR))
OUT_DARWIN_AMD := $(DIST_DIR)/$(BINARY_NAME)-darwin-amd64
OUT_DARWIN_ARM := $(DIST_DIR)/$(BINARY_NAME)-darwin-arm64
OUT_WINDOWS_AMD := $(DIST_DIR)/$(BINARY_NAME)-windows-amd64.exe
OUT_LINUX_AMD := $(DIST_DIR)/$(BINARY_NAME)-linux-amd64

.PHONY: all help check-go build-darwin-amd64 build-darwin-arm64 build-windows-amd64 build-linux-amd64 \
        build-all package-darwin-amd64 package-darwin-arm64 package-windows-amd64 package-linux-amd64 \
        dist-all clean run

all: build-all

help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Common targets:"
	@echo "  build-darwin-amd64    Build macOS (amd64) into $(DIST_DIR)/"
	@echo "  build-darwin-arm64    Build macOS (arm64) into $(DIST_DIR)/"
	@echo "  build-windows-amd64   Build Windows (amd64) into $(DIST_DIR)/"
	@echo "  build-linux-amd64     Build Linux (amd64) into $(DIST_DIR)/"
	@echo "  build-all             Build all platforms into $(DIST_DIR)/"
	@echo "  dist-all              Build & package all into $(DIST_DIR)/"
	@echo "  clean                 Remove binaries and $(DIST_DIR)/"
	@echo "  run                   Run local binary --help"
	@echo ""
	@echo "You can override variables, e.g.:"
	@echo "  make CGO=1 build-darwin-amd64"
	@echo ""

check-go:
	@$(GO) version >/dev/null 2>&1 || (echo "Go not found in PATH. Install Go and retry." && exit 1)

# Ensure dist directory exists (used as order-only prerequisite)
$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

# === Build targets (place outputs directly into $(DIST_DIR)) ===

build-darwin-amd64: check-go | $(DIST_DIR)
	@printf "Building %s for darwin/amd64 (output: %s)...\n" $(BINARY_NAME) $(OUT_DARWIN_AMD)
	CGO_ENABLED=$(CGO) GOOS=darwin GOARCH=amd64 $(GO) build -trimpath -ldflags '$(LD_FLAGS)' -o $(OUT_DARWIN_AMD) .

build-darwin-arm64: check-go | $(DIST_DIR)
	@printf "Building %s for darwin/arm64 (output: %s)...\n" $(BINARY_NAME) $(OUT_DARWIN_ARM)
	CGO_ENABLED=$(CGO) GOOS=darwin GOARCH=arm64 $(GO) build -trimpath -ldflags '$(LD_FLAGS)' -o $(OUT_DARWIN_ARM) .

build-windows-amd64: check-go | $(DIST_DIR)
	@printf "Building %s for windows/amd64 (output: %s)...\n" $(BINARY_NAME) $(OUT_WINDOWS_AMD)
	CGO_ENABLED=$(CGO) GOOS=windows GOARCH=amd64 $(GO) build -trimpath -ldflags '$(LD_FLAGS)' -o $(OUT_WINDOWS_AMD) .

build-linux-amd64: check-go | $(DIST_DIR)
	@printf "Building %s for linux/amd64 (output: %s)...\n" $(BINARY_NAME) $(OUT_LINUX_AMD)
	CGO_ENABLED=$(CGO) GOOS=linux GOARCH=amd64 $(GO) build -trimpath -ldflags '$(LD_FLAGS)' -o $(OUT_LINUX_AMD) .

build-all: build-darwin-amd64 build-darwin-arm64 build-windows-amd64 build-linux-amd64
	@printf "Finished building all targets. Files are in %s/\n" $(DIST_DIR)

# === Packaging helpers ===
# Archive the binaries that were built into $(DIST_DIR)

package-darwin-amd64: build-darwin-amd64 | $(DIST_DIR)
	@printf "Packaging %s into %s/\n" $(OUT_DARWIN_AMD) $(DIST_DIR)
	@tar -C "$(DIST_DIR)" -czf "$(DIST_DIR)/$(notdir $(OUT_DARWIN_AMD)).tar.gz" "$(notdir $(OUT_DARWIN_AMD))"

package-darwin-arm64: build-darwin-arm64 | $(DIST_DIR)
	@printf "Packaging %s into %s/\n" $(OUT_DARWIN_ARM) $(DIST_DIR)
	@tar -C "$(DIST_DIR)" -czf "$(DIST_DIR)/$(notdir $(OUT_DARWIN_ARM)).tar.gz" "$(notdir $(OUT_DARWIN_ARM))"

package-windows-amd64: build-windows-amd64 | $(DIST_DIR)
	@printf "Packaging %s into %s/\n" $(OUT_WINDOWS_AMD) $(DIST_DIR)
	@command -v zip >/dev/null 2>&1 && (cd "$(DIST_DIR)" && zip -q "$(notdir $(OUT_WINDOWS_AMD)).zip" "$(notdir $(OUT_WINDOWS_AMD))") || printf "zip not found; left raw exe in %s/\n" "$(DIST_DIR)"

package-linux-amd64: build-linux-amd64 | $(DIST_DIR)
	@printf "Packaging %s into %s/\n" $(OUT_LINUX_AMD) $(DIST_DIR)
	@tar -C "$(DIST_DIR)" -czf "$(DIST_DIR)/$(notdir $(OUT_LINUX_AMD)).tar.gz" "$(notdir $(OUT_LINUX_AMD))"

dist-all: package-darwin-amd64 package-darwin-arm64 package-windows-amd64 package-linux-amd64
	@printf "All packages created in %s/\n" $(DIST_DIR)

# === Utilities ===

clean:
	@printf "Removing built binaries and %s/\n" $(DIST_DIR)
	@rm -f "$(OUT_DARWIN_AMD)" "$(OUT_DARWIN_ARM)" "$(OUT_WINDOWS_AMD)" "$(OUT_LINUX_AMD)"
	@rm -rf "$(DIST_DIR)"
	@printf "Clean complete.\n"

run: check-go
	@printf "Running local binary --help (if built for host)\n"
	@./$(BINARY_NAME) --help || true
