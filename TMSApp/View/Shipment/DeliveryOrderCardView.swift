//
//  DeliveryOrderCardView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 12/03/25.
//

import SwiftUI

struct DeliveryOrderCardView: View {
    let deliveryOrder: DeliveryOrder
    var isExpanded: Bool
    var onAddBoxTapped: () -> Void
    var onToggle: () -> Void
    var onSaveBoxesTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                
                Text(deliveryOrder.deliveryOrderNum)
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()

                Button(action: onSaveBoxesTapped) {
                    Image(systemName: "tray.and.arrow.down")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange)
                        .clipShape(Circle())
                }

                Button(action: onAddBoxTapped) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.green)
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

struct BoxCardView: View {
    let box: Box
    var onScanTapped: () -> Void
    var onDeleteTapped: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Box ID: \(box.id)")
                    .font(.subheadline)
                Text("Dimensi: \(box.length) x \(box.width) x \(box.height)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onScanTapped) {
                    Image(systemName: "camera.viewfinder")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                Button(action: onDeleteTapped) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(box.isSaved ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    DeliveryOrderCardView(
        deliveryOrder: DeliveryOrder(
            id: 1,
            deliveryOrderNum: "DO-987654",
            boxes: []
        ),
        isExpanded: false,
        onAddBoxTapped: {
            print("Box ditambahkan")
        },
        onToggle: {
            print("Toggle")
        },
        onSaveBoxesTapped: {
            print("Box disimpan")
        }
    )
}
