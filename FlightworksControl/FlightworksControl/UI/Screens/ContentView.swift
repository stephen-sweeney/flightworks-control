//
//  ContentView.swift
//  FlightworksControl
//
//  Created by Stephen Sweeney on 1/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            
            Text("Flightworks Control")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Phase 0: Foundation")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("SwiftVector Architecture")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
