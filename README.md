# Ensemble

# Getting Started

### Counter

```swift
import SwiftUI
import Ensemble

struct CounterStore: Reducing {
    
    // MARK: - State
    
    struct State: Equatable {
        var counter = 0
    }
    
    func initialState() -> State { .init() }
    
    // MARK: - Action
    
    enum Action {
        case increment
        case decrement
    }
    
    // MARK: - Reducer
    
    func reduce(_ state: inout State, action: Action) -> Worker<Action> {
        switch action {
        case .decrement:
            state.counter -= 1
        case .increment:
            state.counter += 1
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
                    Text("\(state.counter)")
                    Button("Increment") { sink.send(.increment) }
                    Button("Decrement") { sink.send(.decrement) }
                }
            }
        }
    }
}
```
