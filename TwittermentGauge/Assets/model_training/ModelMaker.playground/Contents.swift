import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/r1pp3r/git-repos/github.com/xcode-playground/iOS Nanodegree/TwittermentGauge/TwittermentGauge/model_training/twitter-sanders-apple3.csv"))

let(trainingData, testingData) = data.randomSplit(by: 0.97, seed: 5)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")
let evalMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")
let accuracy = (1.0 - evalMetrics.classificationError) * 100

let metadata = MLModelMetadata(author: "Georgi Markov", shortDescription: "A model trained to classify sentiment on tweets", license: "MIT", version: "1.0", additional: nil)
try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/r1pp3r/git-repos/github.com/xcode-playground/iOS Nanodegree/TwittermentGauge/TwittermentGauge/model_training/TwitttermentGauge.mlmodel"))

// Testing
try sentimentClassifier.prediction(from: "@Apple is a terrible company!")
try sentimentClassifier.prediction(from: "I just found the best restaurant even, and it's at @WaffleHouse.")
try sentimentClassifier.prediction(from: "I think @CocaCola company is just OK.")
