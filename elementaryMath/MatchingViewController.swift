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
