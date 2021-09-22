//
//  ViewController.swift
//  TreeView-iOS
//
//  Created by Md. Shamiul Islam on 20/9/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var colorDict = [Int:UIColor]()
    var treeData : NSMutableArray?
    var copyTreeData = NSMutableArray()
    @IBOutlet weak var expandOrCollapseAllButton: UIBarButtonItem!
    var isSelected : Bool = false {
        didSet {
            expandOrCollapseAllButton.image = isSelected ? UIImage(named: "collapse") : UIImage(named: "expand")
        }
    }
    @IBAction func expandOrCollapseAllAction(_ sender: Any) {
        isSelected = !isSelected
        treeData?.removeAllObjects()
        if isSelected {
            expandAll(objectArray: copyTreeData)
        } else {
            for each in copyTreeData {
                treeData?.add(each)
            }
            tableView.reloadData()
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
                self.copyTreeData = NSMutableArray(array: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
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

extension ViewController {
    func expandAll(objectArray:NSMutableArray) {
        for item in objectArray {
            if let dict = item as? [String:Any], let obj = dict["objects"] as? NSArray {
                treeData?.add(item)
                expandAll(objectArray: NSMutableArray(array: obj))
            } else {
                treeData?.add(item)
            }
        }
        tableView.reloadData()
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.treeData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tree = treeData else {return UITableViewCell()}
        if tree.count > indexPath.row {
            
            guard let things = tree[indexPath.row] as? [String:Any], let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as? RcGroupTitleTableViewCell else {
                return UITableViewCell()
            }
            
            if let thingName = things["name"] as? String {
                cell.titleButton.setTitle("\(thingName)".uppercased(), for: .normal)
            }
            if let level = things["level"] as? Int {
                cell.titleCellLeadingConstraing.constant = 16 * CGFloat(level)
                if let color = colorDict[level] {
                    cell.containerViewForTitleCell.backgroundColor = color
                } else {
                    colorDict[level] = .random
                    cell.containerViewForTitleCell.backgroundColor = colorDict[level]
                }
            }
            
            cell.containerViewForTitleCell.tag = indexPath.row
            cell.titleButton.addTarget(self, action: #selector(self.tableViewCellTap(_:)), for : .touchUpInside)
            cell.gatewayImageView.addTarget(self, action: #selector(self.tableViewCellTap(_:)), for : .touchUpInside)
            
            return cell
            
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
    
    func addSelectedItem(row: Int, sender: UIButton)  {
        
        guard let tree = treeData else {return}
        
        if tree.count > row {
            
            guard let things = tree[row] as? [String:Any] else {return}
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

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
