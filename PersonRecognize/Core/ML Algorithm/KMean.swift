//
//  KMeans.swift
//  KMeansSwift
//
//  Created by sdq on 15/12/22.
//  Copyright © 2015年 sdq. All rights reserved.
//

import Foundation
import Accelerate
import Darwin

typealias KMVectors = Array<[Double]>
typealias KMVector = [Double]

enum KMeansError: Error {
    case noDimension
    case noClusteringNumber
    case noVectors
    case clusteringNumberLargerThanVectorsNumber
    case otherReason(String)
}

class KMeansSwift {
    
    static let sharedInstance = KMeansSwift()
    fileprivate init() {}
    
    //MARK: Parameter
    
    //dimension of every vector
    var dimension:Int = 128
    //clustering number K
    var clusteringNumber:Int = 2
    //max interation
    var maxIteration = 100
    //convergence error
    var convergenceError = 0.01
    //number of excution
    var numberOfExcution = 1
    //vectors
    var vectors = KMVectors()
    //final centroids
    var finalCentroids = KMVectors()
    //final clusters
    var finalClusters = Array<KMVectors>()
    //temp centroids
    fileprivate var centroids = KMVectors()
    //temp clusters
    fileprivate var clusters = Array<KMVectors>()
    
    //MARK: Public
    
    //check parameters
    func checkAllParameters() -> Bool {
        if dimension < 1 { return false }
        if clusteringNumber < 1 { return false }
        if maxIteration < 1 { return false }
        if numberOfExcution < 1 { return false }
        if vectors.count < clusteringNumber { return false }
        return true
    }
    
    //add vectors
    func addVector(_ newVector:KMVector) {
        vectors.append(newVector)
    }
    
    func addVectors(_ newVectors:KMVectors) {
        for newVector:KMVector in newVectors {
            addVector(newVector)
        }
    }
    
    //clustering
    func clustering(_ numberOfExcutions:Int, completion:(_ success:Bool, _ centroids:KMVectors, _ clusters:[KMVectors])->()) {
        beginClusteringWithNumberOfExcution(numberOfExcutions)
        return completion(true, finalCentroids, finalClusters)
    }
    
    func reset() {
        vectors.removeAll()
        centroids.removeAll()
        clusters.removeAll()
        finalCentroids.removeAll()
        finalClusters.removeAll()
    }
    
    //MARK: -Private
    
    fileprivate func pickingInitialCentroidsRandomly() {
        let indexes = vectors.count.indexRandom[0..<clusteringNumber]
        var initialCenters = KMVectors()
        for index:Int in indexes {
            initialCenters.append(vectors[index])
        }
        centroids = initialCenters
    }
    
    fileprivate func assignVectorsToTheGroup() {
        clusters.removeAll()
        for _ in 0..<clusteringNumber {
            clusters.append([])
        }
        for vector in vectors{
            var tempDistanceSquare = -1.0
            var groupNumber = 0
            for index in 0..<clusteringNumber {
                if tempDistanceSquare == -1.0 {
                    tempDistanceSquare = EuclideanDistanceSquare(vector, v2: centroids[index])
                    groupNumber = index
                    continue
                }
                if EuclideanDistanceSquare(vector, v2: centroids[index]) < tempDistanceSquare {
                    groupNumber = index
                }
            }
            clusters[groupNumber].append(vector)
        }
    }
    
    fileprivate func recalculateCentroids() -> Double {
        var moveDistanceSquare = 0.0
        for index in 0..<clusteringNumber {
            var newCentroid = KMVector(repeating: 0.0, count: dimension)
            let vectorSum = clusters[index].reduce(newCentroid, { vectorAddition($0, anotherVector: $1) })
            var s = Double(clusters[index].count)
            vDSP_vsdivD(vectorSum, 1, &s, &newCentroid, 1, vDSP_Length(vectorSum.count))
            if moveDistanceSquare < EuclideanDistanceSquare(centroids[index], v2: newCentroid) {
                moveDistanceSquare = EuclideanDistanceSquare(centroids[index], v2: newCentroid)
            }
            centroids[index] = newCentroid
        }
        return moveDistanceSquare
    }
    
    fileprivate func beginClustering() -> Double {
        pickingInitialCentroidsRandomly()
        var iteration = 0
        var moveDistance = 1.0
        while iteration < maxIteration && moveDistance > convergenceError {
            iteration += 1
            assignVectorsToTheGroup()
            moveDistance = recalculateCentroids()
        }
        return costFunction()
    }
    
    fileprivate func costFunction() -> Double {
        var cost = 0.0
        for index in 0..<clusteringNumber {
            for vector in clusters[index] {
                cost += EuclideanDistanceSquare(vector, v2: centroids[index])
            }
        }
        return cost
    }
    
    private func beginClusteringWithNumberOfExcution(_ number:Int) {
        var number = number
        if number < 1 { return }
        var cost = -1.0
        while number > 0 {
            let newCost = beginClustering()
            if cost == -1.0 || cost > newCost {
                cost = newCost
                finalCentroids = centroids
                finalClusters = clusters
            }
            number -= 1
        }
    }
    
}

//MARK: -Helper

//Add Vector
private func vectorAddition(_ vector:KMVector, anotherVector:KMVector) -> KMVector {
    var addresult = KMVector(repeating: 0.0, count: vector.count)
    vDSP_vaddD(vector, 1, anotherVector, 1, &addresult, 1, vDSP_Length(vector.count))
    return addresult
}

//Calculate Euclidean Distance
private func EuclideanDistance(_ v1:[Double],v2:[Double]) -> Double {
    let distance = EuclideanDistanceSquare(v1,v2: v2)
    return sqrt(distance)
}

private func EuclideanDistanceSquare(_ v1:[Double],v2:[Double]) -> Double {
    var subVec = [Double](repeating: 0.0, count: v1.count)
    vDSP_vsubD(v1, 1, v2, 1, &subVec, 1, vDSP_Length(v1.count))
    var distance = 0.0
    vDSP_dotprD(subVec, 1, subVec, 1, &distance, vDSP_Length(subVec.count))
    return abs(distance)
}

private extension Int {
    var random: Int {
        return Int(arc4random_uniform(UInt32(abs(self))))
    }
    var indexRandom: [Int] {
        return  Array(0..<self).shuffle
    }
}

private extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count - index))) + index
            anotherIndex != index ? elements.swapAt(index, anotherIndex) : ()
        }
        return elements
    }
    mutating func shuffled() {
        self = shuffle
    }
}

//get from the same name
func getKMeanVectorSameName(vectors: [Vector], completionHandler: @escaping ([Vector]) -> Void) {
    KMeans.reset()
    
    for i in 0..<vectors.count {
        KMeans.addVector(vectors[i].vector)
    }
    
    KMeans.clusteringNumber = NUMBER_OF_K
//    print(KMeans.vectors.count)
//    print(KMeans.centroids.count)
//    print(KMeans.clusters.count)
    KMeans.clustering(500) { (success, centroids, clusters) -> () in
        if success {
            var vectorList:[Vector] = []
            for i in 0...2 {
                let vector = Vector(name: vectors[0].name, vector: centroids[i], distance: 0)
                vectorList.append(vector)
            }
            completionHandler(vectorList)

        }
    }
    
}
