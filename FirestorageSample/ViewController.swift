//
//  ViewController.swift
//  FirestorageSample
//
//  Created by Togami Yuki on 2018/10/21.
//  Copyright © 2018 Togami Yuki. All rights reserved.
//

import UIKit
import Firebase

class newCell:UICollectionViewCell{
    @IBOutlet weak var cellImageView: UIImageView!
}

class ViewController: UIViewController {

    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var photoList:[UIImage] = []
    let margin:CGFloat = 3.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
    
    @IBAction func upLoadBtn(_ sender: UIButton) {
        pickImageFromLibrary()
    }
    
    @IBAction func Read(_ sender: UIButton) {
        getData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




//写真ライブラリのViewを表示する。
extension ViewController: UINavigationControllerDelegate {
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            present(controller, animated: true, completion: nil)
        }
    }
}

//ライブラリから写真を読み込み、Firestorageに保存する。
extension ViewController: UIImagePickerControllerDelegate {
    //写真を読み込んだ時に発動
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : Any]) {
        //Firestorageに保存する処理
        print("memo:Firestorageへの保存を開始")
        if let data = UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage] as! UIImage) {
            //Firestorageにのパス指定と保存処理を記述
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL:"gs://firestoragesample.appspot.com")
            let reference = storageRef.child("images/test.jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                print("memo:metaData",metaData)
                print("memo:error",error)
            })
        }
        dismiss(animated: true, completion: nil)
    }
}

//Firestorageからデータを読み込む処理
extension ViewController{
    func getData(){
        photoList = []
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL:"gs://firestoragesample.appspot.com")
        let islandRef = storageRef.child("images/test.jpg")
        islandRef.getData(maxSize: 1 * 8192 * 8192) { data, error in
            if let error = error {
                print("memo:error",error)
            } else {
                let image = UIImage(data: data!)
                self.photoList.append(image!)
                self.photoCollectionView.reloadData()
                print("memo:photoList",self.photoList)
            }
        }
    }
}







//コレクションViewに関するコード
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //セルの数指定
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoList.count
    }
    //セルのインスタンス化
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! newCell
        cell.cellImageView.image = photoList[indexPath.row]
        
        return cell
    }
    //セルのサイズ指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = photoCollectionView.frame.width//画面の横側
        let cellNum:CGFloat = 3
        let cellSize = (width - margin * (cellNum + 1))/cellNum//一個あたりのサイズ
        return CGSize(width:cellSize,height:cellSize)
    }
    //セル同士の縦の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    //セル同士の横の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
}
