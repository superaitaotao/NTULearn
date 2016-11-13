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
    let baseUrl = "https://ntulearn.ntu.edu.sg"
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
    
    var courseFolders: [CourseInfo] = []
    let excludedCourses = NSSet(array: ["Home Page", "Announcements", "Tools", "Help", "Library Resources", "Information", "Groups"])
    var numberOfCourses: Int = 0
    
    func logIn(handler: @escaping (FetchResult) -> Void){
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
                        self.parseCourseList(data: data!)
                        handler(FetchResult.success(data!))
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
        for li in doc.css("li") {
            courses.append([(li.css("a").first?["href"])!.trimmingCharacters(in: CharacterSet(charactersIn: " ")), (li.css("a").first?.content)!])
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
                    if let data = data {
                        let html = self.getHtmlDoc(data: data)
                        if let ul = html.at_css("ul[id='courseMenuPalette_contents']"),
                            let ulDoc = HTML(html: ul.toHTML!, encoding: .utf8) {
                            let lis = ulDoc.css("li")
                            for li in lis {
                                if let li = li.at_css("a"),
                                    let content = li.content {
                                    if !self.excludedCourses.contains(content) {
                                        folders.append(content)
                                    }
                                }
                            }
                            let lock = NSRecursiveLock()
                            lock.lock()
                            self.courseFolders.append(CourseInfo(name: course[1], folders: folders))
                            if self.courseFolders.count == self.numberOfCourses {
                                MyUserDefault.sharedInstance.saveCourseFolders(courseFolders: self.courseFolders)
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
    
    func getHtmlDoc(data: Data) -> HTMLDocument{
        return HTML(html: String(data: data, encoding: String.Encoding.utf8)!, encoding: .utf8)!
    }
        
}
