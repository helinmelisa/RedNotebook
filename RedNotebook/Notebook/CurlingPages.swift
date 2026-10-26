import SwiftUI

/// One page per day that you turn with your finger: the page curls up from where you hold it and
/// rolls over to the next day (drag right to left) or back to the day before (left to right).
/// Changing `day` from elsewhere (the arrows, the calendar) turns the pages too.
struct CurlingPages<Page: View>: UIViewControllerRepresentable {
    @Binding var day: Date
    /// While a sticker is being moved or something drawn, the page holds still.
    var isLocked = false
    var page: (Date) -> Page

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal,
                                              options: [.spineLocation: UIPageViewController.SpineLocation.min.rawValue])
        controller.isDoubleSided = false
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.backgroundColor = .clear
        controller.setViewControllers([context.coordinator.host(for: day)], direction: .forward, animated: false)
        for recognizer in controller.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                // Tapping near the edge shouldn't turn the page: it's where you write
                recognizer.isEnabled = false
            } else {
                recognizer.delegate = context.coordinator
            }
        }
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        for recognizer in controller.gestureRecognizers where !(recognizer is UITapGestureRecognizer) {
            recognizer.isEnabled = !isLocked
        }
        coordinator.turn(controller, to: day)
    }

    final class DayHost: UIHostingController<Page> {
        let day: Date

        init(day: Date, rootView: Page) {
            self.day = day
            super.init(rootView: rootView)
            // Solid paper, so the curl shows the page and not what's under it
            view.backgroundColor = UIColor(Theme.paper)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
        var parent: CurlingPages
        private var isTurning = false

        init(parent: CurlingPages) {
            self.parent = parent
        }

        func host(for day: Date) -> DayHost {
            let start = Calendar.current.startOfDay(for: day)
            return DayHost(day: start, rootView: parent.page(start))
        }

        /// Turns to `day` if another page is showing, forwards or backwards.
        func turn(_ controller: UIPageViewController, to day: Date) {
            guard !isTurning, let shown = (controller.viewControllers?.first as? DayHost)?.day,
                  !Calendar.current.isDate(shown, inSameDayAs: day) else { return }
            isTurning = true
            SoundEffects.shared.play(.pageTurn)
            controller.setViewControllers([host(for: day)], direction: day > shown ? .forward : .reverse,
                                          animated: true) { [weak self, weak controller] _ in
                guard let self, let controller else { return }
                self.isTurning = false
                // The day moved on again mid-turn
                self.turn(controller, to: self.parent.day)
            }
        }

        private func neighbour(of controller: UIViewController, by days: Int) -> UIViewController? {
            guard let day = (controller as? DayHost)?.day,
                  let next = Calendar.current.date(byAdding: .day, value: days, to: day) else { return nil }
            return host(for: next)
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            neighbour(of: viewController, by: -1)
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            neighbour(of: viewController, by: 1)
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                willTransitionTo pendingViewControllers: [UIViewController]) {
            SoundEffects.shared.play(.pageTurn)
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let host = pageViewController.viewControllers?.first as? DayHost else { return }
            UISelectionFeedbackGenerator().selectionChanged()
            parent.day = host.day
        }

        // MARK: Sharing touches with the page

        /// Only sideways drags turn the page; up and down scrolls it.
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y) * 1.2
        }

        /// Strips that scroll sideways themselves (notes, countdowns) keep their drags.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            var view = touch.view
            while let current = view {
                if let scroll = current as? UIScrollView, scroll.isScrollEnabled,
                   scroll.contentSize.width > scroll.bounds.width + 1 {
                    return false
                }
                view = current.superview
            }
            return true
        }

        /// The page's own scrolling waits a moment to see whether this is a page turn.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let scroll = otherGestureRecognizer.view as? UIScrollView,
                  otherGestureRecognizer == scroll.panGestureRecognizer else { return false }
            return scroll.contentSize.width <= scroll.bounds.width + 1
        }
    }
}
