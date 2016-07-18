//
//  QCommentDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public protocol QCommentDelegate {
    func didSuccesPostComment(indexPath:NSIndexPath)
    func didFailedPostComment(indexPath:NSIndexPath)
    func downloadingMedia(pogressData:QProgressData)
    func didDownloadMedia(progressData: QProgressData)
    func didUploadFile(postData:QProgressData)
    func uploadingFile(progressData:QProgressData)
    func didFailedUploadFile(data:QPostData)
    func didSuccessPostFile(data:QPostData)
    func didFailedPostFile(data:QPostData)
    func gotNewCommentFromAPI(data: QSyncNotifData?)
    func didFailedLoadDataFromAPI(error: String)
}

