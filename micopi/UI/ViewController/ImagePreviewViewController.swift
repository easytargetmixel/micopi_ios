import UIKit

class ImagePreviewViewController: UIViewController {
    
    // MARK: - Values
    
    var contactWrapper: ContactHashWrapper!
    
    // MARK: IB

    @IBOutlet var viewModel: ContactHashWrapperViewModel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var contactDisplayNameLabel: UILabel!
    @IBAction func assignButtonTouched(_ sender: Any) {
        assignImageToContact()
    }
    @IBAction func previousImageButtonTouched(_ sender: Any) {
        generatePreviousImage()
    }
    @IBAction func nextImageButtonTouched(_ sender: Any) {
        generateNextImage()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showBottomBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideBottomBar()
    }
    
    // MARK: - Implementations
    
    fileprivate func setupViewModel() {
        viewModel.displayName.bind = {
            [unowned self] in
            self.contactDisplayNameLabel.text = $0
        }
        viewModel.generatedImage.bind = {
            [unowned self] in
            self.previewImageView.image = $0
        }
        viewModel.isGenerating.bind = {
            [unowned self] in
            if $0 {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
        }
        viewModel.contactWrapper = contactWrapper
    }
    
    fileprivate func showBottomBar() {
        navigationController?.isToolbarHidden = false
    }
    
    fileprivate func hideBottomBar() {
        navigationController?.isToolbarHidden = true
    }
    
    fileprivate func assignImageToContact() {
        viewModel.assignImageToContact()
    }
    
    fileprivate func generatePreviousImage() {
        viewModel.generatePreviousImage()
    }
    
    fileprivate func generateNextImage() {
        viewModel.generateNextImage()
    }
}
