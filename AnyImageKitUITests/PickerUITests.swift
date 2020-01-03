//
//  PickerUITests.swift
//  AnyImageKitUITests
//
//  Created by 蒋惠 on 2020/1/3.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
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
    }
    
    /// 选择照片
    func testSelectPhoto() {
        selectPhotoBySelectButton()
        tapDoneButton()
        sleep(2.0)
        selectPhotoByOriginalImage()
        tapDoneButton()
        sleep(2.0)
        openPreviewController()
        tapDoneButton()
    }
    
    /// 取消选择图片
    func testUnselectPhoto() {
        selectPhotoBySelectButton()
        let cells = app.collectionViews.children(matching: .cell)
        for i in cells.count-3..<cells.count {
            sleep(0.5)
            selectPhoto(idx: i)
            exitPreviewController()
        }
    }
    
    /// 在已选图片预览中测试跳转
    func testPreviewTool() {
        selectPhotoBySelectButton()
        let cells = app.collectionViews.element(boundBy: 1).cells
        app.collectionViews.children(matching: .cell).element(boundBy: cells.count-3).tap()
        for i in 0..<cells.count {
            sleep(0.5)
            cells.element(boundBy: i).tap()
        }
    }
}

// MARK: - Function
extension PickerUITests {
    
    /// 点击完成
    func tapDoneButton() {
        app.buttons["Done"].firstMatch.tapAfter(0.5)
    }
    
    /// 切换相册
    func switchAlbum(idx: Int) {
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
        app.buttons.element(boundBy: 3).tap() // Select button
    }
    
    /// 通过预览按钮选择图片
    func selectPhotoBySelectButton() {
        openPickerController()
        let cells = app.collectionViews.children(matching: .cell)
        for i in cells.count-3..<cells.count {
            sleep(0.5)
            selectPhoto(idx: i)
            exitPreviewController()
        }
    }
    
    /// 通过原图选择图片
    func selectPhotoByOriginalImage() {
        openPreviewController()
        let app = XCUIApplication()
        app.buttons["Original image"].firstMatch.tap()
        exitPreviewController()
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
    func openOptionController() {
        exitToHomeController()
        app.tables.staticTexts["Picker"].tap()
    }
    
    /// 进入相册控制器
    func openPickerController() {
        exitToHomeController()
        openOptionController()
        let bar = app.navigationBars["Picker"]
        bar.buttons["Open picker"].tap()
    }
    
    /// 进入预览控制器
    func openPreviewController() {
        exitToHomeController()
        openPickerController()
        let cells = app.collectionViews.children(matching: .cell)
        cells.element(boundBy: cells.count-1).tap()
    }
    
    /// 进入切换相册控制器
    func openAlbumController() {
        exitToHomeController()
        openPickerController()
        let bar = app.navigationBars.firstMatch
        bar.buttons.element(boundBy: 1).tap()
    }
}
