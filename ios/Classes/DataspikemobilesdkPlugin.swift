import Flutter
import UIKit

public class DataspikemobilesdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dataspikemobilesdk", binaryMessenger: registrar.messenger())
    let instance = DataspikemobilesdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
   case "startDataspikeFlow":
      result("Dataspike flow started (stub)")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
