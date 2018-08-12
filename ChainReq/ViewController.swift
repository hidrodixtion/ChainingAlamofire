//
//  ViewController.swift
//  ChainReq
//
//  Created by Adi Nugroho on 12/08/18.
//  Copyright © 2018 Lonely Box. All rights reserved.
//

import UIKit
import RxAlamofire
import RxSwift
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var players = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        getData()
    }
    
    private func getData() {
        var selectedTeam = ""
        _ = json(.get, "https://www.thesportsdb.com/api/v1/json/1/search_all_teams.php?l=English%20Premier%20League")
            .flatMap({ data -> Observable<Any> in
                let jsonData = JSON(data)
                let teams = jsonData["teams"].arrayValue
                let randomIndex = Int(arc4random_uniform(UInt32(teams.count)))
                selectedTeam = teams[randomIndex]["strTeam"].stringValue
                
                let url = "https://www.thesportsdb.com/api/v1/json/1/searchplayers.php?t=\(selectedTeam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                return json(.get, url!)
            })
            .observeOn(MainScheduler.instance)
            .subscribe { [unowned self] in
                self.title = "\(selectedTeam) Players"
                if let data = $0.element {
                    let jsonData = JSON(data)
                    let jsonPlayers = jsonData["player"].arrayValue
                    
                    self.players = jsonPlayers.map({ (json) in
                        json["strPlayer"].stringValue
                    })
                    
                    print(self.players)
                    self.tableView.reloadData()
                }
        }
    }
    
    @IBAction func onRefreshClicked(_ sender: UIBarButtonItem) {
        getData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = players[indexPath.row]
        return cell
    }
}
