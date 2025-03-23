//
//  SwiftUIView.swift
//  Dafeaa
//
//  Created by AMNY on 03/11/2024.
//

import SwiftUI


struct PathViewChoice: View {
    @Binding var orderStatus: orderStatusEnum 
    var body: some View {
        ZStack{
            if orderStatus == .pending {
                    ZStack {
                        HStack (spacing: 0) {
                            CircleView(statusPreviewType: .loading)
                            ConnectorView(statusPreviewType: .unchecked)
                            CircleView(statusPreviewType: .unchecked)
                            ConnectorView(statusPreviewType: .unchecked)
                            CircleView(statusPreviewType: .unchecked)
                            ConnectorView(statusPreviewType: .unchecked)
                            CircleView(statusPreviewType: .unchecked)
                        }
                        .padding(.horizontal,10)
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                Text(orderStatus.title)
                                    .textModifier(.plain, 12, .green026C34)
                                    .padding(.leading,4)
                                Spacer()

                            }
                        }
                        .padding(.top , 10)
                    }
                    
                    .frame(height: 85)
            }
            else if orderStatus == .accepted {
                ZStack {
                    HStack (spacing: 0) {
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .loading)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                    }
                    .padding(.horizontal,10)

                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(orderStatus.title)
                                .textModifier(.plain, 12, .green026C34)
                                
                            Spacer()
                            Spacer()

                        }
                    }
                    .padding(.top , 10)

                }
                
                .frame(height: 85)
            }
            else if orderStatus == .away {
                ZStack {
                    HStack (spacing: 0) {
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .loading)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                    }
                    .padding(.horizontal,10)
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Spacer()
                            Spacer()
                            Text(orderStatus.title)
                                .textModifier(.plain, 12, .green026C34)
                            Spacer()

                        }
                    }
                    .padding(.top , 10)

                }
                
                .frame(height: 85)
            }
            else if orderStatus == .rejected {
                ZStack {
                    HStack (spacing: 0) {
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .rejected)
                        CircleView(statusPreviewType: .rejected)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                    }
                    .padding(.horizontal,10)
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            Text(orderStatus.title)
                                .textModifier(.plain, 12, .redEE002B)
                                .padding(.trailing,5)
                            Spacer()
                            Spacer()

                        }
                    }
                    .padding(.top , 10)

                }
                
                .frame(height: 85)
            }
            else if orderStatus == .cancelled {
                ZStack {
                    HStack (spacing: 0) {
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .rejected)
                        CircleView(statusPreviewType: .rejected)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                        ConnectorView(statusPreviewType: .unchecked)
                        CircleView(statusPreviewType: .unchecked)
                    }
                    .padding(.horizontal,10)
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(orderStatus.title)
                                .textModifier(.plain, 12, .redEE002B)
                                .padding(.trailing,5)
                            Spacer()
                            Spacer()

                        }
                    }
                    .padding(.top , 10)

                }
                
                .frame(height: 85)
            }
            else if orderStatus == .done {
                ZStack {
                    HStack (spacing: 0) {
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .checked)
                        ConnectorView(statusPreviewType: .checked)
                        CircleView(statusPreviewType: .checked)
                    }
                    .padding(.horizontal,10)
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(orderStatus.title)
                                .textModifier(.plain, 12, .green026C34)
                                .padding(.trailing,3)
                            

                        }
                    }
                    .padding(.top , 10)

                }
                
                .frame(height: 85)
            }
        }
        
        .padding()
    }
}

enum orderStatusEnum: Int {
    case pending = 1
    case accepted = 2
    case away = 3
    case rejected = 4
    case cancelled = 5
    case done = 6
    
    var pathview: PathViewChoice {
        switch self {
        case .pending: return PathViewChoice(orderStatus: .constant(.pending))
        case .accepted: return PathViewChoice(orderStatus: .constant(.accepted))
        case .away: return PathViewChoice(orderStatus: .constant(.away))
        case .rejected: return PathViewChoice(orderStatus: .constant(.rejected))
        case .cancelled: return PathViewChoice(orderStatus: .constant(.cancelled))
        case .done: return PathViewChoice(orderStatus: .constant(.done))
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
