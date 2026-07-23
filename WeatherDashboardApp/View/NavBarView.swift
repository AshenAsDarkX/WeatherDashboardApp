//
//  NavBarView.swift
//  WeatherDashboardTemplate
//
//  Created by ashen himeshana.
//

import SwiftUI
import SwiftData

struct NavBarView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        ZStack(alignment: .top){
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                // Tab Selection Logic
                TabView(selection: $vm.selectedTab) {
                    CurrentWeatherView()
                        .tabItem { Label("Now", systemImage: "sun.max.fill") }
                        .tag(0)
                    
                    ForecastView()
                        .tabItem { Label("Forecast", systemImage: "calendar") }
                        .tag(1)
                    
                    MapView()
                        .tabItem { Label("Map", systemImage: "map") }
                        .tag(2)
                    
                    VisitedPlacesView()
                        .tabItem { Label("Saved", systemImage: "globe") }
                        .tag(3)
                }
                .accentColor(.blue)
                
                HStack(spacing: 0) {
                    // Floating Search Bar at the Top
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                        TextField("Change Location", text: $vm.query)
                            .foregroundColor(.white)
                            .onSubmit {
                                // Trigger search in VM
                                vm.search()
                                
                            }
                        
                    }
                    .padding(12) 
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding(.horizontal, 10)
                    .padding(.top , 5)
                    
                    // Alert for "Loaded from Storage"
                    .alert("Storage info", isPresented: $vm.showStorageAlert){
                        Button("Ok", role: .cancel){}
                    } message: {
                        Text(vm.storageAlertMessage)
                    }
                    
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
                
                // General App Error Alert (Network, etc.)
                .alert(item: $vm.appError) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}



#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}
