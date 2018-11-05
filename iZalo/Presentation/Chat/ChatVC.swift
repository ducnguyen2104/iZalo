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
import GooglePlacePicker

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
    func openPickContactVC()
    func openPickLocationVC()
    func openPlacePicker()
    func setSendImage()
    func setSendFile()
    func countDown(ip: IndexPath, time: Int)
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
    @IBOutlet weak var sendNameCardButton: UIButton!
    @IBOutlet weak var sendLocationMKButton: UIButton!
    @IBOutlet weak var sendLocationGGButton: UIButton!
    @IBOutlet weak var sendFileButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
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
    private var isSendImage = false
    private var tempImage: UIImage?
    var countdownTimer: Timer!
    
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
        print("b4 layout: \(self.buttonsContainer.frame)")
        setupLayout()
        print("after layout: \(self.buttonsContainer.frame)")
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
        self.tableView.register(UINib(nibName: "MyNameCardMessageCell", bundle: nil), forCellReuseIdentifier: "MyNameCardMessageCell")
        self.tableView.register(UINib(nibName: "OthersNameCardMessageCell", bundle: nil), forCellReuseIdentifier: "OthersNameCardMessageCell")
        self.tableView.register(UINib(nibName: "MyLocationMessageCell", bundle: nil), forCellReuseIdentifier: "MyLocationMessageCell")
        self.tableView.register(UINib(nibName: "OthersLocationMessageCell", bundle: nil), forCellReuseIdentifier: "OthersLocationMessageCell")
        self.tableView.register(UINib(nibName: "MyLocationGGMessageCell", bundle: nil), forCellReuseIdentifier: "MyLocationGGMessageCell")
        self.tableView.register(UINib(nibName: "OthersLocationGGMessageCell", bundle: nil), forCellReuseIdentifier: "OthersLocationGGMessageCell")
        self.tableView.register(UINib(nibName: "MyFileMessageCell", bundle: nil), forCellReuseIdentifier: "MyFileMessageCell")
        self.tableView.register(UINib(nibName: "OthersFileMessageCell", bundle: nil), forCellReuseIdentifier: "OthersFileMessageCell")
        self.tableView.register(UINib(nibName: "MyAudioMessageCell", bundle: nil), forCellReuseIdentifier: "MyAudioMessageCell")
        
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
                    cell.bind(item: item, image: self.tempImage)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersImageMessageCell", for: ip) as! OthersImageMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            case Constant.nameCardMessage:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyNameCardMessageCell", for: ip) as! MyNameCardMessageCell
                    cell.bind(item: item)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersNameCardMessageCell", for: ip) as! OthersNameCardMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            case Constant.locationMessage:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyLocationGGMessageCell", for: ip) as! MyLocationGGMessageCell
                    cell.bind(item: item)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersLocationGGMessageCell", for: ip) as! OthersLocationGGMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            case Constant.fileMessage:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyFileMessageCell", for: ip) as! MyFileMessageCell
                    cell.bind(item: item)
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OthersFileMessageCell", for: ip) as! OthersFileMessageCell
                    cell.bind(item: item, contactObservable: self.contactObservable!)
                    return cell
                }
            case Constant.audioMessage:
                if(item.message.senderId == self.currentUsername) {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyAudioMessageCell", for: ip) as! MyAudioMessageCell
                    cell.bind(item: item)
                    cell.stopAnimating()
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "MyAudioMessageCell", for: ip) as! MyAudioMessageCell
                    cell.bind(item: item)
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

//        self.emojiView.isHidden = true
        self.tableView.rx.itemSelected.asDriver()
            .drive(onNext: {(ip) in
                self.tableView.deselectRow(at: ip, animated: false)
                let item = self.items.sectionModels[0].items[ip.row]
                switch item.message.type {
                case Constant.imageMessage:
                    let vc = ViewImageVC.instance(url: item.message.content)
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                case Constant.nameCardMessage:
                    let members = [self.currentUsername, item.message.content].sorted { $0 < $1 }
                    var conversationId = ""
                    for i in 0...(members.count - 1) {
                        if i == 0 {
                            conversationId += members[i]
                        }
                        else {
                            conversationId += "*\(members[i])"
                        }
                    }
                    let vc = ChatVC.instance(conversation: Conversation(id: conversationId, name: conversationId, members: members, lastMessage: Constant.dummyMessage), currentUsername: self.currentUsername, contactObservable: ContactRepositoryFactory.sharedInstance.getContactInfo(username: item.message.content))
                    var vcArray = self.navigationController?.viewControllers
                    vcArray?.removeLast()
                    vcArray?.append(vc)
                    self.navigationController?.setViewControllers(vcArray!, animated: true)
                
                case Constant.locationMessage:
                    let latlongArray = item.message.content.split(separator: ",")
                    guard latlongArray.count == 2 else {
                        print("error: latlongArray doesn't have 2 element")
                        return
                    }
                    let lat = Double(latlongArray[0])
                    let long = Double(latlongArray[1])
                    guard lat != nil && long != nil else {
                        print("error: nil lat or long")
                        return
                    }
//                    let vc = ViewLocationVC.instance(lat: lat!, long: long!)
                    let vc = ViewLocationGGMapsVC.instance(lat: lat!, long: long!)
                    self.navigationController?.pushViewController(vc, animated: true)
                
                case Constant.fileMessage:
                    let urlString = item.message.content.split(separator: ",")[0]
                    guard let url = URL(string: String(urlString)) else {
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                case Constant.audioMessage:
                    let cell = self.tableView.cellForRow(at: ip) as! MyAudioMessageCell
                    if cell.isAnimating {
                        cell.stopAnimating()
                    }
                    else {
                        cell.startAnimating()
                        self.viewModel.loadAndPlayAudio(path:  String(item.message.content.split(separator: ",")[0]), ip: ip)
                    }
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
            sendImageTrigger: self.sendImageButton.rx.tap.asDriver(),
            sendNameCardTrigger: self.sendNameCardButton.rx.tap.asDriver(),
            sendLocationMKTrigger: self.sendLocationMKButton.rx.tap.asDriver(),
            sendLocationGGTrigger: self.sendLocationGGButton.rx.tap.asDriver(),
            sendFileTrigger: self.sendFileButton.rx.tap.asDriver())
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
        self.tempImage = resizedImage
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
        if(self.isSendImage) {
            self.viewModel.sendImageMessage(url: photoURL)
        }
        else { //send file
            self.viewModel.sendFileMessage(url: photoURL)
        }
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
            if !self.isEmojiViewHidden {
                showButtonContainerAndHideEmojiView()
                self.isEmojiViewHidden = true
            }
            else {
                showButtonContainer()
            }
        default:   //hide it!
            hideButtonContainer()
        }
        self.isButtonContainerHidden = !self.isButtonContainerHidden
    }
    
    func showHideEmojiView() {
        switch self.isEmojiViewHidden {
        case true: //show it!
            if !self.isButtonContainerHidden {
                showEmojiViewAndHideButtonsContainerView()
                self.isButtonContainerHidden = true
            }
            else {
                showEmojiView()
            }
        default: //hide it!
            hideEmojiView()
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
        if !self.isEmojiViewHidden {
            hideEmojiView()
            self.isEmojiViewHidden = true
        }
        if !self.isButtonContainerHidden {
            hideButtonContainer()
            self.isButtonContainerHidden = true
        }
    }
    
    func openPickContactVC() {
        let pickContactVC = PickContactVC.instance(currentUsername: self.currentUsername, conversation: self.conversation)
        self.navigationController?.pushViewController(pickContactVC, animated: true)
    }
    
    func openPickLocationVC() {
        let pickLocationVC = PickLocationVC.instance(currentUsername: self.currentUsername, conversation: self.conversation)
        self.navigationController?.pushViewController(pickLocationVC, animated: true)
    }
    
    func openPlacePicker() {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        placePicker.modalPresentationStyle = .popover
        
        placePicker.popoverPresentationController?.sourceView = self.sendLocationGGButton
        placePicker.popoverPresentationController?.sourceRect = self.sendLocationGGButton.bounds
        
        self.present(placePicker, animated: true, completion: nil)
    }
    
    func setSendImage() {
        self.isSendImage = true
    }
    
    func setSendFile() {
        self.isSendImage = false
    }
    
    func countDown(ip: IndexPath, time: Int) {
//        let cell = self.tableView.cellForRow(at: ip) as! MyAudioMessageCell
//        cell.startTimer(totalTime: time)
    }

    private func showButtonContainer() {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height - self.buttonsContainer.frame.height)
            self.buttonsContainer.frame = self.buttonsContainer.frame.offsetBy(dx: 0, dy: -self.buttonsContainer.frame.height)
        })
        animator.startAnimation()
    }
    
    private func hideButtonContainer() {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height + self.buttonsContainer.frame.height)
            self.buttonsContainer.frame = self.buttonsContainer.frame.offsetBy(dx: 0, dy: self.buttonsContainer.frame.height)
        })
        animator.startAnimation()
    }
    
    private func showEmojiView() {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height - self.emojiView.frame.height)
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: -self.emojiView.frame.height)
        })
        animator.startAnimation()
    }
    
    private func hideEmojiView() {
        let animator = UIViewPropertyAnimator(duration: 0.15, curve: .linear, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height + self.emojiView.frame.height)
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: self.emojiView.frame.height)
        })
        animator.startAnimation()
    }
    
    private func showEmojiViewAndHideButtonsContainerView() {
        let duration1 = 0.15 * (self.buttonsContainer.frame.height / self.emojiView.frame.height)
        let animator1 = UIViewPropertyAnimator(duration: TimeInterval(duration1), curve: .linear, animations: {
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: -self.buttonsContainer.frame.height)
        })
        animator1.startAnimation()
        let animator2 = UIViewPropertyAnimator(duration: TimeInterval(0.15 - duration1), curve: .linear, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height + self.buttonsContainer.frame.height - self.emojiView.frame.height)
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: -(self.emojiView.frame.height - self.buttonsContainer.frame.height))
            self.buttonsContainer.frame = self.buttonsContainer.frame.offsetBy(dx: 0, dy: self.buttonsContainer.frame.height)
        })
        animator2.startAnimation(afterDelay: TimeInterval(duration1))
    }
    
    private func showButtonContainerAndHideEmojiView() {
        let duration1 = 0.15 * ((self.emojiView.frame.height - self.buttonsContainer.frame.height)/self.emojiView.frame.height)
        let animator1 = UIViewPropertyAnimator(duration: TimeInterval(duration1), curve: .linear, animations: {
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: self.emojiView.frame.height - self.buttonsContainer.frame.height)
            self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: self.tableView.frame.width, height: self.tableView.frame.height + self.emojiView.frame.height - self.buttonsContainer.frame.height)
            self.buttonsContainer.frame = self.buttonsContainer.frame.offsetBy(dx: 0, dy: -self.buttonsContainer.frame.height)
        })
        animator1.startAnimation()
        let animator2 = UIViewPropertyAnimator(duration: TimeInterval(0.15 - duration1), curve: .linear, animations: {
            self.emojiView.frame = self.emojiView.frame.offsetBy(dx: 0, dy: self.buttonsContainer.frame.height)
        })
        animator2.startAnimation(afterDelay: TimeInterval(duration1))
    }
}

extension ChatVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }
}

extension ChatVC : GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Create the next view controller we are going to display and present it.
        let lat = NumberUtils.RoundDoubleTo6DigitsPrecision(input: place.coordinate.latitude)
        let long = NumberUtils.RoundDoubleTo6DigitsPrecision(input: place.coordinate.longitude)
        print("GG place picked: \(lat), \(long)")
        
        self.viewModel.sendLocationMessage(lat: lat, long: long)
        
        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        // In your own app you should handle this better, but for the demo we are just going to log
        // a message.
        NSLog("An error occurred while picking a place: \(error)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        NSLog("The place picker was canceled by the user")
        
        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
    }
}

