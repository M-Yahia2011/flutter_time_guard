//
//  TimeChangeListener.swift
//  Runner
//
//  Created by M.Yahia2011 on 08/06/2025.
//

import Flutter
import Foundation

/// Listens for system clock changes and notifies Flutter via a method channel.
/// Ignores changes when the app is in the background or if changes occur within 2 seconds of each other.
class TimeChangeListener {
  private let methodChannel: FlutterMethodChannel
  private var isScreenOn = true

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "time_change_listener", binaryMessenger: messenger)
    subscribeToNotifications()
    print("TimeChangeListener initialized")
  }

  /// Clock Change Observer
  private func subscribeToNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(systemClockDidChange),
      name: NSNotification.Name.NSSystemClockDidChange,
      object: nil)
    /// Time Zone Change Observer
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(systemTimeZoneDidChange),
      name: NSNotification.Name.NSSystemTimeZoneDidChange,
      object: nil)

    /// Screen Locking Observer
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenWillLock),
      name: UIApplication.protectedDataWillBecomeUnavailableNotification,
      object: nil)

    /// Screen Unlocking Observer
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenDidUnlock),
      name: UIApplication.protectedDataDidBecomeAvailableNotification,
      object: nil)
  }

  @objc private func screenWillLock() {
    print("Screen is locking")
    isScreenOn = false
  }

  @objc private func screenDidUnlock() {
    print("Screen unlocked")
    isScreenOn = true
  }

  @objc private func systemClockDidChange() {
    guard shouldNotify() else {
      print("Ignored systemClockDidChange due to foreground or screen lock")
      return
    }
    print("System clock changed")
    methodChannel.invokeMethod("onTimeChanged", arguments: nil)
  }

  @objc private func systemTimeZoneDidChange() {
    guard shouldNotify() else {
      print("Ignored systemTimeZoneDidChange due to foreground or screen lock")
      return
    }

    print("System timezone changed")
    methodChannel.invokeMethod("onTimeChanged", arguments: nil)
  }

  /// notify if the app is in the background and if the screen is not locked.
  private func shouldNotify() -> Bool {
    let appState = UIApplication.shared.applicationState
    print("App state: \(appState)")
    print("Screen state: \(isScreenOn)")
    return appState == .background && isScreenOn
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
