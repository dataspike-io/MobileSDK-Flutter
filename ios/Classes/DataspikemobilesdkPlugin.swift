import Flutter
import UIKit

public class DataspikemobilesdkPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "dataspikemobilesdk", binaryMessenger: registrar.messenger())
    let instance = DataspikemobilesdkPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startDataspikeFlow":
      result(["started": true])
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
