import Photos
import PhotosUI
import SwiftUI
import UIKit

private enum ProfilePhotoReadError: Error {
    case unavailable
}

struct EditProfileDraft {
    let name: String
    let email: String
    let image: String?
}

struct EditProfileScreen: View {
    let user: AuthUser?
    let onSave: (EditProfileDraft) async throws -> AuthUser
    let onUploadProfileImage: (ProfileImageUploadDraft) async throws -> String
    let onDiscard: () -> Void

    @Environment(\.i18n) private var i18n
    @State private var fullName: String
    @State private var email: String
    @State private var profileImageURL: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedAvatarData: Data?
    @State private var errorText: String?
    @State private var photoErrorText: String?
    @State private var isSaving = false
    @State private var isUploadingPhoto = false

    init(
        user: AuthUser?,
        onSave: @escaping (EditProfileDraft) async throws -> AuthUser,
        onUploadProfileImage: @escaping (ProfileImageUploadDraft) async throws -> String,
        onDiscard: @escaping () -> Void
    ) {
        self.user = user
        self.onSave = onSave
        self.onUploadProfileImage = onUploadProfileImage
        self.onDiscard = onDiscard
        _fullName = State(initialValue: Self.displayName(for: user))
        _email = State(initialValue: user?.email ?? "")
        _profileImageURL = State(initialValue: user?.image)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
                    identityCard
                    securitySection
                    if let errorText {
                        WITipInfo(
                            title: i18n.t(.profile.edit.errors.profileNotSaved),
                            bodyText: errorText,
                            size: .small,
                            tone: .danger,
                            onDismiss: { self.errorText = nil }
                        )
                        .task(id: errorText) {
                            try? await Task.sleep(for: .seconds(3))
                            guard !Task.isCancelled else { return }
                            await MainActor.run {
                                self.errorText = nil
                            }
                        }
                    }
                    actionStack
                }
                .padding(.horizontal, WorthItSpacing.xl)
                .padding(.top, WorthItSpacing.xxxl)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack(alignment: .top) {
                WorthItColor.surfaceLowest.ignoresSafeArea()
                Circle()
                    .fill(WorthItColor.surfaceContainerHigh.opacity(0.34))
                    .frame(width: 180, height: 180)
                    .blur(radius: 80)
                .offset(y: -120)
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task { await uploadSelectedPhoto(item) }
        }
    }

    private var topBar: some View {
        ZStack {
            Text(i18n.t(.profile.edit.title))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            HStack {
                Button(action: onDiscard) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(i18n.t(.profile.edit.accessibility.back))

                Spacer()
            }
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.m)
        .background(WorthItColor.surfaceLowest.opacity(0.92))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)
        }
    }

    private var identityCard: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            VStack(spacing: WorthItSpacing.m) {
                editableAvatar

                if let photoErrorText {
                    photoError(photoErrorText)
                }
            }

            VStack(spacing: WorthItSpacing.xl) {
                AccountProfileField(
                    label: i18n.t(.profile.edit.fields.fullName.label),
                    text: $fullName,
                    systemName: "person"
                )

                AccountProfileField(
                    label: i18n.t(.profile.edit.fields.email.label),
                    text: $email,
                    systemName: "envelope",
                    keyboardType: .emailAddress
                )
            }
        }
        .padding(.horizontal, WorthItSpacing.xxl)
        .padding(.top, WorthItSpacing.xxl)
        .padding(.bottom, WorthItSpacing.xxl)
        .frame(maxWidth: .infinity)
        .background {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .fill(WorthItColor.surfaceIsland)

                Circle()
                    .fill(Color(hex: 0xD8E2FF).opacity(0.10))
                    .frame(width: 192, height: 192)
                    .blur(radius: 32)
                    .offset(x: 96, y: -96)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineInput, lineWidth: 1)
        }
        .shadow(color: Color(hex: 0xD8E2FF).opacity(0.05), radius: 40)
    }

    private var editableAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarImage

            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                preferredItemEncoding: .current
            ) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: 0x122F5F))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: 0xD8E2FF), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(WorthItColor.surfaceContainerLow, lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.20), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(isUploadingPhoto || isSaving)
            .simultaneousGesture(TapGesture().onEnded { photoErrorText = nil })
            .accessibilityLabel(i18n.t(.profile.edit.accessibility.changePhoto))
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        ZStack {
            if let selectedAvatarData, let uiImage = UIImage(data: selectedAvatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let profileImageURL,
                      let url = URL(string: profileImageURL),
                      url.scheme == "http" || url.scheme == "https" {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        initialsAvatar
                    }
                }
            } else {
                initialsAvatar
            }

            if isUploadingPhoto {
                Circle()
                    .fill(WorthItColor.surfaceLowest.opacity(0.58))
                ProgressView()
                    .tint(WorthItColor.primaryContainer)
            }
        }
        .frame(width: 112, height: 112)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(WorthItColor.outlineInput, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }

    private var initialsAvatar: some View {
        Text(initials)
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(WorthItColor.primaryContainer)
            .frame(width: 112, height: 112)
            .background(WorthItColor.surfaceContainerHigh, in: Circle())
    }

    private func photoError(_ text: String) -> some View {
        HStack(alignment: .top, spacing: WorthItSpacing.s) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: 0xFFB4AB))

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0xFFB4AB))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, WorthItSpacing.m)
        .padding(.vertical, WorthItSpacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFB4AB).opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(Color(hex: 0xFFB4AB).opacity(0.22), lineWidth: 1)
        }
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(i18n.t(.profile.edit.sections.securityLinkedAccounts))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.80))
                .tracking(1.2)
                .padding(.horizontal, WorthItSpacing.l)

            VStack(spacing: 0) {
                AccountInfoRow(
                    title: i18n.t(.profile.edit.rows.accountStatus),
                    value: i18n.t(.profile.edit.values.verified),
                    systemName: "shield.checkered",
                    valueColor: WorthItColor.accentGold
                )

                Divider()
                    .overlay(WorthItColor.outlineInput)
                    .padding(.leading, 72)

                AccountInfoRow(
                    title: i18n.t(.profile.edit.rows.linkedIdentity),
                    value: linkedIdentity,
                    systemName: "link"
                )
            }
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.16), radius: 18, y: 4)
        }
    }

    private var actionStack: some View {
        VStack(spacing: WorthItSpacing.m) {
            WIButton(title: i18n.t(.profile.edit.actions.saveChanges), height: 56) {
                save()
            }
            .opacity(isSaving || isUploadingPhoto ? 0.62 : 1)
            .allowsHitTesting(!isSaving && !isUploadingPhoto)

            WIButton(title: i18n.t(.profile.edit.actions.discard), style: .outline, height: 56, action: onDiscard)
        }
        .padding(.top, WorthItSpacing.xxxl)
    }

    private var initials: String {
        let parts = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        let value = String(parts).uppercased()
        return value.isEmpty ? "WI" : value
    }

    private var linkedIdentity: String {
        email.isEmpty ? i18n.t(.profile.edit.values.appleId) : i18n.t(.profile.edit.values.email)
    }

    private func save() {
        guard user != nil else { return }

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorText = i18n.t(.profile.edit.errors.nameEmpty)
            return
        }

        guard trimmedEmail.contains("@") else {
            errorText = i18n.t(.profile.edit.errors.invalidEmail)
            return
        }

        isSaving = true
        errorText = nil

        Task {
            do {
                _ = try await onSave(EditProfileDraft(
                    name: trimmedName,
                    email: trimmedEmail,
                    image: profileImageURL
                ))
            } catch {
                errorText = profileSaveErrorText(error)
            }

            isSaving = false
        }
    }

    private func uploadSelectedPhoto(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        photoErrorText = nil

        do {
            let photoData = try await loadPhotoData(from: item)

            guard let jpegData = Self.jpegProfileImageData(from: photoData) else {
                photoErrorText = "Could not prepare this photo. Try another image."
                isUploadingPhoto = false
                selectedPhotoItem = nil
                return
            }

            selectedAvatarData = jpegData
            profileImageURL = try await onUploadProfileImage(
                ProfileImageUploadDraft(
                    data: jpegData,
                    fileName: "profile-\(UUID().uuidString).jpg",
                    contentType: "image/jpeg"
                )
            )
        } catch {
            #if DEBUG
            print("Profile image upload failed:", String(describing: error))
            #endif
            photoErrorText = photoUploadErrorText(error)
        }

        isUploadingPhoto = false
        selectedPhotoItem = nil
    }

    private func loadPhotoData(from item: PhotosPickerItem) async throws -> Data {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                return data
            }
        } catch {
            #if DEBUG
            print(
                "Profile image primary PhotosPicker read failed, trying PHAsset fallback:",
                "itemIdentifier=\(item.itemIdentifier ?? "nil")",
                String(describing: error)
            )
            #endif

            guard let fallbackData = try await Self.loadPhotoAssetData(localIdentifier: item.itemIdentifier) else {
                throw error
            }

            return fallbackData
        }

        guard let fallbackData = try await Self.loadPhotoAssetData(localIdentifier: item.itemIdentifier) else {
            throw ProfilePhotoReadError.unavailable
        }

        return fallbackData
    }

    private static func jpegProfileImageData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.82)
    }

    private static func loadPhotoAssetData(localIdentifier: String?) async throws -> Data? {
        guard let localIdentifier else { return nil }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = assets.firstObject else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        options.version = .current

        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false

            let resumeOnce: (Result<Data?, Error>) -> Void = { result in
                guard !didResume else { return }
                didResume = true

                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, info in
                if (info?[PHImageResultIsDegradedKey] as? Bool) == true {
                    return
                }

                if let error = info?[PHImageErrorKey] as? Error {
                    resumeOnce(.failure(error))
                    return
                }

                if (info?[PHImageCancelledKey] as? Bool) == true {
                    resumeOnce(.success(nil))
                    return
                }

                resumeOnce(.success(data))
            }
        }
    }

    private func photoUploadErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(let statusCode, let body) = error {
            if statusCode == 413 || body.contains("PROFILE_IMAGE_TOO_LARGE") {
                return "Photo is too large. Try a smaller image."
            }

            if statusCode == 422 {
                return "This image format is not supported. Try another photo."
            }

            if statusCode == 404 {
                return "Photo upload is not available yet. Restart the app backend and try again."
            }

            if statusCode == 401 {
                return "Your session expired. Sign in again, then retry photo upload."
            }

            if statusCode == 403 {
                return "You do not have access to update this profile photo."
            }

            if statusCode >= 500 {
                return "Photo upload service failed. Try again in a moment."
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotConnectToHost, .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return "Could not reach photo upload service. Check connection and try again."
            default:
                return "Could not upload this photo. Try again in a moment."
            }
        }

        if error is DecodingError {
            return "Photo upload response was not readable. Restart the app and try again."
        }

        if case ProfilePhotoReadError.unavailable = error {
            return "Could not read this photo. Try another image."
        }

        if isPhotosReadError(error) {
            return "Could not read this photo from iCloud Photos. Open it in Photos first, then try again."
        }

        return "Could not upload this photo. Try again in a moment."
    }

    private func isPhotosReadError(_ error: Error) -> Bool {
        var currentError: NSError? = error as NSError

        while let nsError = currentError {
            let combinedText = [
                nsError.domain,
                nsError.localizedDescription,
                "\(nsError.code)",
            ].joined(separator: " ")

            if combinedText.contains("NSItemProviderErrorDomain") ||
                combinedText.contains(NSItemProvider.errorDomain) ||
                combinedText.contains("PHAssetExportRequestErrorDomain") ||
                combinedText.contains("CloudPhotoLibraryErrorDomain") ||
                combinedText.contains("Cannot load representation") ||
                combinedText.contains("helper application") {
                return true
            }

            currentError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
        }

        return false
    }

    private func profileSaveErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(let statusCode, let body) = error {
            if statusCode == 409 || body.contains("EMAIL_ALREADY_IN_USE") {
                return i18n.t(.profile.edit.errors.emailInUse)
            }
        }

        return WIUpdateErrorText.message(
            for: error,
            fallback: i18n.t(.profile.edit.errors.backendUnreachable)
        )
    }

    private static func displayName(for user: AuthUser?) -> String {
        let trimmedName = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedName.isEmpty ? I18n(localeIdentifier: "en").t(.profile.view.fallback.user) : trimmedName
    }
}

private struct AccountProfileField: View {
    let label: String
    @Binding var text: String
    let systemName: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            fieldLabel(label)
                .tracking(0.6)
                .textCase(.uppercase)
                .padding(.horizontal, WorthItSpacing.xs)

            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .frame(width: 18)

                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .textContentType(keyboardType == .emailAddress ? .emailAddress : .name)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 54)
            .background(WorthItColor.surfaceLowest.opacity(0.50), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}

private struct AccountInfoRow: View {
    let title: String
    let value: String
    let systemName: String
    var valueColor: Color = WorthItColor.textSecondary

    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 40, height: 40)
                .background(WorthItColor.surfaceContainer.opacity(0.52), in: Circle())

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(WorthItColor.textPrimary)

            Spacer(minLength: WorthItSpacing.m)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(minHeight: 72)
        .padding(.horizontal, WorthItSpacing.l)
    }
}

#Preview {
    EditProfileScreen(
        user: AuthUser(id: UUID(), name: "Ilya Brusenko", email: "ilya@example.com", image: nil),
        onSave: { _ in AuthUser(id: UUID(), name: "Ilya Brusenko", email: "ilya@example.com", image: nil) },
        onUploadProfileImage: { _ in "local://preview" },
        onDiscard: {}
    )
}
