
import Flutter
import UIKit

public class FlutterTimeGuardPlugin: NSObject, FlutterPlugin {
  private var timeChangeListener: TimeChangeListener?
  private var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterTimeGuardPlugin()
    let channel = FlutterMethodChannel(name: "time_change_listener", binaryMessenger: registrar.messenger())
    instance.channel = channel
    instance.timeChangeListener = TimeChangeListener(messenger: registrar.messenger())
    instance.timeChangeListener?.setLoggingEnabled(false)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "reset":
      timeChangeListener?.log("FlutterTimeGuardPlugin received reset call")
      result(nil)
    case "configureLogging":
      let enableLogs = (call.arguments as? [String: Any])?["enableLogs"] as? Bool ?? false
      timeChangeListener?.setLoggingEnabled(enableLogs)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
