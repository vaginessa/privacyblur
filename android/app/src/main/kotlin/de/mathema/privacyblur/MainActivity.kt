package de.mathema.privacyblur

import androidx.annotation.NonNull
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "de.mathema.privacyblur/memory"
    private val FACEDETECTION = "de.mathema.privacyblur/face_detection"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getHeapSize") {
                result.success(Runtime.getRuntime().maxMemory())
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FACEDETECTION
        ).setMethodCallHandler { call, result ->
            if (call.method == "detectFaces") {
                try {
                    var srcImage = call.argument<ByteArray>("argb8")
                    var width = call.argument<Int>("width")
                    var height = call.argument<Int>("height")
                    // Real-time contour detection
                    val realTimeOpts = FaceDetectorOptions.Builder()
                        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
                        .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
                        .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_NONE)
                        .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
                        .build()
                    var processedImage = InputImage.fromByteArray(
                        srcImage,
                        width!!,
                        height!!,
                        0,
                        InputImage.IMAGE_FORMAT_NV21
                    )
                    val detector = FaceDetection.getClient(realTimeOpts)
                    val detectionProcess = detector.process(processedImage)
                        .addOnSuccessListener { faces ->
                            result.success(faces)
                        }
                        .addOnFailureListener { e ->
                            result.error(e.stackTrace.toString(), e.localizedMessage, e)
                        }
                        .addOnCanceledListener {
                            result.error("canceled", "canceled", "canceled")
                        }
                } catch (e: Exception) {
                    result.error(e.stackTrace.toString(), e.localizedMessage, e)
                }
            } else {
                result.notImplemented()
            }
        }

    }
}
