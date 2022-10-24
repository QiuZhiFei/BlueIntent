//
//  ViewController.swift
//  BlueIntent
//
//  Created by qiuzhifei on 10/08/2020.
//  Copyright (c) 2020 qiuzhifei. All rights reserved.
//

import UIKit
import BlueIntent
import PhotosUI

class ViewController: UIViewController {

  private let livePhotoView = PHLivePhotoView()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    livePhotoView.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
    view.addSubview(livePhotoView)

    showPickerController()

//    combiningLivePhoto()
  }
  
}

extension ViewController {

  func combiningLivePhoto() {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetCreationRequest.forAsset()
      let options = PHAssetResourceCreationOptions.init()
      let imageUrl = Bundle.main.path(forResource: "001", ofType: "HEIC")!
      let vidoUrl = Bundle.main.path(forResource: "0011", ofType: "MOV")!
      request.addResource(with: .pairedVideo, fileURL: URL.init(fileURLWithPath: vidoUrl), options: options)
      request.addResource(with: .photo, fileURL: URL.init(fileURLWithPath: imageUrl), options: options)
    }) { (boo, error) in
      if boo {
        print("保存到手机成功")
      }else {
        print(error?.localizedDescription ?? "error")
      }
    }
  }

  func showPickerController() {
    if #available(iOS 10.3, *) {
      if let asset: PHAsset = fetchPhotos(.smartAlbumLivePhotos, fetchLimit: 10)?.lastObject {
        assert(asset.mediaSubtypes == .photoLive)

        // HEIC + MOV
        let resources = PHAssetResource.assetResources(for: asset)
        //        assert(resources.count == 2)
        let photoResource: PHAssetResource? = resources.filter({ $0.type == .photo }).first
        let pairedVideoResource: PHAssetResource? = resources.filter({ $0.type == .pairedVideo }).first

        // 获取 live photo
        fetchLivePhoto(asset) { [weak self] livePhoto, _ in
          guard let sself = self else { return }
          sself.livePhotoView.livePhoto = livePhoto
          sself.livePhotoView.startPlayback(with: .full)
        }

        // 获取 image
        if let photoResource = photoResource {
          var photoData = Data()
          PHAssetResourceManager.default().requestData(for: photoResource,
                                                       options: nil) { data in
            photoData.append(data)
          } completionHandler: { error in
            if let error = error {
              debugPrint("export photo data error: \(error)")
            } else {
              let path = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/1.HEIC")
              try? photoData.write(to: path)
              self.saveDataToAlbum(path, type: photoResource.type, nil)
            }
          }
        }

        // 获取 video
        if let pairedVideoResource = pairedVideoResource {
          var videoData = Data()
          PHAssetResourceManager.default().requestData(for: pairedVideoResource,
                                                       options: nil) { data in
            videoData.append(data)
          } completionHandler: { error in
            if let error = error {
              debugPrint("export video data error: \(error)")
            } else {
              let path = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/1.MOV")
              try? videoData.write(to: path)
              self.saveDataToAlbum(path, type: .video, nil)
            }
          }
        }
      }
    } else {
      // Fallback on earlier versions
    }
  }

  func saveDataToAlbum(_ outputURL: URL, type: PHAssetResourceType, _ completion: ((Error?) -> Void)?) {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetCreationRequest.forAsset()
      request.addResource(with: type, fileURL: outputURL, options: nil)
    }) { (result, error) in
      DispatchQueue.main.async {
        if let error = error {
          print("save error: \(error.localizedDescription)")
        } else {
          print("save success")
        }
        completion?(error)
      }
    }
  }

  func fetchLivePhoto(_ asset: PHAsset, completion: ((PHLivePhoto?, [AnyHashable : Any]?) -> Void)?) {
    PHImageManager.default().requestLivePhoto(for: asset,
                                              targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                              contentMode: .aspectFit,
                                              options: nil) { livePhoto, info in
      completion?(livePhoto, info)
    }
  }

  func fetchVideo(_ asset: PHAsset) {
    let opts = PHVideoRequestOptions()
    opts.isNetworkAccessAllowed = true
    //    opts.version = .current
    //    opts.deliveryMode = .automatic

    PHImageManager.default().requestAVAsset(forVideo: asset,
                                            options: opts) { avAsset, _, _ in
      debugPrint("avAsset == \(avAsset)")
      guard let avAsset = avAsset else { return }
      //Output URL
      let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
      let outputURL = URL(fileURLWithPath: "\(path)/1.mov")
      debugPrint("outputURL == \(outputURL)")

      //Begin slow mo video export
      guard let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality) else { return }
      exporter.outputURL = outputURL
      exporter.outputFileType = .mov
      exporter.shouldOptimizeForNetworkUse = true

      exporter.exportAsynchronously {
        if exporter.status == .completed {
          debugPrint("export outputURL == \(exporter.outputURL)")
        } else {
          assert(false, "Should not be here")
        }
      }
    }
  }

  // 获取相册图片
  func fetchPhotos(_ subtype: PHAssetCollectionSubtype, fetchLimit: Int) -> PHFetchResult<PHAsset>? {
    // 相册
    guard let collection: PHAssetCollection = {
      let opts = PHFetchOptions()
      opts.predicate = NSPredicate(format: "estimatedAssetCount != %d", NSNotFound)
      return PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                     subtype: subtype,
                                                     options: opts).firstObject
    }() else {
      assert(false, "Should not be here")
      return nil
    }
    // 图片
    let opts = PHFetchOptions()
    opts.fetchLimit = fetchLimit
    let result = PHAsset.fetchAssets(in: collection, options: opts)
    return result
  }

}
