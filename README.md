# QRCode CLI

A small command-line tool that generates QR code PNG files from provided content. The program accepts flags for `quality`, `content`, `output`, and `size`. The `-content` flag is required and may be either the literal content to encode or a path to a text file containing the content.

This README explains how to build static cross-platform binaries (macOS amd64 / arm64 and Windows amd64) and how to run the tool with a URL string.

---

## Requirements

- Go (version 1.21 or newer) — `slog` is used, which is available in Go 1.21+.
- A shell (bash / sh / PowerShell / cmd) to run build and usage commands.

Note: The commands below perform cross-compilation by setting `GOOS`/`GOARCH`. They also set `CGO_ENABLED=0` to produce a statically linkable binary where possible.

---

## Build (from project root or the `qrcode` directory)

Open a terminal in the `qrcode` directory (the directory containing `main.go`).

### macOS (Intel / amd64)

```
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -o qrcode-darwin-amd64 .
```

### macOS (Apple Silicon / arm64)

```
CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -o qrcode-darwin-arm64 .
```

### Windows (amd64)

```
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o qrcode-windows-amd64.exe .
```

After successful build you will have the binaries:
- `qrcode-darwin-amd64` — macOS x86_64 binary
- `qrcode-darwin-arm64` — macOS arm64 binary
- `qrcode-windows-amd64.exe` — Windows x86_64 binary

---

## Make the macOS binary executable

If you built on macOS or copied the binary to macOS, ensure it is executable:

```
chmod +x qrcode-darwin-amd64
chmod +x qrcode-darwin-arm64
```

---

## Usage

Synopsis:

```
./<binary> -content <content> [options]
```

Flags:
- `-content` (required) — the string to encode, or a path to a file containing the string (plain text). If the path points to an existing regular file, the program will read the file and use its trimmed contents.
- `-quality` — QR recovery level: `low`, `medium` (or `med`), `high`, or `highest`. Default: `highest`.
- `-output` — Output filename for the PNG file. Default: timestamped filename like `2006-01-02_150405Z07.png`.
- `-size` — Image pixel size (width/height). Default: `1024`.

The program logs structured messages (using `slog`) and exits with non-zero status on failure.

---

## Example: Pass content directly on the command line

You can pass the encoded content directly (note: if the content contains spaces or shell-sensitive characters, quote it):

```
./qrcode-darwin-amd64 -content "https://www.youtube.com/watch?v=dQw4w9WgXcQ" -output short.png
```

---

## Exit codes

- `0` — success
- `1` — runtime error (e.g., failed to write file)
- `2` — usage / missing required flag (`-content`)

---

## Packaging and distribution notes

- The builds produced with `CGO_ENABLED=0` are intended to be portable, but you should still test the binaries on the target OS/architecture.
- For macOS distribution you may want to:
  - Sign the binary with a Developer ID certificate.
  - Notarize the binary if you distribute it outside the App Store.
- For Windows distribution, consider producing an installer or bundling the `.exe` in a ZIP.

Optional compression:
- You can compress binaries with tools like `upx` to reduce file size (test the resulting executable carefully).

---

## Troubleshooting

- If you get errors related to `slog` or compilation complaining about unavailable APIs, ensure your Go toolchain is at least version 1.21:
  ```
  go version
  ```
- If cross-compiling from Windows to macOS, or vice versa, ensure you have a Go toolchain that supports cross-compilation. Some CGO-enabled builds may require platform-specific toolchains; using `CGO_ENABLED=0` avoids that by disabling cgo.
- If the program fails to write the PNG, check permissions on the current directory and ensure the output filename is valid for the OS.

---
