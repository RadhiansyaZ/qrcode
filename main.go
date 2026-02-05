package main

import (
	"flag"
	"fmt"
	"log/slog"
	"os"
	"strings"
	"time"

	qrcode "github.com/skip2/go-qrcode"
)

// parseQuality maps a human-friendly quality string to qrcode.RecoveryLevel.
func parseQuality(q string) qrcode.RecoveryLevel {
	switch strings.ToLower(strings.TrimSpace(q)) {
	case "low":
		return qrcode.Low
	case "medium", "med":
		return qrcode.Medium
	case "high":
		return qrcode.High
	case "highest", "max", "ultra":
		return qrcode.Highest
	default:
		// fallback to Highest if unknown
		return qrcode.Highest
	}
}

func main() {
	// Defaults
	defaultQuality := "highest"
	defaultOutput := time.Now().Format("2006-01-02_150405Z07") + ".png"
	defaultSize := 1024

	// CLI flags
	qualityFlag := flag.String("quality", defaultQuality, "QR code recovery level: low, medium, high, highest")
	contentFlag := flag.String("content", "", "Content to encode in the QR code (required)")
	outputFlag := flag.String("output", defaultOutput, "Output filename (default: timestamped .png)")
	sizeFlag := flag.Int("size", defaultSize, "Image size in pixels")

	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "Usage of %s:\n", os.Args[0])
		flag.PrintDefaults()
	}

	flag.Parse()

	// Require content
	content := strings.TrimSpace(*contentFlag)
	if content == "" {
		slog.Error("missing required flag: -content")
		flag.Usage()
		os.Exit(2)
	}

	// Resolve other flags
	quality := parseQuality(*qualityFlag)
	output := strings.TrimSpace(*outputFlag)
	if output == "" {
		output = time.Now().Format("2006-01-02_150405Z07") + ".png"
	}
	size := *sizeFlag

	// Panic recovery: log and exit
	defer func() {
		if r := recover(); r != nil {
			slog.Error("panic recovered", "panic", r)
			os.Exit(1)
		}
	}()

	slog.Info("starting qr generation", "quality", *qualityFlag, "content_len", len(content), "output", output, "size", size)

	// Generate QR code
	if err := qrcode.WriteFile(content, quality, size, output); err != nil {
		slog.Error("failed to write qrcode", "error", err)
		os.Exit(1)
	}

	slog.Info("qrcode generated successfully", "output", output, "content", content)
}
