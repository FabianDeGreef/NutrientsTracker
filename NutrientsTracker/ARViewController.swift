//
//  ARViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 05/11/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var arSceneView: ARSCNView!
    
    var products:[Product] = []
    var productNames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show statistics such as fps and timing information
        arSceneView.showsStatistics = true
        // Create a new scene
        let scene = SCNScene(named: "ARScene.scn")!
        // Set the scene to the view
        arSceneView.scene = scene
        products = ProductRepository.fetchLocalProducts()
        productNames = ProductRepository.fetchLocalProductNames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Object Detection
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Products", bundle: Bundle.main)!
        // Run the view's session
        arSceneView.session.run(configuration)
    }
    
    //MARK:  ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        let name:String = (anchor.name)!
        if productNames.contains(name.lowercased()){
            var foundProduct = Product()
            for product in products {
                if name == product.name{
                    foundProduct = product
                }
            }
            if let objectAnchor = anchor as? ARObjectAnchor {
                let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 1.5), height: CGFloat(objectAnchor.referenceObject.extent.y * 1.5))
                plane.cornerRadius = plane.width / 6
                
                let spriteKitScene = SKScene(fileNamed: "ProductInfo")
                let productTitle = (spriteKitScene?.childNode(withName: "ProductTitle"))! as! SKLabelNode
                productTitle.text = foundProduct.name
                
                let protein = (spriteKitScene?.childNode(withName: "ProteinLabel"))! as! SKLabelNode
                protein.text = ConverterService.convertDoubleToString(double: foundProduct.protein)+"g"
                
                let salt = (spriteKitScene?.childNode(withName: "SaltLabel"))! as! SKLabelNode
                salt.text = ConverterService.convertDoubleToString(double: foundProduct.salt)+"g"

                let carb = (spriteKitScene?.childNode(withName: "CarbLabel"))! as! SKLabelNode
                carb.text = ConverterService.convertDoubleToString(double: foundProduct.carbohydrates)+"g"

                let kcal = (spriteKitScene?.childNode(withName: "KcalLabel"))! as! SKLabelNode
                kcal.text = ConverterService.convertDoubleToString(double: foundProduct.kilocalories)+"g"

                let fat = (spriteKitScene?.childNode(withName: "FatLabel"))! as! SKLabelNode
                fat.text = ConverterService.convertDoubleToString(double: foundProduct.fat)+"g"

                let fiber = (spriteKitScene?.childNode(withName: "FiberLabel"))! as! SKLabelNode
                fiber.text = ConverterService.convertDoubleToString(double: foundProduct.fiber)+"g"

                
                let productImage = (spriteKitScene?.childNode(withName: "ProductImage"))! as! SKSpriteNode
                productImage.size = CGSize(width: 50.0, height: 50.0)
                productImage.texture = SKTexture(image: UIImage(data:foundProduct.image!)!)
                plane.firstMaterial?.diffuse.contents = spriteKitScene
                plane.firstMaterial?.isDoubleSided = true
                plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                
                let planeNode = SCNNode(geometry: plane)
                planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.45, objectAnchor.referenceObject.center.z)
                node.addChildNode(planeNode)
            }
        }
        return node
    }
    //MARK: Segue prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
