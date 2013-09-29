//
//  ModalImageView.m
//  YasnayaPolyana2
//
//  Created by GoloVaZa on 29.05.13.
//  Copyright (c) 2013 pbsputnik. All rights reserved.
//

#import "ModalImageView.h"

@implementation ModalImageView

@synthesize closeButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Добавляем кнопку для закрытия
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(60.0, 60.0, 40.0, 40.0);
        [button setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [button addTarget:(id)self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton = button;
        [self addSubview:self.closeButton];
    }
    return self;
}

-(void)closeButtonPressed
{
    [self removeFromSuperview];
}

@end
