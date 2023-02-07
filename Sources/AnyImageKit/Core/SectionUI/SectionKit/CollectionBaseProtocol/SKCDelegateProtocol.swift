//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public protocol SKCDelegateProtocol {
    
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
    func item(shouldHighlight row: Int) -> Bool
    func item(didHighlight row: Int)
    func item(didUnhighlight row: Int)
    
    func item(shouldSelect row: Int) -> Bool
    func item(shouldDeselect row: Int) -> Bool
    
    func item(selected row: Int)
    //当用户在多选模式下点击一个已经选择的项目时被调用
    func item(deselected row: Int)
    
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
    func item(canPerformPrimaryAction row: Int) -> Bool
    @available(iOS 16.0, *)
    func item(performPrimaryAction row: Int)
    
    func item(willDisplay view: UICollectionViewCell, row: Int)
    func item(didEndDisplaying view: UICollectionViewCell, row: Int)
    
    func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int)
    func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int)
    
    /// Focus
    func item(canFocus row: Int) -> Bool
    /// 确定当焦点移动到指定的索引路径上时，该项目是否也应该被选中。
    /// 如果集合视图的全局selectionFollowsFocus被启用，这个方法将允许你在每个索引路径上覆盖该行为。如果selectionFollowsFocus被禁用，则不调用此方法。
    @available(iOS 15.0, *)
    func item(selectionFollowsFocus row: Int) -> Bool
    @available(iOS 14.0, *)
    func item(canEdit row: Int) -> Bool
    
    // 弹簧加载
    
    /* 允许选择退出某一特定项目的弹簧加载。
     *
     * 如果你想在弹簧加载单元的不同子视图上实现交互效果，请修改context.targetView属性。
     * 默认是单元格。
     *
     * 如果这个方法没有实现，默认是YES。
     */
    func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool
    
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
    func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool
    
    /* 如果-collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath被设置为YES，则在allowMultipleSelection之后立即调用。
     * 返回YES。
     *
     * 在你的应用程序中，这将是一个很好的机会来更新你的用户界面的状态，以反映用户现在正在选择
     * 一次选择多个项目；例如，更新按钮为 "完成"，而不是 "选择"/"编辑"，等等。
     */
    func item(didBeginMultipleSelectionInteraction row: Int)

    func contextMenu(row: Int, point: CGPoint) -> UIContextMenuConfiguration?
    func contextMenu(highlightPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview?
    func contextMenu(dismissalPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview?

    
    /* 在多选互动结束时调用。
     *
     * 此时，集合视图将保持在多选模式下，但这个委托方法被调用以表明
     * 多重选择手势或硬件键盘交互已经结束。
     */
    func section(didEndMultipleSelectionInteraction: Void)
}


public extension SKCDelegateProtocol {

    func contextMenu(row: Int, point: CGPoint) -> UIContextMenuConfiguration? { nil }
    func contextMenu(highlightPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview? { nil }
    func contextMenu(dismissalPreview configuration: UIContextMenuConfiguration, row: Int) -> UITargetedPreview? { nil }
    
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
    func item(shouldHighlight row: Int) -> Bool { true }
    func item(didHighlight row: Int) { }
    func item(didUnhighlight row: Int) { }
    
    func item(shouldSelect row: Int) -> Bool { true }
    func item(shouldDeselect row: Int) -> Bool { true }
    
    func item(selected row: Int) { }
    //当用户在多选模式下点击一个已经选择的项目时被调用
    func item(deselected row: Int) { }
    
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
    func item(canPerformPrimaryAction row: Int) -> Bool { true }
    @available(iOS 16.0, *)
    func item(performPrimaryAction row: Int) { }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) { }
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) { }
    
    func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) { }
    func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) { }
    
    /// Focus
    func item(canFocus row: Int) -> Bool { true }
    /// 确定当焦点移动到指定的索引路径上时，该项目是否也应该被选中。
    /// 如果集合视图的全局selectionFollowsFocus被启用，这个方法将允许你在每个索引路径上覆盖该行为。如果selectionFollowsFocus被禁用，则不调用此方法。
    @available(iOS 15.0, *)
    func item(selectionFollowsFocus row: Int) -> Bool { true }
    @available(iOS 14.0, *)
    func item(canEdit row: Int) -> Bool { false }
    
    // 弹簧加载
    
    /* 允许选择退出某一特定项目的弹簧加载。
     *
     * 如果你想在弹簧加载单元的不同子视图上实现交互效果，请修改context.targetView属性。
     * 默认是单元格。
     *
     * 如果这个方法没有实现，默认是YES。
     */
    func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool { true }
    
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
    func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool { false }
    
    /* 如果-collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath被设置为YES，则在allowMultipleSelection之后立即调用。
     * 返回YES。
     *
     * 在你的应用程序中，这将是一个很好的机会来更新你的用户界面的状态，以反映用户现在正在选择
     * 一次选择多个项目；例如，更新按钮为 "完成"，而不是 "选择"/"编辑"，等等。
     */
    func item(didBeginMultipleSelectionInteraction row: Int) { }
    
    /* 在多选互动结束时调用。
     *
     * 此时，集合视图将保持在多选模式下，但这个委托方法被调用以表明
     * 多重选择手势或硬件键盘交互已经结束。
     */
    func section(didEndMultipleSelectionInteraction: Void) { }
    
}
