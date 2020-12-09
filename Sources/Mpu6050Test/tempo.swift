//
//  Tempo.swift
//  
//
//  Created by Samuel Arellano on 08/12/20.
//

import Foundation

/*
class Tempo {
    
    var PastPoint: NSDate = NSDate()
    var Delta: Double {
        get {
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
*/

class FerventTempo {
    var PastPoint = clock()
    var Delta: Double {
        get {
            let PresentPoint = clock()
            let delta = Double(PresentPoint - PastPoint) / Double(CLOCKS_PER_SEC)
            timeStep()
            return delta
        }
    }
    
    private func timeStep() {
        PastPoint = clock()
    }
    
}
