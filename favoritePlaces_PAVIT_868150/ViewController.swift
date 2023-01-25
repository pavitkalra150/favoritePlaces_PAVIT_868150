//
//  ViewController.swift
//  favoritePlaces_PAVIT_868150
//
//  Created by PAVIT KALRA on 2023-01-24.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MapViewControllerDelegate {
    
    var addresses = [String]()
    func didSelectAnnotation(title: String) {
            addresses.append(title)
            tableView.reloadData()
        }
    
    

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
            tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Retrieve the saved address from UserDefaults
            if let address = UserDefaults.standard.string(forKey: "favorite_address") {
                // Add the address to the data source for the table view
                addresses.append(address)
                // Reload the table view to display the new address
                tableView.reloadData()
            }
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
        secondViewController.delegate = self
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "showMapViewController" {
//                let destination = segue.destination as! MapViewController
//                destination.delegate = self
//            }
//        }
}

