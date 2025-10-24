package com.example.moving_text_background_new

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.opengl.GLES20
import android.opengl.GLUtils
import android.opengl.Matrix
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import kotlin.math.*

class LiquidGlassPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    
    // OpenGL resources
    private var program: Int = 0
    private var textureId: Int = 0
    private var vertexBuffer: FloatBuffer? = null
    private var textureBuffer: FloatBuffer? = null
    
    // Shader uniforms
    private var uResolutionLocation: Int = 0
    private var uMouseLocation: Int = 0
    private var uEffectSizeLocation: Int = 0
    private var uBlurIntensityLocation: Int = 0
    private var uDispersionStrengthLocation: Int = 0
    private var uGlassIntensityLocation: Int = 0
    private var uTextureLocation: Int = 0
    
    // Current parameters
    private var effectSize: Float = 2.0f
    private var blurIntensity: Float = 0.5f
    private var dispersionStrength: Float = 0.1f
    private var glassIntensity: Float = 0.3f
    private var mouseX: Float = 0.0f
    private var mouseY: Float = 0.0f
    private var width: Float = 0.0f
    private var height: Float = 0.0f

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "liquid_glass_shader")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initializeOpenGL(result)
            "applyLiquidGlass" -> applyLiquidGlassEffect(call, result)
            "applyFullScreenLiquidGlass" -> applyFullScreenLiquidGlass(call, result)
            "updateParameters" -> updateParameters(call, result)
            "startRealTimeEffect" -> startRealTimeEffect(result)
            "stopRealTimeEffect" -> stopRealTimeEffect(result)
            "dispose" -> dispose(result)
            else -> result.notImplemented()
        }
    }

    private fun initializeOpenGL(result: Result) {
        try {
            // Initialize OpenGL shader program
            val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShaderCode)
            val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderCode)
            
            program = GLES20.glCreateProgram()
            GLES20.glAttachShader(program, vertexShader)
            GLES20.glAttachShader(program, fragmentShader)
            GLES20.glLinkProgram(program)
            
            // Get uniform locations
            uResolutionLocation = GLES20.glGetUniformLocation(program, "uResolution")
            uMouseLocation = GLES20.glGetUniformLocation(program, "uMouse")
            uEffectSizeLocation = GLES20.glGetUniformLocation(program, "uEffectSize")
            uBlurIntensityLocation = GLES20.glGetUniformLocation(program, "uBlurIntensity")
            uDispersionStrengthLocation = GLES20.glGetUniformLocation(program, "uDispersionStrength")
            uGlassIntensityLocation = GLES20.glGetUniformLocation(program, "uGlassIntensity")
            uTextureLocation = GLES20.glGetUniformLocation(program, "uTexture")
            
            // Create vertex buffer
            val vertices = floatArrayOf(
                -1.0f, -1.0f, 0.0f,
                 1.0f, -1.0f, 0.0f,
                -1.0f,  1.0f, 0.0f,
                 1.0f,  1.0f, 0.0f
            )
            vertexBuffer = ByteBuffer.allocateDirect(vertices.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
            vertexBuffer?.put(vertices)
            vertexBuffer?.position(0)
            
            // Create texture coordinate buffer
            val textureCoords = floatArrayOf(
                0.0f, 1.0f,
                1.0f, 1.0f,
                0.0f, 0.0f,
                1.0f, 0.0f
            )
            textureBuffer = ByteBuffer.allocateDirect(textureCoords.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
            textureBuffer?.put(textureCoords)
            textureBuffer?.position(0)
            
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize OpenGL: ${e.message}", null)
        }
    }

    private fun applyLiquidGlassEffect(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as Map<String, Any>
            val imageData = args["imageData"] as ByteArray
            width = (args["width"] as Double).toFloat()
            height = (args["height"] as Double).toFloat()
            effectSize = (args["effectSize"] as Double).toFloat()
            blurIntensity = (args["blurIntensity"] as Double).toFloat()
            dispersionStrength = (args["dispersionStrength"] as Double).toFloat()
            glassIntensity = (args["glassIntensity"] as Double).toFloat()
            mouseX = (args["mouseX"] as Double).toFloat()
            mouseY = (args["mouseY"] as Double).toFloat()
            
            // Convert byte array to bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            
            // Create OpenGL texture
            val textureIds = IntArray(1)
            GLES20.glGenTextures(1, textureIds, 0)
            textureId = textureIds[0]
            
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId)
            GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            
            // Apply liquid glass shader
            val processedBitmap = applyLiquidGlassShader(bitmap)
            
            // Convert back to byte array
            val outputStream = java.io.ByteArrayOutputStream()
            processedBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val processedImageData = outputStream.toByteArray()
            
            result.success(mapOf(
                "success" to true,
                "imageData" to processedImageData
            ))
            
            // Cleanup
            bitmap.recycle()
            processedBitmap.recycle()
            GLES20.glDeleteTextures(1, intArrayOf(textureId), 0)
            
        } catch (e: Exception) {
            result.error("SHADER_ERROR", "Failed to apply liquid glass effect: ${e.message}", null)
        }
    }

    private fun applyLiquidGlassShader(bitmap: Bitmap): Bitmap {
        val outputBitmap = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        
        // Set up OpenGL viewport
        GLES20.glViewport(0, 0, bitmap.width, bitmap.height)
        GLES20.glUseProgram(program)
        
        // Set uniforms
        GLES20.glUniform2f(uResolutionLocation, width, height)
        GLES20.glUniform2f(uMouseLocation, mouseX, mouseY)
        GLES20.glUniform1f(uEffectSizeLocation, effectSize)
        GLES20.glUniform1f(uBlurIntensityLocation, blurIntensity)
        GLES20.glUniform1f(uDispersionStrengthLocation, dispersionStrength)
        GLES20.glUniform1f(uGlassIntensityLocation, glassIntensity)
        GLES20.glUniform1i(uTextureLocation, 0)
        
        // Bind texture
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId)
        
        // Set up vertex attributes
        val positionHandle = GLES20.glGetAttribLocation(program, "vPosition")
        GLES20.glEnableVertexAttribArray(positionHandle)
        GLES20.glVertexAttribPointer(positionHandle, 3, GLES20.GL_FLOAT, false, 0, vertexBuffer)
        
        val textureHandle = GLES20.glGetAttribLocation(program, "vTexCoord")
        GLES20.glEnableVertexAttribArray(textureHandle)
        GLES20.glVertexAttribPointer(textureHandle, 2, GLES20.GL_FLOAT, false, 0, textureBuffer)
        
        // Draw
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        
        // Read pixels back to bitmap
        val pixels = IntArray(bitmap.width * bitmap.height)
        GLES20.glReadPixels(0, 0, bitmap.width, bitmap.height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, 
            java.nio.IntBuffer.wrap(pixels))
        
        outputBitmap.setPixels(pixels, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
        
        return outputBitmap
    }

    private fun applyFullScreenLiquidGlass(call: MethodCall, result: Result) {
        // Implementation for full screen effect
        result.success(true)
    }

    private fun updateParameters(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as Map<String, Any>
            effectSize = (args["effectSize"] as Double).toFloat()
            blurIntensity = (args["blurIntensity"] as Double).toFloat()
            dispersionStrength = (args["dispersionStrength"] as Double).toFloat()
            glassIntensity = (args["glassIntensity"] as Double).toFloat()
            mouseX = (args["mouseX"] as Double).toFloat()
            mouseY = (args["mouseY"] as Double).toFloat()
            result.success(true)
        } catch (e: Exception) {
            result.error("PARAM_ERROR", "Failed to update parameters: ${e.message}", null)
        }
    }

    private fun startRealTimeEffect(result: Result) {
        result.success(true)
    }

    private fun stopRealTimeEffect(result: Result) {
        result.success(true)
    }

    private fun dispose(result: Result) {
        try {
            if (program != 0) {
                GLES20.glDeleteProgram(program)
                program = 0
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("DISPOSE_ERROR", "Failed to dispose: ${e.message}", null)
        }
    }

    private fun loadShader(type: Int, shaderCode: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, shaderCode)
        GLES20.glCompileShader(shader)
        return shader
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val vertexShaderCode = """
            attribute vec4 vPosition;
            attribute vec2 vTexCoord;
            varying vec2 vTexCoordVarying;
            void main() {
                gl_Position = vPosition;
                vTexCoordVarying = vTexCoord;
            }
        """

        private const val fragmentShaderCode = """
            precision mediump float;
            uniform vec2 uResolution;
            uniform vec2 uMouse;
            uniform float uEffectSize;
            uniform float uBlurIntensity;
            uniform float uDispersionStrength;
            uniform float uGlassIntensity;
            uniform sampler2D uTexture;
            varying vec2 vTexCoordVarying;

            void main() {
                vec2 fragCoord = vTexCoordVarying * uResolution;
                vec2 uv = fragCoord / uResolution;
                vec2 center = uMouse / uResolution;
                vec2 m2 = (uv - center);
                
                // Create rounded box effect
                float effectRadius = uEffectSize * 0.5;
                float sizeMultiplier = 1.0 / (effectRadius * effectRadius);
                float roundedBox = pow(abs(m2.x * uResolution.x / uResolution.y), 4.0) +
                                  pow(abs(m2.y), 4.0);
                
                // Calculate different zones
                float baseIntensity = 100.0 * sizeMultiplier;
                float rb1 = clamp((1.0 - roundedBox * baseIntensity) * 8.0, 0.0, 1.0);
                float rb2 = clamp((0.95 - roundedBox * baseIntensity * 0.95) * 16.0, 0.0, 1.0) -
                            clamp(pow(0.9 - roundedBox * baseIntensity * 0.95, 1.0) * 16.0, 0.0, 1.0);
                float rb3 = clamp((1.5 - roundedBox * baseIntensity * 1.1) * 2.0, 0.0, 1.0) -
                            clamp(pow(1.0 - roundedBox * baseIntensity * 1.1, 1.0) * 2.0, 0.0, 1.0);
                
                vec4 colorResult = texture2D(uTexture, uv);
                
                if (rb1 + rb2 > 0.0) {
                    // Lens distortion effect
                    float distortionStrength = 50.0 * sizeMultiplier;
                    vec2 lens = ((uv - 0.5) * (1.0 - roundedBox * distortionStrength) + 0.5);
                    
                    // Enhanced chromatic dispersion
                    vec2 dir = normalize(m2);
                    float dispersionScale = uDispersionStrength * 0.05;
                    float dispersionMask = smoothstep(0.3, 0.7, roundedBox * baseIntensity);
                    
                    vec2 redOffset = dir * dispersionScale * 2.0 * dispersionMask;
                    vec2 greenOffset = dir * dispersionScale * 1.0 * dispersionMask;
                    vec2 blueOffset = dir * dispersionScale * -1.5 * dispersionMask;
                    
                    // Blur sampling with chromatic dispersion
                    if (uBlurIntensity > 0.0) {
                        float blurRadius = uBlurIntensity / max(uResolution.x, uResolution.y);
                        vec3 colorSum = vec3(0.0);
                        float total = 0.0;
                        for (float x = -2.0; x <= 2.0; x += 1.0) {
                            for (float y = -2.0; y <= 2.0; y += 1.0) {
                                vec2 offset = vec2(x, y) * blurRadius;
                                colorSum.r += texture2D(uTexture, lens + offset + redOffset).r;
                                colorSum.g += texture2D(uTexture, lens + offset + greenOffset).g;
                                colorSum.b += texture2D(uTexture, lens + offset + blueOffset).b;
                                total += 1.0;
                            }
                        }
                        colorResult = vec4(colorSum / total, 1.0);
                    } else {
                        colorResult.r = texture2D(uTexture, lens + redOffset).r;
                        colorResult.g = texture2D(uTexture, lens + greenOffset).g;
                        colorResult.b = texture2D(uTexture, lens + blueOffset).b;
                        colorResult.a = 1.0;
                    }
                    
                    // Add lighting effects
                    float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0.0, 1.0) +
                                    clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0.0, 1.0);
                    
                    colorResult = mix(
                        texture2D(uTexture, uv),
                        colorResult,
                        rb1
                    );
                    colorResult = clamp(colorResult + vec4(rb2 * 0.3) + vec4(gradient * 0.2), 0.0, 1.0);
                }
                
                gl_FragColor = colorResult;
            }
        """
    }
}
