//
//  WebViewController.h
//  PageControlExample
//
//  Created by GoloVaZa on 07.04.13.
//
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>
{
    int pageNumber;
    UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;

- (id)initWithPageNumber:(int)page;
- (void)changeOrientation:(UIDeviceOrientation)orientation;

@end
