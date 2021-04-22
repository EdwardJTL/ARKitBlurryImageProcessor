//
//  ARSCNViewController.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import UIKit

class ARSCNViewController: UIViewController {
    var sceneView = ARSCNView()
    var session: ARSession { sceneView.session }

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.session.delegate = self

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)

        let viewsDict = ["subview": sceneView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDict)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: viewsDict)
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true

        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        session.pause()
    }

    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
