
import OUICore
import RxRelay
import RxSwift

class NewMessageViewModel {
    let items: BehaviorRelay<[NewMessageInfo]> = .init(value: [])
    let loading: PublishSubject<Bool> = .init()
    
    private let _disposeBag = DisposeBag()
    private let dataProvider = OUIMoments.DefaultDataProvider()
    
    init() {
        dataProvider.clearNewMessage(type: 1) { success in
        }
    }
    
    func loadNewMessages() {
        loading.onNext(true)
        dataProvider.queryNewMsg { [weak self] infos in
            self?.items.accept(infos)
            self?.loading.onNext(false)
        }
    }
    
    func clearNewMessage()  {
        dataProvider.clearNewMessage(type: 2) { [weak self] success in
            guard let `self` = self, success else { return }
            var i = self.items.value
            i.removeAll()
            self.items.accept(i)
        }
    }
}
