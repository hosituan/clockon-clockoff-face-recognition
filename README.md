# clockon-clockoff-face-recognition
This is a Face Recognition Application - HR Check-in on iOS Device. 



<h1>How it works</h1>

  Face detection, alignment, embedding and matching come from **FaceKit**
  (https://github.com/hosituan/FaceKit, private Swift package):
  - Vision face landmarks, crop levelled on the eyes.
  - FaceNet (InceptionResNetV1, 128-d) converted to Core ML, fp16, on device.
  - Nearest-neighbour matching with thresholds calibrated on LFW (99.17% verification accuracy).
  - A person is logged after 5 of 8 consecutive frames agree (`FrameConsensus`).

  Templates are stored encrypted on the device and synced through Firebase Realtime Database
  (`FaceKit Identities`). Attendance photos go to Firebase Storage, entries to `LogTimes`.

  References:
  - FaceNet: https://github.com/davidsandberg/facenet
  - Apple Vision: https://developer.apple.com/documentation/vision
  - Apple Core ML: https://developer.apple.com/documentation/coreml

<h1>Supported Platforms</h1>

  - iOS 15.0 or later.
  - Xcode 15 or later, Swift 5.

<h1>Demo </h1>

<h2>Performance</h2> 

  -  Test device: iPhone X, iOS 14.2
  -  Number of people: 50 persons.

  - Time taken: ~0.12 seconds.
  - Accuracy: >= 90%



<h2>Screen </h2>

  - Recognize Screen:

    <img src="https://github.com/hosituanit/clockon-clockoff-face-recognition/blob/master/images/recognize.jpg" width="300">

  - Unknown Person:
  
    <img src="https://github.com/hosituanit/clockon-clockoff-face-recognition/blob/master/images/unknownPerson.PNG" width="300">

  - Predict Image Screen (two people):

    <img src="https://github.com/hosituanit/clockon-clockoff-face-recognition/blob/master/images/testTwoPeople.PNG" width="300">

  - Predict Image Screen, Time Taken (1 person):

     <img src="https://github.com/hosituanit/clockon-clockoff-face-recognition/blob/master/images/testTimeTaken.jpg" width="300">
     
  - Time Logs Screen:
  
      <img src="https://github.com/hosituanit/clockon-clockoff-face-recognition/blob/master/images/timeLogs.PNG" width="300">
  
  

<h1>Usage</h1>

1. Install pods (FaceKit is resolved by Xcode through Swift Package Manager; your GitHub
   account needs access to the private FaceKit repository):
   ```
   pod install
   ```
2. Create a Firebase project with Realtime Database and Storage, download its
   `GoogleService-Info.plist` and put it at `PersonRecognize/GoogleService-Info.plist`
   (ignored by git).
3. Open `PersonRecognize.xcworkspace` and run on a device (the camera is required).

**Upgrading from the TensorFlow version:** templates in `K-mean Vectors` are not compatible
with FaceKit. Re-enroll everyone: All Users → select a user → Generate Vector (uses the
photos saved on the device), or add the user again.

**Limitations:** no liveness detection — a photo of an enrolled person can be logged.

<h1>Author</h1>

  Hồ Sĩ Tuấn - iOS Developer
  
  Contact:
  - Email: hosituan.work@gmail.com
  - Phone: +84983494681
  - Country: VietNam
  - Facebook: https://www.facebook.com/sytuann/
  - Github: hosituanit
  
  Contributor:
  - Lâm Gia Khánh
  
<h1>Contributing</h1>

Issues and pull requests are welcome!
Feel free to folk and fix.

<h1>Copyright</h1>

Please give me a star and reference link to my respository.


