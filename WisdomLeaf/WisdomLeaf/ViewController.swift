//
//  ViewController.swift
//  WisdomLeaf
//
//  Created by DDP on 29/05/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTable.delegate = self
        imageTable.dataSource = self
        imageTable.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        // Do any additional setup after loading the view.
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = imageTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.rolledImage.image = UIImage(named: "dummyimage")
        return cell

    }
    
    
}
