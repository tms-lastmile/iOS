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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(deliveryOrder.deliveryOrderNum)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Tap untuk lihat / sembunyikan box")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Button(action: onSaveBoxesTapped) {
                            Image(systemName: "tray.and.arrow.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                        Text("Simpan")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }

                    VStack(spacing: 4) {
                        Button(action: onAddBoxTapped) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        Text("Tambah")
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct BoxCardView: View {
    let box: Box
    var onDeleteTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(box.name)
                    .font(.headline)
                
                Spacer()
                
                if box.isNew {
                    Label("Belum tersimpan", systemImage: "clock.fill")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }

            Text(String(format: "Ukuran: %.2f cm × %.2f cm × %.2f cm", box.length, box.width, box.height))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Jumlah: \(box.quantity)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                BoxActionButton(
                    icon: "trash",
                    color: .red,
                    label: "Hapus",
                    action: onDeleteTapped
                )
                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 3)
    }
}

struct BoxActionButton: View {
    let icon: String
    let color: Color
    let label: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
            }

            Text(label)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}
