//
//  NTULearnFetcher.swift
//  NewNTULearn
//
//  Created by shutao xu on 12/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import Foundation
import Kanna

let userAgents = ["Mozilla/5.0 (Windows NT 6.1; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36",
              "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36",
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.56 (KHTML, like Gecko) Version/9.0 Safari/601.1.56",
              "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36",
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7",
              "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko]"]

enum FetchResult {
    case logInError(Error)
    case courseListRetrievalError(Error)
    case fileDownloadError(Error)
    case success(Data)
}

class NTULearnFetcher{
    static let DownloadFinishedKey = "DownloadFinishedKey"
    
    let baseUrl = "https://ntulearn.ntu.edu.sg"
    let baseFileUrl = "/Users/shutaoxu/NTULearn"
    let userName = "sxu007"
    let password = "Galaxy1234#"
    let session: URLSession = URLSession.shared
    let logInQueue : OperationQueue = {
        let queue = OperationQueue()
        print("establishing log in queue")
        queue.name = "log in queue"
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    let downloadFileQueue : OperationQueue = {
        let queue = OperationQueue()
        queue.name = "download file queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    let helperQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "helper queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var courseFolders: [CourseInfo] = []
    var noOfDownloadedFiles: Int = 0
    
    let excludedCourses = NSSet(array: ["Home Page", "Announcements", "Tools", "Help", "Library Resources", "Information", "Groups"])
    var numberOfCourses: Int = 0
    let fileManager = FileManager.default
    
    var courseListCompleteHandler: (() -> Void)?
    
    var popover: PopoverViewController
    
    init(popover: PopoverViewController) {
        self.popover = popover
    }
    
    func logIn(handler: @escaping (FetchResult) -> Void){
        logInQueue.cancelAllOperations()
        print("logging in ...")
        var logInRequest = URLRequest(url: URL(string: baseUrl + "/webapps/login/")!);
        let postString = "user_id=\(userName)&password=\(password)"
        logInRequest.httpMethod = "POST"
        logInRequest.httpBody  = postString.data(using: String.Encoding.utf8)
        logInRequest.allHTTPHeaderFields = ["User-Agent" : userAgents[Int(arc4random_uniform(UInt32(userAgents.count)))]]
        session.dataTask(with: logInRequest, completionHandler: { (data, response, error) -> Void in
            if (data == nil) {
                handler(FetchResult.logInError(error!))
            } else {
                let dataString = String(data: data!, encoding: String.Encoding.utf8)!
                if(dataString.contains("Course List")) {
                    handler(FetchResult.success(data!))
                } else {
                    handler(FetchResult.logInError(error!))
                }
            }
        }).resume()
    }
    
    func getCourseList(handler: @escaping (FetchResult) -> Void) {
        courseFolders = []
        logIn( handler: { (fetchResult) -> Void in
            switch fetchResult{
                
            case .success:
                var courseListRuquest = URLRequest(url: URL(string: self.baseUrl + "/webapps/portal/execute/tabs/tabAction")!)
                let postParams = "action=refreshAjaxModule&modId=_22_1&tabId=_31525_1&tab_tab_group_id=_13_1"
                courseListRuquest.httpMethod = "POST"
                courseListRuquest.httpBody = postParams.data(using: String.Encoding.utf8)
                self.session.dataTask(with: courseListRuquest, completionHandler: {(data, response, error) -> Void in
                    if (data == nil) {
                        handler(FetchResult.courseListRetrievalError(error!))
                    } else {
                        self.courseListCompleteHandler = {() -> Void in handler(FetchResult.success(data!))}
                        self.parseCourseList(data: data!)
                    }
                }).resume()
            default:
                handler(fetchResult)
            }
        })
    }


//    <li>
//        <img alt='' src='/images/ci/icons/bookopen_li.gif' width='12' height='12' />
//        <a href=" /webapps/blackboard/execute/launcher?type=Course&id=_38071_1&url=" target="_top">14S2REP: CAREERTOOL</a>
//        <div class='courseInformation'>
//            <span class='courseRole'>Instructor:</span>
//        <span class='name'>. Chew Hwee Leng Christine;&nbsp;&nbsp;</span>
//        <span class='name'>. Huang Junxian;&nbsp;&nbsp;</span>
//        <span class='name'>. Wong Mun Yee Lora;&nbsp;&nbsp;</span></div>
//    </li>
    
    private func parseCourseList(data: Data) {
        let doc = getHtmlDoc(data: data)
        var courses : [[String]] = []
        if let lis = doc?.css("li") {
            for li in lis{
                courses.append([(li.css("a").first?["href"])!.trimmingCharacters(in: CharacterSet(charactersIn: " ")), (li.css("a").first?.content)!])
            }
        }
        parseCourseFolders(courses: courses)
    }
    
//    <ul id="courseMenuPalette_contents" class="courseMenu">
//        <li id="paletteItem:_189559_1" class="clearfix ">
//            <a href="/webapps/blackboard/content/launchLink.jsp?course_id=_22839_1&tool_id=_136_1&tool_type=TOOL&mode=view&mode=reset" target="_self">
//                <span title="Announcements">Announcements</span>
//            </a>
//        </li>
//    </ul>
    
    private func parseCourseFolders(courses: [[String]]) {
        numberOfCourses = courses.count
        for course in  courses{
            addCourseToQueue(course: course)
        }
    }
    
    func addCourseToQueue(course: [String]) {
        let getFolderListRequest = URLRequest(url: URL(string: baseUrl + course[0])!)
        logInQueue.addOperation({ () -> Void in
            self.session.dataTask(with: getFolderListRequest, completionHandler: { (data, response, error) -> Void in
                if data == nil {
                    print("\(getFolderListRequest.url) failed to load")
                } else {
                    var folders: [String] = []
                    var foldersUrl: [String] = []
                    if let data = data {
                        if let html = self.getHtmlDoc(data: data),
                            let ul = html.at_css("ul[id='courseMenuPalette_contents']"),
                            let ulDoc = HTML(html: ul.toHTML!, encoding: .utf8) {
                            let lis = ulDoc.css("li")
                            for li in lis {
                                if let li = li.at_css("a"),
                                    let content = li.content,
                                    let link = li["href"]{
                                        if !self.excludedCourses.contains(content) {
                                            folders.append(content)
                                            foldersUrl.append(link)
                                        }
                                }
                            }
                            
                            let lock = NSRecursiveLock()
                            lock.lock()
                            self.courseFolders.append(CourseInfo(name: course[1], folders: folders, foldersUrl: foldersUrl))
                            if self.courseFolders.count == self.numberOfCourses {
                                MyUserDefault.sharedInstance.saveCourseFolders(courseFolders: self.courseFolders)
                                self.courseListCompleteHandler?()
                            }
                            lock.unlock()
                        }
                    }
                }
            }).resume()
        })
    }

    
    func writeToFile(s: String) {
        let s = s
        if var dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first{
            dir.appendPathComponent("file.txt")
            do {
                try s.write(to: dir, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                
            }
        }
    }
    
    func getHtmlDoc(data: Data) -> HTMLDocument?{
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return HTML(html: string, encoding: .utf8)
        }
        return nil
    }
    
    func download() {
        let goDownload = {
            self.downloadFileQueue.cancelAllOperations()
            self.noOfDownloadedFiles = 0
            self.setDownloadMonitor()
            
            let courses: [CourseInfo] = MyUserDefault.sharedInstance.getCourseFolders()
            
            var path: String
            var folderName: String
            var folderUrl: String
            for course in courses {
                if course.isChecked.value {
                    print ("downloading \(course.name)")
                    for i in 0 ..< course.folders.count {
                        if course.foldersChecked[i].value {
                            folderName = course.folders[i]
                            path = self.baseFileUrl + "/" + course.name + "/" + folderName
                            folderUrl = course.foldersUrl[i]
                            self.downloadRec(url: self.getUrl(url: folderUrl), path: path ,courseName: course.name)
                        }
                    }
                }
            }
        }
        
        logIn(handler: { (fetchResult) -> Void in
            switch fetchResult{
            case .success:
                goDownload()
            default:
                break
            }
        })
    }
    
    func setDownloadMonitor() {
        helperQueue.addOperation {
            while true {
                let num1 = self.noOfDownloadedFiles
                //assume that no file takes less than 20 seconds to download...
                sleep(20)
                let num2 = self.noOfDownloadedFiles
                if num2 != num1 {
                    continue
                } else {
                    print("download finished")
                    NotificationCenter.default.post(name: Notification.Name(NTULearnFetcher.DownloadFinishedKey), object: nil)
                    break
                }
            }
        }
    }
    
    private func downloadFile(url: String, path: String, courseName: String) {
        downloadFileQueue.addOperation({() -> Void in
            self.session.downloadTask(with: URL(string: url)!, completionHandler: { (url, response, error) -> Void in
                if error != nil {
                    print (error.debugDescription)
                    return
                }
                if let url = url {
                    if !self.fileManager.fileExists(atPath: path) {
                        try! self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    let desUrl = URL(fileURLWithPath: path + "/" + response!.suggestedFilename!, isDirectory: false)
                    
                    if !self.fileManager.fileExists(atPath: desUrl.path) && !(response?.suggestedFilename?.contains(".html"))! {
                        print("downloaded \(desUrl.path)")
                        do {
                            try self.fileManager.moveItem(at: url, to: desUrl)
                            self.addRecentFile(file: FileInfo(fileName: (response?.suggestedFilename)!, courseName: courseName, syncDate: Date(), fileUrl: desUrl))
                        } catch is Error{
                            print ("error: \(desUrl.path)")
                        }
                    }
                }
            }).resume()
        })
        
 
    }
    
    private func addRecentFile(file: FileInfo) {
        let lock = NSRecursiveLock()
        lock.lock()
        popover.recentFiles.insert(file, at: 0)
        if  popover.recentFiles.count == 16 {
            popover.recentFiles.remove(at: 15)
        }
        noOfDownloadedFiles += 1
        OperationQueue.main.addOperation({() -> Void in
            self.popover.tableView.reloadData()
        })
        lock.unlock()
    }
    
    private func downloadRec(url: String, path: String, courseName: String) {
        let urlRequest = URLRequest(url: URL(string:url)!)
        logInQueue.addOperation {
            self.session.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
                if let data = data,
                    let html = self.getHtmlDoc(data: data){
                    //attachments first
                    let attachmentLists = html.css("ul[class*='attachments']")
                    for attachmentList in attachmentLists {
                        let attachmentLinks = attachmentList.css("a")
                        for link in attachmentLinks {
                            if let linkk = link["href"] {
                                self.downloadFile(url: self.getUrl(url: linkk), path: path, courseName: courseName)
                            }
                        }
                        
                    }
                    
                    let lis = html.css("li[id*='contentListItem']")
                    for li in lis {
                        let links = li.css("a")
                        for link in links {
                           //contains onclick attribute
                            if link["onclick"] != nil {
                                self.downloadFile(url:  self.getUrl(url: link["href"]!), path: path, courseName: courseName)
                            } else {
                                self.downloadRec(url:  self.getUrl(url: link["href"]!), path: path + "/" + link.content!, courseName: courseName)
                            }
                        }
                    }
                }
            }).resume()
        }
    }
    
    private func getUrl(url : String) -> String {
        if url.characters.count == 0 {
            return ""
        }
        
        if url.characters.first! == "/" {
            return baseUrl + url
        } else {
            return url
        }
    }
        
}
