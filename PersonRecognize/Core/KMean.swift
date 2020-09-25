////
////  KMean.swift
////  PersonRecognize
////
////  Created by Hồ Sĩ Tuấn on 25/09/2020.
////  Copyright © 2020 Sun*. All rights reserved.
////
//
//import Foundation
//
//func kMeans(numCenters: Int, convergeDistance: Double, points: [Vector]) -> [Vector] {
// 
//  // Randomly take k objects from the input data to make the initial centroids.
//  var centers = reservoirSample(points, k: numCenters)
//
//  // This loop repeats until we've reached convergence, i.e. when the centroids
//  // have moved less than convergeDistance since the last iteration.
//  var centerMoveDist = 0.0
//  repeat {
//    // In each iteration of the loop, we move the centroids to a new position.
//    // The newCenters array contains those new positions.
//    let zeros = [Double](count: points[0].length, repeatedValue: 0)
//    var newCenters = [Vector](count: numCenters, repeatedValue: Vector(zeros))
//
//    // We keep track of how many data points belong to each centroid, so we
//    // can calculate the average later.
//    var counts = [Double](count: numCenters, repeatedValue: 0)
//
//    // For each data point, find the centroid that it is closest to. We also
//    // add up the data points that belong to that centroid, in order to compute
//    // that average.
//    for p in points {
//      let c = indexOfNearestCenter(p, centers: centers)
//      newCenters[c] += p
//      counts[c] += 1
//    }
//    
//    // Take the average of all the data points that belong to each centroid.
//    // This moves the centroid to a new position.
//    for idx in 0..<numCenters {
//      newCenters[idx] /= counts[idx]
//    }
//
//    // Find out how far each centroid moved since the last iteration. If it's
//    // only a small distance, then we're done.
//    centerMoveDist = 0.0
//    for idx in 0..<numCenters {
//      centerMoveDist += centers[idx].distanceTo(newCenters[idx])
//    }
//    
//    centers = newCenters
//  } while centerMoveDist > convergeDistance
//
//  return centers
//}
