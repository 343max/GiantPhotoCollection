//
//  TargetActionWrapper.swift
//  GiantPhotoCollection
//
//  Created by Max von Webel on 02/08/14.
//  Copyright (c) 2014 Max von Webel. All rights reserved.
//

protocol TargetAction {
    func performAction(Int)
}

class TargetActionWrapper<T: AnyObject> :TargetAction {
    typealias Action = (T) -> (Int) -> ()
    weak var target: T?
    let action: Action
    
    init(target: T, action: Action) {
        self.target = target
        self.action = action
    }
    
    func performAction(thumbIndex: Int) {
        if let target = self.target {
            action(target)(thumbIndex)
        }
    }
}
