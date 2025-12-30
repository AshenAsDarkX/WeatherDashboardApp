//
//  NavBarView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
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
                // 🌤 Tabs
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
                    // 🔍 Search Bar
                    // MARK: - Search Bar
                    // Screenshot shows "Change Location" at the top
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                        TextField("Change Location", text: $vm.query)
                            .foregroundColor(.white)
                            .onSubmit {
                                // TODO: Call your ViewModel's search function here
                                //                             Task { await vm.searchLocation(name: searchText) }
                                vm.search()
                                
                            }
                        
                    }
                    .padding(12) 
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding(.horizontal, 10)
                    .padding(.top , 5)
                    
                    .alert("Storage info", isPresented: $vm.showStorageAlert){
                        Button("Ok", role: .cancel){}
                    } message: {
                        Text(vm.storageAlertMessage)
                    }
                    
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
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

//#Preview("Full Dashboard") {
//    // 👇 This creates a mock ModelContext using your in-memory preview container
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//
//    // 👇 This displays *all* your tab content at once
//    NavBarView()
//        .environmentObject(vm)
//}
//
