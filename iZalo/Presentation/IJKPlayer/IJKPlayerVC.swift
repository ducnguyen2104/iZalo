//
//  IJKPlayerVC.swift
//  iZalo
//
//  Created by CPU11613 on 11/22/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import IJKMediaFramework
import RxSwift

protocol IJKPlayerDisplayLogic: class {
    func goBack()
}

class IJKPlayerVC: BaseVC {
    
    @IBOutlet weak var backButton: UIButton!
    var url: String?
    var player: IJKMediaPlayback?
    
    class func instance(url: String) -> IJKPlayerVC {
        return IJKPlayerVC(url: url)
    }
    
    public typealias ViewModelType = IJKPlayerVM
    public var viewModel: IJKPlayerVM!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = IJKMPMoviePlayerController.init(contentURLString: self.url!)
        player?.view.frame = self.view.bounds
        view.addSubview((player?.view)!)
        view.bringSubview(toFront: backButton)
        player?.prepareToPlay()
        player?.play()
    }
    
    func bindViewModel() {
        let input = IJKPlayerVM.Input(
            backTrigger: self.backButton.rx.tap.asDriver()
        )
        let output = self.viewModel.transform(input: input)
        
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = IJKPlayerVM(displayLogic: self)
    }
    
    init(url: String) {
        super.init(nibName: "IJKPlayerVC", bundle: nil)
        self.url = url
        self.viewModel = IJKPlayerVM(displayLogic: self)
    }
    
}

extension IJKPlayerVC: IJKPlayerDisplayLogic {
    func goBack() {
        print("back")
        self.navigationController?.popViewController(animated: true)

        self.player?.stop()
        self.player = nil
    }
}
