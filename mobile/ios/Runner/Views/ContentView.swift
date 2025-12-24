import SwiftUI

struct ContentView: View {
    @State private var currentOnboardingPage = 0
    @State private var showOnboarding = true
    
    var body: some View {
        NavigationStack {
            if showOnboarding {
                OnboardingContainerView(currentPage: $currentOnboardingPage) {
                    showOnboarding = false
                }
            } else {
                // Main app content would go here
                VStack {
                    Text("Welcome to the App!")
                        .font(.custom("Poppins-Bold", size: 24))
                        .padding()
                    
                    Button("Show Onboarding Again") {
                        showOnboarding = true
                        currentOnboardingPage = 0
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.86, green: 0.15, blue: 0.15))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct OnboardingContainerView: View {
    @Binding var currentPage: Int
    let onComplete: () -> Void
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingView(
                pageNumber: 0,
                currentPage: $currentPage,
                onButtonTap: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        onComplete()
                    }
                }
            )
            .tag(0)
            
            // Additional onboarding pages would go here
            OnboardingView(
                pageNumber: 1,
                currentPage: $currentPage,
                onButtonTap: {
                    if currentPage < 2 {
                        currentPage += 1
                    } else {
                        onComplete()
                    }
                }
            )
            .tag(1)
            
            OnboardingView(
                pageNumber: 2,
                currentPage: $currentPage,
                onButtonTap: onComplete
            )
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
}

#Preview {
    ContentView()
}
