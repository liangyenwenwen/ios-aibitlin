
import UIKit
import IGListKit
import IGListDiffKit

enum ViewModelEnum: String {
    case moreGraphic, sigleGraphic, location, bottom, comment// prompt for no data
}

class MomentsListController: ListBindingSectionController<ListDiffable> {
    // Comment dynamics / Comment last comment
    var onComment: ((_ replayUserID: String?, _ text: String) -> Void)?
    // like
    var onFavor: ((_ thumbup: Bool) -> Void)?
    // Delete activity/comment
    var onDelete: ((_ commentID: String?) -> Void)?
    //Report
    var onReport: ((_ commentID: String?) -> Void)?
    // Click Avatar / Permissions List
    var onTap: ((_ action: MomentAction) -> Void)?
    
    func updateMoments(moments: MomentsInfo) {
        self.didUpdate(to: moments)
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
        guard let obj = object as? MomentsInfo else { fatalError() }
        super.didUpdate(to: obj)
    }
    
    // MARK: cell
    
    func momentMoreGraphicsCell(at index: Int) -> MomentMoreGraphicsCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentMoreGraphicsCell.self, for: self, at: index) as? MomentMoreGraphicsCell else { fatalError() }
        cell.bindViewModel(object!)
    
        cell.onClick = {[weak self] idx in
            self?.toExpend()
        }
        
        cell.onTapAvatar = { [weak self] r in
            self?.toTapAvatar()
        }
        
        cell.onPreview = { [weak self] index, senders in
            self?.toPreview(index: index, senders: senders)
        }
        return cell
    }
    
    func momentSignalGraphicsCell(at index: Int) -> MomentSignalGraphicsCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentSignalGraphicsCell.self, for: self, at: index) as? MomentSignalGraphicsCell else { fatalError() }
        cell.bindViewModel(object!)
        cell.onExpand = {[weak self] idx in
            self?.toExpend()
        }
        
        cell.onTapAvatar = { [weak self] r in
            self?.toTapAvatar()
        }
        
        cell.onPreview = { [weak self] index, view in
            self?.toPreview(index: index, senders: [view])
        }
        
        return cell
    }
    
    func momentLocationCell(at index: Int) -> MomentLocationCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentLocationCell.self, for: self, at: index) as? MomentLocationCell else { fatalError() }
        cell.bindViewModel(object!)
        return cell
    }
    
    func momentBottomCell(at index: Int) -> MomentBottomCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentBottomCell.self, for: self, at: index) as? MomentBottomCell else { fatalError() }
        cell.bindViewModel(object!)
        cell.onAction = {[weak self] (_, action) in
            guard let self, let m = object as? MomentsInfo else { return }
            switch action {
            case .thumbup:
                self.toFavor(m.likesContainsSelf!)
            case .delete:
                self.toDelete()
            case .report:
                self.toReport()
            case .comment(let text):
                self.toComment(nil, text) // Expand more -> Comments
            case .commentDraft(let text):
                self.toSaveDraft(text)
            case .permisson:
                self.onTap?(.permisson)
            default:
                break
            }
        }
        
        cell.onRelativeRect = {[unowned self] () -> CGRect in
            let first = self.cellForItem(at: 0).frame
            let last = self.cellForItem(at: index).frame
            let rect = CGRect(x: 0, y: first.minY, width: first.width, height: last.maxY-first.minY)
            return rect
        }
        return cell
    }
    
    func momentCommentCell(at index: Int) -> MomentCommentCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: MomentCommentCell.self, for: self, at: index) as? MomentCommentCell else { fatalError() }
        cell.bindViewModel(object!)
        cell.onAction = { [weak self] (ID, action) in
            switch action {
            case .comment(let text):
                print("评论: \(text)")
                self?.toComment(ID, text) // 回复某人，也会走到这里
            case .deleteComment:
                print("delete")
                self?.toDelete(ID)
            default:
                break
            }
        }
        return cell
    }
}

extension MomentsListController: ListBindingSectionControllerDataSource, ListBindingSectionControllerSelectionDelegate {
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? MomentsInfo else { return [] }
        var results: [ListDiffable] = []

        if object.images.count > 1 {
            results.append(ViewModelEnum.moreGraphic.rawValue as ListDiffable)
        } else {
            results.append(ViewModelEnum.sigleGraphic.rawValue as ListDiffable)
        }
        
        if object.location?.isEmpty == false {
            results.append(ViewModelEnum.location.rawValue as ListDiffable)
        }
        
        if !object.userID.isEmpty {
            results.append(ViewModelEnum.bottom.rawValue as ListDiffable)
        }
        
        if !object.comments.isEmpty || !object.likeUsers.isEmpty {
            // The minimum height of the dividing line must be added by 1
            results.append(ViewModelEnum.comment.rawValue as ListDiffable)
        }
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        
        let viewModel = ViewModelEnum(rawValue: viewModel as! String)!
        switch viewModel {
        case .sigleGraphic:
            return momentSignalGraphicsCell(at: index)
        case .moreGraphic:
            return momentMoreGraphicsCell(at: index)
        case .location:
            return momentLocationCell(at: index)
        case .bottom:
            return momentBottomCell(at: index)
        case .comment:
            return momentCommentCell(at: index)
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let object = object as? MomentsInfo else { fatalError() }
        let viewModel = ViewModelEnum(rawValue: viewModel as! String)!
        let width = collectionContext!.containerSize(for: self).width
        switch viewModel {
        case .sigleGraphic, .moreGraphic:
            return CGSize(width: width, height: object.cellHeight)
        case .location:
            return CGSize(width: width, height: 30)
        case .bottom:
            return CGSize(width: width, height: object.operateHeight)
        case .comment:
            var height = object.contentHeight(width - MomentContentLeftPadding - MomentPadding)
            return CGSize(width: width, height: height)
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didSelectItemAt index: Int, viewModel: Any) {
        print("select item")
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didDeselectItemAt index: Int, viewModel: Any) {
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didHighlightItemAt index: Int, viewModel: Any) {
        
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, didUnhighlightItemAt index: Int, viewModel: Any) {
        
    }
}

fileprivate extension MomentsListController {
    
    func toPreview(index: Int, senders: [UIView]) {
        onTap?(.preview(index, senders))
    }
    
    func toTapAvatar() {
        onTap?(.avatar)
    }
    
    func toExpend() {
        guard let object = object as? MomentsInfo else { fatalError() }
        object.isTextExpend = !(object.isTextExpend ?? false)
        self.didUpdate(to: object)
        self.collectionContext?.performBatch(animated: false, updates: { (context) in
            context.reload(self)
        }, completion: nil)
    }
    
    func toDelete(_ commentID: String? = nil) {
        onDelete?( commentID)
    }
    
    func toReport(_ commentID: String? = nil){
        onReport?(commentID)
    }
    
    func toFavor(_ thumbup: Bool = true) {
        guard let object = object as? MomentsInfo else { fatalError() }
        onFavor?(thumbup)
    }

    func toComment(_ replayUserID: String?, _ text: String) {
        onComment?(replayUserID, text)
    }
    
    func toSaveDraft(_ text: String) {
        print("comment draft: \(text)")
    }
}
