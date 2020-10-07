//
//  FrameViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import FaceCropper
import ProgressHUD

class FrameViewController: UIViewController {
    
    deinit {
        print("FrameViewController deinit")
    }
    
    var currentFrame: UIImage?
    @IBOutlet weak var previewView: PreviewView!
    //    private var faceDetectionRequest: VNRequest!
    private var devicePosition: AVCaptureDevice.Position = .front
    
    
    // Session Management
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var session: AVCaptureSession!
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    
    private var setupResult: SessionSetupResult = .success
    
    private var videoDeviceInput:   AVCaptureDeviceInput!
    
    private var videoDataOutput:    AVCaptureVideoDataOutput!
    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
    
    private var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) 
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        fnet.load()
        print("Number of kMeans: \(kMeanVectors.count)")
        session = AVCaptureSession()
        previewView.session = session
        
        // Set up Vision Request
        setupVision()
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
        case .authorized:
            break
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
            
        default:
            setupResult = .notAuthorized
        }
        
        
        sessionQueue.async {() -> Void in
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sessionQueue.async {() -> Void in
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let    alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        fnet.clean()
        super.viewDidDisappear(animated)
        sessionQueue.async {[weak self]()  -> Void in
            guard let self = self else { return }
            if self.setupResult == .success {
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
                self.stopCaptureSession()
            }
        }
    }
    
    fileprivate func stopCaptureSession() {
        session.stopRunning()
        for req in requests {
            req.cancel()
        }
        requests = []
        
        session = nil
        videoDeviceInput = nil
        videoDataOutput = nil
        
    }
    
    
    
    //MARK: - User interaction
    
    @IBAction func tapTakePhoto(_ sender: UIButton) {
        guard let frame = currentFrame else {
            return
        }
        let today = Date()
        formatter.dateFormat = DATE_FORMAT
        let timestamp = formatter.string(from: today)
        let user = User(name: "Unknown - Take Photo", image: frame, time: timestamp)
        uploadLogs(user: user) {
        }
        //fb.uploadLogTimes(user: user)
        showDiaglog3s(name: "Unknown - Take Photo.")
    }
    
    @IBAction func changeCamera(_ sender: UIBarButtonItem) {
        //Remove existing input
        guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
            return
        }
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        if devicePosition == .back {
            devicePosition = .front
        }
        else {
            devicePosition = .back
        }
        
        addVideoDataInput()
        session.commitConfiguration()
    }
    
}


extension FrameViewController {
    private func configureSession() {
        if setupResult != .success { return }
        
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        // Add video input.
        addVideoDataInput()
        // Add video output.
        addVideoDataOutput()
        session.commitConfiguration()
    }
    
    private func addVideoDataInput() {
        do {
            var defaultVideoDevice: AVCaptureDevice!
            
            if devicePosition == .front {
                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            }
            else {
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                }
                
                else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                }
            }
            
            guard let videoDevice = defaultVideoDevice else {
                showDialog(message: "Not supported in simulator!")
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.windows.first!.windowScene!.interfaceOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = statusBarOrientation.videoOrientation {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.previewView.videoPreviewLayer?.connection?.videoOrientation = initialVideoOrientation
                    
                }
            }
            
        }
        catch {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
    }
    
    private func addVideoDataOutput() {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        
        
        if session.canAddOutput(videoDataOutput) {
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            session.addOutput(videoDataOutput)
        }
        else {
            print("Could not add metadata output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
    }
}
// MARK: -- Observers and Event Handlers
extension FrameViewController {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"), object: session)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: Notification.Name("AVCaptureSessionWasInterruptedNotification"), object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: Notification.Name("AVCaptureSessionInterruptionEndedNotification"), object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func sessionRuntimeError(_ notification: Notification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else { return }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        if error.code == .mediaServicesWereReset {
            sessionQueue.async { [unowned self] in
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    @objc func sessionWasInterrupted(_ notification: Notification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?, let reasonIntegerValue = userInfoValue.integerValue, let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
        }
    }
    
    @objc func sessionInterruptionEnded(_ notification: Notification) {
        print("Capture session interruption ended")
    }
}

// MARK: -- Helpers
extension FrameViewController {
    func setupVision() {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces) // Default
        self.requests = [faceDetectionRequest]
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {[weak self]() -> Void in
            guard let self = self else { return }
            //perform all the UI updates on the main queue
            guard let results = request.results as? [VNFaceObservation] else { return }
            self.previewView.removeMask()
            for face in results {
                
                self.previewView.drawFaceboundingBox(face: face, currentFrame: self.currentFrame)
                
            }
        }
    }
    
     /* func getLabel() {
        var lb = UNKNOWN
        if let frame = currentFrame {
            let res = vectorHelper.getResult(image: frame)
            lb = "\(res.name): \(res.distance)%"
            let result = res.name
            if result != UNKNOWN {
                let  label = result
                let today = Date()
                formatter.dateFormat = DATE_FORMAT
                let timestamp = formatter.string(from: today)
                if label != currentLabel {
                    currentLabel = label
                    numberOfFramesDeteced = 1
                } else {
                    numberOfFramesDeteced += 1
                }
                let detectedUser = User(name: label, image: frame, time: timestamp)
                if numberOfFramesDeteced > validFrames  {
                    print("Detected")
                    if localUserList.count == 0 {
                        print("append 1")
                        speak(name: label)
                        //attendList.append(detectedUser)
                        localUserList.append(detectedUser)
                        fb.uploadLogTimes(user: detectedUser)
                        showDiaglog3s(name: label)
                    }
                    else  {
                        var count = 0
                        for item in localUserList {
                            if item.name == label {
                                if let time = formatter.date(from: item.time) {
                                    let diff = abs(time.timeOfDayInterval(toDate: today))
                                    print(diff)
                                    if diff > 60 {
                                        print("append 2")
                                        localUserList.append(detectedUser)
                                        localUserList = localUserList.sorted(by: { $0.time > $1.time })
                                        speak(name: label)
                                        //postLogs(user: detectedUser)
                                        fb.uploadLogTimes(user: detectedUser)
                                        showDiaglog3s(name: label)
                                    }
                                }
                                break
                            }
                            else {
                                count += 1
                            }
                        }
                        
                        if count == localUserList.count {
                            print("append 3")
                            speak(name: label)
                            fb.uploadLogTimes(user: detectedUser)
                            localUserList.append(detectedUser)
                            localUserList = localUserList.sorted(by: { $0.time > $1.time })
                            showDiaglog3s(name: label)
                        }
                    }
                }
            }
            
        }
    } */
    
    func speak(name: String) {
        let utterance = AVSpeechUtterance(string: "Hello \(name)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

// Camera Settings & Orientation
extension FrameViewController {
    func availableSessionPresets() -> [String] {
        let allSessionPresets = [AVCaptureSession.Preset.photo,
                                 AVCaptureSession.Preset.low,
                                 AVCaptureSession.Preset.medium,
                                 AVCaptureSession.Preset.high,
                                 AVCaptureSession.Preset.cif352x288,
                                 AVCaptureSession.Preset.vga640x480,
                                 AVCaptureSession.Preset.hd1280x720,
                                 AVCaptureSession.Preset.iFrame960x540,
                                 AVCaptureSession.Preset.iFrame1280x720,
                                 AVCaptureSession.Preset.hd1920x1080,
                                 AVCaptureSession.Preset.hd4K3840x2160]
        
        var availableSessionPresets = [String]()
        for sessionPreset in allSessionPresets {
            if session.canSetSessionPreset(sessionPreset) {
                availableSessionPresets.append(sessionPreset.rawValue)
            }
        }
        
        return availableSessionPresets
    }
    
    func exifOrientationFromDeviceOrientation() -> UInt32 {
        enum DeviceOrientation: UInt32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = devicePosition == .front ? .bottom0ColRight : .top0ColLeft
        case .landscapeRight:
            exifOrientation = devicePosition == .front ? .top0ColLeft : .bottom0ColRight
        default:
            exifOrientation = devicePosition == .front ? .left0ColTop : .right0ColTop
        }
        return exifOrientation.rawValue
    }
    
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FrameViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation()) else { return }
        //var requestOptions: [VNImageOption : Any] = [:]
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return  }
        
        let image = UIImage(cgImage: cgImage)
        self.currentFrame = image.rotate(radians: .pi/2)//?.flipHorizontally(
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        
        do {
            try imageRequestHandler.perform(requests)
        }
        
        catch {
            print(error)
        }
        
    }
    
}

extension FrameViewController {
    func showDiaglog3s(name: String) {
        let alert = UIAlertController(title: "Joined!", message: "\(name)", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1
        
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}






