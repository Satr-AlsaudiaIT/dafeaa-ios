import SwiftUI

struct CalendarSheet: ViewModifier {
    @Binding var presented: Bool
    @Binding var value: String
    @State private var calendarDate = Date()
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                VStack {
                    DatePicker("", selection: $calendarDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .offset(y: presented ? 0 : 250)
            }
        }
        .animation(.default, value: presented)
        .ignoresSafeArea()
        .onChange(of: calendarDate, perform: { _ in
            value = Globals.dateFormatter.string(from: calendarDate)
        })
    }
}

extension View {
    func calendarSheet(presented: Binding<Bool>, value: Binding<String>) -> some View {
        modifier(CalendarSheet(presented: presented, value: value))
    }
}

struct Globals {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()
}
