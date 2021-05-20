import UIKit
import Flutter
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let heapSizeChannel = FlutterMethodChannel(name: "de.mathema.privacyblur/memory", binaryMessenger: controller.binaryMessenger)

    heapSizeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "getHeapSize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getHeapSize(result: result)
    })


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getHeapSize(result: FlutterResult) {
    let TASK_VM_INFO_COUNT = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size

    var vmInfo = task_vm_info_data_t()
    var vmInfoSize = mach_msg_type_number_t(TASK_VM_INFO_COUNT)

    let kern: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(TASK_VM_INFO),
                          $0,
                          &vmInfoSize)
                }
            }

    if kern == KERN_SUCCESS {
        let usedSize = Int(vmInfo.internal + vmInfo.compressed)
        result(usedSize)
    } else {
        let errorString = String(cString: mach_error_string(kern), encoding: .ascii) ?? "unknown error"
        result("Error with task_info():" + errorString)
    }
  }
}
