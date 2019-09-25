//
//  ViewController.swift
//  VisualEyes
//
//  Created by Justin on 12/14/16.
//  Copyright © 2016 adhoc. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer


let picker = MPMediaPickerController.self(mediaTypes: MPMediaType.music)
var audioFile = try? AKAudioFile()
var player = try? AKAudioPlayer(file: audioFile!)
var frame = CGRect(x:0,y:0,width:0,height:0)
let containerView = AKView(frame: frame)
var filename = String()
var allColors = ColorPickerClass()
var dataForPassing = DataToPass()

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet var visualizeView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var colorPickerView: UIView!
    
    @IBOutlet var plotTypeSegmentedController: UISegmentedControl!
    @IBOutlet var rollingOrBufferSegmentedController: UISegmentedControl!
    
    @IBOutlet var shouldFillSwitch: UISwitch!
    @IBOutlet var shouldMirrorSwitch: UISwitch!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    @IBOutlet var startRestartButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var fullscreenButton: UIButton!
    
    @IBOutlet var alphaTextField: UITextField!
    
    @IBAction func redSliderChanged(_ sender: Any) {
        allColors.redColor = redSlider.value
        colorPickerView.backgroundColor = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
    }
    @IBAction func greenSliderChanged(_ sender: Any) {
        allColors.greenColor = greenSlider.value
        colorPickerView.backgroundColor = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
    }
    @IBAction func blueSliderChanged(_ sender: Any) {
        allColors.blueColor = blueSlider.value
        colorPickerView.backgroundColor = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
    }
    
    
    
    
    @IBAction func startRestart(_ sender: Any) {
            if (player?.isPlaying)! {
                stopDaSongs()
                playSong(songToPlay: filename)
            } else {
                self.present(picker, animated: true, completion: nil)
                startRestartButton.setTitle("Reset With Settings", for: .normal)
            }
        stopButton.isEnabled = true
        fullscreenButton.isEnabled = true
        fullscreenButton.isHidden = false
    }
    
    @IBAction func stopButton(_ sender: Any) {
        if (player?.isPlaying)! {
            stopDaSongs()
            startRestartButton.setTitle("Open Music Picker", for: .normal)
        }
        stopButton.isEnabled = false
        fullscreenButton.isEnabled = false
        fullscreenButton.isHidden = true
    }
    
    var chosenCollection: MPMediaItemCollection!
    var chosenSong: MPMediaItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AKSettings.playbackWhileMuted = true
        try? AKSettings.setSession(category: AKSettings.SessionCategory(rawValue: AVAudioSessionCategoryPlayback)!)
        
        stopButton.isEnabled = false
        fullscreenButton.isEnabled = false
        fullscreenButton.isHidden = true

        
        visualizeView.layer.borderColor = UIColor.black.cgColor
        visualizeView.layer.borderWidth = 1
        picker.allowsPickingMultipleItems = false
        
        
        colorPickerView.backgroundColor = .black
        colorPickerView.layer.borderColor = UIColor.black.cgColor
        colorPickerView.layer.borderWidth = 1
        
        AudioKit.stop()
        player?.stop()
        picker.delegate = self
        
        //lol causes memory error and crashes the device
        //dont enable
        /*let i = 1
        while i == 1 {
            if (player?.isPlaying)! {
                startRestartButton.setTitle("Restart With Options", for: .normal)
            } else {
                startRestartButton.setTitle("Open Music Picker", for: .normal)
            }
        }*/
    }
    
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.dismiss(animated: true, completion:nil)
        chosenCollection = mediaItemCollection
        exportSong()
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion:nil)
        startRestartButton.setTitle("Open Music Picker", for: .normal)
        stopButton.isEnabled = false
        fullscreenButton.isEnabled = false
        fullscreenButton.isHidden = true
    }

        
    func exportSong() {
        chosenSong = chosenCollection.items[0]
        
        print(String(describing: chosenCollection.items[0]))
        
        filename = String(describing: chosenCollection.items[0]) + ".m4a"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportedFileURL = documentsDirectory.appendingPathComponent(filename)
        print("saving to \(exportedFileURL.absoluteString)")
        
    
        let url = chosenSong.value(forProperty: MPMediaItemPropertyAssetURL) as! NSURL
        let songAsset = AVAsset(url: url as URL)
        
        let exporter = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetAppleM4A)!
        exporter.outputFileType = AVFileTypeAppleM4A
        exporter.outputURL = exportedFileURL
        
        let duration = CMTimeGetSeconds(songAsset.duration)
        let endTime = Int64(duration)
        let startTime = CMTimeMake(0, 1)
        let stopTime = CMTimeMake(endTime, 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        exporter.timeRange = exportTimeRange
        
        exporter.exportAsynchronously(completionHandler: {
            
            if exporter.status == AVAssetExportSessionStatus.failed {
                print("Export failed \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.cancelled {
                print("Export cancelled \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.unknown {
                print("Export unknown \(exporter.error)")
            } else {
                print("Export complete")
                self.playSong(songToPlay: filename)
                dataForPassing.fileName = filename
            }
        })
    }
    
    func playSong(songToPlay: String) {
        audioFile = try? AKAudioFile(readFileName: songToPlay, baseDir: .documents)
        player = try? AKAudioPlayer(file: audioFile!)
        
        frame = CGRect(x: 0, y: 0.0, width: visualizeView.frame.width, height: visualizeView.frame.height)
        containerView = AKView(frame: frame)
        
        var rollingOrBufferHolder:[EZPlotType] = [.buffer, .rolling]
        var rollingOrBuffer = rollingOrBufferHolder[0]
        switch rollingOrBufferSegmentedController.selectedSegmentIndex {
        case 0:
            rollingOrBuffer = rollingOrBufferHolder[0]
        case 1:
            rollingOrBuffer = rollingOrBufferHolder[1]
        default:
            rollingOrBuffer = rollingOrBufferHolder[0]
        }
    
        var shouldFillBool = true
        if !shouldFillSwitch.isOn {
            shouldFillBool = false
        } else {
            shouldFillBool = true
        }
        
        var shouldMirrorBool = true
        if !shouldMirrorSwitch.isOn {
            shouldMirrorBool = false
        } else {
            shouldMirrorBool = true
        }
        
        //Ummm... I don't think this is at all valid to convert String -> Float -> CGFloat
        //But XCode complains It cannot directly convert String -> CGFloat
        //Odd...
        let plotAlpha = CGFloat(Float(alphaTextField.text!)!)
        //let plotAlpha = CGFloat(alphaTextField.text!)!
        DispatchQueue.main.async(){
            dataForPassing.rollingBufferHolder = rollingOrBuffer
            dataForPassing.fill = shouldFillBool
            dataForPassing.mirror = shouldMirrorBool
            dataForPassing.alpha = plotAlpha
            
            switch self.plotTypeSegmentedController.selectedSegmentIndex {
            case 0:
                dataForPassing.plotType = 0
                let plotTypeOne = AKNodeFFTPlot(player!, frame: self.containerView.frame, bufferSize: 1024)
                plotTypeOne.plotType = rollingOrBuffer
                plotTypeOne.backgroundColor = AKColor.white
                plotTypeOne.shouldCenterYAxis = true
                plotTypeOne.alpha = plotAlpha
                
                plotTypeOne.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                plotTypeOne.shouldFill = shouldFillBool
                plotTypeOne.shouldMirror = shouldMirrorBool
                
                self.visualizeView.addSubview(self.containerView)
                self.containerView.addSubview(plotTypeOne)
            case 1:
                dataForPassing.plotType = 1
                let plotTypeTwo = AKNodeOutputPlot(player!, frame: self.containerView.frame, bufferSize: 1024)
                plotTypeTwo.plotType = rollingOrBuffer
                plotTypeTwo.backgroundColor = AKColor.white
                plotTypeTwo.shouldCenterYAxis = true
                plotTypeTwo.alpha = plotAlpha
                
                plotTypeTwo.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                plotTypeTwo.shouldFill = shouldFillBool
                plotTypeTwo.shouldMirror = shouldMirrorBool
                
                
                self.visualizeView.addSubview(self.containerView)
                self.containerView.addSubview(plotTypeTwo)
            default:
                let plotTypeOne = AKNodeFFTPlot(player!, frame: self.containerView.frame, bufferSize: 1024)
                plotTypeOne.plotType = rollingOrBuffer
                plotTypeOne.backgroundColor = AKColor.white
                plotTypeOne.shouldCenterYAxis = true
                plotTypeOne.alpha = plotAlpha
                
                plotTypeOne.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                plotTypeOne.shouldFill = shouldFillBool
                plotTypeOne.shouldMirror = shouldMirrorBool
                
                
                self.visualizeView.addSubview(self.containerView)
                self.containerView.addSubview(plotTypeOne)
                
            }
            
            //self.visualizeView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        AudioKit.output = player
        AudioKit.start()
        player?.play()
        
        player?.completionHandler = { AudioKit.stop(); player?.stop(); self.containerView.removeFromSuperview(); }
        
    }
    
    
    func stopDaSongs() {
        self.containerView.removeFromSuperview()
        AudioKit.stop()
        player?.stop()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        stopDaSongs()
        startRestartButton.setTitle("Open Music Picker", for: .normal)
        stopButton.isEnabled = false
        fullscreenButton.isEnabled = false
        fullscreenButton.isHidden = true
        if let destination = segue.destination as? FullScreenViewController {
            destination.isButtonClick = true
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
 



