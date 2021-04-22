//
//  ARView.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import ARKit
import Foundation
import UIKit
import SwiftUI

struct ARView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARSCNViewController

    var arController = ARSCNViewController()

    func makeUIViewController(context: Context) -> ARSCNViewController {
        return arController
    }

    func updateUIViewController(_ uiViewController: ARSCNViewController, context: Context) {
    }
}
