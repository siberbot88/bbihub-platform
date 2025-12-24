import SwiftUI

struct OnboardingView: View {
    let pageNumber: Int
    @Binding var currentPage: Int
    let onButtonTap: () -> Void

    private var pageData: OnboardingPage {
        OnboardingData.pages[pageNumber]
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Background blob shape
                    ZStack {
                        // Red blob background
                        BlobShape()
                            .fill(Color(red: 0.86, green: 0.15, blue: 0.15))
                            .frame(width: geometry.size.width * 0.95, height: 346)
                            .offset(x: 20, y: -40)
                        
                        // Main illustration
                        AsyncImage(url: URL(string: pageData.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 380, height: 380)
                        .padding(.top, 40)
                    }
                    .frame(height: 450)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Content section
                    VStack(spacing: 31) {
                        VStack(spacing: 22) {
                            // Title
                            Text(pageData.title)
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(Color(red: 0.14, green: 0.14, blue: 0.14))
                                .multilineTextAlignment(.center)
                            
                            // Description
                            Text(pageData.description)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color(red: 0.14, green: 0.14, blue: 0.14))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                        
                        // Page indicators
                        HStack(spacing: 11) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color(red: 0.86, green: 0.15, blue: 0.15) : Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .padding(.horizontal, 35)
                    
                    Spacer()
                        .frame(height: 64)
                    
                    // Start button
                    Button(action: onButtonTap) {
                        Text(pageData.buttonText)
                            .font(.custom("Poppins-Bold", size: 15))
                            .foregroundColor(.white)
                            .frame(width: 287, height: 48)
                            .background(Color(red: 0.86, green: 0.15, blue: 0.15))
                            .cornerRadius(24)
                    }
                    .padding(.horizontal, 58)
                    
                    Spacer()
                        .frame(height: 61)
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        // Creating a blob-like shape based on the design
        path.move(to: CGPoint(x: width * 0.38, y: height * 0.39))
        
        // Curved blob shape approximating the design
        path.addQuadCurve(
            to: CGPoint(x: width * 0.73, y: height * 0.35),
            control: CGPoint(x: width * 0.55, y: height * 0.20)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 1.0, y: height * 0.02),
            control: CGPoint(x: width * 0.78, y: height * -0.08)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 1.0, y: height * 0.84),
            control: CGPoint(x: width * 1.31, y: height * 0.15)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.05, y: height * 0.91),
            control: CGPoint(x: width * 1.0, y: height * 0.97)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.03, y: height * 0.41),
            control: CGPoint(x: width * -0.08, y: height * 0.75)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.38, y: height * 0.39),
            control: CGPoint(x: width * 0.03, y: height * 0.41)
        )
        
        return path
    }
}

#Preview {
    OnboardingView()
}
