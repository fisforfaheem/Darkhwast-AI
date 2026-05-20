package com.example.darkhwast_ai

import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.darkhwast_ai/camera"
    private var pendingResult: MethodChannel.Result? = null
    private var outputUri: Uri? = null
    private var outputFile: File? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "capture" -> capturePhoto(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun capturePhoto(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "Camera already active", null)
            return
        }

        try {
            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            val file = File.createTempFile("scan_${UUID.randomUUID()}", ".jpg", cacheDir)
            val authority = "${applicationContext.packageName}.flutter.image_provider"
            val uri = FileProvider.getUriForFile(this, authority, file)

            outputFile = file
            outputUri = uri
            pendingResult = result

            intent.putExtra(MediaStore.EXTRA_OUTPUT, uri)
            intent.addFlags(
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
            intent.clipData = ClipData.newUri(contentResolver, "photo", uri)

            grantUriPermissionsToCameraApps(intent, uri)

            startActivityForResult(intent, REQUEST_CAPTURE)
        } catch (e: Exception) {
            cleanupCapture()
            result.error("capture_failed", e.message, null)
        }
    }

    private fun grantUriPermissionsToCameraApps(intent: Intent, uri: Uri) {
        val flags = Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
            Intent.FLAG_GRANT_READ_URI_PERMISSION
        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(
                    PackageManager.MATCH_DEFAULT_ONLY.toLong(),
                ),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        }
        for (info in resolveInfos) {
            grantUriPermission(info.activityInfo.packageName, uri, flags)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_CAPTURE) return

        val result = pendingResult
        pendingResult = null

        val file = outputFile
        val uri = outputUri
        outputFile = null
        outputUri = null

        if (uri != null) {
            revokeUriPermission(
                uri,
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        }

        if (result == null) return

        if (resultCode == RESULT_OK && file != null && file.exists() && file.length() > 0L) {
            result.success(file.absolutePath)
        } else {
            file?.delete()
            result.success(null)
        }
    }

    private fun cleanupCapture() {
        pendingResult = null
        outputFile?.delete()
        outputFile = null
        outputUri = null
    }

    companion object {
        private const val REQUEST_CAPTURE = 57001
    }
}
