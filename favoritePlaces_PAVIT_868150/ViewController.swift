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
        if let addresses = UserDefaults.standard.array(forKey: "favorite_addresses") as? [String] {
            self.addresses = addresses
        }
        tableView.reloadData()
        }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UserDefaults.standard.set(addresses, forKey: "favorite_addresses")
        UserDefaults.standard.synchronize()
        
        super.viewWillDisappear(animated)
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
