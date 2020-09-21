import UIKit

typealias FaceOutput = [CIImage]

// MARK: - FaceNet
final class FaceNet {
    
    private var tfFacenet: tfWrap?
    
    // MARK: - Methods
    func load() {
        clean()
        tfFacenet = tfWrap()
        tfFacenet?.loadModel("modelFacenet.pb",
                             labels: nil,
                             memMapped: false,
                             optEnv: true)
        tfFacenet?.setInputLayer("input",
                                 outputLayer: "embeddings")
    }
    
    func run(image: CIImage) -> [Double] {
        let inputEdge = 160
        guard let tfFacenet = tfFacenet,
            let resize = image.resizeImage(newWidth: CGFloat(inputEdge),
                                           newHeight: CGFloat(inputEdge))?.cgImage else { return [] }
        let input = CIImage(cgImage: resize)
        var buffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            inputEdge,
                            inputEdge,
                            kCVPixelFormatType_32BGRA,
                            [String(kCVPixelBufferIOSurfacePropertiesKey): [:]] as CFDictionary,
                            &buffer)
        if let buffer = buffer { CIContext().render(input, to: buffer) }
        guard let network_output = tfFacenet.run(onFrame: buffer) else { return [] }
        let output = network_output.compactMap {
            ($0 as? NSNumber)?.doubleValue
        }
        return output
    }
    
    func clean() {
        tfFacenet?.clean()
        tfFacenet = nil
    }
    
    func loadedModel() -> Bool {
        return tfFacenet != nil
    }
    
}

// MARK: - FaceDetector
final class FaceDetector {
    
    private let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                          context: nil,
                                          options: [ CIDetectorAccuracy: CIDetectorAccuracyLow ])
    
    func extractFaces(frame: CIImage) -> FaceOutput {
        guard let features = faceDetector?.features(in: frame,
                                                    options: [CIDetectorSmile: true]) as?
                                                        [CIFaceFeature] else {
                                                        return []
        }
        return features.map({ (f) -> CIImage in
            let rect = f.bounds
            let cropped = frame.cropped(to: rect)
            let face = cropped.transformed(by: CGAffineTransform(translationX: -rect.origin.x,
                                                                 y: -rect.origin.y))
            return face
        })
    }
}
