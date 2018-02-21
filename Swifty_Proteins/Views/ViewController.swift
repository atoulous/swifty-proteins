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
        self.navigationController?.navigationBar.tintColor = UIColor.white
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
            vc.title = sender as? String
        }
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

