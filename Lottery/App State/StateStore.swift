//
//  AppReducer.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 02/10/2025.
//

func dispatchAppAction(_ action: StateAction) {
    StateStore.state = StateStore.stateReducer(state: StateStore.state, action: action)
}

final class StateStore {

    static var state = AppState(drawType: .lotto)

    static func stateReducer(state: AppState, action: StateAction) -> AppState {
        switch action {
        case .changeDrawType(let drawType):
            if drawType != state.drawType {
                DependencyInjection.container.resetObjectScope(.drawType)
            }
            return AppState(drawType: drawType)
        }
    }
}
