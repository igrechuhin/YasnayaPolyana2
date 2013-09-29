//
//  ModalImageView.h
//  YasnayaPolyana2
//
//  Created by GoloVaZa on 29.05.13.
//  Copyright (c) 2013 pbsputnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalImageView : UIImageView
{
    UIButton *_closeButton;
}

@property (nonatomic, retain) UIButton *closeButton;

-(void)closeButtonPressed;

@end
