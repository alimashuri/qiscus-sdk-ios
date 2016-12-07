//
//  QCommentDelegate.swift
//  Example
//
//  Created by Ahmad Athaullah on 7/18/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

public protocol QCommentDelegate {
    func didSuccesPostComment(_ comment:QiscusComment)
    func didFailedPostComment(_ comment:QiscusComment)
    func downloadingMedia(_ comment:QiscusComment)
    func didDownloadMedia(_ comment: QiscusComment)
    func didUploadFile(_ comment:QiscusComment)
    func uploadingFile(_ comment:QiscusComment)
    func didFailedUploadFile(_ comment:QiscusComment)
    func didSuccessPostFile(_ comment:QiscusComment)
    func didFailedPostFile(_ comment:QiscusComment)
    func finishedLoadFromAPI(_ topicId: Int)
    func gotNewComment(_ comments:[QiscusComment])
    func didFailedLoadDataFromAPI(_ error: String)
    func didFinishLoadMore()
    func commentDidChangeStatus(Comments comments:[QiscusComment], toStatus: QiscusCommentStatus)
    func performResendMessage(onIndexPath: IndexPath)
    func performDeleteMessage(onIndexPath:IndexPath)
}

