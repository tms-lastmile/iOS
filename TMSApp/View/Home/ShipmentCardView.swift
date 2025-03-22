//
//  ShipmentCardView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct ShipmentCardView: View {
    
    let shipment: ShipmentSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(shipment.shipmentNum)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
            }
            
            Text("Status: \(shipment.status)")
                .font(.subheadline)
                .foregroundColor(statusColor)
                .bold()
            
            Text("ETA: \(shipment.eta ?? "N/A")")
                .font(.footnote)
                .foregroundColor(.blue)
            
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var statusColor: Color {
        switch shipment.status {
        case "RUNNING": return .blue
        case "DRAF": return .gray
        default: return .black
        }
    }
    
    private var statusIcon: String {
        switch shipment.status {
        case "RUNNING": return "clock.arrow.circlepath"
        case "DRAF": return "doc.fill"
        default: return "questionmark.circle.fill"
        }
    }
}


#Preview {
    ShipmentCardView(
        shipment: ShipmentSummary(
            id: 1,
            shipmentNum: "SHIP123456",
            status: "RUNNING",
            eta: nil
        )
    )
}
