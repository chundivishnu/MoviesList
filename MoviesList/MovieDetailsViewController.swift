//
//  MovieDetailViewController.swift
//  MoviesList
//
//  Created by Mr.Ved on 6/1/17.
//  Copyright © 2017 Vishnu. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UITextView!
    
    var movieDetails = [String : Any]()
    let posterPathStr = "http://image.tmdb.org/t/p/w185"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateDetails()
    }
    
    func populateDetails() {
        ///Loading poster image
        if let checkedUrl = URL(string: "\(posterPathStr)\(movieDetails["poster_path"] as! String)") {
            posterImageView.contentMode = .scaleAspectFit
            downloadImage(url: checkedUrl)
        }
        
        self.titleLabel.text = movieDetails["title"] as? String
        self.releaseDateLabel.text = movieDetails["release_date"] as? String
        self.overviewLabel.text = movieDetails["overview"] as? String
    }
    

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else {
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.posterImageView.image = UIImage(data: data)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
