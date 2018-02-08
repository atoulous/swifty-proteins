//
//  protein3DViewController.swift
//  Swifty_Proteins
//
//  Created by Sloven GRACIET on 2/4/18.
//  Copyright © 2018 Sloven GRACIET. All rights reserved.
//

import UIKit
import SceneKit

class protein3DViewController: UIViewController {
    
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var ligand:Ligand!
    var ligandNode: SCNNode!
    var color: [String:String]!
    var hydHasToDisplay = true
    var tapgesture: UITapGestureRecognizer!
    
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var chemicalIdLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var chemicalNameLabel: UITextView!
    
    
    var newRepere : SCNVector3!
    
    
    @IBOutlet weak var aButton: UIButton!
    @IBAction func atomButton(_ sender: Any) {
        print("hit")
        if gameView.allowsCameraControl == true {
            gameView.allowsCameraControl = false
            gameView.addGestureRecognizer(tapgesture)
            aButton.backgroundColor = UIColor.lightGray
        }else{
            gameView.allowsCameraControl = true
            gameView.removeGestureRecognizer(tapgesture)
            aButton.backgroundColor = nil
        }
        
    }
    
    @IBAction func hydroButton(_ sender: Any) {
        hydHasToDisplay = hydHasToDisplay == true ? false : true
        gameScene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
        self.createLigand()
    }
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let alertController =  UIAlertController(title: "SHARE IT !!!", message: "Share this awesome Picture", preferredStyle: UIAlertControllerStyle.alert)
        alertController.view.backgroundColor = UIColor.blue
        alertController.addAction(UIAlertAction(title: "oh yeah", style: UIAlertActionStyle.default, handler: { (alertAction) in
            let saveImg = self.gameView.snapshot()
            let imageToShare = [ saveImg ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            print(activityViewController)
            self.present(activityViewController, animated: true, completion: nil)
        }))
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        setDataInfo()
        getMinMax()
        changePositionInNewRpere()
        createLigand()
    }
    
  
    func setDataInfo(){
        print(self.ligand.ligdata)
        self.chemicalIdLabel.text = self.ligand.ligdata.chemicalID
        self.typeLabel.text = self.ligand.ligdata.type
        self.weightLabel.text = self.ligand.ligdata.weight
        self.formulaLabel.text = self.ligand.ligdata.formula
        self.chemicalNameLabel.text = self.ligand.ligdata.chemicalName
    }
    
    
    func getMinMax(){
       var vectorMax = ligand.atoms[0].position
        var vectorMin = ligand.atoms[0].position
        for atom in ligand.atoms{
            if atom.position.x > vectorMax.x{
                vectorMax.x = atom.position.x
            }else if atom.position.x < vectorMin.x{
                vectorMin.x = atom.position.x
            }
            if atom.position.y > vectorMax.y{
                vectorMax.y = atom.position.y
            }else if atom.position.y < vectorMin.y{
                vectorMin.y = atom.position.y
            }
            if atom.position.z > vectorMax.z{
                vectorMax.z = atom.position.z
            }else if atom.position.z < vectorMin.z{
                vectorMin.z = atom.position.z
            }
        }
         newRepere = SCNVector3(x:(vectorMin.x + vectorMax.x)/2,y:(vectorMin.y + vectorMax.y)/2 ,z:(vectorMin.z + vectorMax.z)/2)
    }
    
    func changePositionInNewRpere(){
        
         for (index,atom) in ligand.atoms.enumerated(){
            let newPos = SCNVector3(x: atom.position.x - newRepere.x, y: atom.position.y - newRepere.y, z: atom.position.z - newRepere.z)
            ligand.atoms[index].position = newPos
        }
    }
    
   
  
    

    func initView(){
        
        gameView = SCNView(frame: self.view.frame)
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        self.view.addSubview(gameView)
        gameView.backgroundColor = UIColor.darkGray
        gameView.addSubview(aButton)
        gameView.addSubview(dataView)
    }
    
    func initScene(){
        print("init")
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
        tapgesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(gesture:)))
//        tapgesture.numberOfTapsRequired = 2
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
    }
    
    
    @IBAction func tapGesture(gesture: UITapGestureRecognizer){
        if gesture.state == .ended {
            let location: CGPoint = gesture.location(in: gameView)
            let hits = gameView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                if tappedNode?.name != nil{
                    aButton.titleLabel?.text = tappedNode?.name!
                }
            }
        }
    }
    
    
    
    func createLigand(){
        ligandNode = SCNNode()
        gameScene.rootNode.addChildNode(ligandNode)
    
        for atom in self.ligand.atoms{
            if atom.nameAtom == "H" && hydHasToDisplay == false{
                continue
            }
            let geometry:SCNGeometry = SCNSphere(radius: 0.5)
            geometry.materials.first?.diffuse.contents = getColor(atom: atom.nameAtom)
            let geometryNode = SCNNode(geometry: geometry)
            geometryNode.position = atom.position
            geometryNode.name = atom.nameAtom
            ligandNode.addChildNode(geometryNode)
        }
        for conect in self.ligand.conects{
            for c in conect.connections{
                let d1 = SCNNode()
                let d2 = SCNNode()
                if let at1 = self.ligand.atoms.first(where: {$0.id == conect.currentAtom }) {
                    d1.position = at1.position
                    if let at2 = self.ligand.atoms.first(where: {$0.id == c }) {
                        if (at2.nameAtom == "H"  || at1.nameAtom == "H") && self.hydHasToDisplay == false {
                            continue
                        }else{
                            d2.position = at2.position
                        }
                    }
                }
                let height = d1.position.distance(vector: d2.position)
                let sourceNode = SCNNode()
                sourceNode.position = d1.position
                let zalign = SCNNode()
                zalign.eulerAngles.x = Float(Double.pi/2)
                let geotube:SCNGeometry = SCNTube(innerRadius: 0.1, outerRadius: 0.1, height: CGFloat(height))
                geotube.materials.first?.diffuse.contents = UIColor.gray
                let tube = SCNNode(geometry:geotube)
                tube.position.y = -height/2
                zalign.addChildNode(tube)
                sourceNode.addChildNode(zalign)
                sourceNode.constraints = [SCNLookAtConstraint(target: d2)]
                ligandNode.addChildNode(d1)
                ligandNode.addChildNode(d2)
                ligandNode.addChildNode(sourceNode)
            }
            
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        if hex == "" {
            return UIColor.magenta
        }
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getColor(atom:String)->UIColor{
        if self.color[atom] == nil{
            self.color[atom] = ""
        }
        return hexStringToUIColor(hex:self.color[atom]!)
    }
    

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
  
    
   
}


