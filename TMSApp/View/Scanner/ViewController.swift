/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Main view controller for the AR experience.
 */

import UIKit
import Metal
import MetalKit
import ARKit

final class ViewController: UIViewController, ARSessionDelegate {
    private let isUIEnabled = true
    private let confidenceControl = UISegmentedControl(items: ["Low", "Medium", "High"])
    private let rgbRadiusSlider = UISlider()
    private let pickFramesSlider = UISlider()
    private let recordButton = UIButton()
    private let textLabel = UILabel()
    
    private var isRecording = false
    
    private var taskNum = 0;
    private var completedTaskNum = 0;
    
    private let session = ARSession()
    private var renderer: Renderer!
    
    var onDone: (_ path: String) -> Void
    
    init (onDone: @escaping (_ path: String) -> Void) {
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewController loaded")
        
        view.backgroundColor = .black
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        session.delegate = self
        
        let metalView = MTKView(frame: view.bounds, device: device)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.backgroundColor = UIColor.clear
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.contentScaleFactor = 1
        metalView.delegate = self
        view.addSubview(metalView)
        view.backgroundColor = UIColor.clear
        
        renderer = Renderer(session: session, metalDevice: device, renderDestination: metalView)
        renderer.drawRectResized(size: metalView.bounds.size)
        renderer.delegate = self
        
        // Confidence control
        confidenceControl.backgroundColor = .white
        confidenceControl.selectedSegmentIndex = renderer.confidenceThreshold
        confidenceControl.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)
        
        // RGB Radius control
        rgbRadiusSlider.minimumValue = 0
        rgbRadiusSlider.maximumValue = 2
        rgbRadiusSlider.isContinuous = true
        rgbRadiusSlider.value = renderer.rgbRadius
        rgbRadiusSlider.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)

        // Pick every x Frames control
        pickFramesSlider.minimumValue = 1
        pickFramesSlider.maximumValue = 50
        pickFramesSlider.isContinuous = true
        pickFramesSlider.value = Float(renderer.pickFrames)
        pickFramesSlider.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)

        // UIButton
        recordButton.setTitle("START", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 5
        recordButton.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        
        // UILabel
        textLabel.text = "  1/5 of new frames  \n  Files saved 0/0  "
        textLabel.textColor = .white
        textLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.layer.masksToBounds = true
        textLabel.layer.cornerRadius = 8
        textLabel.sizeToFit()
        textLabel.numberOfLines = 2
        
        let stackView = UIStackView(arrangedSubviews: [
            confidenceControl, rgbRadiusSlider, pickFramesSlider, recordButton])
        stackView.isHidden = !isUIEnabled
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            textLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
        
        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("memory warning!!!")
        memoryAlert()
        updateIsRecording(_isRecording: false)
    }
    
    private func memoryAlert() {
        let alert = UIAlertController(title: "Low Memory Warning", message: "The recording has been paused. Do not quit the app until all files have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func viewValueChanged(view: UIView) {
        switch view {
            
        case confidenceControl:
            renderer.confidenceThreshold = confidenceControl.selectedSegmentIndex
            
        case rgbRadiusSlider:
            renderer.rgbRadius = rgbRadiusSlider.value
            
        case pickFramesSlider:
            renderer.pickFrames = Int(pickFramesSlider.value)
            updateTextLabel()

        default:
            break
        }
    }
    
    @objc
    private func onButtonClick(_ sender: UIButton) {
        if (sender != recordButton) {
            return
        }
        updateIsRecording(_isRecording: !isRecording)
    }
    
    private func updateIsRecording(_isRecording: Bool) {
        isRecording = _isRecording
        if (isRecording){
            recordButton.setTitle("HITUNG", for: .normal)
            recordButton.backgroundColor = .systemTeal
            renderer.currentFolder = getTimeStr()
            createDirectory(folder: renderer.currentFolder + "/data")
        } else {
            recordButton.setTitle("MULAI", for: .normal)
            recordButton.backgroundColor = .systemBlue
            renderer.savePointCloud { result in
                switch result {
                case .success(let path):
                    print("Point cloud saved successfully with filename: \(path)")
                    self.onDone(path)
                case .failure(let error):
                    print("Failed to save point cloud: \(error.localizedDescription)")
                }
            }
        }
        renderer.isRecording = isRecording
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// update textlabel on tasks start/finish
extension ViewController: TaskDelegate {
    func didStartTask() {
        self.taskNum += 1
        updateTextLabel()
    }
    
    func didFinishTask() {
        self.completedTaskNum += 1
        updateTextLabel()
    }
    
    private func updateTextLabel() {
        let text = "  1/\(self.renderer.pickFrames)  of new frames  \n  Files saved \(self.completedTaskNum)/\(self.taskNum)  "
        DispatchQueue.main.async {
            self.textLabel.text = text
        }
    }
}

// MARK: - MTKViewDelegate

extension ViewController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}

// MARK: - RenderDestinationProvider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension MTKView: RenderDestinationProvider {
    
}
