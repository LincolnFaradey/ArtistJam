//
//  Operation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/10/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

typealias progressBlock = (Int8) -> ()
typealias operationBlock = () -> ()

class OperationWrapper: Operation {
    
    enum State: String {
        case Ready = "isReady"
        case Executing = "isExecuting"
        case Finished = "isFinished"
        case Cancelled = "isCancelled"
    }
    
    // MARK: - Properties
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: self.state.rawValue)
        }
        didSet {
            willChangeValue(forKey: oldValue.rawValue)
            willChangeValue(forKey: self.state.rawValue)
        }
    }
    
    var cancellationBlock = operationBlock?(nilLiteral: ())
    
    // MARK: - NSOperation
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if self.isCancelled {
            state = .Finished
        }else {
            self.main()
            state = .Executing
        }
    }
    
    func finish() {
        state = .Finished
    }
    
    override func cancel() {
//        super.cancel()
        state = .Cancelled
        if let cancellationBlock = cancellationBlock {
            cancellationBlock()
        }
        
    }
}
