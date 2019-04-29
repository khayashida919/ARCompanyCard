//
//  ViewController.swift
//  ARCompanyCard
//
//  Created by khayashida on 2019/04/24.
//  Copyright © 2019 jp.co.khayashida.ARCompanyCard. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private var profileNode: SCNNode!
    
    let imageConfiguration: ARImageTrackingConfiguration = {
        let configuration = ARImageTrackingConfiguration()
        
        let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        configuration.trackingImages = images!
        configuration.maximumNumberOfTrackedImages = 1
        return configuration
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        setProfileNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(imageConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        setProfileNode()
        sceneView.session.run(imageConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setProfileNode() {
        profileNode = SCNScene(named: "art.scnassets/CompanyCard.scn")!.rootNode.childNode(withName: "card", recursively: false)
        profileNode.childNode(withName: "thumbnail", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "thumbnails")
        profileNode.childNode(withName: "twittericon", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "twittericon")
        profileNode.childNode(withName: "githubicon", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "github")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: sceneView),
            let result = sceneView.hitTest(location, options: nil).first else {
                return
        }
        switch result.node.name {
        case "twittericon":
            let safari = SFSafariViewController(url: URL(string: "https://twitter.com/solty_919")!)
            present(safari, animated: true, completion: nil)
        case "githubicon":
            let safari = SFSafariViewController(url: URL(string: "https://github.com/khayashida919")!)
            present(safari, animated: true, completion: nil)
        default: break
        }
    }

}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return nil
        }
        if imageAnchor.referenceImage.name == "trackingImage" {
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator().impactOccurred()
            }
            
            func fadeInMoveAction(node: SCNNode) {
                node.opacity = 0
                let position = SCNVector3(node.position.x, node.position.y, node.position.z+0.077)
                let wait = SCNAction.wait(duration: 1)
                let move = SCNAction.move(to: position, duration: 1)
                let fadeIn = SCNAction.fadeIn(duration: 0.5)
                let actions = SCNAction.sequence([wait, SCNAction.group([move, fadeIn])])
                node.runAction(actions)
            }
            
            func fadeInRotate(node: SCNNode) {
                node.opacity = 0
                let wait = SCNAction.wait(duration: 2)
                let fadeIn = SCNAction.fadeIn(duration: 0.5)
                let rotate = SCNAction.rotateBy(x: .pi*2, y: 0, z: 0, duration: 0.5)
                let actions = SCNAction.sequence([wait, fadeIn, rotate])
                node.runAction(actions)
            }
            
            let cardNode = profileNode.childNode(withName: "card", recursively: true)!
            cardNode.opacity = 0
            let fadeIn = SCNAction.fadeIn(duration: 0.25)
            let fadeOut = SCNAction.fadeOut(duration: 0.25)
            let cardActions = SCNAction.sequence([fadeIn, fadeOut, fadeIn, fadeOut])
            cardNode.runAction(cardActions)
            
            let thumbnailNode = profileNode.childNode(withName: "profile", recursively: true)!
            fadeInMoveAction(node: thumbnailNode)
            
            let twitterNode = profileNode.childNode(withName: "buttons", recursively: true)!
            fadeInRotate(node: twitterNode)
            
            return profileNode
        }
        return nil
    }

}
