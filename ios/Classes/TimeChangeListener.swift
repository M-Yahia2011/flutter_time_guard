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

  init(messenger: FlutterBinaryMessenger) {
    methodChannel = FlutterMethodChannel(
      name: "time_change_listener", binaryMessenger: messenger)
    subscribeToNotifications()
  }

  private func subscribeToNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(systemClockDidChange),
      name: NSNotification.Name.NSSystemClockDidChange,
      object: nil)

    // NotificationCenter.default.addObserver(
    //     self,
    //     selector: #selector(systemTimeZoneDidChange),
    //     name: NSNotification.Name.NSSystemTimeZoneDidChange,
    //     object: nil)
  }
  @objc private func systemClockDidChange() {

    guard UIApplication.shared.applicationState != .active else {
      return  // Ignore if app is in foreground
    }
    print("System clock changed")

    methodChannel.invokeMethod("onTimeChanged", arguments: nil)
  }

  // @objc private func systemTimeZoneDidChange() {
  //     print("System timezone changed")
  //     methodChannel.invokeMethod("onTimeChanged", arguments: nil)
  // }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
