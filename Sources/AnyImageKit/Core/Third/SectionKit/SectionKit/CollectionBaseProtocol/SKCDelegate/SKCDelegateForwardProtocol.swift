//
//  File.swift
//  
//
//  Created by linhey on 2024/3/14.
//

import UIKit

public protocol SKCDelegateForwardProtocol {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> SKHandleResult<UICollectionViewTransitionLayout>
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) -> SKHandleResult<Void>
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> SKHandleResult<IndexPath?>
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> SKHandleResult<IndexPath>
    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> SKHandleResult<IndexPath>
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> SKHandleResult<CGPoint>
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Bool>
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Void>
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) -> SKHandleResult<Void>
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?>
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?>
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?>
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) -> SKHandleResult<Void>
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) -> SKHandleResult<Void>
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) -> SKHandleResult<Void>
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> SKHandleResult<UIWindowScene.ActivationConfiguration?>
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?>
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?>
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?>
}

public extension SKCDelegateForwardProtocol {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> SKHandleResult<UICollectionViewTransitionLayout> { .next }
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) -> SKHandleResult<Void> { .next }
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> SKHandleResult<IndexPath?> { .next }
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> SKHandleResult<IndexPath> { .next }
    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> SKHandleResult<IndexPath> { .next }
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> SKHandleResult<CGPoint> { .next }
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Bool> { .next }
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> SKHandleResult<Void> { .next }
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) -> SKHandleResult<Void> { .next }
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?> { .next }
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview> { .next }
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?> { .next }
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) -> SKHandleResult<Void> { .next }
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) -> SKHandleResult<Void> { .next }
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) -> SKHandleResult<Void> { .next }
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> SKHandleResult<UIWindowScene.ActivationConfiguration?> { .next }
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> SKHandleResult<UIContextMenuConfiguration?> { .next }
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?> { .next }
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> SKHandleResult<UITargetedPreview?> { .next }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> SKHandleResult<UITargetedPreview?> { .next }
}
