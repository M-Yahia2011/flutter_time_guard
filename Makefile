# ===============================
# Flutter Package – Makefile
# ===============================

FLUTTER := flutter

.PHONY: help clean get format analyze test pub_check pub_publish \
        version_patch version_minor version_major

# -------------------------------
# Default target
# -------------------------------
help:
	@echo "Flutter Package Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make get            Install dependencies"
	@echo "  make format         Format Dart code"
	@echo "  make analyze        Run static analysis"
	@echo "  make test           Run tests"
	@echo "  make pub_check      Dry-run publish (recommended)"
	@echo "  make pub_publish    Publish package to pub.dev"
	@echo "  make clean          Clean build artifacts"
	@echo ""
	@echo "Version helpers:"
	@echo "  make version_patch  Bump patch version (x.y.Z)"
	@echo "  make version_minor  Bump minor version (x.Y.0)"
	@echo "  make version_major  Bump major version (X.0.0)"

# -------------------------------
# Dependencies
# -------------------------------
get:
	$(FLUTTER) pub get

# -------------------------------
# Code quality
# -------------------------------
format:
	dart format .

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

# -------------------------------
# Publishing
# -------------------------------
pub_check:
	$(FLUTTER) pub publish --dry-run

pub_publish:
	$(FLUTTER) pub publish

# -------------------------------
# Clean
# -------------------------------
clean:
	$(FLUTTER) clean
	rm -rf .dart_tool
	rm -rf build

# -------------------------------
# Version bump helpers
# Requires pubspec.yaml
# -------------------------------
version_patch:
	dart pub bump patch

version_minor:
	dart pub bump minor

version_major:
	dart pub bump major
