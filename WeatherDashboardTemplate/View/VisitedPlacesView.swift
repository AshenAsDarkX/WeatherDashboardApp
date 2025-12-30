//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
    
    @Environment(\.openURL) var openURL
    
    // MARK:  add local variables for this view
    @Query(sort: \Place.lastUsedAt, order: .reverse) private var visitedPlaces: [Place]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack{
                Text("Visited Places")
                if vm.visited.isEmpty {
                    ContentUnavailableView("No places saved", systemImage: "mappin.slash")
                }
                else{
                    List{
                        ForEach(vm.visited){
                            place in VStack(alignment: .leading){
                                Text(place.name)
                                    .font(.headline)
                                Text("Last used: \(place.lastUsedAt, style: .date)")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Task {
                                    await vm.loadLocation(fromPlace: place)
                                }
                                vm.selectedTab = 0 // Switch to Home Tab
                            }
                        }
                        .onDelete(perform: vm.delete)
                        
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            
        }
        
        
        
        //            VStack{
        //                Text("Image shows the information to be presented in this view")
        //                Spacer()
        //                Image("places")
        //                    .resizable()
        //
        //                Spacer()
        //            }
        //            .frame(height: 600)
    }
}



#Preview {
    // 1. Create an in-memory database for previewing

    let container = ModelContainer.preview
//    
////   Add Dummy Data
    let place1 = Place(name: "Pari", latitude: 48.8566, longitude: 2.3522)
    let place2 = Place(name: "Tunice", latitude: 49.8566, longitude: 2.3622)
    let place3 = Place(name: "Tunice", latitude: 49.8566, longitude: 2.3622)
    let place4 = Place(name: "Tunice", latitude: 49.8566, longitude: 2.3622)
    let place5 = Place(name: "Tunice", latitude: 49.8566, longitude: 2.3622)
    place1.lastUsedAt = Date()
    place2.lastUsedAt = Date().addingTimeInterval(-1000)
    place3.lastUsedAt = Date().addingTimeInterval(-1000)
    place4.lastUsedAt = Date().addingTimeInterval(-1000)
    place5.lastUsedAt = Date().addingTimeInterval(-1000)
    container.mainContext.insert(place1)
    container.mainContext.insert(place2)
    container.mainContext.insert(place3)
    container.mainContext.insert(place4)
    container.mainContext.insert(place5)
    
    
    // 3. Create ViewModel with this context
    let vm = MainAppViewModel(context: container.mainContext)
    
    return VisitedPlacesView()
        .environmentObject(vm)
        .modelContainer(container)
//    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
//    VisitedPlacesView()
//        .environmentObject(vm)
}
