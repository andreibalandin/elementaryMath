//
//  MatchingViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-13.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

// implement number matching game
// user has to highlight all pairs of adjucent numbers that together make ten
// upon verification, wrong pairs are marked red, and missed pairs are marked blue
// then a screen shot is created
class MatchingViewController: UIViewController, GameInitialization, GameControlDelegate {
    var name: String = ""
    var date: Date = Date()
    
    // links between numbers and helper functions to handle them
    private var links: Links? = nil
    
    // 2d grid of number buttons and helper functions
    private var buttons: Matrix<MatchingButtonWrapper>?
    
    // to create a new pair or remove existing pair
    private var selectedNeighbour: MatchingButtonWrapper? = nil
    private var selectedButton: MatchingButtonWrapper? = nil
    
    // header UI
    @IBOutlet weak var gameControl: ControlView!
    
    // create a new game if user changes complexity in the header
    func reset(complexity: Int) {
        // clean up state
        selectedButton = nil
        selectedNeighbour = nil
        
        // destroy existing buttons
        if buttons != nil {
            for button in buttons!.data {
                button!.button.removeFromSuperview()
            }
        }

        // destroy existing links
        if links != nil {
            links?.destroy()
        }

        // set geometry
        let width = Int(view.frame.size.width)
        let height = width
        let yOffset = 200
        let buttonCount = 5 + 6 * complexity/100
        let size = width/buttonCount
        let padding = 10
        
        // create storage for new buttons
        buttons = Matrix<MatchingButtonWrapper>(width/size, height/size)
        
        // fill butotn grid
        for x in 0..<buttons!.columns {
            for y in 0..<buttons!.rows {
                let buttonFrame = CGRect(x:x*size+padding, y:y*size+yOffset+padding, width:size-padding*2, height:size-padding*2)
                let button = MatchingButtonWrapper(frame: buttonFrame)
                button.coords = (x, y)
                
                // need to retrieve the wrapper on tap, using tag to store wrapper index
                button.button.tag = buttons!.CoordsToIndex(button.coords!)
                buttons!.set(button.coords!, button)
                button.button.setTitle(String(Int.random(in: 1..<10)), for:.normal)
                button.button.addTarget(self, action: #selector(tapDigit(sender:)), for: .touchUpInside)
                view.addSubview(button.button)
            }
        }
        
        // create storage for links
        // provide a closure that will create views for new links
        links = Links(view, {a, b in
            let (x1, y1) = a
            let (x2, y2) = b
            let left = min(x1, x2) * size + padding/2
            let right = (max(x1, x2) + 1) * size - padding/2
            let top = min(y1, y2) * size + yOffset + padding/2
            let bottom = (max(y1, y2) + 1) * size + yOffset - padding/2
            return CGRect(x: left, y: top, width: right-left, height: bottom-top)
        })
    }
    
    // taps are used to create new links and delete existing
    @objc func tapDigit(sender: UIButton) {
        // button wrapper can be retrieved by UIButton tag
        let button = buttons!.get(sender.tag)!
        
        // tap unlinks the button
        links!.unlink(button.coords!)
        
        if selectedButton != nil {
            selectedButton!.deselect((buttons?.neighbors(selectedButton!.coords!))!)
            
            // link previous and current buttons if they are neighbours
            if buttons!.isNeighbour(selectedButton!.coords!, button.coords!),
                !links!.isLinked(selectedButton!.coords!) {
                selectedNeighbour = selectedButton
                
                // unlink previous button before creating new link
                links!.unlink(selectedNeighbour!.coords!)
                _ = links!.link(button.coords!, selectedNeighbour!.coords!)
            }
        }
        
        // remember this button for the next tap
        selectedButton = button
        
        // highlight it
        let withNeighbors = buttons!.neighbors(button.coords!)
        button.select(withNeighbors)
    }

    // compute score and highlight answers
    func verify() -> Int {
        var correctAnswers = 0.0
        var wrongAnswers = 0.0
        var missedMatches = 0.0
        
        // scan button grid
        for x in 0..<buttons!.columns {
            for y in 0..<buttons!.rows {
                let b = links?.linkedTo((x, y))
                let v1 = buttons!.get((x, y))!.value

                // test matches
                if b != nil {
                    let v2 = buttons!.get(b!)!.value
                    if v1 + v2 == 10 {
                        correctAnswers += 1
                    }
                    else {
                        wrongAnswers += 1
                        // change wrong pairs to red
                        let l = links!.get((x, y), b!)!
                        l.layer.borderColor = UIColor.red.cgColor
                        l.layer.borderWidth = 3
                    }
                }
                else { // test for missed matches
                    let neighbours = buttons!.neighbors((x, y))
                    let coords = neighbours.map({ $0.coords! })
                    let notLinked = coords.filter({ !links!.isLinked($0) })
                    let coordsValues = notLinked.map({ ($0, buttons!.get($0)!.value) })
                    
                    for v2 in coordsValues {
                        if v1 + v2.1 == 10 {
                            missedMatches += 1
                            let link = links!.link((x, y), v2.0)!
                            // highlight missed matches with blue
                            link.layer.borderColor = UIColor.blue.cgColor
                            link.layer.borderWidth = 3
                        }
                    }
                }
            }
        }
        
        // compute score
        if Int(correctAnswers + wrongAnswers + missedMatches) == 0 {
            return 100
        }
        return Int(correctAnswers / (correctAnswers + wrongAnswers + missedMatches) * 100)
    }
    
    // initialize game control header
    override func viewDidLoad() {
        gameControl.name = name
        gameControl.date = date
        gameControl.view = view
        gameControl.delegate = self
        gameControl.complexityStep = 100/6
        
        // start a new game
        gameControl.reset()
    }
}

// storage and helpers to handle matched pairs
class Links {
    // a link is a pair of 2d coords
    private var links: [((Int, Int), (Int, Int))] = []
    
    // views corresponding to links are indexed by 4 coords
    private var views: [[Int]:UIView] = [:]
    private func coordsToList(_ a: (Int, Int), _ b: (Int, Int)) -> [Int] {
        let (x1, y1) = a
        let (x2, y2) = b
        return [x1, y1, x2, y2]
    }
    
    // views that visually represent links are added and removed from this view
    var superview: UIView
    
    // matrix coords should be converted to screen
    var frameFactory: ((Int, Int), (Int, Int)) -> CGRect
    init(_ superview: UIView, _ frameFactory: @escaping ((Int, Int), (Int, Int)) -> CGRect) {
        self.superview = superview
        self.frameFactory = frameFactory
    }
    
    // link two numbers by coords
    func link(_ a: (Int, Int), _ b: (Int, Int)) -> UIView? {
        if !isLinked(a), !isLinked(b) {
            links.append((a, b))
            let view = UIView(frame: frameFactory(a, b))
            
            //should be displayed at the bottom
            view.layer.zPosition = 0
            view.layer.borderWidth = 2
            
            // have to use transparent background, because of zPosition didn't work on simulated screenshot
            view.layer.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0).cgColor
            view.layer.cornerRadius = 15
            view.isUserInteractionEnabled = false
            
            // save new view in the dictionary indexed by its coords
            views[coordsToList(a, b)] = view
            superview.addSubview(view)
            
            return view
        }
        
        print("\(a) and \(b) are already linked")
        return nil
    }
    
    // what coords are linked to given coords?
    func linkedTo(_ coords: (Int, Int)) -> (Int, Int)? {
        let i = findIndex(coords)
        if i == nil {
            return nil
        }
        
        let (a, b) = links[i!]
        if a == coords {
            return b
        }
        return a
    }
    
    func unlink(_ coords: (Int, Int)) {
        let i = findIndex(coords)
        if i != nil {
            let ((x1, y1), (x2, y2)) = links[i!]
            let view = views[[x1, y1, x2, y2]]
            view!.removeFromSuperview()
            links.remove(at: i!)
        }
    }
    
    func isLinked(_ coords: (Int, Int)) -> Bool {
        for l in links {
            let (a, b) = l
            if a == coords || b == coords {
                return true
            }
        }
        return false
    }
    
    // links are not directional, so need to check both (a, b) and (b, a)
    func get(_ a: (Int, Int), _ b: (Int, Int)) -> UIView? {
        let key = coordsToList(a, b)
        if views[key] != nil {
            return views[key]
        }
        return views[coordsToList(b, a)]
    }
    
    private func findIndex(_ coords: (Int, Int)) -> Int? {
        for i in 0..<links.count {
            let (a, b) = links[i]
            if a == coords || b == coords {
                return i
            }
        }
        return nil
    }
    
    func destroy() {
        for (_, view) in views {
            view.removeFromSuperview()
        }
    }
}

// 2d arrays are cumbersome in swift, reinventing a wheel
// it is generic to support square wheels
class Matrix<T> {
    let columns: Int
    let rows: Int
    private(set) var data: [T?]
    
    init(_ columns: Int, _ rows: Int) {
        self.columns = columns
        self.rows = rows
        
        data = Array<T?>(repeating: nil, count: columns * rows)
    }
    
    // index and coords are interchangeable via CoordsToIndex/IndexToCoords
    func CoordsToIndex(_ coords: (Int, Int)) -> Int {
        let (x, y) = coords
        return y * rows + x
    }

    func IndexToCoords(_ index: Int) -> (Int, Int) {
        return (index % columns, index / columns)
    }
    
    func get(_ coords: (Int, Int)) -> T? {
        return data[CoordsToIndex(coords)]
    }
    
    func get(_ index: Int) -> T? {
        return data[index]
    }
    
    func set(_ coords: (Int, Int), _ value: T?) {
        data[CoordsToIndex(coords)] = value
    }
    
    // neighbors are the locations to the top, bottom, left and right
    func isNeighbour(_ a: (Int, Int), _ b: (Int, Int)) -> Bool {
        let (x1, y1) = a
        let (x2, y2) = b
        return abs(x1 - x2) + abs(y1 - y2) == 1
    }
    
    // get the neighbors of a cell
    func neighbors(_ coords: (Int, Int)) -> [T] {
        let (x, y) = coords
        let neighbourCoords = [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)].filter({[weak self] in
            return self!.areCoordsValid($0)
        })
        let potentialNeighbors = neighbourCoords.map({[weak self] in
            return self!.get($0)
        })
        let result = potentialNeighbors.filter({ $0 != nil }).map({ $0! })
        return result
    }
    
    func areCoordsValid(_ coords: (Int, Int)) -> Bool {
        let (x, y) = coords
        return x >= 0 && x < columns && y >= 0 && y < rows
    }
}

// subclassing UIButton does not work with addTarget, so wrap it instead
// https://stackoverflow.com/questions/25919472/adding-a-closure-as-target-to-a-uibutton
class MatchingButtonWrapper {
    let button: UIButton
    var coords: (Int, Int)? = nil

    init(frame: CGRect) {
        button = UIButton(frame: frame)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 10
        button.layer.zPosition = 10
    }

    var value: Int {
        get {
            return Int(button.titleLabel!.text!)!
        }
    }
    
    func select(_ andNeighbours: [MatchingButtonWrapper]) {
        button.layer.borderWidth = 4
        
        for n in andNeighbours {
            n.selectAsNeighbour()
        }
    }
    
    func selectAsNeighbour() {
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 20
    }
    
    func deselect(_ andNeighbours: [MatchingButtonWrapper]) {
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 10
        
        for n in andNeighbours {
            n.deselect([])
        }
    }
}
