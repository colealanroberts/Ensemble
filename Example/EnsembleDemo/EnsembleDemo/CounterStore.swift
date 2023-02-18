//
//  CounterStore.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/17/23.
//

import Ensemble
import Foundation
import SwiftUI

struct CounterStore: Reducing {}

// MARK: - `State` -

extension CounterStore {
    struct State: Equatable {
        var count: Int
        var fetched: String
        var isFetching: Bool
        var name: String
    }
    
    func initialState() -> State {
        .init(
            count: 0,
            fetched: "",
            isFetching: false,
            name: ""
        )
    }
    
    func reduce(_ state: inout State, action: Action) -> Action? {
        switch action {
        case .increment:
            state.count += 1
        case .decrement:
            state.count -= 1
        case .fetch:
            state.isFetching = true
            
            return .worker(
                Worker {
                    try await Task.sleep(for: .seconds(1))
                    return .fetched("Hello, world!")
                }
            )
        case .fetchTwo:
            state.isFetching = true
            
            return .worker(
                Worker {
                    try await Task.sleep(for: .seconds(3))
                    return .fetched("Hello, world again!")
                }
            )
        case .fetched(let string):
            state.isFetching = false
            state.fetched = string
        case .name(let name):
            state.name = name
        default:
            break
        }
        
        return nil
    }
}

// MARK: - `Action` -

extension CounterStore {
    enum Action: Equatable, Working {
        case increment
        case decrement
        case fetch
        case fetchTwo
        case fetched(String)
        case worker(Worker<CounterStore>)
        case name(String)
        
        func worker() async throws -> CounterStore.Action? {
            guard case .worker(let worker) = self else { return nil }
            return try await worker.run()
        }
    }
}

// MARK: - `Render` -

extension CounterStore {
    func render(_ sink: Sink<CounterStore>, _ state: State) -> some View {
        ScrollView {
            Spacer()
                .padding()
            VStack {
                Text("Counter Example")
                    .fontWeight(.semibold)
                Text("\(state.count)")
                
                HStack {
                    Button("+ Increment"){
                        sink.send(.increment)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("- Decrement") {
                        sink.send(.decrement)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            VStack {
                Text("Binding Example")
                    .fontWeight(.semibold)
                Text(state.name)
                TextField("Text Here", text: sink.bindState(\.name, { .name($0) }))
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack {
                Text("Async Example")
                    .fontWeight(.semibold)
                Button("Fetch") {
                    sink.send(.fetch)
                }
                .buttonStyle(.borderedProminent)
                
                Text("Async Example")
                    .fontWeight(.semibold)
                Button("Fetch 2") {
                    sink.send(.fetchTwo)
                }
                .buttonStyle(.borderedProminent)
                
                if state.isFetching {
                    ProgressView()
                } else {
                    Text(state.fetched)
                }
            }
        }
        .navigationTitle("Ensemble")
    }
}
