//
//  FrameViewController.swift
//  PersonRez
//
//  Created by Hồ Sĩ Tuấn on 06/09/2020.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import AVFoundation
import FaceKit
import UIKit

class FrameViewController: UIViewController {
    
    
    @IBOutlet weak var previewView: PreviewView!
    /// Latest upright camera frame (main thread only), used for "Take Photo" and log photos.
    private var latestFrame: CIImage?
    /// True while a frame is being recognised; newer frames are dropped meanwhile (main thread only).
    private var isRecognizing = false
    private var consensus = FrameConsensus(requiredFrames: 5, windowSize: 8)
    private let frameContext = CIContext()
    private let synthesizer = AVSpeechSynthesizer()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) 
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        // Load the model before the first frame arrives.
        Task { _ = try? await FaceService.shared.recognizer() }
        session = AVCaptureSession()
        previewView.session = session
        
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
        
        session = nil
        videoDeviceInput = nil
        videoDataOutput = nil
        
    }
    
    
    
    //MARK: - User interaction
    
    @IBAction func tapTakePhoto(_ sender: UIButton) {
        guard let frame = latestFrame.flatMap(uiImage) else {
            print("nil frame")
            return
        }
        let today = Date()
        formatter.dateFormat = DATE_FORMAT
        let timestamp = formatter.string(from: today)
        let user = User(name: TAKE_PHOTO_NAME, image: frame, time: timestamp)
        showDiaglog3s(name: TAKE_PHOTO_NAME, true)
        
        //        api.uploadLogs(user: user) { error in
        //            if error != nil {
        //                self.showDiaglog3s(name: TAKE_PHOTO_NAME, false)
        //            }
        //        }
        fb.uploadLogTimes(user: user) { error in
            if error != nil {
                DispatchQueue.main.async { self.showDiaglog3s(name: TAKE_PHOTO_NAME, false) }
            }
        }
        
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

// MARK: -- Recognition
extension FrameViewController {
    /// Shows every face with its own label and logs attendance once a person is confirmed.
    func handle(_ results: [Recognition], frame: CIImage) {
        previewView.removeMask()
        for result in results {
            previewView.drawFaceboundingBox(boundingBox: result.face.boundingBox,
                                            label: PredictImageViewController.describe(result.match))
        }
        // Confirm the largest face: the person standing in front of the device.
        let main = results.max { $0.face.boundingBox.width < $1.face.boundingBox.width }
        if let name = consensus.observe(main?.match.identityID) {
            logAttendance(name: name, frame: frame)
        }
    }

    func logAttendance(name: String, frame: CIImage) {
        let now = Date()
        formatter.dateFormat = DATE_FORMAT
        if let last = localUserList.first(where: { $0.name == name }),
           let time = formatter.date(from: last.time),
           now.timeIntervalSince(time) < Double(VALID_TIME) {
            return
        }
        guard let image = uiImage(from: frame) else { return }
        let user = User(name: name, image: image, time: formatter.string(from: now))
        localUserList.insert(user, at: 0)
        speak(name: name)
        showDiaglog3s(name: name, true)
        fb.uploadLogTimes(user: user) { error in
            if error != nil {
                DispatchQueue.main.async { self.showDiaglog3s(name: name, false) }
            }
        }
    }

    func uiImage(from frame: CIImage) -> UIImage? {
        frameContext.createCGImage(frame, from: frame.extent).map { UIImage(cgImage: $0) }
    }

    func speak(name: String) {
        let utterance = AVSpeechUtterance(string: "Hello \(name)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
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
              let orientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation()) else { return }
        let frame = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.latestFrame = frame
            guard !self.isRecognizing else { return }
            self.isRecognizing = true
            Task { @MainActor in
                defer { self.isRecognizing = false }
                do {
                    let results = try await FaceService.shared.recognizer().identify(in: pixelBuffer, orientation: orientation)
                    self.handle(results, frame: frame)
                } catch {
                    print("Recognition failed: \(error)")
                }
            }
        }
    }
    
}






