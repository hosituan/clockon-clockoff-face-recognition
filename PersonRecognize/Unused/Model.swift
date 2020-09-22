////
////  Model.swift
////  PersonRez
////
////  Created by Hồ Sĩ Tuấn on 06/09/2020.
////  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
////
//
//import Foundation
//import MBProgressHUD
//import Vision
//import CoreML
//
//class Model {
//    private func batchProvider() -> MLArrayBatchProvider
//    {
//        var batchInputs: [MLFeatureProvider] = []
//        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
//            .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
//        ]
//        print(imageLabelDictionary.count)
//        for (image, label) in imageLabelDictionary {
//            do{
//                let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions)
//
//                if let pixelBuffer = featureValue.imageBufferValue{
//                    let value = HumanFinalTrainingInput(image: pixelBuffer, label: label)
//                    batchInputs.append(value)
//                }
//            }
//            catch(let error){
//                print("error description is \(error.localizedDescription)")
//            }
//        }
//        return MLArrayBatchProvider(array: batchInputs)
//    }
//
//
//    func startTraining(view: UIView) {
//        let modelConfig = MLModelConfiguration()
//        modelConfig.computeUnits = .cpuAndGPU
//        do {
//            let fileManager = FileManager.default
//            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
//
//            var modelURL = HumanFinal.urlOfModelInThisBundle
//
//            let pathOfFile = documentDirectory.appendingPathComponent("HumanTrained.mlmodelc")
//
//            if fileManager.fileExists(atPath: pathOfFile.path){
//                modelURL = pathOfFile
//            }
//
//            let updateTask = try MLUpdateTask(forModelAt: modelURL, trainingData: batchProvider(), configuration: modelConfig,
//                                              progressHandlers: MLUpdateProgressHandlers(forEvents: [.trainingBegin,.epochEnd],
//                                                                                         progressHandler: { (contextProgress) in
//                                                                                            print(contextProgress.event)
//
//
//                                                                                         }) { [self] (finalContext) in
//                                                print("Done Context")
//                                                DispatchQueue.main.async {
//
//                                                    MBProgressHUD.hide(for: view, animated: true)
//                                                }
//
//                                                if finalContext.task.error?.localizedDescription == nil
//                                                {
//                                                    do {
//
//                                                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
//                                                        let fileURL = documentDirectory.appendingPathComponent("HumanTrained.mlmodelc")
//                                                        try finalContext.model.write(to: fileURL)
//                                                        updatableModel = self.loadModel(url: fileURL)
//                                                    } catch(let error) {
//                                                        print("error is \(error.localizedDescription)")
//
//                                                    }
//                                                }
//                                                else {
//                                                    print(finalContext.task.error!.localizedDescription)
//                                                }
//
//
//                                              })
//            updateTask.resume()
//        } catch {
//            print("Error while upgrading \(error.localizedDescription)")
//        }
//    }
//
//    //MARK:- Load Model From URL
//
//    func loadModel(url: URL) -> MLModel? {
//        do {
//            let config = MLModelConfiguration()
//            config.computeUnits = .all
//            return try MLModel(contentsOf: url, configuration: config)
//        } catch {
//            print("Error loading model: \(error)")
//            return nil
//        }
//    }
//    func predict(image: UIImage) -> (String?, Double?) {
//        do{
//            let imageOptions: [MLFeatureValue.ImageOption: Any] = [
//                .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
//            ]
//            let featureValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions)
//            let featureProviderDict = try MLDictionaryFeatureProvider(dictionary: ["image" : featureValue])
//            let prediction = try updatableModel?.prediction(from: featureProviderDict)
//            let value = prediction?.featureValue(for: "label")?.stringValue
//            let probabilities = prediction?.featureValue(for: "labelProbability")?.dictionaryValue
//            let predictedProbability = probabilities?[value!]?.doubleValue
//            return (value, predictedProbability)
//        }catch(let error){
//            print("error is \(error.localizedDescription)")
//        }
//        return (nil, nil)
//    }
//    func getImageConstraint(model: MLModel) -> MLImageConstraint {
//        return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
//    }
//}
//
//
//
