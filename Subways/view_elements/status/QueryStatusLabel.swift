//
//  QueryStatusLabel.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/28/24.
//

import SwiftUI

struct QueryStatusLabel: View {
    @Binding var queryStatus: ArrivalQueryStatus
    
    var body: some View {
        VStack {
            switch(queryStatus) {
            case .SUCCESS, .CANCELLED:
                EmptyView()
            case .FAILURE:
                Label("Issue retrieving data", systemImage: "wifi.exclamationmark")
                    .labelStyle(.titleAndIcon)
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
            case .NO_INTERNET:
                Label("No network connection", systemImage: "wifi.slash")
                    .labelStyle(.titleAndIcon)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)))
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var queryStatus: ArrivalQueryStatus
        var body: some View {
            QueryStatusLabel(queryStatus: $queryStatus)
        }
    }
    
    return VStack {
        Text("Success")
        Preview(queryStatus: .SUCCESS)
        Divider()
        Text("Cancelled")
        Preview(queryStatus: .CANCELLED)
        Divider()
        Text("No internet")
        Preview(queryStatus: .NO_INTERNET)
        Divider()
        Text("Failure")
        Preview(queryStatus: .FAILURE)
    }
}
