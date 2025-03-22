//
//  DeliveryOrderCardView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct DeliveryOrderCardView: View {
    let deliveryOrder: DeliveryOrder
    var onScanTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(deliveryOrder.deliveryOrderNum)")
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()

                Button(action: onScanTapped) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

#Preview {
    DeliveryOrderCardView(
        deliveryOrder: DeliveryOrder(
            id: 1,
            deliveryOrderNum: "DO-987654"
        )
    ) {
        print("Scan tapped")
    }
}
