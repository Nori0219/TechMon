//
//  BattleViewController.swift
//  TechMon
//
//  Created by 杉井位次 on 2023/05/11.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPBar: UIProgressView!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPBar: UIProgressView!
    
    //ステータスを表すクラス
    var player: Player!
    var enemy: Enemy!
    
    //敵の攻撃頻度
    var enemyAttackTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //プログレスバーが細いので拡大
        playerHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        enemyHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        
        //プレイヤーと敵のステータスを設定
        player =  Player(name: "勇者", imageName: "yusya.png", attackPoint: 20, maxHP: 100)
        enemy =  Enemy(name: "ドラゴン", imageName: "monster.png", attackPoint: 10, maxHP: 300)
        
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        
        //画面更新
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TechMonManager.playBGM(fileName: "BGM_battle001")
        //敵の自動攻撃
        enemyAttackTimer = Timer.scheduledTimer(
            timeInterval: 1.5,
            target: self,
            selector: #selector(enemyAttack),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TechMonManager.stopBGM()
    }
    
    //画面表示を更新
    func updateUI() {
        playerHPBar.progress = player.currentHP / player.maxHP
        enemyHPBar.progress = enemy.currentHP / enemy.maxHP
    }
    
    //攻撃
    @IBAction func attackAction() {
        TechMonManager.damageAnimation(imageView: enemyImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        
        //攻撃でダメージを与える
        enemy.currentHP -= player.attackPoint
        updateUI()
        
        //プレイヤーの勝利
        if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    //敵の攻撃
    @IBAction func enemyAttack() {
        TechMonManager.damageAnimation(imageView: playerImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        
        //敵からダメージを受ける
        player.currentHP -= enemy.attackPoint
        updateUI()
        
        //プレイヤーの勝利
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
    }
    
    //勝敗が決定した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        TechMonManager.vanishAnimation(imageView: vanishImageView)
        TechMonManager.stopBGM()
        enemyAttackTimer.invalidate()
        
        var finishMessage: String = ""
        if isPlayerWin {
            TechMonManager.playBGM(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！！"
        } else {
            TechMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北"
        }
        
        //アラートを表示
        let alert = UIAlertController(
            title: "バトル終了",
            message: finishMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
}
