//
//  ViewImageVC.swift
//  iZalo
//
//  Created by CPU11613 on 10/17/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

protocol ViewImageDisplayLogic:class {
    func goBack()
}
class ViewImageVC: BaseVC, UIScrollViewDelegate {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    
    private let disposeBag = DisposeBag()
    private var url: String?
    
    class func instance(url: String) -> ViewImageVC {
        return ViewImageVC(url: url)
    }
    
    public typealias ViewModelType = ViewImageVM
    public var viewModel: ViewImageVM!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.viewModel = ViewImageVM(displayLogic: self)
    }
    
    init(url: String) {
        super.init(nibName: "ViewImageVC", bundle: nil)
        self.url = url
        self.viewModel = ViewImageVM(displayLogic: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
    }

    private func setupLayout() {
        print("url: \(self.url)")
        self.mainImageView.kf.setImage(with: URL(string: self.url!))
        self.mainScrollView.minimumZoomScale = 1.0
        self.mainScrollView.maximumZoomScale = 6.0
        mainScrollView.delegate = self
    }
    
    private func bindViewModel() {
        let input = ViewImageVM.Input(backTrigger: self.backButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
    }
    func viewForZooming(in mainScrollView: UIScrollView) -> UIView? {
        
        return self.mainImageView
    }
}
extension ViewImageVC: ViewImageDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
