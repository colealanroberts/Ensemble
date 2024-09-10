# Ensemble

# Getting Started

### Counter

```swift
import SwiftUI
import Ensemble

struct CounterStore: Reducing {
    
    // MARK: - State
    
    struct State: StateIntializable {
        var count: Int = 0
    }
    
    // MARK: - Action
    
    enum Action {
        case increment
        case decrement
    }
    
    // MARK: - Reducer
    
    func reduce(_ state: inout State, action: Action) -> Worker<Action> {
        switch action {
        case .decrement:
            state.count -= 1
        case .increment:
            state.count += 1
        }
        
        return .none
    }
}

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            Screen(reducer: CounterStore()) { sink, state in
                VStack {
                    Text("\(state.count)")
                    Button("Increment") { sink.send(.increment) }
                    Button("Decrement") { sink.send(.decrement) }
                }
            }
        }
    }
}
```

### Async

```swift
import SwiftUI
import Ensemble

struct ModelStore: Reducing {
    
    // MARK: - State
    
    struct State: Equatable {
        var results: [Model]
    }
    
    func initialState() -> State { .init(results: []) }
    
    // MARK: - Action
    
    enum Action {
        case error(any Error)
        case fetch
        case results([Model])
    }
    
    // MARK: - Reducer
    
    func reduce(_ state: inout State, action: Action) -> Worker<Action> {
        switch action {
        case .error(let error):
            print(error)
        case .fetch:
            .task {
                let models = try await fetch() // Example function that returns an array of `[Model]`
                return .results(models)
            } error: {
                return .error(error)
            }
        case .results(let results):
            state.results = results
        }
        
        return .none
    }
}

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            Screen(reducer: ModelStore()) { sink, state in
                List(state.results) {
                    ...
                }
                .onAppear {
                    sink.send(.fetch)
                }
            }
        }
    }
}
```
