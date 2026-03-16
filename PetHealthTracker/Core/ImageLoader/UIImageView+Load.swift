//
//  UIImageView+Load.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit
import ObjectiveC

private var imageTaskKey: UInt8 = 0

extension UIImageView {
    
    private var imageLoadTask: Task<Void, Never>? {
        get { objc_getAssociatedObject(self, &imageTaskKey) as? Task<Void, Never> }
        set { objc_setAssociatedObject(self, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func setImage(
        from url: URL,
        placeholder: UIImage? = nil
    ) {
        imageLoadTask?.cancel()
        image = placeholder
        
        imageLoadTask = Task { [weak self] in
            do {
                let loadedImage = try await ImageLoader.shared.loadImage(from: url)
                
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self?.image = loadedImage
                }
            } catch {
                if Task.isCancelled { return }
            }
        }
    }
    
    func cancelImageLoad() {
        imageLoadTask?.cancel()
        imageLoadTask = nil
    }
}
