//
//  ARFrameReceiver.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-22.
//

import ARKit
import Foundation

protocol ARFrameReceiver: class {
    func send(frame: ARFrame)
}
