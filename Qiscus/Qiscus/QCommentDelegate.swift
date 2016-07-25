//
//  QCommentDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public protocol QCommentDelegate {
    func didSuccesPostComment(comment:QiscusComment)
    func didFailedPostComment(comment:QiscusComment)
    func downloadingMedia(comment:QiscusComment)
    func didDownloadMedia(comment: QiscusComment)
    func didUploadFile(comment:QiscusComment)
    func uploadingFile(comment:QiscusComment)
    func didFailedUploadFile(comment:QiscusComment)
    func didSuccessPostFile(comment:QiscusComment)
    func didFailedPostFile(comment:QiscusComment)
    func finishedLoadFromAPI(topicId: Int)
    func gotNewComment(comments:[QiscusComment])
    func didFailedLoadDataFromAPI(error: String)
}

