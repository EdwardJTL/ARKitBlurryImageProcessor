//
//  ARSCNViewController+ARSessionDelegate.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import ARKit
import Foundation

extension ARSCNViewController: ARSessionDelegate {
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameReceiver?.send(frame: frame)
    }
}
