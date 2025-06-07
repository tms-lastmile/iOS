//
//  BoxView.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 04/05/25.
//

import SwiftUI

struct BoxView: View {
    @StateObject private var viewModel = BoxViewModel()
    var refreshTrigger: Bool
    @State private var isShowingAddBoxForm = false
    @State private var newBoxName: String = ""
    @State private var isShowingScanner = false
    @State private var scannerBoxName: String = ""
    @State private var isShowingInfo = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Memuat daftar box...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else if viewModel.boxes.isEmpty {
                    Spacer()
                    Text("Tidak ada box yang ditemukan")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    List(viewModel.boxes, id: \.id) { box in
                        ListBoxCardView(
                            box: box,
                            onCalculateTapped: {
                                viewModel.calculateVolume(for: box.id)
                            }
                        )
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchBoxes()
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 100)
                    }
                }
            }
            .navigationTitle("Box")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingInfo = true
                    }) {
                        Image(systemName: "lightbulb.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.yellow, .orange)
                            .font(.system(size: 20))
                            .padding(6)
                    }
                }
            }
            .onChange(of: refreshTrigger) {
                viewModel.fetchBoxes()
            }
            .onAppear {
                if viewModel.boxes.isEmpty {
                    viewModel.fetchBoxes()
                }
            }
            .overlay {
                Group {
                    if viewModel.isUploading {
                        ToastView(message: "Mengunggah file...")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    viewModel.isUploading = false
                                }
                            }
                    }

                    if viewModel.isCalculating {
                        ToastView(message: "Menghitung volume...")
                    }

                    if viewModel.uploadSuccess != nil {
                        ToastView(message: viewModel.uploadMessage)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    viewModel.uploadSuccess = nil
                                }
                            }
                    }
                }
            }
            .alert("Informasi", isPresented: $isShowingInfo, actions: {
                Button("Tutup", role: .cancel) {}
            }, message: {
                Text("Beberapa box mungkin masih dalam proses perhitungan dimensi secara asinkron. Silakan tarik ke bawah untuk menyegarkan daftar.")
            })
            .alert("Tambah Box Baru", isPresented: $isShowingAddBoxForm, actions: {
                TextField("Nama Box", text: $newBoxName)

                Button("Batal", role: .cancel) {
                    newBoxName = ""
                }

                Button("Scan & Simpan") {
                    scannerBoxName = newBoxName
                    viewModel.addNewBox(name: newBoxName)
                    isShowingScanner = true
                    isShowingAddBoxForm = false
                    newBoxName = ""
                }
            }, message: {
                Text("Masukkan nama box yang ingin ditambahkan lalu lakukan scan.")
            })
            .fullScreenCover(isPresented: $isShowingScanner) {
                ScannerWrapper(onDone: { path in
                    DispatchQueue.main.async {
                        isShowingScanner = false
                        viewModel.uploadPlyFile(forDirectory: path)
                    }
                })
                .edgesIgnoringSafeArea(.all)
            }
            .overlay {
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isShowingAddBoxForm = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                    }
                    
                    VStack {
                        if viewModel.isUploading {
                            ToastView(message: "Mengunggah file...")
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        viewModel.isUploading = false
                                    }
                                }
                        }

                        if viewModel.isCalculating {
                            ToastView(message: "Menghitung volume...")
                        }

                        if viewModel.uploadSuccess != nil {
                            ToastView(message: viewModel.uploadMessage)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        viewModel.uploadSuccess = nil
                                    }
                                }
                        }
                    }
                }
            }

        }
    }
}
