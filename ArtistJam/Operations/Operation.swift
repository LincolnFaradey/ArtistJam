//
//  Operation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/10/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

typealias progressBlock = (Int8) -> ()
typealias operationBlock = () -> ()

class Operation: NSOperation {
    enum State: String {
        case Ready = "isReady"
        case Executing = "isExecuting"
        case Finished = "isFinished"
        case Cancelled = "isCancelled"
    }
    
    // MARK: - Properties
    var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.rawValue)
            willChangeValueForKey(self.state.rawValue)
        }
        didSet {
            didChangeValueForKey(oldValue.rawValue)
            didChangeValueForKey(self.state.rawValue)
        }
    }
    
    var cancellationBlock = operationBlock?()
    
    // MARK: - NSOperation
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override var asynchronous: Bool {
        return true
    }
    
    override func start() {
        if self.cancelled {
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
