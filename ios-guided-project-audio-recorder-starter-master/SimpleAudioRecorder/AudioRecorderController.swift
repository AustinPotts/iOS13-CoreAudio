//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Paul Solt on 10/1/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var timeRemainingLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var audioVisualizer: AudioVisualizer!
    
    
    //MARK: - Audio Player Property
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else {return}
            audioPlayer.delegate = self
        }
    }
    
    
    var timer: Timer?
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        // NOTE: DateComponentFormatter is good for minutes/hours/seconds
        // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
        
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional // 00:00  mm:ss
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use a font that won't jump around as values change
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
        loadAudio()
    }
    
    deinit {
        cancelTimer()
    }
    
    func updateViews() {
        
        playButton.isSelected = isPlaying
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        let duration = audioPlayer?.duration ?? 0
        
        timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
        
        timeSlider.value = Float(elapsedTime)
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(duration)
        
        
    }
    
    
    // MARK: - Timer
    
    
    func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            print("updateTimer")
            
            self.updateViews()
            
//            if let audioRecorder = self.audioRecorder,
//                self.isRecording == true {
//
//                audioRecorder.updateMeters()
//                self.audioVisualizer.addValue(decibelValue: audioRecorder.averagePower(forChannel: 0))
//
//            }
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {
            
                audioPlayer.updateMeters()
                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
            }
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    
    // MARK: - Playback
    
    var isPlaying: Bool {
        // when the audio player is nil that means theres no resource loaded to play
        audioPlayer?.isPlaying ?? false
    }
    
    func loadAudio() {
        
        //TODO: Clean Up for production, good for prototyping, we want to crash to find issues
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        
        audioPlayer = try! AVAudioPlayer(contentsOf: songURL) //Crash if resource cannot be loaded
        //FIXME: Use error Handling if crash
        
    }
    
    /*
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    */
    
    
    
    func play() {
        
        audioPlayer?.play()
        updateViews()
        startTimer()
        
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    
    // MARK: - Recording
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
//        print("recording URL: \(file)")
        
        return file
    }
    
    /*
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }
    */
    
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
    
    // MARK: - Actions
    
    @IBAction func togglePlayback(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
        
    }
    
    @IBAction func updateCurrentTime(_ sender: UISlider) {
        
    }
    
    @IBAction func toggleRecording(_ sender: Any) {
        
    }
}

extension AudioRecorderController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying.flag = \(flag)")
       
            cancelTimer()
            updateViews()
      
    }
    
    //Helps us debug audio files
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error decoding audi: \(error)")
        }
        cancelTimer()
        updateViews()
    }
}
