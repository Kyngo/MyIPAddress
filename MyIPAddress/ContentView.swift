//
//  ContentView.swift
//  My IP Address
//
//  Created by Arnau Martín on 14/7/21.
//

import SwiftUI
import Network

struct ContentView: View {
    @State private var ipDetails: IPInfo? = nil
    @State private var error: Bool = false
    @State private var showingMapPrompt: Bool = false
    @State private var connectionType: String = "Unknown";
    
    func loadData() {
        self.error = false
        self.ipDetails = nil
        detectNetworkType()
        guard let url = URL(string: "https://ipinfo.io/json") else {
            print("Invalid URL")
            self.error = true
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(IPInfo.self, from: data) {
                    DispatchQueue.main.async {
                        self.ipDetails = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            self.error = true
        }.resume()
    }
    
    func handleCoords(_ endpoint: String) {
        let targetURL = URL(string: endpoint)!
        let isAvailable = UIApplication.shared.canOpenURL(targetURL)
        if (isAvailable == true) {
            UIApplication.shared.open(targetURL)
        } else {
            print("Could not open the URL? \(endpoint)")
        }
    }
    
    func detectNetworkType() {
        let nwPathMonitor = NWPathMonitor()
        nwPathMonitor.pathUpdateHandler = { path in
            if path.usesInterfaceType( .wifi) {
                self.connectionType = "Wi-Fi";
            } else if path.usesInterfaceType(.cellular) {
                self.connectionType = "Cell Network"
            } else if path.usesInterfaceType(.wiredEthernet) {
                self.connectionType = "Wired Connection"
            } else {
                self.connectionType = "Unknown"
            }
        }
        nwPathMonitor.start(queue: .main)
    }
    
    var body: some View {
        NavigationView {
            List {
                if error == true {
                    Section {
                        Text("Something went wrong getting the details...")
                    }
                    Button(action: {
                        loadData()
                    }) {
                        HStack {
                            Spacer()
                            Text("Try Again")
                            Spacer()
                        }
                    }
                } else {
                    if let ipDetails = ipDetails {
                        Section(header: Text("IP Address")) {
                            Text(ipDetails.ip)
                            Text("Connected via: \(connectionType)")
                        }
                        Section(header: Text("Host Name")) {
                            Text(ipDetails.hostname)
                        }
                        Section(header: Text("Network Provider")) {
                            Text(ipDetails.org)
                        }
                        Section(header: Text("Network-Based Location")) {
                            Text("\(ipDetails.city), \(ipDetails.region) (\(ipDetails.country))")
                            Button("\(ipDetails.loc)") {
                                self.showingMapPrompt = true
                            }
                            .actionSheet(isPresented: $showingMapPrompt) {
                                ActionSheet(title: Text("Open coordinates with..."), buttons: [
                                    .default(Text("Apple Maps")) {
                                        handleCoords("https://maps.apple.com/?q=\(ipDetails.loc)")
                                    },
                                    .default(Text("Google Maps")) {
                                        handleCoords("https://maps.google.com/?q=\(ipDetails.loc)")
                                    },
                                    .cancel(Text("Don't open"))
                                ])
                            }
                            Text("\(ipDetails.timezone)")
                        }
                        Button(action: {
                            loadData()
                        }) {
                            HStack {
                                Spacer()
                                Text("Update")
                                Spacer()
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Retrieving...")
                            Spacer()
                        }
                        
                    }
                }
            }
            .onAppear(perform: loadData)
            .navigationTitle("My IP Address")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
