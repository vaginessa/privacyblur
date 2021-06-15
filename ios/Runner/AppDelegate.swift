import UIKit
import Flutter
import Foundation
import MLKitFaceDetection
import MLKitVision

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let HEAP_SIZE_CHANNEL = "de.mathema.privacyblur/memory";
    let FACE_DETECTION_CHANNEL = "de.mathema.privacyblur/face_detection";

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let heapSizeChannel = FlutterMethodChannel(name: HEAP_SIZE_CHANNEL, binaryMessenger: controller.binaryMessenger)
    let faceDetectionChannel = FlutterMethodChannel(name: FACE_DETECTION_CHANNEL, binaryMessenger: controller.binaryMessenger)

    heapSizeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "getHeapSize" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getHeapSize(result: result)
    })

    faceDetectionChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "detectFaces" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        try self?.detectFaces(call: call, result: result)
      } catch {
        result(FlutterError(code: "UNAVAILABLE", message: "Unexpected error.", details: nil))
        return
      }
    })


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
  private struct PixelData {
    var a: UInt8 = 255
    var r: UInt8
    var g: UInt8
    var b: UInt8
  }

  private func detectFaces(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let srcImage = args["nv21"] as? FlutterStandardTypedData,
       let width = args["width"] as? Int,
       let height = args["height"] as? Int {

        let options = FaceDetectorOptions()
         options.performanceMode = .fast
         options.landmarkMode = .none
         options.classificationMode = .none
        let image : UIImage = UIImage(data: srcImage.data)!
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        let faceDetector = FaceDetector.faceDetector(options: options)

        weak var weakSelf = self
        faceDetector.process(visionImage) { faces, error in
          guard let strongSelf = weakSelf else {
              print("Self is nil!")
              return
          }
        var arr: Array<Int> = Array()
        var arrIndex: Int = 0

        for face in faces! {
            arrIndex += 1
            arr[arrIndex] = Int(face.frame.minX)
            arrIndex += 1
            arr[arrIndex] = Int(face.frame.minY)
            arrIndex += 1
            arr[arrIndex] = Int(face.frame.maxX)
            arrIndex += 1
            arr[arrIndex] = Int(face.frame.maxY)
        }
          result(arr)
            return
        }
    } else {
        result(FlutterError.init(code: "BAD ARGS", message: nil, details: nil))
    }
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
