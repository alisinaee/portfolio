import Flutter
import UIKit
import Metal
import MetalKit
import simd

public class LiquidGlassPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var pipelineState: MTLRenderPipelineState?
    private var texture: MTLTexture?
    
    // Shader parameters
    private var effectSize: Float = 2.0
    private var blurIntensity: Float = 0.5
    private var dispersionStrength: Float = 0.1
    private var glassIntensity: Float = 0.3
    private var mouseX: Float = 0.0
    private var mouseY: Float = 0.0
    private var width: Float = 0.0
    private var height: Float = 0.0
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "liquid_glass_shader", binaryMessenger: registrar.messenger())
        let instance = LiquidGlassPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initializeMetal(result: result)
        case "applyLiquidGlass":
            applyLiquidGlassEffect(call: call, result: result)
        case "applyFullScreenLiquidGlass":
            applyFullScreenLiquidGlass(call: call, result: result)
        case "updateParameters":
            updateParameters(call: call, result: result)
        case "startRealTimeEffect":
            startRealTimeEffect(result: result)
        case "stopRealTimeEffect":
            stopRealTimeEffect(result: result)
        case "dispose":
            dispose(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeMetal(result: @escaping FlutterResult) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            result(FlutterError(code: "INIT_ERROR", message: "Metal is not supported on this device", details: nil))
            return
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        // Create render pipeline state
        let library = device.makeDefaultLibrary()
        guard let vertexFunction = library?.makeFunction(name: "vertex_main"),
              let fragmentFunction = library?.makeFunction(name: "fragment_main") else {
            result(FlutterError(code: "INIT_ERROR", message: "Failed to load shader functions", details: nil))
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            result(true)
        } catch {
            result(FlutterError(code: "INIT_ERROR", message: "Failed to create pipeline state: \(error)", details: nil))
        }
    }
    
    private func applyLiquidGlassEffect(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let device = device,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState else {
            result(FlutterError(code: "SHADER_ERROR", message: "Metal not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let imageData = args["imageData"] as? FlutterStandardTypedData,
              let width = args["width"] as? Double,
              let height = args["height"] as? Double,
              let effectSize = args["effectSize"] as? Double,
              let blurIntensity = args["blurIntensity"] as? Double,
              let dispersionStrength = args["dispersionStrength"] as? Double,
              let glassIntensity = args["glassIntensity"] as? Double,
              let mouseX = args["mouseX"] as? Double,
              let mouseY = args["mouseY"] as? Double else {
            result(FlutterError(code: "SHADER_ERROR", message: "Invalid arguments", details: nil))
            return
        }
        
        // Update parameters
        self.width = Float(width)
        self.height = Float(height)
        self.effectSize = Float(effectSize)
        self.blurIntensity = Float(blurIntensity)
        self.dispersionStrength = Float(dispersionStrength)
        self.glassIntensity = Float(glassIntensity)
        self.mouseX = Float(mouseX)
        self.mouseY = Float(mouseY)
        
        do {
            // Create texture from image data
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: Int(width),
                height: Int(height),
                mipmapped: false
            )
            textureDescriptor.usage = [.shaderRead, .shaderWrite]
            
            guard let inputTexture = device.makeTexture(descriptor: textureDescriptor) else {
                result(FlutterError(code: "SHADER_ERROR", message: "Failed to create input texture", details: nil))
                return
            }
            
            // Copy image data to texture
            let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                                 size: MTLSize(width: Int(width), height: Int(height), depth: 1))
            inputTexture.replace(region: region, mipmapLevel: 0, withBytes: imageData.data, bytesPerRow: Int(width) * 4)
            
            // Create output texture
            guard let outputTexture = device.makeTexture(descriptor: textureDescriptor) else {
                result(FlutterError(code: "SHADER_ERROR", message: "Failed to create output texture", details: nil))
                return
            }
            
            // Apply liquid glass shader
            let processedImageData = try applyLiquidGlassShader(
                inputTexture: inputTexture,
                outputTexture: outputTexture,
                device: device,
                commandQueue: commandQueue,
                pipelineState: pipelineState
            )
            
            result([
                "success": true,
                "imageData": processedImageData
            ])
            
        } catch {
            result(FlutterError(code: "SHADER_ERROR", message: "Failed to apply liquid glass effect: \(error)", details: nil))
        }
    }
    
    private func applyLiquidGlassShader(
        inputTexture: MTLTexture,
        outputTexture: MTLTexture,
        device: MTLDevice,
        commandQueue: MTLCommandQueue,
        pipelineState: MTLRenderPipelineState
    ) throws -> Data {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: createRenderPassDescriptor(outputTexture: outputTexture)) else {
            throw NSError(domain: "LiquidGlassPlugin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create command buffer"])
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(inputTexture, index: 0)
        
        // Set shader uniforms
        var uniforms = LiquidGlassUniforms(
            resolution: SIMD2<Float>(width, height),
            mouse: SIMD2<Float>(mouseX, mouseY),
            effectSize: effectSize,
            blurIntensity: blurIntensity,
            dispersionStrength: dispersionStrength,
            glassIntensity: glassIntensity
        )
        
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<LiquidGlassUniforms>.size, index: 0)
        
        // Draw full screen quad
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Read back the processed texture
        return try readTextureData(texture: outputTexture)
    }
    
    private func createRenderPassDescriptor(outputTexture: MTLTexture) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        return renderPassDescriptor
    }
    
    private func readTextureData(texture: MTLTexture) throws -> Data {
        let bytesPerPixel = 4
        let bytesPerRow = texture.width * bytesPerPixel
        let totalBytes = bytesPerRow * texture.height
        
        var imageData = Data(count: totalBytes)
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                              size: MTLSize(width: texture.width, height: texture.height, depth: 1))
        
        imageData.withUnsafeMutableBytes { bytes in
            texture.getBytes(bytes.bindMemory(to: UInt8.self).baseAddress!,
                           bytesPerRow: bytesPerRow,
                           from: region,
                           mipmapLevel: 0)
        }
        
        return imageData
    }
    
    private func applyFullScreenLiquidGlass(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Implementation for full screen effect
        result(true)
    }
    
    private func updateParameters(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "PARAM_ERROR", message: "Invalid arguments", details: nil))
            return
        }
        
        if let effectSize = args["effectSize"] as? Double { self.effectSize = Float(effectSize) }
        if let blurIntensity = args["blurIntensity"] as? Double { self.blurIntensity = Float(blurIntensity) }
        if let dispersionStrength = args["dispersionStrength"] as? Double { self.dispersionStrength = Float(dispersionStrength) }
        if let glassIntensity = args["glassIntensity"] as? Double { self.glassIntensity = Float(glassIntensity) }
        if let mouseX = args["mouseX"] as? Double { self.mouseX = Float(mouseX) }
        if let mouseY = args["mouseY"] as? Double { self.mouseY = Float(mouseY) }
        
        result(true)
    }
    
    private func startRealTimeEffect(result: @escaping FlutterResult) {
        result(true)
    }
    
    private func stopRealTimeEffect(result: @escaping FlutterResult) {
        result(true)
    }
    
    private func dispose(result: @escaping FlutterResult) {
        device = nil
        commandQueue = nil
        pipelineState = nil
        texture = nil
        result(true)
    }
}

// Shader uniforms structure
struct LiquidGlassUniforms {
    var resolution: SIMD2<Float>
    var mouse: SIMD2<Float>
    var effectSize: Float
    var blurIntensity: Float
    var dispersionStrength: Float
    var glassIntensity: Float
}
