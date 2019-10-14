//
//  CreditsTableViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

struct CreditCell {
    
    let title: String
    let text: String
    let url: String
    
}

final class CreditsTableViewController: UITableViewController {
    
    // MARK: - Properties
    let tableData = [CreditCell(title: "\"keys\"",
                                text: "\"keys\"\nby Markus from the Noun Project",
                                url:  "https://thenounproject.com/search/?q=key&i=1807018"),
                     CreditCell(title: "\"Location\"",
                                text: "\"Location\"\nby designillustration10 from the Noun Project",
                                url: "https://thenounproject.com/search/?q=location&i=2096895"),
                     CreditCell(title: "\"Book\"",
                                text: "\"Book\"\nby Diego Naive from the Noun Project",
                                url: "https://thenounproject.com/search/?q=bibliography&i=15474"),
                     CreditCell(title: "\"Error\"",
                                text: "\"Error\"\nby Thengakola from the Noun Project",
                                url: "https://thenounproject.com/search/?q=error&i=940617"),
                     CreditCell(title: "\"Lock\"",
                                text: "\"Lock\"\nby Aya Sofya from the Noun Project",
                                url: "https://thenounproject.com/search/?q=lock&i=771674"),
                     CreditCell(title: "\"Bell\"",
                                text: "\"Bell\"\nby Graphic Tigers from the Noun Project",
                                url: "https://thenounproject.com/search/?q=timed%20notification&i=818887"),
                     CreditCell(title: "\"Email\"",
                                text: "\"Email\"\nby unlimicon from the Noun Project",
                                url: "https://thenounproject.com/search/?q=mail&i=565415"),
                     CreditCell(title: "\"treasure map\"",
                                text: "\"treasure map\"\nby Nikita Kozin from the Noun Project",
                                url: "https://thenounproject.com/search/?q=map&i=1173392"),
                     CreditCell(title: "\"call\"",
                                text: "\"call\"\nby Gregor Cresnar from the Noun Project",
                                url: "https://thenounproject.com/search/?q=phone%20notification&i=625941"),
                     CreditCell(title: "\"Lost and Found\"",
                                text: "\"Lost and Found\"\nby icon 54 from the Noun Project",
                                url: "https://thenounproject.com/search/?q=lost%20and%20found&i=545855"),
                     CreditCell(title:"\"Book\"",
                                text: "\"Book\"\nby scott desmond from the Noun Project",
                                url: "https://thenounproject.com/search/?q=BOOk&i=2173674"),
                     CreditCell(title: "\"link\"",
                                text: "\"link\"\nby Luiz Carvalho from the Noun Project",
                                url: "https://thenounproject.com/search/?q=link&i=1713473")]

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
        
        // Return the view
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
        
        // Return the cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Give the rows a height of 60
        return 60
        
    }
    
}
