//
//  File.swift
//  
//
//  Created by linhey on 2022/8/10.
//

#if canImport(UIKit)
import UIKit

public struct SKCDelegate: SKCDelegateForwardProtocol {
    
    struct ContextMenuConfiguration {
        var ID: ObjectIdentifier { ObjectIdentifier(configuration) }
        let indexPath: IndexPath
        let configuration: UIContextMenuConfiguration
    }
    
    class Store {
        lazy var contextMenuConfiguration = [ObjectIdentifier: ContextMenuConfiguration]()
    }
    
    let dataSource: SKCManagerPublishers
    let store = Store()
}

public extension SKCDelegate {
    
    private func section(_ indexPath: IndexPath) -> SKCDelegateProtocol? {
        return dataSource.safe(section: indexPath.section)
    }
    
    private func endDisplaySection(_ indexPath: IndexPath) -> SKCDelegateProtocol? {
        return dataSource.safe(section: indexPath.section)
    }
    
    private func sections() -> any Collection<SKCDelegateProtocol> {
        return dataSource.collection()
    }
    
}

public extension SKCDelegate {
    
    // 用于通知选择/取消选择和高亮/非高亮事件的方法。
    // 导致用户触摸选择的调用顺序是。
    //
    // (当触摸开始时)
    // 1. -collectionView:shouldHighlightItemAtIndexPath:
    // 2. -collectionView:didHighlightItemAtIndexPath:
    //
    // (当触摸抬起时)
    // 3. -collectionView:shouldSelectItemAtIndexPath: 或 -collectionView:shouldDeselectItemAtIndexPath:
    // 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
    // 5. -collectionView:didUnhighlightItemAtIndexPath:
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(shouldHighlight: indexPath.item))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(didHighlight: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(didUnhighlight: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(shouldSelect: indexPath.item))
    }
    
    //当用户在多选模式下点击一个已经选择的项目时被调用
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(shouldDeselect: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(selected: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(deselected: indexPath.item))
    }
    
    /**
     * @abstract 调用以确定是否可以在给定的indexPath处为项目执行主要操作。
     * 请参阅 @c collectionView:performPrimaryActionForItemAtIndexPath:了解更多关于主要动作的细节。
     *
     * @param collectionView 这个UICollectionView
     * @param indexPath 项目的NSIndexPath
     *
     * @return `YES`如果可以执行主要动作；否则`NO`。如果没有实现，在不编辑时默认为`YES`。
     *和编辑时的`NO'。
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(canPerformPrimaryAction: indexPath.item))
    }
    
    /**
     * @abstract 当应该对给定索引路径的项目进行主要操作时调用。
     *
     * @讨论 主要动作允许你区分选择的变化（可以是基于焦点的变化或
     * 其他间接的选择变化）和不同的用户操作。当用户选择一个单元格而不扩展一个现有的选择时，会执行初级操作。
     * 现有的选择。这是在@c shouldSelectItem和@c didSelectItem之后被调用的，不管该单元格的选择是否被允许改变。
     * 状态是否被允许改变。
     *
     * 作为一个例子，使用@c didSelectItemAtIndexPath来更新当前视图控制器中的状态（如按钮、标题等），并且
     * 使用主要动作进行导航或显示另一个分割视图列。
     *
     * @param collectionView This UICollectionView
     * @param indexPath 要执行动作的项目的NSIndexPath
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(performPrimaryAction: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(willDisplay: cell, row: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.supplementary(willDisplay: view, kind: .init(rawValue: elementKind), at: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(endDisplaySection(indexPath)?.item(didEndDisplaying: cell, row: indexPath.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(endDisplaySection(indexPath)?.supplementary(didEndDisplaying: view, kind: .init(rawValue: elementKind), at: indexPath.item))
    }
    
    
    // support for custom transition layout
    //    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
    //        .init(currentLayout: fromLayout, nextLayout: toLayout)
    //    }
    
    // Focus
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(canFocus: indexPath.item))
    }
    
    //    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
    //
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    //
    //    }
    //
    //    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
    //
    //    }
    
    /// 确定当焦点移动到指定的索引路径上时，该项目是否也应该被选中。
    /// 如果集合视图的全局selectionFollowsFocus被启用，这个方法将允许你在每个索引路径上覆盖该行为。如果selectionFollowsFocus被禁用，则不调用此方法。
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(selectionFollowsFocus: indexPath.item))
    }
    
    //    @available(iOS 15.0, *)
    //    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    //
    //    @available(iOS, introduced: 9.0, deprecated: 15.0)
    //    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    //
    //
    //    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint // customize the content offset to be applied during transition or update animations
    
    // 编辑
    /* 要求委托人验证给定项目是否可编辑。
     *
     * @param collectionView 请求该信息的集合视图对象。
     * @param indexPath 在`collectionView`中定位一个项目的索引路径。
     *
     * @return `YES`如果该项目是可编辑的；否则，`NO`。默认为 "YES"。
     */
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(canEdit: indexPath.item))
    }
    
    // 弹簧加载
    
    /* 允许选择退出某一特定项目的弹簧加载。
     *
     * 如果你想在弹簧加载单元的不同子视图上实现交互效果，请修改context.targetView属性。
     * 默认是单元格。
     *
     * 如果这个方法没有实现，默认是YES。
     */
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(shouldSpringLoad: indexPath.item, with: context))
    }
    
    // 多重选择
    
    /* 允许用双指平移的手势来自动启用允许多重选择并开始选择多个单元格。
     *
     * 在一个多选手势被识别之后，这个方法将在允许多选被自动调用之前被调用。
     * 设置为 "是"，以允许用户使用双指平移手势在受限的滚动方向上选择多个连续的项目。
     * 滚动方向。
     *
     * 如果集合视图没有受限的滚动方向（即集合视图同时在水平和垂直方向上滚动）。
     * 那么这个方法将不会被调用，多选手势将被禁用。
     *
     * 如果这个方法没有实现，默认是NO。
     */
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Bool> {
        .handleable(section(indexPath)?.item(shouldBeginMultipleSelectionInteraction: indexPath.item))
    }
    
    /* 如果-collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath被设置为YES，则在allowMultipleSelection之后立即调用。
     * 返回YES。
     *
     * 在你的应用程序中，这将是一个很好的机会来更新你的用户界面的状态，以反映用户现在正在选择
     * 一次选择多个项目；例如，更新按钮为 "完成"，而不是 "选择"/"编辑"，等等。
     */
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Void> {
        .handleable(section(indexPath)?.item(didBeginMultipleSelectionInteraction: indexPath.item))
    }
    
    /* 在多选互动结束时调用。
     *
     * 此时，集合视图将保持在多选模式下，但这个委托方法被调用以表明
     * 多重选择手势或硬件键盘交互已经结束。
     */
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) -> SKHandleResult<Void> {
        sections().forEach({ section in
            section.section(didEndMultipleSelectionInteraction: ())
        })
        return .handle
    }
    
    /**
     * @abstract Called when the interaction begins.
     *
     * @param collectionView  The @c UICollectionView.
     * @param indexPath       IndexPath of the item for which a configuration is being requested.
     * @param point           Touch location in the collection view's coordinate space
     *
     * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time. If the non-deprecated replacement for the configuration, highlight preview, or dismissal preview methods is implemented this method is not called.
     *
     * @abstract 当互动开始时被调用。
     *
     * @param collectionView @c UICollectionView。
     * @param indexPath 正在请求配置的项目的索引路径。
     * @param point 在集合视图的坐标空间中的触摸位置。
     *
     * @return 一个UIContextMenuConfiguration，描述要展示的菜单。返回nil以阻止交互的开始。
     * 返回一个空的配置会导致交互开始，然后以取消的效果失败。你可以使用这个
     * 来向用户表明，有可能从这个元素中呈现一个菜单，但是在这个特定的时间内没有任何动作可以
     *在这个特定的时间里，没有任何动作可以呈现。如果实现了配置、高亮预览或取消预览方法的非降级替换，则不调用此方法。
     */
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?> {
        guard let configuration = section(indexPath)?.contextMenu(row: indexPath.row, point: point) else {
            return .next
        }
        store.contextMenuConfiguration[ObjectIdentifier(configuration)] = .init(indexPath: indexPath, configuration: configuration)
        return .handle(configuration)
    }
    
    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview describing the desired highlight preview.
     *           If the non-deprecated replacement for the configuration, highlight preview, or dismissal preview methods is implemented this method is not called.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   The configuration of the menu about to be displayed by this interaction.
     *
     * @abstract 当互动开始时被调用。返回一个UITargetedPreview，描述所需的高亮预览。
     * 如果实现了配置、高亮预览或驳回预览方法的非弃用替换，则不调用此方法。
     *
     * @param collectionView @c UICollectionView。
     * @param configuration 即将被这个交互显示的菜单的配置。
     */
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?> {
        guard let configuration = store.contextMenuConfiguration[ObjectIdentifier(configuration)] else {
            return .next
        }
        return .handleable(section(configuration.indexPath)?.contextMenu(highlightPreview: configuration.configuration, row: configuration.indexPath.row))
    }
    
    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     *           The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *           If the non-deprecated replacement for the configuration, highlight preview, or dismissal preview methods is implemented this method is not called.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   The configuration of the menu displayed by this interaction.
     */
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?> {
        guard let configuration = store.contextMenuConfiguration[ObjectIdentifier(configuration)] else {
            return .next
        }
        defer { store.contextMenuConfiguration[configuration.ID] = nil }
        return .handleable(section(configuration.indexPath)?.contextMenu(dismissalPreview: configuration.configuration, row: configuration.indexPath.row))
    }
    
    /**
     * @abstract Called when a context menu is invoked from this collection view.
     *
     * @param collectionView  The @c UICollectionView.
     * @param indexPaths      An array of index paths on which the menu acts.
     * @param point           Touch location in the collection view's coordinate space.
     *
     * @return A @c UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time.
     *
     * @discussion  The @c indexPaths array may contain 0-many items:
     *              - An empty array indicates that the menu was invoked in the space between cells (or any location that does not map to an item index path).
     *              - An array with multiple index paths indicates that the menu was invoked on an item within a multiple selection.
     *
     *
     * @param collectionView @c UICollectionView.
     * @param indexPaths 一个索引路径的数组，该菜单在其中起作用。
     * @param point 在集合视图的坐标空间中的触摸位置。
     *
     * @return 一个描述要呈现的菜单的@c UIContextMenuConfiguration。返回nil以防止互动开始。
     * 返回一个空的配置会导致交互开始，然后以取消的效果失败。你可以使用这个
     * 来向用户表明，有可能从这个元素中呈现一个菜单，但在这个特定的时间内没有任何行动可以
     * 在这个特定的时间呈现。
     *
     * @讨论 @c indexPaths数组可以包含0-many项。
     * - 一个空数组表示菜单是在单元格之间的空间（或任何没有映射到项目索引路径的位置）调用的。
     * - 一个有多个索引路径的数组表示菜单是在一个多选中的一个项目上调用的。
     */
    
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?> {
        if indexPaths.count == 1, let indexPath = indexPaths.first {
            return .handleable(section(indexPath)?.contextMenu(row: indexPath.row, point: point))
        } else {
            return .next
        }
    }
    
    /**
     * @abstract Called when a context menu presented from this collection view is dismissed. Return a @c UITargetedPreview corresponding to the item at the given indexPath.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Configuration of the menu being dismissed.
     * @param indexPath       Index path of the item to which the menu is being dismissed.
     *
     * @abstract 当该集合视图中的上下文菜单交互开始时调用，以请求为交互的初始高亮效果提供预览。
     * 返回一个@c UITargetedPreview，对应于给定indexPath的项目。
     *
     * @param collectionView @c UICollectionView。
     * @param configuration 如果互动继续进行，将呈现的菜单的配置。
     * @param indexPath 发生交互的项目的索引路径。
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?> {
        .handleable(section(indexPath)?.contextMenu(highlightPreview: configuration, row: indexPath.row))
    }
    
    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Configuration of the currently displayed menu.
     * @param animator        Commit animator. Add animations to this object to run them alongside the commit transition.
     *
     * @abstract 当从这个集合视图中呈现的上下文菜单被驳回时被调用。返回一个@c UITargetedPreview，对应于给定indexPath的项目。
     *
     * @param collectionView @c UICollectionView.
     * @param configuration 被取消的菜单的配置。
     * @param indexPath 菜单被取消的项目的索引路径。
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?> {
        .handleable(section(indexPath)?.contextMenu(dismissalPreview: configuration, row: indexPath.row))
    }
    
    /**
     * @abstract 当交互即将 "提交 "时调用，以响应用户点选预览。
     *
     * @param collectionView @c UICollectionView。
     * @param configuration 当前显示的菜单的配置。
     * @param animator 提交动画器。向这个对象添加动画，以便在提交过渡的同时运行这些动画。
     */
    //    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {}
    
    /**
     * @abstract Called when the collection view is about to display a menu.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     *
     * @abstract 当集合视图要显示一个菜单时调用。
     *
     * @param collectionView 指@c UICollectionView。
     * @param configuration 即将显示的菜单的配置。
     * @param animator 外观动画器。添加动画，在外观转换的同时运行它们。
     */
    //    @available(iOS 13.2, *)
    //    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) { }
    
    /**
     * @abstract Called when the collection view's context menu interaction is about to end.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     *
     * @abstract 当集合视图的上下文菜单交互即将结束时调用。
     *
     * @param collectionView 该@c UICollectionView。
     * @param configuration 结束配置。
     * @param animator 消失的动画器。添加动画，在消失过渡的同时运行它们。
     */
    //    @available(iOS 13.2, *)
    //    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) { }
    
    /**
     * @abstract Return a valid @c UIWindowSceneActivationConfiguration to allow for the cell to be expanded into a new scene. Return nil to prevent the interaction from starting.
     *
     * @param collectionView The collection view
     * @param indexPath The index path of the cell being interacted with
     * @param point The centroid of the interaction in the collection view's coordinate space.
     *
     * @abstract 返回一个有效的@c UIWindowSceneActivationConfiguration，允许单元格被扩展到一个新的场景。返回nil以阻止交互的开始。
     *
     * @param collectionView 集合视图
     * @param indexPath 被交互的单元格的索引路径。
     * @param point 在集合视图的坐标空间中互动的中心点。
     */
    // @available(iOS 15.0, *)
    // func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIWindowScene.ActivationConfiguration? { }
}

#endif
