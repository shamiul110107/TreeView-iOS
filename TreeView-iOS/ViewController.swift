//
//  ViewController.swift
//  TreeView-iOS
//
//  Created by Md. Shamiul Islam on 20/9/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var expandedCellId = NSMutableArray()
    var iduSelectedArray = NSMutableArray()
    var treeData : NSMutableArray? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
 
        loadJson(filename: "File", completion: { response in
            if let data = response?["zone"] as? NSArray {
                self.treeData = NSMutableArray(array: data)
            }
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.treeData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        guard let tree = treeData else {return UITableViewCell()}
        
        if tree.count > indexPath.row {
            
            let things = tree[indexPath.row] as! [String:Any]
            let type = things["type"] as? String
            
            if type == "idu" {
                let iduCell = tableView.dequeueReusableCell(withIdentifier: "iduCell", for: indexPath) as! IDUTableViewCell
                
                if let name = things["name"] as? String {
                    iduCell.iduName.text = name
                } else {
                    iduCell.iduName.text = ""
                }
                
                if let iduOnOf = things["iduOnOf"] as? Bool {
                    iduCell.statusLabel.text = iduOnOf ? "RUNNING" : "STOPPED"
                }
                                
                iduCell.leadingConstraintForIduCell.constant = 48
                iduCell.statusLabel.textColor = UIColor.red
                
                if let zoneName = things["zoneName"] as? String {
                    iduCell.oduCapacityLabel.text = zoneName
                } else {
                    iduCell.oduCapacityLabel.text = ""
                }
                
                iduCell.dotedMenuButton.tag = indexPath.row
                
                return iduCell
                
            } else if type == "odu" {
                
                let oduCell = tableView.dequeueReusableCell(withIdentifier: "oduCell", for: indexPath) as! ODUTableViewCell
                
                oduCell.oduTitle.setTitle("\(things["name"] ?? "")".uppercased(), for: .normal)
                oduCell.containerViewLeadingConstant.constant = 24
                oduCell.oduTitle.addTarget(self, action: #selector(self.oduViewCellTap(_:)), for : .touchUpInside)
                
                return oduCell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! RcGroupTitleTableViewCell

                if let thingName = things["name"] as? String {
                    cell.titleButton.setTitle("\(thingName)".uppercased(), for: .normal)
                }
      
                cell.titleCellLeadingConstraing.constant = 16
                cell.containerViewForTitleCell.tag = indexPath.row
                
                cell.titleButton.addTarget(self, action: #selector(self.tableViewCellTap(_:)), for : .touchUpInside)
                return cell

            }
        }
        
        return UITableViewCell()
    }
}

extension ViewController {
    @objc func tableViewCellTap(_ sender: UIButton) {
        
        let gpoint = sender.convert(CGPoint.zero, to: tableView)
        let index = tableView.indexPathForRow(at: gpoint)
        guard let tree = treeData else {return}
        if let tag = index?.row {
            if tree.count > tag {
                if let things = tree[tag] as? [String:Any] {
                    if let _ = things["objects"] as? NSArray {
                        addSelectedItem(row: tag, sender: sender)
                    }
                }
            }
        }
    }
    @objc func oduViewCellTap(_ sender: UIButton) {
        
        let gpoint = sender.convert(CGPoint.zero, to: tableView)
        let index = tableView.indexPathForRow(at: gpoint)
        guard let tree = treeData else {return}

        if let tag = index?.row {
            if tree.count > tag {
                if let things = tree[tag] as? [String:Any] {
                    if let _ = things["objects"] as? NSArray {
                        addSelectedItem(row: tag, sender: sender)
                    }
                }
            }
        }
    }

    func addSelectedItem(row: Int, sender: UIButton)  {
        
        guard let tree = treeData else {return}
                
        if tree.count > row {
            
            let things = tree[row] as! [String:Any]
            let id1 = things["id"]
            addOrDeleteExpandableId(id: id1)
            if let obj = things["objects"] as? NSArray {
                
                var isAlreadyInserted = false
                
                for dictForTreeData in obj {
                    
                    let index = tree.indexOfObjectIdentical(to: dictForTreeData)
                    isAlreadyInserted = (index > 0) && (index != NSIntegerMax)
                    if isAlreadyInserted {
                        break
                    }
                }
                
                if isAlreadyInserted {
                    minimizeRows(array: obj)
                } else {
                    
                    var count = row + 1
                    var cellsToAdd = [IndexPath]()
                    let dict = NSMutableDictionary()
                    dict["isSelected"] = 0
                    if let objects = things["objects"] as? NSArray {
                        for each in objects {
                            let indexPath = IndexPath(row: count, section: 0)
                            cellsToAdd.append(indexPath)
                            if tree.count == count {
                                tree.add(each)
                            } else {
                                tree.insert(each, at: count)
                            }
                            count+=1
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.insertRows(at: cellsToAdd, with: .none)
                    }
                }
            }
        }
        
    }
    func addOrDeleteExpandableId(id: Any)  {
        
        if expandedCellId.contains(id) {
            expandedCellId.remove(id)
        } else {
            expandedCellId.add(id)
        }
    }
    
    func minimizeRows(array: NSArray) {
        
        guard let tree = treeData else {return}
        for dictForTreeData in array {
            
            let dictForTree = dictForTreeData as! [String:Any]
            
            let indexToRemove = tree.indexOfObjectIdentical(to: dictForTreeData)
            if let dict = dictForTree["objects"] as? NSArray {
                
                let innerData = dict
                if(innerData.count > 0){
                    minimizeRows(array: innerData)
                }
            }
            
            if (tree.indexOfObjectIdentical(to: dictForTreeData) != NSNotFound) {
                tree.removeObject(identicalTo: dictForTreeData)
                let indexPath = IndexPath(row: indexToRemove, section: 0)
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension ViewController {
    func loadJson(filename fileName: String,completion: @escaping ([String: AnyObject]?) -> Void) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    completion(dictionary)
                }
            } catch {
                print("Error!! Unable to parse  \(fileName).json")
            }
        }
    }
}
