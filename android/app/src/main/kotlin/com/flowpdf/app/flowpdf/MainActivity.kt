package com.flowpdf.app.flowpdf

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.flowpdf.app/pdf_cover"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "renderFirstPage") {
                val pdfPath = call.argument<String>("pdfPath")
                val outputPath = call.argument<String>("outputPath")
                if (pdfPath == null || outputPath == null) {
                    result.error("INVALID_ARGS", "Paths cannot be null", null)
                    return@setMethodCallHandler
                }
                try {
                    val file = File(pdfPath)
                    if (!file.exists()) {
                        result.error("FILE_NOT_FOUND", "PDF file does not exist", null)
                        return@setMethodCallHandler
                    }
                    val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                    val renderer = PdfRenderer(pfd)
                    if (renderer.pageCount > 0) {
                        val page = renderer.openPage(0)
                        val targetWidth = 600
                        val targetHeight = ((targetWidth.toFloat() / page.width.toFloat()) * page.height.toFloat()).toInt().coerceAtLeast(100)
                        val bitmap = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.ARGB_8888)
                        val canvas = Canvas(bitmap)
                        canvas.drawColor(Color.WHITE)
                        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                        page.close()
                        renderer.close()
                        pfd.close()

                        val outFile = File(outputPath)
                        outFile.parentFile?.mkdirs()
                        FileOutputStream(outFile).use { out ->
                            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
                        }
                        result.success(outputPath)
                    } else {
                        renderer.close()
                        pfd.close()
                        result.error("EMPTY_PDF", "PDF has 0 pages", null)
                    }
                } catch (e: Exception) {
                    result.error("RENDER_ERROR", e.localizedMessage ?: "Unknown error", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
