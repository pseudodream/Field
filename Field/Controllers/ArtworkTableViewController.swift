//
//  ArtworkTableViewController.swift
//  Field
//
//  Created by amyz on 5/14/21.
//

import UIKit

class ArtworkTableViewController: UITableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var artwork: Artwork!
    override func viewDidLoad() {
        super.viewDidLoad()
        artwork=Artwork()
        
        artwork.getData {
            DispatchQueue.main.async {
                print(self.artwork.primaryImage)
                self.titleLabel.text="\(self.artwork.title)" == "" ? "Unknown Title" : "\(self.artwork.title)"
                self.artist.text="\(self.artwork.artistDisplayName)" == "" ? "Unknown Artist" : "\(self.artwork.artistDisplayName)"
                guard let url = URL(string: self.artwork.primaryImage) else {return}
                do {
                    let data = try Data(contentsOf: url)
                    self.imageView.image = UIImage(data: data)
                } catch {
                    print(" ERROR: Could not get image from url \(url), \(error.localizedDescription)")
                }
            }
            
            
        }

    }
    
    


}
