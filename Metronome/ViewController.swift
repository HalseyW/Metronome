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
    let btnPlay = UIButton()
    /// pickerView的数组
    var beatsArray: [Int] {
        var array = [Int]()
        for i in 40 ... 200 {
            array.append(i)
        }
        return array
    }
    /// 播放器
    var player: AVAudioPlayer!
    /// 计时器，用于精准控制节奏
    var timer: Timer!
    /// 是否在播放的标志，因为 mp3 时长太短，player 的 isPlaying 不准确
    var isPlaying = false {
        didSet {
            if isPlaying {
                timer = Timer.scheduledTimer(timeInterval: 60.0 / beat, target: self, selector: #selector(play), userInfo: nil, repeats: true)
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                if timer != nil {
                    timer.invalidate()
                    timer = nil
                }
                UIApplication.shared.isIdleTimerDisabled = false
            }
            btnPlay.isSelected = isPlaying
        }
    }
    /// 当前节奏
    var beat = UserDefaults.getBeat() {
        didSet {
            stopTimer()
            startTimer()
            UserDefaults.saveBeat(beat)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initPlayer()
    }
    
    /// 初始化播放器
    func initPlayer() {
        let path = Bundle.main.path(forResource: "click_sound_1", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            fatalError("player init fail")
        }
        player.prepareToPlay()
    }
    
    /// 点击播放按钮
    ///
    /// - Parameter sender: 播放/暂停按钮
    @objc func onClickPlayButton(_ sender: UIButton) {
        isPlaying.toggle()
    }
    
    /// 开始计时（播放）
    func startTimer() {
        isPlaying = true
    }
    
    /// 停止计时（暂停）
    func stopTimer() {
        isPlaying = false
    }
    
    /// 播放，用于 timer 的调用
    @objc func play() {
        player.play()
    }
    
    deinit {
        stopTimer()
        player.stop()
    }
}

extension ViewController {
    func initView() {
        self.view.backgroundColor = .black
        /// 节奏选择
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(Int(beat - 40), inComponent: 0, animated: false)
        self.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.height.equalTo(400)
            make.centerY.equalToSuperview().offset(-50)
        }
        /// 播放/暂停按钮
        btnPlay.setImage(UIImage(named: "play"), for: .normal)
        btnPlay.setImage(UIImage(named: "pause"), for: .selected)
        self.view.addSubview(btnPlay)
        btnPlay.snp.makeConstraints { (make) in
            make.size.equalTo(100)
            make.top.equalTo(pickerView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        btnPlay.addTarget(self, action: #selector(onClickPlayButton(_:)), for: .touchUpInside)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return beatsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 200
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let lable = UILabel()
        lable.text = String(beatsArray[row])
        lable.font = UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 2)
        lable.textAlignment = .center
        lable.textColor = .lightGray
        return lable
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.beat = Double(beatsArray[row])
    }
}

// MARK: - UserDefaults，保存用户设置的 beat
extension UserDefaults {
    /// 获取用户保存的 beat
    static func getBeat() -> Double {
        let beat = self.standard.double(forKey: "metronome_ beats")
        return beat == 0.0 ? 100.0 : beat
    }
    
    /// 保存用户设置的 beat
    static func saveBeat(_ beat: Double) {
        self.standard.set(beat, forKey: "metronome_ beats")
    }
}
