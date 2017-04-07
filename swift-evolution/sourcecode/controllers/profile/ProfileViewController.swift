import UIKit

class ProfileViewController: UIViewController {

    fileprivate struct Section {
        let title: String
        let proposals: [Proposal]
    }
    
    @IBOutlet fileprivate weak var profileView: ProfileView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    open var profile: Person?
    fileprivate var sections: [Section] = []
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cell to TableView
        self.tableView.registerNib(withClass: ProposalTableViewCell.self)
        self.tableView.registerNib(withClass: ProposalListHeaderTableViewCell.self)
        
        self.tableView.estimatedRowHeight = 164
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Settings
        self.profileView.profile = profile
        self.requestUserDataFromGithub()
        self.tableView.reloadData()
        
        // Title
        if let profile = self.profile, let username = profile.username {
            self.title = "@\(username)"
        }
        
        self.configureSections()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //self.navigationController?.backgroundTransparent()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ProposalDetailViewController,
            let indexPath = self.tableView.indexPathForSelectedRow,
            let destination = segue.destination as? ProposalDetailViewController {
            
            let section = self.sections[indexPath.section]
            let proposal = section.proposals[indexPath.row]
            
            destination.proposal = proposal
        }
    }
}

// MARK: - Requests
extension ProfileViewController {
    fileprivate func configureSections() {
        guard let profile = self.profile else {
            return
        }
        
        if let author = profile.asAuthor, author.count > 0 {
            let section = Section(title: "Author", proposals: author)
            sections.append(section)
        }
        
        if let manager = profile.asManager, manager.count > 0 {
            let section = Section(title: "Review Manager", proposals: manager)
            sections.append(section)
        }
        
        self.tableView.reloadData()
    }
    
    fileprivate func requestUserDataFromGithub() {
        guard let profile = self.profile, let username = profile.username else {
            return
        }
        
        GithubService.profile(from: username) { [weak self] error, github in
            guard let github = github, error == nil else {
                return
            }
            
            self?.profile?.github = github
            self?.profileView.imageURL = github.avatar
        }
    }
}


// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = self.sections.count
        
        guard sections > 0 else {
            return 0
        }

        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].proposals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cell(forRowAt: indexPath) as ProposalTableViewCell
        
        let section = self.sections[indexPath.section]
        let proposal = section.proposals[indexPath.row]
        
        cell.proposal = proposal
        
        return cell
    }
}

// MARK: - UITableView Delegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Config.Segues.proposalDetail.performSegue(in: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.cell(forClass: ProposalListHeaderTableViewCell.self)
        
        let section = self.sections[section]
        headerCell.header = section.title

        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}




