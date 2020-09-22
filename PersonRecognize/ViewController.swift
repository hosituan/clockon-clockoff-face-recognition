//
//  ViewController.swift
//  SimpleFacenet
//


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            let fnet = FaceNet()
            let fDetector = FaceDetector()
            fnet.load()
            
            var vectors = [Vector]()
            
            vectors.append(Vector(name: "Trump",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "trump2")!)!)
                                    .first!)))
            vectors.append(Vector(name: "Trump",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "trump3")!)!)
                                    .first!)))
            vectors.append(Vector(name: "TA",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "hotgirlTA")!)!)
                                    .first!)))
            vectors.append(Vector(name: "Nene",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "nene1")!)!)
                                    .first!)))
            vectors.append(Vector(name: "Nene",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "nene2")!)!)
                                    .first!)))
            vectors.append(Vector(name: "Ribi",
                                  vector: fnet.run(image: fDetector
                                    .extractFaces(frame: CIImage(image: UIImage(named: "ribi")!)!)
                                    .first!)))
            
            let targetVector = fnet.run(image: fDetector
                .extractFaces(frame: CIImage(image: UIImage(named: "trump1")!)!)
                .first!)
            
            var result = Vector(name: "",
                                vector: [],
                                distance: 10)
            
            for vector in vectors {
                let distance = self.l2distance(targetVector, vector.vector)
                if distance < result.distance {
                    result = vector
                    result.distance = distance
                }
            }
            
            print(result.name)
        }
    }
    
    func l2distance(_ feat1: [Double], _ feat2: [Double]) -> Double {
        return sqrt(zip(feat1, feat2).map { f1, f2 in pow(f2 - f1, 2) }.reduce(0, +))
    }
}

//struct Vector {
//    var name: String
//    var vector: [Double]
//    var distance: Double
//}
//extension Vector {
//    init(name: String, vector: [Double]) {
//        self.init(name: name,
//                  vector: vector,
//                  distance: 0)
//    }
//}

