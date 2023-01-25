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
        if let addresses = UserDefaults.standard.array(forKey: "addresses") as? [String] {
                self.addresses = addresses
            }
            tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Retrieve the saved address from UserDefaults
                if let address = UserDefaults.standard.string(forKey: "addresses") {
                // Add the address to the data source for the table view
                addresses.append(address)
                // Reload the table view to display the new address
                tableView.reloadData()
            }
        }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(addresses, forKey: "addresses")
        UserDefaults.standard.synchronize()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = addresses[indexPath.row]
                return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            addresses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func AddButtonTapped(_ sender: UIBarButtonItem) {
        
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        secondViewController.delegate = self
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
}


extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAddress = addresses[indexPath.row]
        let mapViewController = storyboard!.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        mapViewController.selectedAddress = selectedAddress
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
