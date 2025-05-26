//
//  CameraScanSheet.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 5/25/25.
//
import SwiftUI
import Foundation
import AVFoundation
import UIKit
import Observation


// MARK: - CameraScanSheet
struct CameraScanSheet: View {
    @Environment(TaskViewModel.self) var taskViewModel
    @Binding var showScanner: Bool
    @Binding var isProcessing: Bool
    @Binding var resultText: String?
    var onCapture: (UIImage) -> Void
    @State var selectedGroup: String = ""
    @Binding var showNewGroupSheet: Bool
    @State var showingParseAlert = false

    @State private var camera = CameraController()
    @State private var currentFrame: UIImage?
    /// Holds the captured frame so we can freeze the preview.
    @State private var frozenImage: UIImage? = nil
    /// Animation namespace for preview ↔︎ frozen image morph
    @Namespace private var cameraAnim

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            resetState()
                            withAnimation(.spring) { showScanner = false }
                        }) {
                            Text("Cancel")
                                .font(.system(size: 17))
                        }

                        Spacer()
 
                        Button(action: {
                            taskViewModel.commitDraftTasks()
                            resetState()
                            withAnimation(.spring) { showScanner = false }
                        }) {
                            Text("Add")
                                .font(.system(size: 17).bold())
                        }
                        .disabled(!hasParsedTasks)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 10)
                                        
                    /*
                    if resultText != nil {
                        HStack {
                            Text("Group:")
                                .font(.system(size: 17, weight: .bold))
                                .padding(.leading, 20)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(taskViewModel.groups), id: \.key) { key, value in
                                        GroupBar(group: key,
                                                 color: value,
                                                 selectedGroup: selectedGroup) { _ in
                                            // toggle selection exactly like AddTaskView
                                            if selectedGroup == key {
                                                selectedGroup = ""
                                            } else {
                                                selectedGroup = key
                                            }
                                        }
                                    }
                                    /*
                                    Button(action: {                 // “Add Group / Edit” chip
                                        showNewGroupSheet = true
                                    }) {
                                        Text(taskViewModel.groups.isEmpty ? "Add Group" : "Edit")
                                            .padding(.bottom, 2)
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 17, weight: .semibold))
                                            .frame(width: taskViewModel.groups.isEmpty ? 110 : 60,
                                                   height: 34)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.gray)
                                                    .opacity(0.2)
                                                    .shadow(color: .black.opacity(0.5),
                                                            radius: 2, x: 0, y: 2)
                                            )
                                            .opacity(0.7)
                                    }
                                     */
                                }
                                .padding(.bottom, 4)
                                .padding(.trailing, 20)
                                .padding(.leading, 5)
                            }
                            .padding(.top, 6)
                            .onAppear {
                                UIScrollView.appearance().bounces = true
                            }
                            .onDisappear {
                                UIScrollView.appearance().bounces = false
                            }
                        }
                        .padding(.bottom, 10)
                        
                    }
                     */
                    
                    if frozenImage == nil {
                        
                        Text("Take a picture of your schedule or notes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.gray)
                            .font(.system(size: 13))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)

                    }

                    Group {
                        if let frozen = frozenImage {
                            

                        } else {
                            
                            CameraPreview(camera: camera)
                                .matchedGeometryEffect(id: "cameraFrame", in: cameraAnim)
                                .aspectRatio(4/3, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                    }
                    
                    if let _ = frozenImage {
                        if isProcessing {
                            Spacer()
                            VStack {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("  Importing...")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 13))
                            }
                        } else if let result = resultText {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(taskViewModel.draftTasks.indices, id: \.self) { idx in
                                        VStack(alignment: .leading, spacing: 6) {

                                            // ── Title ─────────────────────────────
                                            TextField(
                                                "Title",
                                                text: Binding(
                                                    get: {
                                                        guard idx < taskViewModel.draftTasks.count else { return "" }
                                                        return taskViewModel.draftTasks[idx].title
                                                    },
                                                    set: { newValue in
                                                        guard idx < taskViewModel.draftTasks.count else { return }
                                                        taskViewModel.draftTasks[idx].title = newValue
                                                    }
                                                )
                                            )
                                            .font(.system(size: 20, weight: .semibold))
                                            // ── Per-task group picker ─────────────────────────
                                            HStack {
                                                Text("Group")                 .font(.system(size: 17).weight(.semibold))
                                                    .foregroundStyle(Color(red: 0.13, green: 0.13, blue: 0.15))
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 8) {
                                                        ForEach(Array(taskViewModel.groups), id: \.key) { key, color in
                                                            GroupBar(
                                                                group: key,
                                                                color: color,
                                                                selectedGroup: {
                                                                    guard idx < taskViewModel.draftTasks.count else { return "" }
                                                                    return taskViewModel.draftTasks[idx].group
                                                                }()
                                                            ) { _ in
                                                                guard idx < taskViewModel.draftTasks.count else { return }
                                                                if taskViewModel.draftTasks[idx].group == key {
                                                                    taskViewModel.draftTasks[idx].group = ""
                                                                } else {
                                                                    taskViewModel.draftTasks[idx].group = key
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .padding(.leading, 5)
                                                    .padding(.bottom, 4)
                                                }
                                                
                                            }
                                            
                                            // ── Starts ────────────────────────────
                                            HStack {
                                                Text("Starts")                    .font(.system(size: 17).weight(.semibold))
                                                    .foregroundStyle(Color(red: 0.13, green: 0.13, blue: 0.15))
                                                Spacer()
                                                DatePicker(
                                                    "",
                                                    selection: Binding(
                                                        get: {
                                                            guard idx < taskViewModel.draftTasks.count else { return Date() }
                                                            return taskViewModel.draftTasks[idx].start
                                                        },
                                                        set: { newValue in
                                                            guard idx < taskViewModel.draftTasks.count else { return }
                                                            taskViewModel.draftTasks[idx].start = newValue
                                                        }
                                                    ),
                                                    displayedComponents: [.date, .hourAndMinute]
                                                )
                                                .labelsHidden()
                                            }

                                            // ── Ends ──────────────────────────────
                                            HStack {
                                                Text("Ends")               .font(.system(size: 17).weight(.semibold))
                                                    .foregroundStyle(Color(red: 0.13, green: 0.13, blue: 0.15))
                                                Spacer()
                                                DatePicker(
                                                    "",
                                                    selection: Binding(
                                                        get: {
                                                            guard idx < taskViewModel.draftTasks.count else { return Date() }
                                                            return taskViewModel.draftTasks[idx].end
                                                        },
                                                        set: { newValue in
                                                            guard idx < taskViewModel.draftTasks.count else { return }
                                                            taskViewModel.draftTasks[idx].end = newValue
                                                        }
                                                    ),
                                                    displayedComponents: [.date, .hourAndMinute]
                                                )
                                                .labelsHidden()
                                            }

                                            Divider()
                                                .padding(.top, 10)
                                                .padding(.bottom, 15)
                                        }
                                        .padding(.horizontal, 22)
                                    }
                                }
                                .padding(.top, 4)            // alittle breathing room under the camera
                                .padding(.bottom, 12)        // keep last item off bottom edge
                            }
                            .onAppear {
                                UIScrollView.appearance().bounces = true
                            }
                            .onDisappear {
                                UIScrollView.appearance().bounces = false
                            }
                            .scrollIndicators(.hidden)       // optional: hide indicator for cleaner look
                        }
                    } else {
                        Button {
                            camera.takePhoto { shot in
                                if let shot = shot {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        frozenImage = shot      // freeze the frame with animation
                                    }
                                    camera.stop()               // stop live preview
                                    onCapture(shot)             // propagate up
                                }
                            }
                        } label: {
                            Circle()
                                .fill(.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 3)
                                )
                        }
                        .padding(.vertical, 15)
                    }
                    Spacer()

                }
                .frame(
                    width: (resultText != nil)
                    ? geo.size.width * 0.90   // Expanded when results are present
            : geo.size.width * 0.85,
                    height: (resultText != nil)
                            ? geo.size.height * 0.95   // Expanded when results are present
                    : geo.size.width * 0.98   // Compact for preview & controls
                )
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(radius: 7)
                )
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8),
                    value: resultText != nil       // Animate height change when resultText toggles
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: resultText) { newVal in
                if let json = newVal {
                    parseAssignments(from: json)
                }
            }
            .alert("Unable to parse assignments",
                   isPresented: $showingParseAlert,
                   actions: { Button("Dismiss", role: .cancel) {} },
                   message: { Text("Please make sure the scanned text is valid JSON.") })
            .onAppear {
                camera.start()

                if frozenImage == nil, let extImg = taskViewModel.importedImage {
                    frozenImage = extImg
                }
            }
            .onDisappear { camera.stop() }
        }
    }

    func resetState() {
        frozenImage           = nil
        resultText            = nil
        taskViewModel.draftTasks.removeAll()
        selectedGroup         = ""
        isProcessing          = false
        taskViewModel.importedImage = nil
    }
    
    private var hasParsedTasks: Bool {
        // Treat any non-empty resultText as “parsed tasks present”.
        !(resultText?.isEmpty ?? true)
    }
    
    private func parseAssignments(from json: String) {
        // Strip Markdown code‑block fences (```json … ```) before decoding
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let data = cleaned.data(using: .utf8),
            let assignments = try? JSONDecoder().decode([Import].self, from: data)
        else {
            showingParseAlert = true
            return
        }

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: .now)

        taskViewModel.draftTasks = assignments.compactMap { a in
            // Example due_date comes back like "Wed, 2/5" — we just need "2/5"
            let dateString = a.due_date
                .components(separatedBy: ",")
                .last?
                .trimmingCharacters(in: .whitespaces) ?? a.due_date

            guard let monthDay = DateFormatter.monthDay.date(from: dateString) else { return nil }

            let time: Date
            if !a.due_time.isEmpty, let parsedTime = DateFormatter.hoursMinutes.date(from: a.due_time) {
                time = parsedTime
            } else {
                // Default to 11:59PM when no due_time is provided
                time = DateFormatter.hoursMinutes.date(from: "11:59PM")!
            }

            // Determine start date and time
            let start: Date
            // Helper to combine date and time components
            func combine(date: Date, with time: Date) -> Date {
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
                var components = DateComponents()
                components.year = dateComponents.year
                components.month = dateComponents.month
                components.day = dateComponents.day
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                components.second = timeComponents.second
                return calendar.date(from: components)!
            }

            if !a.start_date.isEmpty, let startDateOnly = DateFormatter.monthDay.date(from: a.start_date) {
                // Set year on parsed start date
                let fullStartDate = startDateOnly.setting(year: currentYear)
                if !a.start_time.isEmpty, let parsedTime = DateFormatter.hoursMinutes.date(from: a.start_time) {
                    start = combine(date: fullStartDate, with: parsedTime)
                } else {
                    // Use current time on that date
                    let nowComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
                    start = calendar.date(
                        bySettingHour: nowComponents.hour!,
                        minute: nowComponents.minute!,
                        second: nowComponents.second!,
                        of: fullStartDate
                    )!
                }
            } else {
                if !a.start_time.isEmpty, let parsedTime = DateFormatter.hoursMinutes.date(from: a.start_time) {
                    // Use today's date with parsed start_time
                    start = combine(date: Date(), with: parsedTime)
                } else {
                    // Fallback to current date and time
                    start = Date()
                }
            }

            let end = calendar.date(
                bySettingHour: calendar.component(.hour, from: time),
                minute: calendar.component(.minute, from: time),
                second: 0,
                of: monthDay.setting(year: currentYear))!

            return LineaTaskDraft(
                title: a.assignment_name,
                start: start,
                end: end,
                group: ""
            )
        }
    }
}

private extension DateFormatter {
    static let monthDay: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M/d"          // accepts 1/2 … 12/31 (no leading zeros needed)
        df.timeZone = .current
        return df
    }()
    static let hoursMinutes: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mma"        // e.g. "11:59PM"
        df.amSymbol = "AM"
        df.pmSymbol = "PM"
        df.timeZone = .current
        return df
    }()
}

private extension Date {
    func setting(year: Int) -> Date {
        Calendar.current.date(
            from: DateComponents(
                calendar: Calendar.current,
                timeZone: .current,
                year: year,
                month: Calendar.current.component(.month, from: self),
                day: Calendar.current.component(.day, from: self))
        )!
    }
}

struct CameraPreview: UIViewRepresentable {
    typealias UIViewType = PreviewView
    let camera: CameraController

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        camera.attachPreview(to: view)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

extension CameraController {
    func attachPreview(to view: PreviewView) {
        guard let session = self.captureSession else { return }
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}



class CameraController: NSObject, ObservableObject {

    // MARK: - Session Management
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private let photoOutput = AVCapturePhotoOutput()
    /// True once the user has granted camera permission.
    private var permissionGranted = false

    /// Expose the session for preview attachment.
    var captureSession: AVCaptureSession? { session }

    override init() {
        super.init()
        checkPermission()
    }

    /// Handle camera-authorization flow up front.
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
            self.configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    if granted {
                        self.configureSession()
                    } else {
                        print("❌ User denied camera access.")
                    }
                }
            }
        case .denied, .restricted:
            print("❌ Camera access denied or restricted.")
        @unknown default:
            print("❌ Unknown authorization status.")
        }
    }

    /// Configure inputs & outputs.
    private func configureSession() {
        guard permissionGranted else { return }
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Input — back wide‑angle camera
        guard
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .back),
            let cameraInput = try? AVCaptureDeviceInput(device: camera),
            session.canAddInput(cameraInput)
        else {
            print("❌ Unable to create back‑camera input.")
            session.commitConfiguration()
            return
        }
        session.addInput(cameraInput)

        // Output — still photo
        guard session.canAddOutput(photoOutput) else {
            print("❌ Unable to add photo output.")
            session.commitConfiguration()
            return
        }
        session.addOutput(photoOutput)
        photoOutput.isHighResolutionCaptureEnabled = true

        session.commitConfiguration()
    }

    // MARK: - Public controls
    /// Start the capture session.
    func start() {
        guard permissionGranted else { return }
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    /// Stop the capture session.
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - Still‑photo capture
    private var photoCaptureCompletion: ((UIImage?) -> Void)?

    /// Capture a single still frame and return it via completion on the main queue.
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            settings.isHighResolutionPhotoEnabled = true
            self.photoCaptureCompletion = completion
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        var image: UIImage? = nil
        if let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        }
        DispatchQueue.main.async {
            self.photoCaptureCompletion?(image)
            self.photoCaptureCompletion = nil
        }
    }
}
