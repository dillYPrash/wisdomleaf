//
//  ViewController.swift
//  WisdomLeaf
//
//  Created by DDP on 29/05/23.
//

import UIKit

class ViewController: UIViewController {

    var imageInfos = [ImageDetails]()
    @IBOutlet weak var imageTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeURLSession()
        imageTable.delegate = self
        imageTable.dataSource = self
        imageTable.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
    }


    func initializeURLSession() {
        let session = URLSession.shared

        guard let url = URL(string: Constants.BASE_URL(page_no: 3)) else {
            fatalError("Invalid URL")
        }

        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let imageDetails = try decoder.decode([ImageDetails].self, from: data)
                        
                        for imageInfo in imageDetails {
                            self.imageInfos.append(imageInfo)
                            print("Image ID: \(imageInfo.id ?? "")")
                            print("Author: \(imageInfo.author ?? "")")
                            print("URL: \(imageInfo.url ?? "")")
                            print("Download URL: \(imageInfo.download_url ?? "")")
                            print("==========================")
                        }
                        DispatchQueue.main.async {
                            self.imageTable.reloadData()
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                // Request was not successful
                print("HTTP status code: \(httpResponse.statusCode)")
            }
        }

        // Start the task
        task.resume()

    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = imageTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.authorLabel.text = imageInfos[indexPath.row].author
        if let imageUrl = self.imageInfos[indexPath.row].url {
            cell.rolledImage.imageFromURL(urlString: imageUrl)
        } else {
            cell.rolledImage.image = UIImage(named: "dummyimage")
        }
        
        return cell
    }
    
    
}
