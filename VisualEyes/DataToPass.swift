//
//  DataToPass.swift
//  VisualEyes
//
//  Created by Justin on 12/22/16.
//  Copyright © 2016 adhoc. All rights reserved.
//

import Foundation
import AudioKit

class DataToPass: ColorPickerClass {
    var fileName = String()
    var plotType = Int()
    var rollingBufferHolder:EZPlotType = EZPlotType(rawValue: Int())!
    var alpha = CGFloat()
    var mirror = Bool()
    var fill = Bool()
}
