//
//  ViewController.swift
//  Metronome
//
//  Created by HalseyW-15 on 2019/8/22.
//  Copyright © 2019 wushhhhhh. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController {
    let labelSpeed = UILabel()
    var player: AVAudioPlayer!
    var timer: Timer!
    var isPlaying = false {
        didSet {
            if oldValue {
                timer.invalidate()
                timer = nil
                player.stop()
                player.prepareToPlay()
            } else {
                timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(play), userInfo: nil, repeats: true)
            }
        }
    }
    var speed = 120.0 {
        didSet {
            labelSpeed.text = "\(Int(speed))"
            stopPlay()
            startPlay()
        }
    }
    var timeInterval: TimeInterval {
        return 60.0 / speed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initPlayer()
    }
    
    /// 初始化播放器
    func initPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            let path = Bundle.main.path(forResource: "click_sound_1", ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch let error as NSError{
            fatalError(error.localizedDescription)
        }
    }
    
    /// 点击播放按钮
    @objc func onClickPlayButton() {
        isPlaying.toggle()
    }
    
    @objc func onClickDecelerateButton() {
        if speed == 40 {
            return
        }
        speed -= 1
    }
    
    @objc func onClickAccelerateButton() {
        if speed == 200 {
            return
        }
        speed += 1
    }
    
    @objc func play() {
        player.play()
    }
    

    func startPlay() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(play), userInfo: nil, repeats: true)
    }
    
    func stopPlay() {
        if timer == nil {
            return
        }
        timer.invalidate()
        timer = nil
        player.stop()
    }
    
    deinit {
        timer.invalidate()
        timer = nil
        player.stop()
    }
 
}

extension ViewController {
    func initView() {
        self.view.backgroundColor = .black
        
        let btnPlay = UIButton()
        btnPlay.backgroundColor = .darkGray
        self.view.addSubview(btnPlay)
        btnPlay.snp.makeConstraints { (make) in
            make.size.equalTo(100)
            make.center.equalToSuperview()
        }
        btnPlay.addTarget(self, action: #selector(onClickPlayButton), for: .touchUpInside)
        
        labelSpeed.text = "\(Int(speed))"
        labelSpeed.font = UIFont.systemFont(ofSize: 50)
        labelSpeed.textColor = .darkGray
        labelSpeed.textAlignment = .center
        self.view.addSubview(labelSpeed)
        labelSpeed.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.bottom.equalTo(btnPlay.snp.top).offset(-50)
        }
        
        let btnDecelerate = UIButton()
        btnDecelerate.backgroundColor = .darkGray
        self.view.addSubview(btnDecelerate)
        btnDecelerate.snp.makeConstraints { (make) in
            make.size.equalTo(50)
            make.centerY.equalTo(labelSpeed)
            make.right.equalTo(labelSpeed.snp.left).offset(-20)
        }
        btnDecelerate.addTarget(self, action: #selector(onClickDecelerateButton), for: .touchUpInside)
        
        let btnAccelerate = UIButton()
        btnAccelerate.backgroundColor = .darkGray
        self.view.addSubview(btnAccelerate)
        btnAccelerate.snp.makeConstraints { (make) in
            make.size.equalTo(50)
            make.centerY.equalTo(labelSpeed)
            make.left.equalTo(labelSpeed.snp.right).offset(20)
        }
        btnAccelerate.addTarget(self, action: #selector(onClickAccelerateButton), for: .touchUpInside)
    }
}
