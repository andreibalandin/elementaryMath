//
//  MatchingViewController.swift
//  elementaryMath
//
//  Created by Andrei Balandin on 2019-02-13.
//  Copyright © 2019 Andrei Balandin. All rights reserved.
//

import UIKit

class MatchingViewController: UIViewController, GameInitialization, GameControlDelegate {
    var name: String = ""
    var date: Date = Date()
    private var buttons: Matrix<MatchingButtonWrapper>?
    private var selectedButton: MatchingButtonWrapper? = nil
    
    @IBOutlet weak var gameControl: ControlView!
    
    func reset(complexity: Int) {
        print("match reset \(complexity)")
        print("frame \(view.frame)")
        
        let width = Int(view.frame.size.width)
        let height = width
        let yOffset = 200
        let buttonCount = 10
        let size = width/buttonCount
        let padding = 10
        buttons = Matrix<MatchingButtonWrapper>(width/size, height/size)
        
        for x in 0..<buttons!.columns {
            for y in 0..<buttons!.rows {
                let buttonFrame = CGRect(x:x*size+padding, y:y*size+yOffset+padding, width:size-padding*2, height:size-padding*2)
                let button = MatchingButtonWrapper(frame: buttonFrame)
                button.coords = (x, y)
                button.button.tag = buttons!.CoordsToIndex(button.coords!)
                buttons!.set(button.coords!, button)
                button.button.setTitle(String(Int.random(in: 1..<10)), for:.normal)
                button.button.addTarget(self, action: #selector(MatchingViewController.tapDigit(sender:)), for: .touchUpInside)
                view.addSubview(button.button)
            }
        }
        
        
        let links = Links(view, {a, b in
            let (x1, y1) = a
            let (x2, y2) = b
            let left = min(x1, x2) * size + padding/2
            let right = (max(x1, x2) + 1) * size - padding/2
            let top = min(y1, y2) * size + yOffset + padding/2
            let bottom = (max(y1, y2) + 1) * size + yOffset - padding/2
            let result = CGRect(x: left, y: top, width: right-left, height: bottom-top)
            print("new link \(a) -> \(b) = \(result)")
            return result
        })
        links.link((0,1), (0,1))
    }
    
    @objc func tapDigit(sender: UIButton) {
        let button = buttons!.get(sender.tag)!
        if selectedButton != nil {
            selectedButton?.deselect((buttons?.neighbors(selectedButton!.coords!))!)
        }
        selectedButton = button
        let withNeighbors = buttons!.neighbors(button.coords!)
        button.select(withNeighbors)
    }

    func verify() -> Int {
        return 0
    }
    
    override func viewDidLoad() {
        gameControl.name = name
        gameControl.date = date
        gameControl.view = view
        gameControl.delegate = self
        
        gameControl.reset()
    }
}

class Links {
    private var links: [((Int, Int), (Int, Int))] = []
    private var linkViews: [UIView] = []
    
    var superview: UIView
    var frameFactory: ((Int, Int), (Int, Int)) -> CGRect
    init(_ superview: UIView, _ frameFactory: @escaping ((Int, Int), (Int, Int)) -> CGRect) {
        self.superview = superview
        self.frameFactory = frameFactory
    }
    
    func link(_ a: (Int, Int), _ b: (Int, Int)) {
        if !isLinked(a), !isLinked(b) {
            links.append((a, b))
            let view = UIView(frame: frameFactory(a, b))
            view.layer.zPosition = 0
            view.layer.borderWidth = 2
            view.layer.backgroundColor = UIColor.lightGray.cgColor
            view.layer.cornerRadius = 15
            view.isUserInteractionEnabled = false
            superview.addSubview(view)
        }
    }
    
    func unlink(_ coords: (Int, Int)) {
        let i = findIndex(coords)
        if i != nil {
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
    
    private func findIndex(_ coords: (Int, Int)) -> Int? {
        for i in 0..<links.count {
            let (a, b) = links[i]
            if a == coords || b == coords {
                return i
            }
        }
        return nil
    }
}

class Matrix<T> {
    let columns: Int
    let rows: Int
    private var data: [T?]
    
    init(_ columns: Int, _ rows: Int) {
        self.columns = columns
        self.rows = rows
        
        data = Array<T?>(repeating: nil, count: columns * rows)
    }
    
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
