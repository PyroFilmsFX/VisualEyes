//
//  FullScreenViewController.swift
//  VisualEyes
//
//  Created by Justin on 12/20/16.
//  Copyright © 2016 adhoc. All rights reserved.
//

import UIKit
import AudioKit

var audioFileTwo = try? AKAudioFile()
var playerTwo = try? AKAudioPlayer(file: audioFileTwo!)

class FullScreenViewController: UIViewController {
    var isButtonClick = Bool()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FullScreenViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        if isButtonClick == true {
            isButtonClick = !isButtonClick
            audioFileTwo = try? AKAudioFile(readFileName: dataForPassing.fileName, baseDir: .documents)
            playerTwo = try? AKAudioPlayer(file: audioFileTwo!)
            AudioKit.output = playerTwo
            AudioKit.start()
            playerTwo?.play()
            startView()
        }
    }
    func back(sender: UIBarButtonItem) {
        AudioKit.stop()
        playerTwo?.stop()
        _ = navigationController?.popViewController(animated: true)
    }
    func startView() {
        DispatchQueue.main.async(){
            switch dataForPassing.plotType {
            case 0:
                let magicPlot = AKNodeFFTPlot(playerTwo!, frame: self.view.frame, bufferSize: 1024)
                magicPlot.plotType = dataForPassing.rollingBufferHolder
                magicPlot.backgroundColor = AKColor.white
                magicPlot.shouldCenterYAxis = true
                magicPlot.alpha = dataForPassing.alpha
                
                magicPlot.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                magicPlot.shouldFill = dataForPassing.fill
                magicPlot.shouldMirror = dataForPassing.mirror
                
                self.view.addSubview(magicPlot)
            case 1:
                let magicPlotTwo = AKNodeOutputPlot(playerTwo!, frame: self.view.frame, bufferSize: 1024)
                magicPlotTwo.plotType = dataForPassing.rollingBufferHolder
                magicPlotTwo.backgroundColor = AKColor.white
                magicPlotTwo.shouldCenterYAxis = true
                magicPlotTwo.alpha = dataForPassing.alpha
                
                magicPlotTwo.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                magicPlotTwo.shouldFill = dataForPassing.fill
                magicPlotTwo.shouldMirror = dataForPassing.mirror
                
                self.view.addSubview(magicPlotTwo)
            default:
                let magicPlot = AKNodeFFTPlot(playerTwo!, frame: self.view.frame, bufferSize: 1024)
                magicPlot.plotType = dataForPassing.rollingBufferHolder
                magicPlot.backgroundColor = AKColor.white
                magicPlot.shouldCenterYAxis = true
                magicPlot.alpha = dataForPassing.alpha
                
                magicPlot.color = UIColor(red: CGFloat(allColors.redColor), green: CGFloat(allColors.greenColor), blue: CGFloat(allColors.blueColor), alpha: 1.0)
                magicPlot.shouldFill = dataForPassing.fill
                magicPlot.shouldMirror = dataForPassing.mirror
                
                self.view.addSubview(magicPlot)

            }
        }
    }
}
