
import UIKit
import IGListKit
import IGListDiffKit

private enum HeaderType: String {
    case header
    case newMessage
}

class MomentsHeaderController: ListBindingSectionController<ListDiffable> {
    
    var onTap: ((_ type: MomentAction) -> Void)?
    
    func updateInfo(info: HeaderInfo) {
        self.didUpdate(to: info)
        self.collectionContext?.performBatch(animated: false, updates: { (context) in
            context.reload(self)
        }, completion: nil)
    }
    
    override init() {
        super.init()
        dataSource = self
        selectionDelegate = self
    }
    
    override func didUpdate(to object: Any) {
        guard let obj = object as? HeaderInfo else { fatalError() }
        super.didUpdate(to: obj)
    }
    
    // MARK: cell
    func momentHeaderCell(at index: Int) -> MomentHeaderCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentHeaderCell.self, for: self, at: index) as? MomentHeaderCell else { fatalError() }
        cell.bindViewModel(object!)
        cell.onTap = {[weak self] action in
            switch action {
            case .avatar:
                self?.onTap?(action)
            default:
                break
            }
        }
        return cell
    }
    
    func momentsNewMessageCell(at index: Int) -> MomentNewMessageCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentNewMessageCell.self, for: self, at: index) as? MomentNewMessageCell else { fatalError() }
        cell.bindViewModel(object!)
        cell.onTap = { [weak self] in
            self?.onTap?(.newMessage)
        }
        return cell
    }
}


extension MomentsHeaderController: ListBindingSectionControllerDataSource, ListBindingSectionControllerSelectionDelegate {
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? HeaderInfo else { return [] }
        var results: [ListDiffable] = []

        results.append(HeaderType.header.rawValue as ListDiffable)
        
        if (object.newMsgCount > 0) {
            results.append(HeaderType.newMessage.rawValue as ListDiffable)
        }
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        
        let viewModel = HeaderType(rawValue: viewModel as! String)!
        switch viewModel {
        case .header:
            return momentHeaderCell(at: index)
        case .newMessage:
            return momentsNewMessageCell(at: index)
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let object = object as? HeaderInfo else { fatalError() }
        let viewModel = HeaderType(rawValue: viewModel as! String)!
        let width: CGFloat = collectionContext!.containerSize(for: self).width
        switch viewModel {
        case .header:
            return CGSize(width: width, height: 222.h + UIApplication.safeAreaInsets.top + UIApplication.statusBarHeight)
        case .newMessage:
            return CGSize(width: width, height: 44.h)
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didSelectItemAt index: Int, viewModel: Any) {
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didDeselectItemAt index: Int, viewModel: Any) {
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didHighlightItemAt index: Int, viewModel: Any) {
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didUnhighlightItemAt index: Int, viewModel: Any) {
        
    }
}
