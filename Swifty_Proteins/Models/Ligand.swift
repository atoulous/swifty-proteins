//
//  Ligand.swift
//  Swifty_Proteins
//
//  Created by Sloven GRACIET on 2/4/18.
//  Copyright © 2018 Sloven GRACIET. All rights reserved.
//

import Foundation
import SceneKit


struct Atom {
    var id : Int
    var nameLigand: String
    var position : SCNVector3
    var nameAtom : String
}

struct Conect {
    var currentAtom : Int
    var connections : [Int]
}

struct ligData{
    var chemicalID : String
    var chemicalName : String
    var type : String
    var weight : String
    var formula : String
    
}

class Ligand {
    var atoms = [Atom]()
    var conects = [Conect]()
    var ligdata:ligData!
    
    func addItems(lig: [String]){
        for l in lig {
            let components: [String] = l.components(separatedBy: " ").filter {$0 != ""}
            if components != []{
                if components[0] == "ATOM"{
                    let id = Int(components[1])!
                    let nL = components[3]
                    let pos = SCNVector3(Float(components[6])!,Float(components[7])!,Float(components[8])!)
                    let nA = components[11]
                    self.atoms.append(Atom(id: id,nameLigand: nL,position: pos,nameAtom: nA))
                }else if components[0] == "CONECT"{
                    let curAtom = Int(components[1])!
                    var connec = [Int]()
                    for (index,component) in components.enumerated(){
                        if index > 1{
                            connec.append(Int(component)!)
                        }
                    }
                    self.conects.append(Conect(currentAtom: curAtom,connections: connec))
                }
            }
            
        }
    }
    
    func removeAll(){
        if self.atoms.isEmpty == false{
            self.atoms.removeAll()
        }
        if self.conects.isEmpty == false{
            self.conects.removeAll()
        }
    }
}


extension SCNVector3{
    func distance(vector: SCNVector3) -> Float {
        let x = vector.x - self.x
        let y = vector.y - self.y
        let z = vector.z - self.z
        let d = Float(sqrt(x * x + y * y + z * z))
        if (d < 0){
            return (d * -1)
        } else {
            return (d)
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
     convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}
