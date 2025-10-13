//
//  File.swift
//  
//
//  Created by linhey on 2024/3/14.
//

import UIKit

public protocol SKCDelegateObserverProtocol {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath, value: Void)
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath, value: Bool)
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath, value: Void)
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout, value: UICollectionViewTransitionLayout)
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext, value: Bool)
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator, value: Void)
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView, value: IndexPath?)
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath, value: Bool)
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, value: IndexPath)
    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, value: IndexPath)
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint, value: CGPoint)
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext, value: Bool)
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath, value: Bool)
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath, value: Void)
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView, value: Void)
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint, value: UIContextMenuConfiguration?)
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath, value: UITargetedPreview?)
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath, value: UITargetedPreview?)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating, value: Void)
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?, value: Void)
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?, value: Void)
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint, value: UIWindowScene.ActivationConfiguration?)
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint, value: UIContextMenuConfiguration?)
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration, value: UITargetedPreview?)
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration, value: UITargetedPreview?)
}

public extension SKCDelegateObserverProtocol {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath, value: Void) {}
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, canPerformPrimaryActionForItemAt indexPath: IndexPath, value: Bool) {}
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, performPrimaryActionForItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath, value: Void) {}
    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout, value: UICollectionViewTransitionLayout) {}
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator, value: Void) {}
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView, value: IndexPath?) {}
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath, value: Bool) {}
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath, atCurrentIndexPath currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, value: IndexPath) {}
    @available(iOS, introduced: 9.0, deprecated: 15.0)
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath, value: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint, value: CGPoint) {}
    @available(iOS 14.0, *)
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: any UISpringLoadedInteractionContext, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath, value: Bool) {}
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath, value: Void) {}
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView, value: Void) {}
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint, value: UIContextMenuConfiguration?) {}
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath, value: UITargetedPreview?) {}
    @available(iOS 16.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath, value: UITargetedPreview?) {}
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating, value: Void) {}
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?, value: Void) {}
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?, value: Void) {}
    @available(iOS 15.0, *)
    func collectionView(_ collectionView: UICollectionView, sceneActivationConfigurationForItemAt indexPath: IndexPath, point: CGPoint, value: UIWindowScene.ActivationConfiguration?) {}
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint, value: UIContextMenuConfiguration?) {}
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration, value: UITargetedPreview?) {}
    @available(iOS, introduced: 13.0, deprecated: 16.0)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration, value: UITargetedPreview?) {}
}
