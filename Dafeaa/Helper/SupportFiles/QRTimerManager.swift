//
//  QRTimerManager.swift
//  Dafeaa
//
//  Created by AMNY on 14/04/2026.
//
import SwiftUI

 class QRTimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    private var timer: DispatchSourceTimer?
    private var expiryDate: Date?

    func start(seconds: Int) {
        expiryDate = Date().addingTimeInterval(TimeInterval(seconds))
        remainingSeconds = seconds
        stop()
        let t = DispatchSource.makeTimerSource(queue: .global(qos: .background))
        t.schedule(deadline: .now(), repeating: 1.0)
        t.setEventHandler { [weak self] in
            guard let self, let expiry = self.expiryDate else { return }
            let remaining = Int(expiry.timeIntervalSinceNow)
            DispatchQueue.main.async {
                if remaining > 0 {
                    self.remainingSeconds = remaining
                } else {
                    self.stop()
                    self.remainingSeconds = 0
                }
            }
        }
        t.resume()
        timer = t
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    var isExpired: Bool { remainingSeconds <= 0 && expiryDate != nil }
}
