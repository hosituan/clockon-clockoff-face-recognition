# clockon-clockoff-face-recognition
This is a Face Recognition Application - HR Check-in on iOS Device. 



<h1> References </h1>

  - Pre-train Model: Facenet https://github.com/davidsandberg/facenet 
  - Dataset: VGGFace2 https://drive.google.com/file/d/1EXPBSXwTaqrSC0OhUdXNmKSh9qJUQ55-/view?usp=drive_open
  - Architecture: InceptionResnetV1 https://github.com/davidsandberg/facenet/blob/master/src/models/inception_resnet_v1.py
  - Algorithms and Libraries: 
    + Swift for TensorFlow: https://www.tensorflow.org/swift
    + Swift K-means Clustering https://github.com/raywenderlich/swift-algorithm-club/tree/master/K-Means 
    + Swift k-NN https://github.com/mmahler2/Swift-DTW-KNN 
    + Apple Vision: https://developer.apple.com/documentation/vision
    + Apple CoreML: https://developer.apple.com/documentation/coreml
    + Apple TuriCreate: https://github.com/apple/turicreate
  
  
  
<h1>Supported Platforms</h1>

  - iOS 12.0 or later.
  - Xcode 11 or later, Swift 5.
  


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

```
pod install
```
```
pod update
```

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


