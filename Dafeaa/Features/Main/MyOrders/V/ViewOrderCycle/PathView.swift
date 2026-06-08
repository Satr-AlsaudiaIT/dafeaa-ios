//
//  SwiftUIView.swift
//  Dafeaa
//
//  Created by AMNY on 03/11/2024.
//

import SwiftUI


struct PathViewChoice: View {
    @Binding var orderStatus: orderStatusEnum

    // MARK: - Circle types derived from status
    private var c1:   statusPreviewTypes { orderStatus == .pending ? .loading : .checked }
    private var con1: statusPreviewTypes {
        switch orderStatus {
        case .pending:             return .unchecked
        case .rejected, .cancelled: return .rejected
        default:                   return .checked
        }
    }
    private var c2: statusPreviewTypes {
        switch orderStatus {
        case .pending:              return .unchecked
        case .accepted:             return .loading
        case .rejected, .cancelled: return .rejected
        default:                    return .checked
        }
    }
    private var con2: statusPreviewTypes {
        switch orderStatus {
        case .away, .pickup, .done, .shipmentField: return .checked
        default:                                    return .unchecked
        }
    }
    private var c3: statusPreviewTypes {
        switch orderStatus {
        case .away, .pickup:                        return .loading
        case .done, .shipmentField:                 return .checked
        default:                                    return .unchecked
        }
    }
    private var con3: statusPreviewTypes {
        switch orderStatus {
        case .done, .shipmentField: return .checked
        default:                    return .unchecked
        }
    }
    private var c4: statusPreviewTypes {
        switch orderStatus {
        case .done:          return .checked
        case .shipmentField: return .rejected
        default:             return .unchecked
        }
    }

    // MARK: - Step labels
    private var step2Label: String {
        switch orderStatus {
        case .rejected:  return "rejectedState".localized()
        case .cancelled: return "cancelledState".localized()
        default:         return "acceptedState".localized()
        }
    }
    private var step4Label: String {
        orderStatus == .shipmentField ? "shipmentFailedState".localized() : "doneState".localized()
    }

    // MARK: - Label colour
    private func labelColor(_ type: statusPreviewTypes) -> Color {
        switch type {
        case .checked:  return Color(.black292D32)
        case .loading:  return Color(.green026C34)
        case .rejected: return Color(.redEE002B)
        case .unchecked: return Color(.gray666666)
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            stepView(type: c1,   label: "pendingState".localized())
            connector(type: con1)
            stepView(type: c2,   label: step2Label)
            connector(type: con2)
            stepView(type: c3,   label: "awayState".localized())
            connector(type: con3)
            stepView(type: c4,   label: step4Label)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }

    // MARK: - Helpers
    @ViewBuilder
    private func stepView(type: statusPreviewTypes, label: String) -> some View {
        VStack(spacing: 4) {
            CircleView(statusPreviewType: type)
            Text(label)
                .textModifier(.plain, 11, labelColor(type))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(width: 52) // fixed to ~circle width so connectors fill the gap between circles
    }

    @ViewBuilder
    private func connector(type: statusPreviewTypes) -> some View {
        Rectangle()
            .fill(type == .unchecked ? Color(.grayD1D5DB) : type.color)
            .frame(maxWidth: .infinity, maxHeight: 1)
            .padding(.top, 20) // vertically centres line with circle (circle h ≈ 40)
    }
}

enum orderStatusEnum: Int {
    case pending = 1
    case accepted = 2
    case away = 3
    case rejected = 4
    case cancelled = 5
    case done = 6
     case pickup = 8
     case shipmentField = 9
    
    var pathview: PathViewChoice {
        switch self {
        case .pending: return PathViewChoice(orderStatus: .constant(.pending))
        case .accepted: return PathViewChoice(orderStatus: .constant(.accepted))
        case .away: return PathViewChoice(orderStatus: .constant(.away))
        case .rejected: return PathViewChoice(orderStatus: .constant(.cancelled))
        case .cancelled: return PathViewChoice(orderStatus: .constant(.cancelled))
        case .done: return PathViewChoice(orderStatus: .constant(.done))
        case .pickup: return PathViewChoice(orderStatus: .constant(.pickup))
        case .shipmentField: return PathViewChoice(orderStatus: .constant(.shipmentField))
        }
    }
    var title : String {
        switch self {
        case .pending: return "pendingState".localized()
        case .accepted: return "acceptedState".localized()
        case .away: return "awayState".localized()
        case .rejected: return "rejectedState".localized()
        case .cancelled: return "cancelledState".localized()
        case .done: return "doneState".localized()
        case .pickup: return "awayState".localized()
        case .shipmentField: return "shipmentFailedState".localized()
        }
    }
    
}

enum statusPreviewTypes {
    case checked
    case unchecked
    case rejected
    case loading
    
    var color: Color {
        switch self {
        case .checked: return .green026C34
        case .unchecked: return .white
        case .rejected: return .redEE002B
        case .loading: return .green026C34
        }
    }
    var image: UIImage {
        switch self {
        case .checked: return .checkMark
        case .unchecked: return UIImage()
        case .rejected: return UIImage(systemName: "xmark") ?? UIImage()
        case .loading: return .loadingState
        }
    }
    
}

struct CircleView: View {
    @State var statusPreviewType: statusPreviewTypes

    var body: some View {
        
        ZStack {
            Circle()
                .fill(statusPreviewType.color)
                .frame(width: statusPreviewType == .loading ? 45 : 40, height: statusPreviewType == .loading ? 45 : 40)
                .overlay(
                    Circle()
                        .stroke(statusPreviewType == .unchecked ? .grayD1D5DB : .clear , lineWidth: 1)
                )
            Image(uiImage: statusPreviewType.image)
                .renderingMode(.template)
                .foregroundColor(.white)
        }
    }
}

struct ConnectorView: View {
    @State var statusPreviewType: statusPreviewTypes

    var body: some View {
        Rectangle()
            .fill(statusPreviewType == .unchecked ? .grayD1D5DB : statusPreviewType.color)
            .frame(width: .infinity, height: 1) // Adjust width and height as needed
    }
}

struct PathView_Previews: PreviewProvider {
    static var previews: some View {
        PathViewChoice(orderStatus: .constant( orderStatusEnum(rawValue: 6) ?? .pending))
    }
}
