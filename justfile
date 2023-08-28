#!/usr/bin/env just --justfile

[private]
default: help

# Set shell to use on Windows
set windows-shell := ["powershell.exe", "-c"]

# Load environment variables
set dotenv-load

# Colors
red := "\\033[0;31m"
green := "\\033[0;32m"
yellow := "\\033[0;33m"
blue := "\\033[0;34m"
reset := "\\033[0m"

# Prefixes
error := "❌"
success := "🍻"
info := ""
wait := "⏳"

# Aliases
alias h := help
alias bs := bootstrap

# Display this help message
@help:
  just --list

# Format the code in /lib
@format:
  echo "{{yellow}}{{wait}} Formatting... {{reset}}"
  cd lib
  dart format . --fix
  dart fix --apply
  echo "{{green}}{{success}} Done! {{reset}}"

# Analyze the code in /lib
@analyze:
  echo "{{yellow}}{{wait}} Analyzing... {{reset}}"
  cd lib
  dart analyze . && echo "{{green}}{{success}} Done! {{reset}}" || echo "{{red}}{{error}} Issues found! {{reset}}" && exit 3

# Getting dependencies, generating code and l10n
@bootstrap:
  echo "{{yellow}}{{wait}} Bootstrapping... {{reset}}"
  dart pub get
  echo "{{green}}{{success}} Done! {{reset}}"

# Run tests with coverage
@coverage:
  echo "{{yellow}}{{wait}} Testing (with coverage)... {{reset}}"
  dart run test --coverage=./coverage
  dart pub global activate coverage
  dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage
  genhtml -o ./coverage/report ./coverage/lcov.info
  open ./coverage/report/index.html
  echo "{{green}}{{success}} Done! {{reset}}"

# Run tests
@test:
  echo "{{yellow}}{{wait}} Testing... {{reset}}"
  dart run test
  echo "{{green}}{{success}} Done! {{reset}}"

# Run example
@example:
  dart example/bin/result_example.dart
