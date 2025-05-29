
//
//  AddEventView.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI
import AVFoundation

struct AddEventView: View {
    @Bindable var viewModel: AddEventViewModel

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 40) {
                                VStack(spacing: 32) {
                                    TossScheduleHeader(viewModel: viewModel)

                                    if viewModel.currentStep == 1 {
                                        TossStepSection(stepNumber: 1, currentStep: viewModel.currentStep) {
                                            TossDateTimeInput(viewModel: viewModel)
                                        }
                                        .id("step1")
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)
                                        ))
                                    }

                                    if viewModel.currentStep == 2 {
                                        TossStepSection(stepNumber: 2, currentStep: viewModel.currentStep) {
                                            TossTitleInput(viewModel: viewModel)
                                        }
                                        .id("step2")
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)
                                        ))
                                        .onAppear {
                                            viewModel.setTitleFocus()
                                        }
                                    }

                                    if viewModel.currentStep == 3 {
                                        TossStepSection(stepNumber: 3, currentStep: viewModel.currentStep) {
                                            TossNotesInput(viewModel: viewModel)
                                        }
                                        .id("step3")
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)
                                        ))
                                        .onAppear {
                                            viewModel.setNotesFocus()
                                        }
                                    }

                                    if viewModel.currentStep == 4 {
                                        TossStepSection(stepNumber: 4, currentStep: viewModel.currentStep) {
                                            TossAudioInput(viewModel: viewModel)
                                        }
                                        .id("step4")
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)
                                        ))
                                    }
                                }
                                .padding(.top, 20)

                                Spacer(minLength: 300)
                            }
                            .padding(.horizontal, 20)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onChange(of: viewModel.currentStep) { _, newStep in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("step\(newStep)", anchor: .top)
                            }
                        }
                    }
                }

                TossBottomCTA(viewModel: viewModel)
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                Task {
                    await viewModel.requestAudioPermission()
                }
            }
            .alert("마이크 권한이 필요해요", isPresented: $viewModel.audioRecorder.showingPermissionAlert) {
                Button("설정으로 이동") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("나중에", role: .cancel) {}
            } message: {
                Text("음성 메모를 녹음하려면\n마이크 접근 권한을 허용해주세요")
            }
        }
    }
}

// MARK: - Factory Method
extension AddEventView {
    static func create(homeViewModel: HomeVM, coordinator: CalendarCoordinator, selectedDate: Date) -> AddEventView {
        let viewModel = AddEventViewModel(
            homeViewModel: homeViewModel,
            coordinator: coordinator,
            selectedDate: selectedDate
        )
        return AddEventView(viewModel: viewModel)
    }
}

#Preview {
    AddEventView.create(
        homeViewModel: HomeVM(coordinator: HomeCoordinator()),
        coordinator: CalendarCoordinator(),
        selectedDate: Date()
    )
}
