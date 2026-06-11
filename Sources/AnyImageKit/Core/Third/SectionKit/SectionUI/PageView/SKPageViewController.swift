import UIKit
import Combine

public final class SKPageManager: NSObject {
    
    public struct ChildContext {
        public let index: Int
        public weak var controller: UIViewController?
    }
    
    public struct Child {
        
        public let maker: (_ context: ChildContext) -> UIViewController
        
        public static func withController(_ maker: @MainActor @escaping (_ context: ChildContext) -> UIViewController) -> Child {
            self.init(maker: maker)
        }
        
        public init(maker: @escaping (_ context: ChildContext) -> UIViewController) {
            self.maker = maker
        }
        
        public init(maker: @escaping (_ context: ChildContext) -> UIView) {
            self.init { context in
                SKPageViewBoxController(context: maker(context))
            }
        }
    }
    
    enum EventSource {
        case system
        case user
    }
    
    struct Trackable<Value> {
        var source: EventSource
        var value: Value
    }
    
    public var currentIndex: Int {
        get {
            current?.index ?? selection
        } set {
            selection = newValue
        }
    }
    
    @SKPublished private var selection = 0
    @SKPublished public var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    @SKPublished public var spacing: CGFloat = 0
    @SKPublished public var childs = [Child]()
    var controllers: [Int: SKWeakBox<SKPageChildController>] = [:]
    @SKPublished var trackSelection = Trackable<Int>(source: .user, value: 0)
    @Published public var current: ChildContext?
    public weak var container: UIPageViewController?
    private var cancellables = Set<AnyCancellable>()
    public override init() {}
}

public extension SKPageManager {
    
     var currentModel: ChildContext? {
        (container?.viewControllers?.first as? SKPageChildController)?.model.map {
            .init(index: $0.index, controller: $0.controller)
        }
    }
    
}

extension SKPageManager {

    private func child(at index: Int, parent: UIViewController) -> UIViewController? {
        guard index >= 0 && index < childs.count else {
            return nil
        }
        
        if let box = controllers[index], let controller = box.value {
            return controller
        }
        
        let controller = childs[index].maker(.init(index: index, controller: parent))
        let container = SKPageChildController()
        container.config(.init(index: index, controller: controller))
        controllers[index] = .init(container)
        return container
    }
    
    func makePageController() -> UIPageViewController {
        if let container {
            return container
        }
        cancellables.removeAll()
        let orientation: UIPageViewController.NavigationOrientation = (scrollDirection == .vertical) ? .vertical : .horizontal
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: orientation, options: [
            .interPageSpacing: spacing,
        ])
        controller.dataSource = self
        controller.delegate = self
        trackSelection = .init(source: .user, value: selection)
        $selection.bind { [weak self] selection in
            guard let self = self else { return }
            if selection != trackSelection.value {
                trackSelection = .init(source: .user, value: selection)
            }
        }.store(in: &cancellables)
        
        $trackSelection.bind { [weak self, weak controller] item in
            guard let self = self, let controller = controller else { return }
            let child = child(at: item.value, parent: controller)
            if item.source == .user, let child = child {
                controller.setViewControllers([child],
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
            }
            self.current = .init(index: item.value, controller: (child as? SKPageChildController)?.model?.controller)
        }.store(in: &cancellables)
        container = controller
        return controller
    }
    
}

extension SKPageManager: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? SKPageChildController,
              let index = controller.model?.index else {
            return nil
        }
        return child(at: index - 1, parent: pageViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? SKPageChildController,
              let index = controller.model?.index else {
            return nil
        }
        return child(at: index + 1, parent: pageViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        if completed,
           let controller = pageViewController.viewControllers?.first as? SKPageChildController,
           let index = controller.model?.index {
            trackSelection = .init(source: .system, value: index)
        }
    }
}

open class SKPageViewController: UIViewController {
    
    public private(set) var manager = SKPageManager()
    public private(set) lazy var pageController = manager.makePageController()
    public var cancellables = Set<AnyCancellable>()
    
    private var reloadSubject = PassthroughSubject<Void, Never>()
    private var builtInCancellables = Set<AnyCancellable>()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        set(manager: manager)
    }
    
   public func set(manager: SKPageManager) {
        self.manager = manager
        guard isViewLoaded else {
            return
        }
        builtInCancellables.removeAll()
        reloadSubject
            .throttle(for: .milliseconds(60), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                if !manager.childs.isEmpty, pageController != manager.container {
                    renderUI()
                }
            }.store(in: &builtInCancellables)
       
       Publishers.MergeMany([manager.$scrollDirection.ignoreOutputType().eraseToAnyPublisher(),
                             manager.$spacing.ignoreOutputType().eraseToAnyPublisher(),
                             manager.$childs.ignoreOutputType().eraseToAnyPublisher()])
       .debounce(for: .milliseconds(60), scheduler: RunLoop.main)
       .sink { [weak self] _ in
           guard let self = self else { return }
           reloadSubject.send()
       }
       .store(in: &builtInCancellables)
    }
    
    open func renderUI() {
        pageController.removeFromParent()
        pageController.view.removeFromSuperview()
        pageController = manager.makePageController()
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

private class SKPageViewBoxController: UIViewController {
    
    let context: UIView
    
    init(context: UIView) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(context)
        context.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            context.topAnchor.constraint(equalTo: view.topAnchor),
            context.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            context.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            context.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}


public class SKPageChildController: UIViewController {
    
    public struct Model {
        public let index: Int
        public var controller: UIViewController
    }
    
    public var model: Model?
    
    func config(_ model: Model) {
        if isViewLoaded {
            let controller = model.controller
            controller.removeFromParent()
            controller.view.removeFromSuperview()
            
            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        } else {
            self.model = model
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let model = model {
            config(model)
        }
    }
}
