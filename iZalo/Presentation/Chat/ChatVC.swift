//
//  ChatVC.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import ReverseExtension

protocol ChatDisplayLogic: class {
    func goBack()
    func hideKeyboard()
    func clearInputTextField()
    func updateSendStatus()
    func scollTableToBottom(noRows: Int)
    func showHideButtonContainer()
    func showHideEmojiView()
    func gotoLibrary()
    func hideAllExtraViews()
}

class ChatVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var sendImageButton: UIButton!
    @IBOutlet weak var showHideButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var emojiView: UIView!
    
    private let contactRepository = ContactRepositoryFactory.sharedInstance
    public var isButtonContainerHidden = true
    public var isEmojiViewHidden = true
    public var viewModel: ChatVM!
    public var conversation: Conversation!
    public var currentUsername: String!
    private let disposeBag = DisposeBag()
    private var items: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MessageItem>>!
    private var emojis: RxCollectionViewSectionedReloadDataSource<SectionModel<String, EmojiItem>>!
    private var contactObservable: Observable<Contact>?
    
    class func instance(conversation: Conversation, currentUsername: String, contactObservable: Observable<Contact>) -> ChatVC {
        return ChatVC(conversation: conversation, currentUsername: currentUsername, contactObservable: contactObservable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(conversation: Conversation, currentUsername: String, contactObservable: Observable<Contact>) {
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.contactObservable = contactObservable
        super.init(nibName: "ChatVC", bundle: nil)
        self.viewModel = ChatVM(conversation: conversation, currentUsername: currentUsername, displayLogic: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindViewModel()
        // Do any additional setup after loading the view.
    }

    private func setupLayout() {
        switch conversation.members.count {
        case 2: //2 members conversation
            conversationNameLabel.text = self.conversation.name
            statusLabel.text = "Vừa mới truy cập"
            
        default: //group chat
            conversationNameLabel.text = self.conversation.name
            statusLabel.text = "\(self.conversation.members.count) thành viên"
        }
        
        self.tableView.re.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
//        self.tableView.estimatedRowHeight = 80
        self.tableView.register(UINib(nibName: "MyMessageCell", bundle: nil), forCellReuseIdentifier: "MyMessageCell")
        self.tableView.register(UINib(nibName: "OthersMessageCell", bundle: nil), forCellReuseIdentifier: "OthersMessageCell")
        self.tableView.register(UINib(nibName: "MyImageMessageCell", bundle: nil), forCellReuseIdentifier: "MyImageMessageCell")
        self.tableView.register(UINib(nibName: "OthersImageMessageCell", bundle: nil), forCellReuseIdentifier: "OthersImageMessageCell")
        self.tableView.separatorStyle = .none
        
        self.emojiCollectionView.register(UINib(nibName: "EmojiCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCell")
        
        self.emojis = RxCollectionViewSectionedReloadDataSource<SectionModel<String, EmojiItem>>(configureCell: {(_, cv, ip, item) -> UICollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: ip) as! EmojiCell
            cell.bind(item: item)
            return cell
        })
        
        self.items = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, MessageItem>>(configureCell: { (_, tv, ip, item) -> UITableViewCell in
            switch item.message.type {
            case Constant.imageMessage:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyImageMessageCell", for: ip) as! MyImageMessageCell
                    cell.bind(item: item)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersImageMessageCell", for: ip) as! OthersImageMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            default:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyMessageCell", for: ip) as! MyMessageCell
                    cell.bind(item: item)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersMessageCell", for: ip) as! OthersMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            }
        })
        let _ = contactObservable!.subscribe(onNext: {(contact) in
                self.conversationNameLabel.text = contact.name
            } )
        self.buttonsContainer.isHidden = true
        self.emojiView.isHidden = true
        self.tableView.rx.itemSelected.asDriver()
            .drive(onNext: {(ip) in
                self.tableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                switch item.message.type {
                case Constant.imageMessage:
                    let vc = ViewImageVC.init(url: item.message.content)
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    return
                }
            })
        .disposed(by: disposeBag)
        
        self.emojiCollectionView.rx.itemSelected.asDriver()
            .drive(onNext: {(ip) in
                self.emojiCollectionView.deselectItem(at: ip, animated: false)
                let item = self.emojis.sectionModels[0].items[ip.row]
                self.inputTextField.text = "\( self.inputTextField.text ?? "")\(item.emoji)"
                self.inputTextField.sendActions(for: .valueChanged) //trigger change
                
            })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = ChatVM.Input(
            trigger: viewWillAppear,
            backTrigger: self.backButton.rx.tap.asDriver(),
            textMessage: self.inputTextField.rx.text.orEmpty,
            sendTrigger: self.sendButton.rx.tap.asDriver(),
            showHideTrigger: self.showHideButton.rx.tap.asDriver(),
            emojiButtonTrigger: self.emojiButton.rx.tap.asDriver(),
            sendImageTrigger: self.sendImageButton.rx.tap.asDriver())
        let output = self.viewModel.transform(input: input)
        
        output.fetching.drive(onNext: { [unowned self] (show) in
            self.showLoading(withStatus: show)
        }).disposed(by: self.disposeBag)
        
        output.items
            .map { [AnimatableSectionModel(model: "Items", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: self.items))
            .disposed(by: self.disposeBag)
        
        output.emojiItems
            .map { [SectionModel(model: "EmojiItems", items: $0)]}
            .drive(self.emojiCollectionView.rx.items(dataSource: self.emojis))
            .disposed(by: disposeBag)
        
        output.error.drive(onNext: { [unowned self] (error) in
            self.handleError(error: error)
        }).disposed(by: self.disposeBag)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        guard chosenImage != nil else {
            return
        }
        let resizedImage = ImageUtils.resizeImage(image: chosenImage!, targetSize: CGSize(width: min(chosenImage?.size.width ?? 0, 360), height: min(chosenImage?.size.height  ?? 0, 360)))
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
        self.viewModel.sendImageMessage(url: photoURL)
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

extension ChatVC: ChatDisplayLogic {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func hideKeyboard() {
        self.view.resignFirstResponder()
    }
    
    func clearInputTextField() {
        self.inputTextField.text = ""
    }
    
    func updateSendStatus() {
        
    }
    
    func scollTableToBottom(noRows: Int) {
        let indexPath = NSIndexPath(item: noRows, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    func showHideButtonContainer() {
        switch self.isButtonContainerHidden {
        case true: //show it!
            self.buttonsContainer.isHidden = false
            self.emojiView.isHidden = true
            self.isEmojiViewHidden = true
        
        default:   //hide it!
            self.buttonsContainer.isHidden = true
        }
        self.isButtonContainerHidden = !self.isButtonContainerHidden
    }
    
    func showHideEmojiView() {
        switch self.isEmojiViewHidden {
        case true: //show it!
            self.emojiView.isHidden = false
            self.buttonsContainer.isHidden = true //hide buttons container
            self.isButtonContainerHidden = true
        default: //hide it!
            self.emojiView.isHidden = true
        }
        self.isEmojiViewHidden = !self.isEmojiViewHidden
    }
    
    func gotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func hideAllExtraViews() {
        self.buttonsContainer.isHidden = true //hide buttons container
        self.isButtonContainerHidden = true
        self.emojiView.isHidden = true
        self.isEmojiViewHidden = true
    }
}

extension ChatVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }
}
