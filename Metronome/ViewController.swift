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
            stopPlay()
            startPlay()
        }
    }
    
    var timeInterval: TimeInterval {
        return 60.0 / speed
    }
    
    var speedArray: [Int] {
        var array = [Int]()
        for i in 40 ... 200 {
            array.append(i)
        }
        return array
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
    
    @objc func onClickPlayButton(_ sender: UIButton) {
        isPlaying.toggle()
        sender.isSelected.toggle()
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
 
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(Int(speed - 40), inComponent: 0, animated: false)
        self.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
        }
        
        let btnPlay = UIButton()
        btnPlay.setBackgroundImage(UIImage(named: "play"), for: .normal)
        btnPlay.setBackgroundImage(UIImage(named: "pause"), for: .selected)
        self.view.addSubview(btnPlay)
        btnPlay.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.top.equalTo(pickerView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        btnPlay.addTarget(self, action: #selector(onClickPlayButton(_:)), for: .touchUpInside)
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speedArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 200
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lable = UILabel()
        lable.text = String(speedArray[row])
        lable.font = UIFont.systemFont(ofSize: 200)
        lable.textAlignment = .center
        lable.textColor = .lightGray
        return lable
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.speed = Double(speedArray[row])
    }
    
}
