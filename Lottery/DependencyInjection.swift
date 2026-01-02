//
//  DependencyInjection.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 02/10/2025.
//

import CouponGenerator
import Swinject

func resolveDI<Service>(_ service: Service.Type) -> Service {
    return DependencyInjection.container.resolve(service)!
}

extension ObjectScope {
    static let drawType = ObjectScope(storageFactory: PermanentStorage.init)
}

class DependencyInjection {

    static let container = Container()

    private var container: Container {
        DependencyInjection.container
    }

    init() {
        
        container.register(CouponController.self) { resolver in
            return CouponController(drawType: StateStore.state.drawType)
        }.inObjectScope(.drawType)
            
        // TODO: should be here?
        container.register(CouponsGeneratorViewModel.self) { resolver in
            let couponController = resolver.resolve(CouponController.self)!
            return CouponsGeneratorViewModel(couponController: couponController)
        }.inObjectScope(.drawType)
    }
}
