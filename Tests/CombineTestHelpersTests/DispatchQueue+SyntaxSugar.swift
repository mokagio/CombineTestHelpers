import Foundation

func asyncAfter(_ delay: Double, _ work: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) { work() }
}
