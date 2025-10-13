//
//  File.swift
//
//
//  Created by linhey on 2024/3/13.
//

import UIKit

public class SKCDelegateForward: SKScrollViewDelegateForward, UICollectionViewDelegate {
   
    public var shouldBeginMultipleSelectionInteraction: Bool?
    public var shouldSpringLoad: Bool?
    public var canEdit: Bool?
    public var canFocus: Bool?
    public var shouldUpdateFocus: Bool?
    public var selectionFollowsFocus: Bool?
    public var shouldHighlight: Bool?
    public var shouldSelect: Bool?
    public var shouldDeselect: Bool?
    public var canPerformPrimaryAction: Bool?
    
    var uiForwards: [SKCDelegateForwardProtocol] = []
    var uiObservers: [SKCDelegateObserverProtocol] = []
    
}

public extension SKCDelegateForward {

    func add(ui item: SKCDelegateObserverProtocol) {
        uiObservers.append(item)
    }

    func add(ui item: SKCDelegateForwardProtocol) {
        uiForwards.append(item)
    }
    
    func add(_ item: SKCDelegateObserverProtocol) {
        add(ui: item)
    }
    
    func add(_ item: SKCDelegateForwardProtocol) {
        add(ui: item)
    }
    
    func find<T>(`default`: T,
                 overwrite: KeyPath<SKCDelegateForward, T?>?,
                 _ task: (_ item: SKCDelegateForwardProtocol) -> SKHandleResult<T>) -> T {
        if let overwrite = overwrite, let value = self[keyPath: overwrite] {
            return value
        }
        for item in uiForwards.reversed() {
            let result = task(item)
            switch result {
            case .handle(let value):
                return value
            case .next:
                break
            }
        }
        return `default`
    }
    
    func find(_ task: (_ item: SKCDelegateForwardProtocol) -> SKHandleResult<Void>) -> Void {
        return find(default: (), overwrite: nil, task)
    }
    
    func observe(_ task: (_ item: SKCDelegateObserverProtocol) -> Void) {
        uiObservers.forEach(task)
    }
    
}

public extension SKCDelegateForward {
    // Methods for notification of selection/deselection and highlight/unhighlight events.
    // The sequence of calls leading to selection from a user touch is:
    //
    // (when the touch begins)
    // 1. -collectionView:shouldHighlightItemAtIndexPath:
    // 2. -collectionView:didHighlightItemAtIndexPath:
    //
    // (when the touch lifts)
    // 3. -collectionView:shouldSelectItemAtIndexPath: or -collectionView:shouldDeselectItemAtIndexPath:
    // 4. -collectionView:didSelectItemAtIndexPath: or -collectionView:didDeselectItemAtIndexPath:
    // 5. -collectionView:didUnhighlightItemAtIndexPath:
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.shouldHighlight) { $0.collectionView(collectionView, shouldHighlightItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, shouldHighlightItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didHighlightItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didHighlightItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didUnhighlightItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didUnhighlightItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.shouldSelect) { $0.collectionView(collectionView, shouldSelectItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, shouldSelectItemAt: indexPath, value: value)
        }
        return value
    }
    
    // called when the user taps on an already-selected item in multi-select mode
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.shouldDeselect) { $0.collectionView(collectionView, shouldDeselectItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, shouldDeselectItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didSelectItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didSelectItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didDeselectItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didDeselectItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called to determine if a primary action can be performed for the item at the given indexPath.
     * See @c collectionView:performPrimaryActionForItemAtIndexPath: for more details about primary actions.
     *
     * @param collectionView This UICollectionView
     * @param indexPath NSIndexPath of the item
     *
     * @return `YES` if the primary action can be performed; otherwise `NO`. If not implemented, defaults to `YES` when not editing
     * and `NO` when editing.
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.canPerformPrimaryAction) { $0.collectionView(collectionView, canPerformPrimaryActionForItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, canPerformPrimaryActionForItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when the primary action should be performed for the item at the given indexPath.
     *
     * @discussion Primary actions allow you to distinguish between a change of selection (which can be based on focus changes or
     * other indirect selection changes) and distinct user actions. Primary actions are performed when the user selects a cell without extending
     * an existing selection. This is called after @c shouldSelectItem and @c didSelectItem , regardless of whether the cell's selection
     * state was allowed to change.
     *
     * As an example, use @c didSelectItemAtIndexPath for updating state in the current view controller (i.e. buttons, title, etc) and
     * use the primary action for navigation or showing another split view column.
     *
     * @param collectionView This UICollectionView
     * @param indexPath NSIndexPath of the item to perform the action on
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, performPrimaryActionForItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, performPrimaryActionForItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath) }
        observe { item in
            item.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 8.0, *)
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath) }
        observe { item in
            item.collectionView(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath, value: value)
        }
        return value
    }

    // support for custom transition layout
    @available(iOS 7.0, *)
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        let value = find(default: UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout), overwrite: nil) { $0.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout) }
        observe { item in
            item.collectionView(collectionView, transitionLayoutForOldLayout: fromLayout, newLayout: toLayout, value: value)
        }
        return value
    }
    
    
    // Focus
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.canFocus) { $0.collectionView(collectionView, canFocusItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, canFocusItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        let value = find(default: true, overwrite: \.shouldUpdateFocus) { $0.collectionView(collectionView, shouldUpdateFocusIn: context) }
        observe { item in
            item.collectionView(collectionView, shouldUpdateFocusIn: context, value: value)
        }
        return value
    }
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        let value: Void = find { $0.collectionView(collectionView, didUpdateFocusIn: context, with: coordinator) }
        observe { item in
            item.collectionView(collectionView, didUpdateFocusIn: context, with: coordinator, value: value)
        }
        return value
    }
    
    @available(iOS 9.0, *)
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        let value = find(default: nil, overwrite: nil) { $0.indexPathForPreferredFocusedView(in: collectionView) }
        observe { item in
            item.indexPathForPreferredFocusedView(in: collectionView, value: value)
        }
        return value
    }
    
    
    /// Determines if the item at the specified index path should also become selected when focus moves to it.
    /// If the collection view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.selectionFollowsFocus) { $0.collectionView(collectionView, selectionFollowsFocusForItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, selectionFollowsFocusForItemAt: indexPath, value: value)
        }
        return value
    }
    
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let value = find(default: proposedIndexPath, overwrite: nil) { $0.collectionView(collectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath: originalIndexPath, atCurrentIndexPath: currentIndexPath, toProposedIndexPath: proposedIndexPath) }
        observe { item in
            item.collectionView(collectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath: originalIndexPath, atCurrentIndexPath: currentIndexPath, toProposedIndexPath: proposedIndexPath, value: value)
        }
        return value
    }
    
    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let value = find(default: proposedIndexPath, overwrite: nil) { $0.collectionView(collectionView, targetIndexPathForMoveFromItemAt: currentIndexPath, toProposedIndexPath: proposedIndexPath) }
        observe { item in
            item.collectionView(collectionView, targetIndexPathForMoveFromItemAt: currentIndexPath, toProposedIndexPath: proposedIndexPath, value: value)
        }
        return value
    }
    
    // customize the content offset to be applied during transition or update animations
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let value = find(default: proposedContentOffset, overwrite: nil) { $0.collectionView(collectionView, targetContentOffsetForProposedContentOffset: proposedContentOffset) }
        observe { item in
            item.collectionView(collectionView, targetContentOffsetForProposedContentOffset: proposedContentOffset, value: value)
        }
        return value
    }
    
    
    // Editing
    /* Asks the delegate to verify that the given item is editable.
     *
     * @param collectionView The collection view object requesting this information.
     * @param indexPath An index path locating an item in `collectionView`.
     *
     * @return `YES` if the item is editable; otherwise, `NO`. Defaults to `YES`.
     */
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        let value = find(default: true, overwrite: \.canEdit) { $0.collectionView(collectionView, canEditItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, canEditItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    // Spring Loading
    
    /* Allows opting-out of spring loading for an particular item.
     *
     * If you want the interaction effect on a different subview of the spring loaded cell, modify the context.targetView property.
     * The default is the cell.
     *
     * If this method is not implemented, the default is YES.
     */
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext) -> Bool {
        let value = find(default: true, overwrite: \.shouldSpringLoad) { $0.collectionView(collectionView, shouldSpringLoadItemAt: indexPath, with: context) }
        observe { item in
            item.collectionView(collectionView, shouldSpringLoadItemAt: indexPath, with: context, value: value)
        }
        return value
    }
    
    
    // Multiple Selection
    
    /* Allows a two-finger pan gesture to automatically enable allowsMultipleSelection and start selecting multiple cells.
     *
     * After a multi-select gesture is recognized, this method will be called before allowsMultipleSelection is automatically
     * set to YES to allow the user to select multiple contiguous items using a two-finger pan gesture across the constrained
     * scroll direction.
     *
     * If the collection view has no constrained scroll direction (i.e., the collection view scrolls both horizontally and vertically),
     * then this method will not be called and the multi-select gesture will be disabled.
     *
     * If this method is not implemented, the default is NO.
     */
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        let value = find(default: false, overwrite: \.shouldBeginMultipleSelectionInteraction) { $0.collectionView(collectionView, shouldBeginMultipleSelectionInteractionAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, shouldBeginMultipleSelectionInteractionAt: indexPath, value: value)
        }
        return value
    }
    
    
    /* Called right after allowsMultipleSelection is set to YES if -collectionView:shouldBeginMultipleSelectionInteractionAtIndexPath:
     * returned YES.
     *
     * In your app, this would be a good opportunity to update the state of your UI to reflect the fact that the user is now selecting
     * multiple items at once; such as updating buttons to say "Done" instead of "Select"/"Edit", for instance.
     */
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        let value: Void = find { $0.collectionView(collectionView, didBeginMultipleSelectionInteractionAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, didBeginMultipleSelectionInteractionAt: indexPath, value: value)
        }
        return value
    }
    
    
    /* Called when the multi-select interaction ends.
     *
     * At this point, the collection view will remain in multi-select mode, but this delegate method is called to indicate that the
     * multiple selection gesture or hardware keyboard interaction has ended.
     */
    @available(iOS 13.0, *)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        let value: Void = find { $0.collectionViewDidEndMultipleSelectionInteraction(collectionView) }
        observe { item in
            item.collectionViewDidEndMultipleSelectionInteraction(collectionView, value: value)
        }
        return value
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
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, contextMenuConfigurationForItemsAt: indexPaths, point: point) }
        observe { item in
            item.collectionView(collectionView, contextMenuConfigurationForItemsAt: indexPaths, point: point, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when a context menu interaction begins in this collection view to request a preview for the interaction's initial highlight effect.
     *           Return a @c UITargetedPreview corresponding to the item at the given indexPath.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Configuration of the menu that will be presented if the interaction proceeds.
     * @param indexPath       Index path of the item at which the interaction is occurring.
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, contextMenuConfiguration: configuration, highlightPreviewForItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, contextMenuConfiguration: configuration, highlightPreviewForItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when a context menu presented from this collection view is dismissed. Return a @c UITargetedPreview corresponding to the item at the given indexPath.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Configuration of the menu being dismissed.
     * @param indexPath       Index path of the item to which the menu is being dismissed.
     */
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, contextMenuConfiguration: configuration, dismissalPreviewForItemAt: indexPath) }
        observe { item in
            item.collectionView(collectionView, contextMenuConfiguration: configuration, dismissalPreviewForItemAt: indexPath, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Configuration of the currently displayed menu.
     * @param animator        Commit animator. Add animations to this object to run them alongside the commit transition.
     */
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        let value: Void = find { $0.collectionView(collectionView, willPerformPreviewActionForMenuWith: configuration, animator: animator) }
        observe { item in
            item.collectionView(collectionView, willPerformPreviewActionForMenuWith: configuration, animator: animator, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when the collection view is about to display a menu.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) {
        let value: Void = find { $0.collectionView(collectionView, willDisplayContextMenu: configuration, animator: animator) }
        observe { item in
            item.collectionView(collectionView, willDisplayContextMenu: configuration, animator: animator, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when the collection view's context menu interaction is about to end.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) {
        let value: Void = find { $0.collectionView(collectionView, willEndContextMenuInteraction: configuration, animator: animator) }
        observe { item in
            item.collectionView(collectionView, willEndContextMenuInteraction: configuration, animator: animator, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Return a valid @c UIWindowSceneActivationConfiguration to allow for the cell to be expanded into a new scene. Return nil to prevent the interaction from starting.
     *
     * @param collectionView The collection view
     * @param indexPath The index path of the cell being interacted with
     * @param point The centroid of the interaction in the collection view's coordinate space.
     */
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIWindowScene.ActivationConfiguration? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, sceneActivationConfigurationForItemAt: indexPath, point: point) }
        observe { item in
            item.collectionView(collectionView, sceneActivationConfigurationForItemAt: indexPath, point: point, value: value)
        }
        return value
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
     */
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, contextMenuConfigurationForItemAt: indexPath, point: point) }
        observe { item in
            item.collectionView(collectionView, contextMenuConfigurationForItemAt: indexPath, point: point, value: value)
        }
        return value
    }
    
    
    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview describing the desired highlight preview.
     *           If the non-deprecated replacement for the configuration, highlight preview, or dismissal preview methods is implemented this method is not called.
     *
     * @param collectionView  The @c UICollectionView.
     * @param configuration   The configuration of the menu about to be displayed by this interaction.
     */
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration) }
        observe { item in
            item.collectionView(collectionView, previewForHighlightingContextMenuWithConfiguration: configuration, value: value)
        }
        return value
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
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let value = find(default: nil, overwrite: nil) { $0.collectionView(collectionView, previewForDismissingContextMenuWithConfiguration: configuration) }
        observe { item in
            item.collectionView(collectionView, previewForDismissingContextMenuWithConfiguration: configuration, value: value)
        }
        return value
    }
}
