//
//  CreditsTableViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

struct CreditCell {
    
    let title: String
    let text: String
    let url: String
    
}

class CreditsTableViewController: UITableViewController {
    
    // MARK: - Properties
    let tableData = [CreditCell(title: "\"keys\"",
                                text: "\"keys\"\n by Markus from the Noun Project",
                                url:  "https://thenounproject.com/search/?q=key&i=1807018"),
                     CreditCell(title: "\"Location\"",
                                text: "\"Location\"\n by designillustration10 from the Noun Project",
                                url: "https://thenounproject.com/search/?q=location&i=2096895"),
                     CreditCell(title: "\"Book\"",
                                text: "\"Book\"\n by Diego Naive from the Noun Project",
                                url: "https://thenounproject.com/search/?q=bibliography&i=15474"),
                     CreditCell(title: "\"Error\"",
                                text: "\"Error\"\n by Thengakola from the Noun Project",
                                url: "https://thenounproject.com/search/?q=error&i=940617"),
                     CreditCell(title: "\"Lock\"",
                                text: "\"Lock\"\n by Aya Sofya from the Noun Project",
                                url: "https://thenounproject.com/search/?q=lock&i=771674"),
                     CreditCell(title: "\"notification\"",
                                text: "\"notification\"\n by Angelo Troiano from the Noun Project",
                                url: "https://thenounproject.com/search/?q=notification&i=2695723"),
                    CreditCell(title: "\"Email\"",
                               text: "\"Email\"\n by unlimicon from the Noun Project",
                               url: "https://thenounproject.com/search/?q=mail&i=565415"),
                    CreditCell(title: "\"name\"",
                               text: "\"name\"\n by Adrien Coquet from the Noun Project",
                               url: "https://thenounproject.com/search/?q=name&i=1946983"),
                    CreditCell(title: "\"treasure map\"",
                               text: "\"treasure map\"\n by Nikita Kozin from the Noun Project",
                               url: "https://thenounproject.com/search/?q=map&i=1173392"),
                    CreditCell(title: "\"call\"",
                               text: "\"call\"\n by Gregor Cresnar from the Noun Project",
                               url: "https://thenounproject.com/search/?q=phone%20notification&i=625941")]
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Section Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the section for icon creators
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create a header label
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: 200, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Icon Creators"
        
        // Create a view for the header to lie in
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 255/255)
        view.addSubview(label)
        
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Give the header a height of 30
        return 30
        
    }

    // MARK: - Row Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of pieces of data
        return tableData.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a Credit Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCell", for: indexPath) as! CreditTableViewCell
        
        // Get the name, credit and url for the row
        let name       = tableData[indexPath.row].title
        let creditText = tableData[indexPath.row].text
        let url        = tableData[indexPath.row].url
        
        // Create a hyperlink for the information
        cell.linkTextView.attributedText = NSAttributedString.makeHyperlink(for: url, in: creditText, as: name)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Give the rows a height of 60
        return 60
        
    }
    
}
