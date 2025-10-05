//
//  DependencyInjection.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 02/10/2025.
//

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
        container.register(DrawDataModel.self) { _ in
            return DrawDataModel(drawType: StateStore.state.drawType)
        }.inObjectScope(.drawType)

        container.register(CouponController.self) { resolver in
            let dataModel = resolver.resolve(DrawDataModel.self)!
            return CouponController(dataModel: dataModel)
        }.inObjectScope(.drawType)

        // TODO: should be here?
        container.register(CouponsGeneratorViewModel.self) { resolver in
            let couponController = resolver.resolve(CouponController.self)!
            return CouponsGeneratorViewModel(couponController: couponController)
        }.inObjectScope(.drawType)

        container.register(AgesPerPositionModel.self) { _ in
            return AgesPerPositionModel(drawType: StateStore.state.drawType)
        }.inObjectScope(.drawType)

        container.register(ExclusionModel.self) { _ in
            return ExclusionModel(drawType: StateStore.state.drawType)
        }.inObjectScope(.drawType)

        container.register(BestFriendsModel.self) { _ in
            return BestFriendsModel(drawType: StateStore.state.drawType)
        }.inObjectScope(.drawType)

        container.register(ModelsTuner.self) { resolver in
            let model = resolver.resolve(DrawDataModel.self)!
            return ModelsTuner(dataModel: model)
        }.inObjectScope(.drawType)
    }
}
