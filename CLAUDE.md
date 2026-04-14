# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TaktTime is a macOS stopwatch app built with SwiftUI using Swift Package Manager (not Xcode project). It targets macOS 15+ and uses Swift 6.2 with strict concurrency.

## Build & Run Commands

- **Build:** `swift build`
- **Run:** `swift run`
- **Release .app bundle:**
  1. `swift build -c release`
  2. Assemble `TaktTime.app/Contents/` with `MacOS/TaktTime` binary, `Info.plist`, and `Resources/AppIcon.icns` (generated from `AppIcon.iconset/` via `iconutil -c icns`)

There are no tests currently configured.

## Architecture

Single-target SwiftUI app (`Sources/TaktTime/`):

- **TaktTimeApp.swift** - App entry point. Forces regular activation policy (dock icon) and fixed window size. Uses `Window` (not `WindowGroup`) — this is critical to ensure only one `StopwatchModel` instance exists. Multiple instances would race on the shared state files.
- **StopwatchModel.swift** - `@Observable` model tracking elapsed time in seconds with Timer-based counting. All state is `@MainActor`.
- **StopwatchView.swift** - Main UI with time display, start/stop/reset controls, and preset time adjustment buttons (+/- 1h, 30m, 15m, 5m).

## State Persistence Requirements

State is persisted to `~/Library/Application Support/TaktTime/` using **two separate files** — this separation is load-bearing, do not combine them:

- **`seconds`** — contains only the integer totalSeconds. Written from `didSet` on totalSeconds (every timer tick and every adjustment).
- **`running`** — contains "true" or "false". Written **only** by `start()` and `stop()`. Timer ticks must never write to this file.

Behavioral rules:

- **Restart:** On relaunch, restore the exact totalSeconds and isRunning state from the files. Do NOT add any elapsed wall-clock time — the timer only counts while the app process is alive and the Timer is firing.
- **Sleep/wake:** The timer does not count time while the display is off (lid closed). On `screensDidSleepNotification`, invalidate the timer. On `screensDidWakeNotification`, re-create it if still in running state. Do not use system sleep/wake notifications (they fire too late after lid close).
- **Normal ticking:** Each timer fire increments totalSeconds by 1. Do not calculate elapsed time between fires.
