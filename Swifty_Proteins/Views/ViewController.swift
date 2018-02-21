//
//  ViewController.swift
//  Swifty_Proteins
//
//  Created by Sloven GRACIET on 2/3/18.
//  Copyright © 2018 Sloven GRACIET. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating{

    @IBOutlet weak var proteinTableView: UITableView!
    
    var proteins : [String]?
    var filteredProteins = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var ligand:Ligand!
    var color: [String:String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ligand = Ligand()
        getProtsfromTxt()
        getCPKcolorfromJson()
        filteredProteins = proteins!
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ligands"
        proteinTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        self.proteinTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredProteins = proteins!
        } else {
            filteredProteins = (proteins?.filter({ $0.uppercased().contains(searchController.searchBar.text!.uppercased())}))!
        }
        self.proteinTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (filteredProteins.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proteinCell") as! proteinTableViewCell
        cell.protNameLabel?.text = filteredProteins[indexPath.row]
        return cell
    }
    
    
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected licands : \(filteredProteins[indexPath.row])")
        self.performSegue(withIdentifier: "3Dsegue", sender: self.filteredProteins[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "3Dsegue"{
            let vc = segue.destination as! protein3DViewController
            vc.ligand = self.ligand
            vc.color = self.color
            vc.title = sender as! String
            
        }
    }
    
    func doRequest(ligands: String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseUrl =  "http://file.rcsb.org/ligands/download/"
        let url = URL(string : baseUrl + ligands + "_model.pdb")
        let request = NSMutableURLRequest(url : url!)
        request.httpMethod = "GET"
        print("Request on \(request.url!)")
        let task = URLSession.shared.dataTask(with: url!){
            data, response, error in
            if error != nil{
                let alertController =  UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.present(alertController, animated: true, completion: nil)
            }else if let d = data{
                if let lig =  String(data: d, encoding: String.Encoding.utf8)?.components(separatedBy: "\n") {
                    
                    DispatchQueue.main.async {
                        self.ligand.removeAll()
                        self.ligand.addItems(lig: lig)

                        self.performSegue(withIdentifier: "3Dsegue", sender: self)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                
                }
            }
        }
        task.resume()
    }
    
    func doRequestData(ligands: String){
        // activity monitor when request on
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseUrl =  "https://www.rcsb.org/pdb/rest/describeHet?chemicalID="
        let url = URL(string : baseUrl + ligands)
        let request = NSMutableURLRequest(url : url!)
        request.httpMethod = "GET"
        print("Request on \(request.url!)")
        let task = URLSession.shared.dataTask(with: url!){
            data, response, error in
            if error != nil{
                let alertController =  UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.present(alertController, animated: true, completion: nil)
            }else if let d = data{
                if let lig =  String(data: d, encoding: String.Encoding.utf8)?.components(separatedBy: "\n") {
                    if lig[1].range(of: "error") == nil {
                        var chemicalName = String()
                        var chemicalAttribute = [String]()
                        var formula = String()
                        for l in lig{
                            if l.range(of:"chemicalName") != nil {
                               chemicalName = l.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression , range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
                            }else if l.range(of:"chemicalID") != nil {
                                var s = l.components(separatedBy: "<ligand ")
                                let t = s[1].replacingOccurrences(of: ">", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                chemicalAttribute = t.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "=", with: ":").components(separatedBy: " ")
                            }else if l.range(of:"formula") != nil {
                                formula = l.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression , range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                        self.ligand.ligdata = ligData(chemicalID: chemicalAttribute[0], chemicalName: chemicalName, type: chemicalAttribute[1],weight: chemicalAttribute[2], formula: formula)
                    }
                    DispatchQueue.main.async {
                        self.doRequest(ligands: ligands)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
  
    func getCPKcolorfromJson(){
        let file = "color"
        let path  = Bundle.main.path(forResource: file, ofType:"json")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? [String:String]{
                self.color = jsonResult
            }
        } catch {
            // handle error
        }
    }
    
    func getProtsfromTxt(){
         let file = "ligands"
        let path  = Bundle.main.path(forResource: file, ofType:"txt")
        do {
            let text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            proteins = text.components(separatedBy: "\n")
        }
        catch {
            print(error)
        }
    }
}

