//
//  Object.swift
//  Field
//
//  Created by amyz on 5/14/21.
//

import Foundation

class Artwork {
    var urlString="https://collectionapi.metmuseum.org/public/collection/v1/objects/"
    
    struct Returned: Codable{
        var title: String
        var artistDisplayName: String
        var primaryImage: String
    }
    
    var title=""
    var artistDisplayName=""
    var primaryImage=""
    
    
    func getData(completed: @escaping ()->()){
        var urlString="https://collectionapi.metmuseum.org/public/collection/v1/objects/"
        let index=Int.random(in:1..<10000)
        urlString+="\(index)"
        print("accessing url \(urlString)")
        guard let url = URL(string: urlString) else {
            print("can't read url")
            completed()
            return
        }
        
        let session=URLSession.shared
        let task=session.dataTask(with: url){ (data,response,error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            do{
                let returned=try JSONDecoder().decode(Returned.self, from: data!)
                self.title=returned.title
                self.artistDisplayName=returned.artistDisplayName
                if returned.primaryImage==""{
                    self.getData(){
                        self.primaryImage=returned.primaryImage
                    }
                }else{
                    self.primaryImage=returned.primaryImage
                }
                
               
                
            }catch{
                print("JSON ERROR sss:\(error.localizedDescription)")
            }
            completed()
            
        }
        
        task.resume()
    }
}
