//
//  ProfileController.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 22/01/2024.
//

import UIKit

class ProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycellMenu", for: indexPath)

        cell.textLabel?.text = lstMenuProflie[indexPath.row]
        return cell
    }
    
    
    
    let lstMenuProflie: [String] = ["Accout","Edit Profile"]
    @IBAction func btnMenuProfile(_ sender: UIButton) {
        self.TableViewProfile.isHidden = !self.TableViewProfile.isHidden
    }
    
    @IBOutlet weak var TableViewProfile: UITableView!
    @IBOutlet weak var btnChonMenuProfile: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableViewProfile.isHidden = true

        // Do any additional setup after loading the view.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lstMenuProflie.count
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
