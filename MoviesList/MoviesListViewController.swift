//
//  ViewController.swift
//  MoviesList
//
//  Created by Mr.Ved on 6/1/17.
//  Copyright © 2017 Vishnu. All rights reserved.
//

import UIKit

class MoviesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var moviesTableView: UITableView!
    
    var searchController: UISearchController!
    var resultsController = UIViewController()
    
    //API Key generated in Movies DB API Portal
    let apiKey = "ffea4438a4ff5ddf2386e5189be357cb"
    
    var pageNumber = 1
    var totalPages: Int = 0
    var searchText = ""
    var moviesList = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search a Movie"
        
        self.moviesTableView.tableHeaderView = self.searchController.searchBar
        self.moviesTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    //MARK:- UITableViewDataSource Methods
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
    
    //MARK:- UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: self.moviesList[indexPath.row])
    }
    
    //MARK: Reset the values
    func resetTheValuesForNewSearch() {
        self.moviesList.removeAll()
        pageNumber = 1
    }
    
    //MARK:- getMoviesList by using search string
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
                        
                        //Append the new list of Movies from next page of data
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
    
    //MARK:- UISearchBarDelegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text!
        self.resetTheValuesForNewSearch()
        self.getMoviesList(movieName: searchBar.text!, page: pageNumber)
        self.searchController.isActive = false
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset : CGFloat = scrollView.contentOffset.y
        let scrollHeight : CGFloat = scrollView.frame.size.height
        
        let scrollContentSizeHeight : CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        //Scroll reaches bottom start lazy loading the values
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

