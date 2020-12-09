//
//  Tempo.swift
//  
//
//  Created by Samuel Arellano on 08/12/20.
//

import Foundation

class Tempo {
    
    var PastPoint: NSDate = NSDate()
    var Delta: Double {
        get {
            //if First { PresentPoint = NSDate() }
            let PresentPoint: NSDate = NSDate()
            let delta = PresentPoint.timeIntervalSince(PastPoint as Date).magnitude
            timeStep()
            return delta
        }
    }
    
    private func timeStep() {
        PastPoint = NSDate()
    }
    
}
