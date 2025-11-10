import SwiftUI

struct ContentView: View {
    @State private var notificationType: String = "ZaloPay"
    @State private var zaloPayTemplate: String = "Giao dịch"
    
    // ZaloPay Transaction Fields
    @State private var title: String = "155"
    @State private var message: String = "Quy khach da duoc thanh toan 100000 VND"
    @State private var amount: String = "100000"
    @State private var accountNumber: String = "4300540025"
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var transactionId: String = "251110676604164"
    @State private var referenceNumber: String = "18008098"
    @State private var note: String = "Tran trong"
    
    // ZaloPay Promotion Fields
    @State private var promoTitle: String = "💥 ZaloPay Tặng Quà Tri Ân – Vào Nhận Ngay 1 Triệu Tiền Mặt!"
    @State private var promoMessage: String = "Chúc mừng bạn đã nhận được 1,000,000đ từ ZaloPay"
    @State private var promoAmount: String = "1000000"
    
    // MB Bank Fields
    @State private var mbAccount: String = ""
    @State private var mbAmount: String = ""
    @State private var mbService: String = ""
    @State private var mbNote: String = ""
    
    @State private var showUpdateAlert = false

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Text("Tạo Thông Báo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    // Picker chọn loại thông báo
                    Picker("Loại thông báo", selection: $notificationType) {
                        Text("ZaloPay").tag("ZaloPay")
                        Text("MB Bank").tag("MBBank")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    VStack(spacing: 15) {
                        if notificationType == "ZaloPay" {
                            // ZaloPay Template Picker
                            Picker("Loại thông báo ZaloPay", selection: $zaloPayTemplate) {
                                Text("Giao dịch").tag("Giao dịch")
                                Text("Khuyến mãi/Quà tặng").tag("Khuyến mãi")