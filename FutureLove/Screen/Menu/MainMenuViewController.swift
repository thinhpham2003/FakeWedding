//
//  MainMenuViewController.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 18/01/2024.
//

import UIKit

class MainMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycellMenu", for: indexPath)
        
        cell.textLabel?.text = lstMenu[indexPath.row]
        return cell
    }
    
    
    
    let lstMenu: [String] = ["Home","Service","Contact Us"]
    
    @IBAction func btnMainMenu(_ sender: UIButton) {
        self.TableViewMenu.isHidden = !self.TableViewMenu.isHidden
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(identifier: "ProfileController") as? ProfileController{
            self.navigationController?.pushViewController(vc, animated: true)
            let selectedItem = lstMenu[indexPath.row]
            
            if selectedItem == "Service" {
                
                
                self.present(vc, animated: true, completion: nil)
            }
            
            else if selectedItem == "OtherMenuItem" {
                
            }
        }
        
    }
    
    
    @IBOutlet weak var TableViewMenu: UITableView!
    @IBOutlet weak var btnChonMenu: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableViewMenu.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lstMenu.count
    }
    
    @IBAction func BackApp(){
        self.dismiss(animated: true)
    }
    
    @IBAction func BackApp1(){
        self.dismiss(animated: true)
    }
    
}
