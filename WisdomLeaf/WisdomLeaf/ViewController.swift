//
//  ViewController.swift
//  WisdomLeaf
//
//  Created by DDP on 29/05/23.
//

import UIKit
import WebKit
import QuickLook

class ViewController: UIViewController{

    var imageInfos = [ImageDetails]()
    @IBOutlet weak var imageTable: UITableView!
    //webKit outlet for showing the screen using html response
    @IBOutlet weak var preView_view: UIView!
    @IBOutlet weak var web_Kit: WKWebView!
    @IBOutlet weak var cancel_btn: UIButton!
    
    let previewController = QLPreviewController()
    var previewItems: [PreviewItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //WebKit related method and view hidden
        self.preView_view.isHidden = true
        self.cancel_btn.addTarget(self, action: #selector(cancel_btnaction), for: .touchUpInside)
        
        
        initializeURLSession()
        imageTable.delegate = self
        imageTable.dataSource = self
        imageTable.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        
    }

//MARK:- Initialize webservice

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
    
// Preview Webservice using Webkit in HTML response or URL path
    
    func preViewImage(URL1:String){
        let session = URLSession.shared

        guard let url = URL(string: URL1) else {
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
                        guard let prettyPrintedJson = String(data: data, encoding: .utf8)else { return }
                        
                        DispatchQueue.main.async {
                            
                        self.preView_view.isHidden = false
                        self.web_Kit.navigationDelegate = self
                        self.web_Kit.uiDelegate = self
                        self.web_Kit.loadHTMLString(prettyPrintedJson, baseURL: nil) //using HTML string
                        //self.web_Kit.load(URLRequest(url: url)) // using URL Path
                            
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
    
 // Download Path and Preview the download path Webservice
    
    func quickLook(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                //  in case of failure to download your data you need to present alert to the user
                self.presentAlertController(with: error?.localizedDescription ?? "Failed to download the pdf!!!")
                return
            }
            // you neeed to check if the downloaded data is a valid pdf
            //            guard
            //                let httpURLResponse = response as? HTTPURLResponse,
            //                let mimeType = httpURLResponse.mimeType,
            //                mimeType.hasSuffix("pdf")
            //            else {
            //                print((response as? HTTPURLResponse)?.mimeType ?? "")
            //                self.presentAlertController(with: "the data downloaded it is not a valid pdf file")
            //                return
            //            }
            let httpResponse = response as? HTTPURLResponse
            print (httpResponse!)
            //  let statuscode = httpResponse?.statusCode
            
            let header = httpResponse?.allHeaderFields as NSDictionary?
            let headername = header!["Content-Disposition"] as? String
            let filename12 = headername?.components(separatedBy: ";")
            var filename13:String?
            
            if filename12 != nil
            {
                
                for i in 0..<filename12!.count{
                    
                    let tempfile = filename12![i]
                    if tempfile.contains("filename=")
                    {
                        filename13 = tempfile.replacingOccurrences(of: "filename=", with: "")
                        filename13 = filename13!.replacingOccurrences(of: "\"", with: "")
                    }
                }
                
            }
            
            print("checking filename \(filename13 ?? "")")
            print("checking \(headername ?? "")")
            
            
            DispatchQueue.main.async {
            do {
                // rename the temporary file or save it to the document or library directory if you want to keep the file
                let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                var fileURL:URL?
                if filename13 != nil
                {
                    fileURL = documentsDirectoryURL.appendingPathComponent(filename13!);
                    // print(fileURL)
                    print("developing")
                    
                    try data.write(to:fileURL!)
                    
                }
                else
                {
                    fileURL = documentsDirectoryURL.appendingPathComponent(filename13 ?? "");
                    //print(fileURL)
                    print("developing")
                    
                    try data.write(to:fileURL!)
                }
                
                let alert = UIAlertController(title: "", message: "File Downloaded Successfully", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    
                    return
                    // Code for Cam
                }))
                alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { action in
                    fileURL!.hasHiddenExtension = true
                    let previewItem = PreviewItem()
                    previewItem.previewItemURL = fileURL
                    self.previewItems.append(previewItem)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.previewController.delegate = self
                    self.previewController.dataSource = self
                    self.previewController.currentPreviewItemIndex = 0
                    self.present(self.previewController, animated: true)
                    
                    
                }))
                
                self.present(alert,animated: true)
                
                
            } catch {
                print(error)
                return
            }
        }
        }.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    
    
//preview View method hide button
    @objc func cancel_btnaction(sender:UIButton){
        
        self.preView_view.isHidden = true
    }
   
}


//MARK:- UITableView Delegate and Datasource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = imageTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.authorLabel.text = imageInfos[indexPath.row].author
        if let imageUrl = self.imageInfos[indexPath.row].download_url {
            cell.rolledImage.imageFromURL(urlString: imageUrl)
        } else {
            cell.rolledImage.image = UIImage(named: "dummyimage")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tagId = indexPath.row
        
        let url = self.imageInfos[indexPath.row].download_url ?? ""
        let url1 = URL(string:url ?? "")
        quickLook(url: url1!)
    }
    
   
    
}


// MARK:- Webkit Delegate
extension ViewController: WKUIDelegate, WKNavigationDelegate {
    
            func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("Start to load")
           
             //  activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
                                     //
                                     //                  activityView.center = view.center
               
    //                                                   let view12 = UIView(frame: CGRect(x: 0, y: -50, width: self.view.frame.size.width, height: self.view.frame.size.height))
    //
    //                                                    activityView.center = view12.center
    //
    //                                                   activityView.hidesWhenStopped = false
    //
    //                                                   let color = UserDefaults.standard.data(forKey:"background_color")
    //
    //                                                              if((UserDefaults.standard .string(forKey: "BG_Color")) == "DARKTHEME")
    //                                                              {
    //                                                                  activityView.color =   NetworkAPI.shared.DARKTHEME_ActivityCOLOR
    //                                                              }
    //                                                              else
    //
    //                                                              {
    //                                                                 activityView.color =   NSKeyedUnarchiver.unarchiveObject(with:color!) as? UIColor
    //                                                              }
               
               
    //                                                   activityView.startAnimating()
    //
    //            self.ESSWebView.addSubview(activityView)

            }

                func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    print("Finish to load")
    //                self.activityView.stopAnimating()
    //                self.activityView.removeFromSuperview()
                }

                func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                    print(error.localizedDescription)
    //                self.activityView.stopAnimating()
    //                self.activityView.removeFromSuperview()
                }

                func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                print(error.localizedDescription)
    //            self.activityView.stopAnimating()
    //                      self.activityView.removeFromSuperview()
                }
           
            func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
                let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
                webView.evaluateJavaScript(javascript, completionHandler: nil)
            }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
         if navigationAction.navigationType == WKNavigationType.linkActivated {

             print("run code")

             decisionHandler(WKNavigationActionPolicy.cancel)
             return
         }
         decisionHandler(WKNavigationActionPolicy.allow)
     }

    
}

// MARK:- QLPreviewController Delegate and Datasource

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { previewItems.count }
    
   
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem { previewItems[index] }
    
    
    func presentAlertController(with message: String) {
         // present your alert controller from the main thread
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    
}

extension URL {
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}
