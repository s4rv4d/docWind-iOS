//
//  CustomCameraController.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit
import AVFoundation
import MetalKit
import CoreImage.CIFilterBuiltins
//import YesWeScan
import CoreGraphics
import CoreImage


// MARK: - Protocol
protocol CustomCameraDelegate {
    func sendDataBack(uiimage: UIImage)
}


class CustomCameraController: UIViewController {
    
    // MARK: - Properties
    var image: UIImage?
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureVideoDataOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var imageCapturer: ImageCapturer?
    private var rectangleFeatures: [RectangleFeature2] = []
    private var isStopped = false
    public let progress = Progress()
    private let imageQueue = DispatchQueue(label: "imageQueue")
    public var desiredJitter: CGFloat = 100 {
        didSet { progress.completedUnitCount = Int64(desiredJitter) }
    }
    public var featuresRequired = 7
    
    private let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [
        CIDetectorAccuracy: CIDetectorAccuracyHigh,
        CIDetectorMaxFeatureCount: 10

        // swiftlint:disable:next force_unwrapping
    ])!
    
    var didTap = false
    
    // MARK: - METAL
    let mtkView = MTKView()
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    
    // MARK: - CoreImage
    var ciContext: CIContext?
    var currentCIImage : CIImage?
    
    // MARK: - Delegate
    var mainDelegate: CustomCameraDelegate?
    
    // MARK: - Filters
    let sepiaFilter = CIFilter(name: "CISepiaTone")
    var filterIndex = 0
    let filters:[CIFilter?] = [nil, CIFilter.sepiaTone(), CIFilter.photoEffectNoir()]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainSetup()
    }
    
    // MARK: - Methods
    func setup() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCaptureSession()
            self.captureSession.beginConfiguration()
            self.setupDevice()
            self.setupInputOutput()
            self.setupPreviewLayer()
            self.captureSession.commitConfiguration()
            self.startRunningCaptureSession()
        }
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = .photo
        imageCapturer = ImageCapturer(session: captureSession)
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: .back)

        for device in deviceDiscoverySession.devices {
            print(device)
            switch device.position {
            case .front:
                self.frontCamera = device
            case .back:
                self.backCamera = device
            default:
                break
            }
        }
        
        self.currentCamera = self.backCamera
        setupInputOutput()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touching screen ...")
        let touchPoint = touches.first! as UITouch
        let screenSize = mtkView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: mtkView).y / screenSize.height, y: 1.0 - touchPoint.location(in: mtkView).x / screenSize.width)

        if let device = self.currentCamera {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                }
                device.unlockForConfiguration()

            } catch {
                // Handle errors here
                print("error in focus point \(error.localizedDescription)")
            }
        }
    }
    
    func setupInputOutput() {
        do {
            guard let curr = currentCamera else { fatalError("Error unwrapping optional avcapturedevice") }
            let captureDeviceInput = try AVCaptureDeviceInput(device: curr)
            captureSession.addInput(captureDeviceInput)
            
            /// OLD CODE
            //photoOutput = AVCapturePhotoOutput()
            //photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            //guard let po = photoOutput else { fatalError("Error unwrapping photoOutput") }
            //captureSession.addOutput(po)
            
            videoOutput = AVCaptureVideoDataOutput()
            captureSession.addOutput(videoOutput!)
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
                
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
            videoOutput!.setSampleBufferDelegate(self, queue: videoQueue)
            videoOutput!.connections.first?.videoOrientation = .portrait
            
            //commit config
            captureSession.commitConfiguration()
            
        } catch {
            print("ERROR WHILE SETTING INPUT OUTPUT: \(error.localizedDescription)")
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer!.connection?.videoOrientation = .portrait
        cameraPreviewLayer!.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func settingUpMetalView() {
        
        defer {
            setupMetal()
        }
        
        view.backgroundColor = .white
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mtkView)
        
        // adding constraints
        NSLayoutConstraint.activate([
            mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mtkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mtkView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
    }
    
    func setupMetal() {
        
        defer {
            setupCoreImage()
        }
        
        // fetching default gpu of device
        metalDevice = MTLCreateSystemDefaultDevice()
        
        // telling mtkview which gpu to use
        mtkView.device = metalDevice
        
        // telling the mtkview to update continously
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = false
        
        // setup up pipeline to device to executr instructions
        metalCommandQueue = metalDevice.makeCommandQueue()
        
        mtkView.delegate = self
        
        // lets its drawable texture be written too
        mtkView.framebufferOnly = false
    }
    
    func setupCoreImage() {
        ciContext = CIContext(mtlDevice: metalDevice!)
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    func didTapRecord() {
        /// OLD CODE
        //let settings = AVCapturePhotoSettings()
        //self.photoOutput?.capturePhoto(with: settings, delegate: delegate!) // we are using the second del
        didTap = true
        
    }
    
    func mainSetup() {
        DispatchQueue.global(qos: .userInitiated).async {
            /// start configuration
            self.captureSession.beginConfiguration()
            /// config
            
            /// preset selection check
            if self.captureSession.canSetSessionPreset(.photo) {
                self.setupCaptureSession()
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            /// setting up device
            self.setupDevice()
            
            DispatchQueue.main.async {
                /// OLD CODE
                //self.setupPreviewLayer()
                self.settingUpMetalView()
            }
            
            /// commit config
            self.captureSession.commitConfiguration()
            /// start running
            self.captureSession.startRunning()
        }
    }
    
    func setupFilters() {
        sepiaFilter?.setValue(NSNumber(value: 1), forKey: "inputIntensity")
    }
    
    func applyFilter(inputImage image: CIImage, index: Int) -> CIImage? {
        var filteredImage: CIImage?
        /// applying filters
        filters[index]?.setValue(image, forKey: kCIInputImageKey)
        filteredImage = filters[index]?.outputImage
        
        return filteredImage
    }
}

// MARK: - Extensions
extension CustomCameraController: MTKViewDelegate {
    
    // MARK: - Delegate functions
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // tells us when the drawable size changes
    }
    
    func draw(in view: MTKView) {
        // this is where we render screen
        
        /// create command buffer for ciContext to use to encode its rendering instructions to our GPU
        guard let commandBuffer = metalCommandQueue?.makeCommandBuffer() else { return }
        
        /// making sure we have a CIImage to wok with
        guard let ciImage = currentCIImage else { return }
        
        /// make sure the current drawable object for this metal view is avaliable
        guard let currentDrawable = view.currentDrawable else { return }
        
        /// make sure frame is centered on screen
        let heightOfciImage = ciImage.extent.height
        let heightOfDrawable = view.drawableSize.height
        let yOffsetFromBottom = (heightOfDrawable - heightOfciImage)
        
        /// not being used
//        let destRect = view.bounds.applying(CGAffineTransform(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))
        /// render into metal texture
        self.ciContext?.render(ciImage, to: currentDrawable.texture, commandBuffer: commandBuffer, bounds: CGRect(origin: CGPoint(x: 0, y: -yOffsetFromBottom), size: CGSize(width: .max, height: .max)), colorSpace: CGColorSpaceCreateDeviceRGB())
        
        /// register where to draw the instructions in the command buffer once it executes
        commandBuffer.present(currentDrawable)
        /// commiting the command to the queue
        commandBuffer.commit()
    }
}

extension CustomCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        //try and get a CVImageBuffer out of the sample buffer
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // get a CIImage out of a CIImageBuffer
        let ciimage = CIImage(cvImageBuffer: cvBuffer)
        
        
        // add filter
        
        DispatchQueue.main.async {
            if self.filterIndex != 0 {
                if let filteredImage = self.applyFilter(inputImage: ciimage, index: self.filterIndex) {
                    self.currentCIImage = filteredImage  //filteredImage
                } else {
                    
                }
            } else {
                self.currentCIImage = ciimage  //filteredImage
            }
            
            self.mtkView.draw()
        }
        
        let context = CIContext()
        guard self.currentCIImage != nil else { return }
        guard let cgImage = context.createCGImage(self.currentCIImage!, from: currentCIImage!.extent) else { return }
        
         //get uiimage image out of ciimage
//        let uiimage = UIImage(cgImage: cgImage) --> not being used

        //let uiimage = UIImage(ciImage: ciimage)
        
        if !didTap {
            return // we have nothing to do with the image buffer
        }
        
        let feature = detector.features(in: ciimage)
            .compactMap { $0 as? CIRectangleFeature }
            .map(RectangleFeature2.init)
            .max()
            .map {
                $0.normalized(source: ciimage.extent.size,
                              target: UIScreen.main.bounds.size)
            }
            .flatMap { smooth(feature: $0, in: ciimage) }
        
        captureImage(in: feature) { [self] (image) in
            mainDelegate?.sendDataBack(uiimage: image)
        }
        
//        mainDelegate?.sendDataBack(uiimage: uiimage)
        didTap = false
    }
    
    func smooth(feature: RectangleFeature2?, in image: CIImage) -> RectangleFeature2? {
        guard let feature = feature else { return nil }

        let smoothed = feature.smoothed(with: &rectangleFeatures)
        progress.totalUnitCount = Int64(rectangleFeatures.jitter)

        if rectangleFeatures.count > featuresRequired,
            rectangleFeatures.jitter < desiredJitter,
            isStopped == false,
            let delegate = mainDelegate {
            print("here sarvad")
            pause()

            captureImage(in: smoothed) { [delegate] image in
                print("erhererh")
                delegate.sendDataBack(uiimage: image)
            }
        }

        return smoothed
    }
}
//
//private var destRect: CGRect {
//let scale: CGFloat
//if UIScreen.main.scale == 3 {
//// BUG?
//            scale = 2.0 * (2.0 / UIScreen.mainScreen().scale) * 2
//        } else {
//            scale = UIScreen.main.scale
//        }
//let destRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(scale, scale))
//return destRect
//    }
//}



extension Array where Element == RectangleFeature2 {
    // Difference of all elements vs. average
    var jitter: CGFloat {
        let averageElement = average
        let diffs = map { $0.difference(to: averageElement) }
        return diffs.reduce(0, +)
    }

    var average: RectangleFeature2 {
        // Calculates the mean Rectangle Feature. Maybe the median is better...
        reduce(RectangleFeature2(), +) / CGFloat(count)
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs // swiftlint:disable:this shorthand_operator
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

func abs(_ point: CGPoint) -> CGFloat {
    abs(point.x) + abs(point.y)
}




public struct RectangleFeature2 {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint

    
    init(topLeft: CGPoint = .zero,
         topRight: CGPoint = .zero,
         bottomLeft: CGPoint = .zero,
         bottomRight: CGPoint = .zero) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
}

extension RectangleFeature2 {
    static func + (lhs: RectangleFeature2, rhs: RectangleFeature2) -> RectangleFeature2 {
        RectangleFeature2(topLeft: lhs.topLeft + rhs.topLeft,
                         topRight: lhs.topRight + rhs.topRight,
                         bottomLeft: lhs.bottomLeft + rhs.bottomLeft,
                         bottomRight: lhs.bottomRight + rhs.bottomRight)
    }

    static func / (lhs: RectangleFeature2, rhs: CGFloat) -> RectangleFeature2 {
        RectangleFeature2(topLeft: lhs.topLeft / rhs,
                         topRight: lhs.topRight / rhs,
                         bottomLeft: lhs.bottomLeft / rhs,
                         bottomRight: lhs.bottomRight / rhs)
    }
}

extension RectangleFeature2 {
    init(_ rectangleFeature: CIRectangleFeature) {
        topLeft = rectangleFeature.topLeft
        topRight = rectangleFeature.topRight
        bottomLeft = rectangleFeature.bottomLeft
        bottomRight = rectangleFeature.bottomRight
    }

    func smoothed(with previous: inout [RectangleFeature2]) -> RectangleFeature2 {

        let allFeatures = [self] + previous
        let smoothed = allFeatures.average
        previous = Array(allFeatures.prefix(10))

        return smoothed
    }

    func normalized(source: CGSize, target: CGSize) -> RectangleFeature2 {
        // Since the source and target sizes have different aspect ratios,
        // source must be normalized. It behaves like
        // `UIView.ContentMode.aspectFill`, truncating portions that don't fit
        let normalizedSource = CGSize(width: source.height * target.aspectRatio,
                                      height: source.height)
        let xShift = (normalizedSource.width - source.width) / 2
        let yShift = (normalizedSource.height - source.height) / 2

        let distortion = CGVector(dx: target.width / normalizedSource.width,
                                  dy: target.height / normalizedSource.height)

        func normalize(_ point: CGPoint) -> CGPoint {
            return point
                .yAxisInverted(source.height)
                .shifted(by: CGPoint(x: xShift, y: yShift))
                .distorted(by: distortion)
        }

        return RectangleFeature2(
            topLeft: normalize(topLeft),
            topRight: normalize(topRight),
            bottomLeft: normalize(bottomLeft),
            bottomRight: normalize(bottomRight)
        )
    }

    public var bezierPath: UIBezierPath {

        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()

        return path
    }

    public func difference(to: RectangleFeature2) -> CGFloat {
            return
                abs(to.topLeft - topLeft) +
                abs(to.topRight - topRight) +
                abs(to.bottomLeft - bottomLeft) +
                abs(to.bottomRight - bottomRight)
    }

    /// This isn't the real area, but enables correct comparison
    private var areaQualifier: CGFloat {
        let diagonalToLeft = (topRight - bottomLeft)
        let diagonalToRight = (topLeft - bottomRight)
        let phi = diagonalToLeft.x * diagonalToRight.x
            + diagonalToLeft.y * diagonalToRight.y
            / (diagonalToLeft.length * diagonalToRight.length)
        return sqrt(1 - phi * phi) * diagonalToLeft.length * diagonalToRight.length
    }
}

extension RectangleFeature2: Comparable {
    public static func < (lhs: RectangleFeature2, rhs: RectangleFeature2) -> Bool {
        return lhs.areaQualifier < rhs.areaQualifier
    }

    public static func == (lhs: RectangleFeature2, rhs: RectangleFeature2) -> Bool {
        return lhs.topLeft == rhs.topLeft
            && lhs.topRight == rhs.topRight
            && lhs.bottomLeft == rhs.bottomLeft
            && lhs.bottomRight == rhs.bottomRight
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        return width / height
    }
}

extension CGPoint {
    func distorted(by distortion: CGVector) -> CGPoint {
        return CGPoint(x: x * distortion.dx, y: y * distortion.dy)
    }

    func yAxisInverted(_ maxY: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: maxY - y)
    }

    func shifted(by shiftAmount: CGPoint) -> CGPoint {
        return CGPoint(x: x + shiftAmount.x, y: y + shiftAmount.y)
    }

    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}




final class ImageCapturer: NSObject {
    private var feature: RectangleFeature2?
    private var imageClosure: ((UIImage) -> Void)

    private let output: AVCapturePhotoOutput

    init(session: AVCaptureSession) {
        let output = AVCapturePhotoOutput()
        output.isHighResolutionCaptureEnabled = true
        session.addOutput(output)
        self.output = output
        imageClosure = { _ in }

        super.init()
    }

    func captureImage(in rectangleFeature: RectangleFeature2?, completion: @escaping (UIImage) -> Void) {
        feature = rectangleFeature
        imageClosure = completion

        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true

        output.capturePhoto(with: settings, delegate: self)
    }
}

extension ImageCapturer: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {

        guard let sampleBuffer = photoSampleBuffer,
            let imageData = AVCapturePhotoOutput
                .jpegPhotoDataRepresentation(
                    forJPEGSampleBuffer: sampleBuffer,
                    previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let image = CIImage(data: imageData)?.oriented(forExifOrientation: 6)
            else { return }

        let processed: CIImage
        if let feature = feature {
            let normalized = feature.normalized(source: UIScreen.main.bounds.size,
                                                target: image.extent.size)

            processed = image
                .applyingFilter("CIPerspectiveCorrection", parameters: [
                    "inputTopLeft": CIVector(cgPoint: normalized.topLeft),
                    "inputTopRight": CIVector(cgPoint: normalized.topRight),
                    "inputBottomLeft": CIVector(cgPoint: normalized.bottomLeft),
                    "inputBottomRight": CIVector(cgPoint: normalized.bottomRight)
                ])
        } else {
            processed = image
        }

        // This is necessary because most UIKit functionality expects UIImages
        // that have the cgImage property set
        if let cgImage = CIContext().createCGImage(processed, from: processed.extent) {
            imageClosure(UIImage(cgImage: cgImage))
        }
    }
}


public protocol DocumentScanner {

    /// Jitter of automatic capture. Higher values will capture images faster,
    /// but will reduce quality. Default value is 100.
    var desiredJitter: CGFloat { get set }

    /// A value that controls the desiered features captured before pausing
    /// the camera and use the capture.
    var featuresRequired: Int { get set }

    /// A layer for preview in the view controller. The scanner assumes that
    /// this will have the same bounds as the device's screen
//    var previewLayer: CALayer { get }

    /// Indicates the progress of the scan
    var progress: Progress { get }

    /// Manually capture an image in given bounds
    ///
    /// - Parameters:
    ///   - bounds: In the coordinate space of the screen
    ///   - completion: Called with the captured image
    func captureImage(in bounds: RectangleFeature2?, completion: @escaping (UIImage) -> Void)

    /// Creates a scanner with the supplied, immutable delegate
    ///
    /// - Parameter delegate: Is captured using a weak pointer
//    init(sessionPreset: AVCaptureSession.Preset, delegate: DocumentScannerDelegate)
//
//    func start()
    func pause()
//    func stop()
}


public protocol DocumentScannerDelegate: AnyObject {

    /// Called when the scanner successfully found an image
    ///
    /// - Parameter image: The image that was found
    func didCapture(image: UIImage)

    /// Use this method to display a preview border of the image that is about
    /// to be recognized
    ///
    /// - Parameters:
    ///   - feature: The extent of the image that is being recognized
    ///   - image: The image that contains the image to be recognized
    func didRecognize(feature: RectangleFeature2?, in image: CIImage)
}


extension CustomCameraController: DocumentScanner {
    
    public func captureImage(in bounds: RectangleFeature2?, completion: @escaping (UIImage) -> Void) {
        imageCapturer!.captureImage(in: bounds, completion: completion)
    }
    
    public func pause() {
        isStopped = true
    }
}
