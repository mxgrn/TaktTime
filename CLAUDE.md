# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TaktTime is a macOS stopwatch app built with SwiftUI using Swift Package Manager (not Xcode project). It targets macOS 15+ and uses Swift 6.2 with strict concurrency.

## Build & Run Commands

- **Build:** `swift build`
- **Run:** `swift run`

There are no tests currently configured.

## Architecture

Single-target SwiftUI app (`Sources/TaktTime/`):

- **TaktTimeApp.swift** - App entry point. Forces regular activation policy (dock icon) and fixed window size.
- **StopwatchModel.swift** - `@Observable` model tracking elapsed time in seconds with Timer-based counting. All state is `@MainActor`.
- **StopwatchView.swift** - Main UI with time display, start/stop/reset controls, and preset time adjustment buttons (+/- 1h, 30m, 15m, 5m).
