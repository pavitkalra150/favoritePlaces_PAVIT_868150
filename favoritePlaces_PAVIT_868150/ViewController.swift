//
//  ViewController.swift
//  favoritePlaces_PAVIT_868150
//
//  Created by PAVIT KALRA on 2023-01-24.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var addresses = [String]()
    func didSelectAddress(address: String) {
            addresses.append(address)
            tableView.reloadData()
    }
    
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
            tableView.dataSource = self
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = addresses[indexPath.row]
            return cell
    }

    
    @IBAction func AddButtonTapped(_ sender: UIBarButtonItem) {
        
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "showMapViewController" {
//                let destination = segue.destination as! MapViewController
//                destination.delegate = self
//            }
//        }
}

