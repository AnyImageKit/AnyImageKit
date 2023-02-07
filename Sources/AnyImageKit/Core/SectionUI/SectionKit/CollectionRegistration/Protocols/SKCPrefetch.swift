//
//  File.swift
//  
//
//  Created by linhey on 2022/9/14.
//

import Combine

public class SKCPrefetch {
    
    let prefetch = PassthroughSubject<[Int], Never>()
    let cancelPrefetching = PassthroughSubject<[Int], Never>()
    private var prefetchCancellable: AnyCancellable?
    
    var enableLoadMore: Bool = false
    let count: () -> Int
    
    init(count: @escaping () -> Int) {
        self.count = count
    }
    
}

public extension SKCPrefetch {
    
    /// 加载更多
    var loadMorePublisher: AnyPublisher<Void, Never> {
        prefetch
            .compactMap({ $0.max() })
            .filter({ [weak self] row in
                guard let self = self else { return false }
                return row + 1 >= self.count()
            })
            .map({ _ in })
            .eraseToAnyPublisher()
        
    }
    /// 预测将加载的 rows
    var prefetchPublisher: AnyPublisher<[Int], Never> { prefetch.eraseToAnyPublisher() }
    /// 取消加载
    var cancelPrefetchingPublisher: AnyPublisher<[Int], Never> { cancelPrefetching.eraseToAnyPublisher() }
    
}
