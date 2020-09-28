//
//  KNN.swift
//  PersonRecognize
//
//  Created by Hồ Sĩ Tuấn on 28/09/2020.
//  Copyright © 2020 Sun*. All rights reserved.
//


//

import Foundation

public class KNNDTW: NSObject {
    
    
    //meta parameters
    private var n_neighbors: Int = 0
    private var max_warping_window: Int = 1000 // this isn't implemented yet
    private var unique_labels: [String] = [String]()
    
    
    //internal data structures
    private var curves: [[Float]] = [[Float]]()
    private var labels: [String] = [String]()
    
    private var curve_label_pairs: [knn_curve_label_pair] = [knn_curve_label_pair]()
    
    public func configure(neighbors: Int, max_warp: Int) {
        self.n_neighbors = neighbors
        self.max_warping_window = max_warp // not implemented
    }
    
    
    
    public func train(data_sets: [knn_curve_label_pair]) {
        
        
        self.curve_label_pairs = data_sets
        
        for set in data_sets {
            
            if (set.curve.count == 0 || set.label == "") {
                print("HEY! BOTH CURVE AND LABEL ARE REQUIRED!")
            }
            
            
            //we'll need a list of unique labels for later
            var unique = true
            for in_label in self.unique_labels {
                if (in_label == set.label) {
                    unique = false
                }
            }
            if (unique) {
                self.unique_labels.append(set.label)
            }
            
        }
    }
    
    
    
    private func dtw_cost(y: [Float], x: [Float]) -> Float {
        
        //FIRST, we get the distance between each point
        
        var distances = [[Float]](repeating: [Float](repeating: 0, count: x.count), count: y.count)
        //use euclidean distance between the pairs of points.
        
        for (i,_) in y.enumerated() {
            for (j,_) in x.enumerated() {
                //distances[i][j] = (a[j]-b[i])**2
                distances[i][j] = pow(abs( x[j] - y[i] ), 2)
            }
        }
        

        
        //SECOND, we compute the warp path (basically cost of each path)
        
        var acc_cost = [[Float]](repeating: [Float](repeating: 0, count: x.count), count: y.count)
        acc_cost[0][0] = distances[0][0]
        
        
        //horiz axis
        for i in 1...x.count-1 {
            acc_cost[0][i] = distances[0][i] + acc_cost[0][i-1]
        }
        
        //vert axis
        for i in 1...y.count-1 {
            acc_cost[i][0] = distances[i][0] + acc_cost[i-1][0]
        }
        

        //should be non horiz and vertical values
        for i in 1...y.count-1 {
            for j in 1...x.count-1 {
                acc_cost[i][j] = min(acc_cost[i-1][j-1], acc_cost[i-1][j], acc_cost[i][j-1]) + distances[i][j]
            }
        }
        
        
        
        //THIRD, we backtrack and find cost of optimal path
        var path = [[Int]]()
        var i = y.count-1
        var j = x.count-1
        
        path.append([j, i])
        
        while (i > 0 && j > 0) {
            if (i==0) {
                j = j - 1
            }
            else if (j==0) {
                i = i - 1
            }
            else {
                if ( acc_cost[i-1][j] == min(acc_cost[i-1][j-1], acc_cost[i-1][j], acc_cost[i][j-1]) ) {
                    i = i - 1
                }
                else if (acc_cost[i][j-1] == min(acc_cost[i-1][j-1], acc_cost[i-1][j], acc_cost[i][j-1])) {
                    j = j - 1
                }
                else {
                    i = i - 1
                    j = j - 1
                }
            }
            path.append([j, i])
        }
        path.append([0,0])
        
        
        //FOURTH, add up all the costs of the selected path
        var cost: Float = 0.0
        for sub in path {
            let x: Int = sub[0]
            let y: Int = sub[1]
            //print(x, ",", y)
            cost = cost + distances[y][x]
        }
        
        return cost
    }
    

    
    
    public func predict(curve_to_test: [Float]) -> knn_certainty_label_pair {
        
        if (self.n_neighbors == 0) {
            self.n_neighbors = Int(sqrt(Float(self.curve_label_pairs.count)))
            print("No 'k' value given. Using ", self.n_neighbors, ".")
        }
        
        /*
            loop over all know datapoints and take note of their distances
        */
        var distances: [knn_distance_label_pair] = [knn_distance_label_pair]()
        
        for pair in self.curve_label_pairs {
            distances.append(knn_distance_label_pair(distance: self.dtw_cost(y: pair.curve, x: curve_to_test), label: pair.label))
        }
        
        //sort the distances, ascending distances
        
        distances = distances.sorted(by: { (a, b) -> Bool in
            if (a.distance < b.distance) {
                return true
            }
            else {
                return false
            }
        })
        
        
        
        
        /*
            tally up the votes, but keep the correlation between labels
        */
        
        //populate the vote counter array
        var votes: [String:Int] = [String:Int]()
        for sub in self.unique_labels {
            votes[sub] = 0
        }
        
        //put the first n elements in the vote count
        for i in 0...self.n_neighbors-1 {
            votes[distances[i].label] = votes[distances[i].label]! + 1
        }
        
        //sort/separate out the votes
        let sorted_votes = votes.max(by: { (a, b) -> Bool in

            if (a.1 < b.1) {
                return true
            }
            else {
                return false
            }
        })
        
        //return the label and a certainty
        return knn_certainty_label_pair(probability: Float(sorted_votes!.1)/Float(self.n_neighbors), label: (sorted_votes?.0)!)
        
    }
    
    
    private struct knn_distance_label_pair {
        let distance: Float
        let label: String
    }
    

}


//input type
public struct knn_curve_label_pair {
    let curve: [Float]
    let label: String
}

//output type
public struct knn_certainty_label_pair {
    let probability: Float
    let label: String
}





