import SwiftUI

struct ServerSettingsView: View {

    @AppStorage(Constants.Server.UserDefaultsKey) var serverSettings: ServerSettings = ServerSettings()
    @FocusState private var focusedField: FormField?

    var body: some View {

        ScrollView {
            
            VStack {

                Text("Server settings")
                    .fontWeight(.heavy)
                    .font(.largeTitle)
                    .padding([.top, .bottom], 20)

                schemeView
                    .padding(.bottom, 15)

                Divider()

                inputField(
                    title: "Host:",
                    prompt: "Enter Host",
                    inputBinding: $serverSettings.host,
                    inputKind: .text(textContentType: .URL, keyboardType: .URL),
                    field: .host
                )
                .padding(.bottom, 15)

                Divider()

                inputField(
                    title: "Port:",
                    prompt: "Enter Port",
                    inputBinding: Binding(
                        get: { serverSettings.port.map(String.init) ?? "" },
                        set: { serverSettings.port = Int($0) }),
                    inputKind: .text(textContentType: nil, keyboardType: .numberPad),
                    field: .port
                )
                .padding(.bottom, 15)

                Divider()

                inputField(
                    title: "Root path segment:",
                    prompt: "Enter remote API's root path segment",
                    inputBinding: $serverSettings.rootSegment,
                    inputKind: .text(textContentType: .URL, keyboardType: .namePhonePad),
                    field: .rootSegment
                )
                .padding(.bottom, 15)
            }

            Spacer()
        }
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .textFieldStyle(.roundedBorder)
        .padding()
        .formNavigationHarness(self)
        .embedInNavViewWithoutToolbar

        Spacer()
    }

    @ViewBuilder
    var schemeView: some View {

        VStack(alignment: .leading) {

            Text("Scheme:")
                .font(.headline)
                .fontWeight(.light)
                .foregroundColor(Color(.label).opacity(0.75))

            HStack {

                Picker(selection: $serverSettings.scheme, label: Text("Enter remote API's server scheme")) {
                    Text(URLScheme.http.rawValue).tag(URLScheme.http)
                    Text(URLScheme.https.rawValue).tag(URLScheme.https)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)

                Spacer()
            }

            .textContentType(.URL)
            .keyboardType(.URL)
        }
    }
}

extension ServerSettingsView: FormNavigatableView {

    enum FormField: NavigatableFormFieldEnum {
        case host, port, rootSegment
    }

    var focusedFieldFocusState: FocusState<FormField?> { _focusedField }
    var focusedFieldFocusStateBinding: FocusState<FormField?>.Binding { $focusedField }
}
