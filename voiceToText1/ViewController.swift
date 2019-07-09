//
//  ViewController.swift
//  voiceToText1
//
//  Created by Haris Shobaruddin Roabbni on 02/07/19.
//  Copyright © 2019 Haris Shobaruddin Robbani. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lblToChange: UILabel!
    @IBOutlet weak var viewToChangeColor: UIView!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestSpeechRecognation()
    }

    @IBAction func btnRecordTap(_ sender: Any) {
        recordAndRecognize()
    }
    
    func recordAndRecognize(){        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){ buffer, _ in self.request.append(buffer)}
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable{
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.lblToChange.text = bestString
                print(bestString)
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments{
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorSaid(resultString: lastString)
            }else{
                print(error)
            }
        })

    }
    
    func checkForColorSaid(resultString: String) {
        switch resultString {
        case "red":
            viewToChangeColor.backgroundColor = .red
        case "blue":
            viewToChangeColor.backgroundColor = .blue
        case "yellow":
            viewToChangeColor.backgroundColor = .yellow
        case "green":
            viewToChangeColor.backgroundColor = .green
        default:
            viewToChangeColor.backgroundColor = .gray
        }
    }
    
    func requestSpeechRecognation(){
        SFSpeechRecognizer.requestAuthorization{
            authStatus in OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnRecord.isEnabled = true
                case .denied:
                    self.btnRecord.isEnabled = false
                    self.lblToChange.text = "user denied to access speech recognition"
                case .restricted:
                    self.btnRecord.isEnabled = false
                    self.lblToChange.text = "speech recognition restricted on this device"
                case .notDetermined:
                    self.btnRecord.isEnabled = false
                    self.lblToChange.text = "speech recognition not yet authorized"
                }
            }
        }
    }
    
}

