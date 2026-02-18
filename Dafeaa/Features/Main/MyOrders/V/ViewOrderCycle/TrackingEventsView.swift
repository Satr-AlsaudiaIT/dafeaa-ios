//
//  TrackingEventsView.swift
//  Dafeaa
//
//  Created by AMNY on 08/02/2026.
//

import SwiftUI

struct TrackingEventsView: View {
    let events: [TrackingEvent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("tracking_events".localized())
                .textModifier(.plain, 15, .black222222)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.8), lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.clear))
                
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        TrackingEventRow(
                            event: event,
                            isLast: index == events.count - 1
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
    }
}

struct TrackingEventRow: View {
    let event: TrackingEvent
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                // Circle
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 40)
                        .padding(.top, 0)
                        .padding(.bottom, 0)
                }
            }
            
            // Left side: Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.description)
                    .textModifier(.plain, 14, .black222222)
                    .multilineTextAlignment(.trailing)
                
                if let serviceArea = event.serviceArea.first {
                    Text(serviceArea.description)
                        .textModifier(.plain, 12, .gray919191)
                }
                
                Text("\(formatTime(event.time)) \(event.date)")
                    .textModifier(.plain, 12, .gray919191)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, isLast ? 0 : 0) 
    }
    
    private func formatTime(_ time: String) -> String {
        return time
    }
}

// MARK: - Preview
#Preview {
    TrackingEventsView(events: TrackingEvent.mockData)
        .padding()
}

// MARK: - Mock Data Extension
extension TrackingEvent {
    static let mockData: [TrackingEvent] = [
        TrackingEvent(
            date: "2026-01-18",
            time: "12:51:57",
            typeCode: "PU",
            description: "Shipment picked up",
            serviceArea: [ServiceArea(code: "CAN", description: "Guangzhou-CN")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-18",
            time: "18:11:01",
            typeCode: "AF",
            description: "Arrived at DHL Sort Facility  GUANGZHOU,AP-CHINA, PEOPLES REPUBLIC",
            serviceArea: [ServiceArea(code: "CAN", description: "Guangzhou-CN")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-19",
            time: "01:15:59",
            typeCode: "PL",
            description: "Processed at GUANGZHOU,AP-CHINA, PEOPLES REPUBLIC",
            serviceArea: [ServiceArea(code: "HKG", description: "Guangzhou-CN")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-19",
            time: "21:43:26",
            typeCode: "PL",
            description: "Processed at HONG KONG-HONG KONG SAR, CHINA",
            serviceArea: [ServiceArea(code: "HKG", description: "Hong Kong-HK")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-20",
            time: "12:19:59",
            typeCode: "WC",
            description: "Shipment is out with courier for delivery",
            serviceArea: [ServiceArea(code: "YHM", description: "Brampton-CA")],
            signedBy: nil
        ),
        TrackingEvent(
            date: "2026-01-20",
            time: "13:14:49",
            typeCode: "OK",
            description: "Delivered",
            serviceArea: [ServiceArea(code: "YHM", description: "Brampton-CA")],
            signedBy: ""
        )
    ]
}
