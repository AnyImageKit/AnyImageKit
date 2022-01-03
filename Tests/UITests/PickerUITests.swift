//
//  PickerUITests.swift
//  AnyImageKitUITests
//
//  Created by 蒋惠 on 2020/1/3.
//  Copyright © 2020-2022 AnyImageKit.org. All rights reserved.
//

import XCTest

class PickerUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launchArguments = [
            "-inUITest",
            "-AppleLanguages",
            "(en)",
        ]
        app.launch()
        continueAfterFailure = false
    }

    /// 测试进出控制器
    func testExit() {
        openPreviewController()
        exitToHomeController()
        sleep(0.5)
        openPreviewController()
        exitPreviewControllerBySwipe()
        exitToHomeController()
    }
    
    /// 切换相册
    func testSwitchAlbum() {
        openAlbumController()
        selectLastAlbum()
        openAlbumController(false)
        selectAlbum(idx: 0)
    }
    
    /// 选择照片
    func testSelectPhoto() {
        openPreviewController()
        selectPhotoBySelectButton(count: 3)
        tapDoneButton()
        sleep(2.0)
        openOptionController()
        setOption("Use Original Image", value: nil)
        openPreviewController(false)
        selectPhotoByOriginalImage()
        exitPreviewController()
        tapDoneButton()
        sleep(2.0)
        openPreviewController()
        tapDoneButton()
    }
    
    /// 取消选择图片
    func testUnselectPhoto() {
        openPreviewController()
        selectPhotoBySelectButton(count: 3)
        exitPreviewController()
        let cells = app.collectionViews.children(matching: .cell)
        for i in cells.count-3..<cells.count {
            sleep(0.5)
            selectPhoto(idx: i)
            exitPreviewController()
        }
    }
    
    /// 在已选图片预览中测试跳转
    func testPreviewTool() {
        openPreviewController()
        selectPhotoBySelectButton(count: 3)
        exitPreviewController()
        app.buttons["Preview"].tap()
        sleep(0.5)
        let cells = app.collectionViews.element(boundBy: 1).cells
        for i in 0..<cells.count {
            sleep(0.5)
            cells.element(boundBy: i).tap()
        }
    }
    
    /// 测试预览时滑动
    func testSwipeInPreviewController() {
        openPreviewController()
        let collectionView = app.collectionViews.firstMatch
        for _ in 0...5 {
            collectionView.swipeRight()
        }
        for _ in 0...5 {
            collectionView.swipeLeft()
        }
    }
    
    /// 测试选择上限
    func testSelectLimit() {
        openOptionController()
        setOption("Select Limit", value: "2")
        openPreviewController(false)
        selectPhotoBySelectButton(count: 3)
        app.alerts["Alert"].scrollViews.otherElements.buttons["OK"].tap()
    }
    
    /// 测试播放视频
    func testPlayVideo() {
        openOptionController()
        setOption("Select Options", value: "Video")
        openPreviewController(false)
        app.collectionViews.firstMatch.tap()
        sleep(5.0)
    }
    
    /// 测试选择视频
    func testSelectVideo() {
        openOptionController()
        setOption("Select Options", value: "Video")
        openPreviewController(false)
        selectPhotoBySelectButton(count: 3)
        exitPreviewController()
        tapDoneButton()
    }
}

// MARK: - Function
extension PickerUITests {
    
    /// 点击完成
    func tapDoneButton() {
        app.buttons["Done"].firstMatch.tapAfter(0.5)
    }
    
    /// 切换相册
    func selectAlbum(idx: Int) {
        app.tables.cells.element(boundBy: idx).tapIfElementExists()
    }
    
    /// 选择最后一个相册
    func selectLastAlbum() {
        let cells = app.tables.cells
        cells.element(boundBy: cells.count-1).tap()
    }
    
    /// 选择照片
    func selectPhoto(idx: Int) {
        app.collectionViews.children(matching: .cell).element(boundBy: idx).tap() // Cell
        sleep(0.5)
        app.buttons.element(boundBy: 3).tap() // Select button
    }
    
    /// 通过选择按钮选择图片
    func selectPhotoBySelectButton(count: Int) {
        for i in 0..<count {
            app.buttons.element(boundBy: 3).tap() // Select button
            if i != count-1 {
                app.collectionViews.firstMatch.swipeRight()
            }
        }
    }
    
    /// 通过原图选择图片
    func selectPhotoByOriginalImage() {
        let app = XCUIApplication()
        app.buttons["Original image"].firstMatch.tap()
    }
    
    /// 设置配置项
    func setOption(_ option: String, value: String?) {
        app.tables.staticTexts[option].tap()
        if let value = value {
            app.alerts[option].scrollViews.otherElements.buttons[value].tap()
        }
    }
}

// MARK: - Open/Exit Controller
extension PickerUITests {
    
    /// 退回到主控制器
    func exitToHomeController() {
        exitPreviewController()
        exitPickerController()
        exitResultController()
        exitOptionController()
    }
    
    /// 退出结果控制器 - Example
    func exitResultController() {
        app.navigationBars.firstMatch.buttons["Picker"].tapIfElementExists()
    }
    
    /// 退出配置控制器
    func exitOptionController() {
        app.navigationBars.firstMatch.buttons["AnyImageKit"].tapIfElementExists()
    }
    
    /// 退出相册控制器
    func exitPickerController() {
        let bar = app.navigationBars.firstMatch
        if bar.exists {
            bar.buttons["Cancel"].tapIfElementExists()
        }
    }
    
    /// 退出预览控制器
    func exitPreviewController() {
        app.buttons["Back"].tapIfElementExists()
    }
    
    /// 滑动退出预览控制器
    func exitPreviewControllerBySwipe() {
        app.collectionViews.firstMatch.swipeDown()
    }
    
    /// 进入配置控制器
    func openOptionController(_ exit: Bool = true) {
        if exit {
            exitToHomeController()
        }
        app.tables.staticTexts["Picker"].tapIfElementExists()
    }
    
    /// 进入相册控制器
    func openPickerController(_ exit: Bool = true) {
        if exit {
            exitToHomeController()
        }
        openOptionController(exit)
        let bar = app.navigationBars["Picker"]
        bar.buttons["Open picker"].tapIfElementExists()
    }
    
    /// 进入预览控制器
    func openPreviewController(_ exit: Bool = true) {
        if exit {
            exitToHomeController()
        }
        openPickerController(exit)
        let cells = app.collectionViews.children(matching: .cell)
        cells.element(boundBy: cells.count-1).tapIfElementExists()
        sleep(0.5)
    }
    
    /// 进入切换相册控制器
    func openAlbumController(_ exit: Bool = true) {
        if exit {
            exitToHomeController()
        }
        openPickerController(exit)
        let bar = app.navigationBars.firstMatch
        bar.buttons.element(boundBy: 1).tap()
    }
}
