//
//  ViewController.swift
//  MoviesList
//
//  Created by Mr.Ved on 6/1/17.
//  Copyright © 2017 Vishnu. All rights reserved.
//

import UIKit

class MoviesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var moviesTableView: UITableView!
    
    let apiKey = "ffea4438a4ff5ddf2386e5189be357cb"
    var pageNumber = 1
    var totalPages: Int = 0
    var searchText = ""
    var moviesList = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.moviesTableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesList.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        if let movie:[String : Any] = moviesList[indexPath.row] as? [String : Any] {
            cell.textLabel?.text = movie["title"] as? String
        } else {
            cell.textLabel?.text = moviesList[indexPath.row] as? String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: self.moviesList[indexPath.row])
    }
    
    @IBAction func didTapOnSubmitButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.resetTheValuesForNewSearch()
        self.getMoviesList(movieName: searchText, page: pageNumber)
    }
    
    func resetTheValuesForNewSearch() {
        self.moviesList.removeAll()
        pageNumber = 1
    }
    
    func getMoviesList(movieName: String, page: Int) {
        let headers = [
            "content-type": "application/json",
            ]
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(movieName)&page=\(page)"
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = NSMutableURLRequest(url: NSURL(string: encodedString!)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                        let resultArray = result["results"] as! [Any]
                        self.totalPages = result["total_pages"] as! Int
                        self.moviesList += resultArray
                        DispatchQueue.main.async {
                            if self.moviesList.count == 0 {
                                self.moviesList.append("No results found")
                            }
                            self.moviesTableView.reloadData()
                        }
                    } catch {
                        
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchText = searchTextField.text!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset : CGFloat = scrollView.contentOffset.y
        let scrollHeight : CGFloat = scrollView.frame.size.height
        
        let scrollContentSizeHeight : CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if scrollOffset + scrollHeight == scrollContentSizeHeight && pageNumber != totalPages
        {
            pageNumber += 1
            self.getMoviesList(movieName: searchText, page: pageNumber)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            let movieDetailsVC = segue.destination as! MovieDetailsViewController
            movieDetailsVC.movieDetails = sender as! [String : Any]
        }
    }
    
}

