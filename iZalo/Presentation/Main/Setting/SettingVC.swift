//
//  ProfileVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/20/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
protocol SettingDisplayLogic: class {
    func gotoLogin()
    func bindUserInfo(user: User?)
    func gotoLibrary()
    func updateAvatar(newURL:String)
}

class SettingVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public typealias ViewModelType = SettingVM
    public var viewModel: SettingVM!
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedReloadDataSource<SectionModel<String, SettingItem>>!
    private var currentUsername: String!
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    func setCurrentUsername(currentUsername: String) {
        self.currentUsername = currentUsername
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    class func instance(currentUsername: String) -> SettingVC {
        return SettingVC(currentUsername: currentUsername)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(currentUsername: String) {
        super.init(nibName: "SettingVC", bundle: nil)
        self.currentUsername = currentUsername
        self.viewModel = SettingVM(displayLogic: self, currentUsername: self.currentUsername)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupLayout()
        bindViewModel()
    }
    
    private func setupLayout() {
        self.settingTableView.tableFooterView = UIView()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
        self.avatarImageView.clipsToBounds = true
        self.navigationController?.isNavigationBarHidden = true;
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Tìm bạn bè, tin nhắn, ...",
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)])
        self.settingTableView.rowHeight = UITableViewAutomaticDimension
        self.settingTableView.estimatedRowHeight = 60
        self.settingTableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
        self.settingTableView.separatorStyle = .singleLine
        self.settingTableView.separatorInset = UIEdgeInsetsMake(0, 55, 0, 10);
        self.items = RxTableViewSectionedReloadDataSource<SectionModel<String, SettingItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "SettingCell", for: ip) as! SettingCell
            cell.bind(item: item)
            return cell
        })
        self.settingTableView.rx.itemSelected.asDriver()
            .drive(onNext: {(ip) in
                self.settingTableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                switch item.text {
                case "Đổi mật khẩu":
                    print("change pwd")
                case "Đổi ảnh đại diện":
                    self.gotoLibrary()
                case "Thông tin về iZalo":
                    print("info")
                default:
                    let vc = UINavigationController(rootViewController: LoginVC.instance())
                    vc.setNavigationBarHidden(true, animated: false)
                    AppDelegate.sharedInstance.window?.rootViewController = vc
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = SettingVM.Input(trigger: viewWillAppear)
        let output = self.viewModel.transform(input: input)
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.showLoading(withStatus: false)
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
        
        output.items
            .map { [SectionModel(model: "Items", items: $0)] }
            .drive(self.settingTableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard chosenImage != nil else {
            return
        }
        let resizedImage = ImageUtils.resizeImage(image: chosenImage!, targetSize: CGSize(width: 120, height: 120))
        let imageURL = info[UIImagePickerControllerImageURL] as? URL
        guard imageURL != nil else {
            return
        }
        let imageName = imageURL!.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let localPath = documentDirectory?.appending(imageName)
        let data = UIImageJPEGRepresentation(resizedImage, 80)! as NSData
        data.write(toFile: localPath!, atomically: true)
        let photoURL = URL.init(fileURLWithPath: localPath!)
        print(photoURL)
        self.avatarImageView.image = resizedImage
        self.viewModel.saveAvatarImage(path : photoURL)
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingVC: SettingDisplayLogic {
    
    func gotoLogin() {
        let vc = UINavigationController(rootViewController: LoginVC.instance())
        vc.setNavigationBarHidden(true, animated: false)
        AppDelegate.sharedInstance.window?.rootViewController = vc
    }
    
    func bindUserInfo(user: User?) {
        guard user != nil else {
            self.nameLabel.text = "Không thể tải thông tin user"
            return
        }
        if self.avatarImageView.image == nil {
            self.avatarImageView.kf.setImage(with: URL(string: user!.avatarURL!), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
        }
        self.nameLabel.text = user!.name
        self.usernameLabel.text = user!.username
    }
    
    func gotoLibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func updateAvatar(newURL: String) {
//        self.avatarImageView.kf.setImage(with: URL(string: newURL), placeholder: nil,  options: [.processor(Constant.avatarImageProcessor)])
        showToast(message: "Đổi ảnh đại diện thành công")
    }
}
