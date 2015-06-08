//
//  KDLoggerViewController.m
//  Moving
//
//  Created by Blankwonder on 8/12/14.
//  Copyright (c) 2014 Sensoro. All rights reserved.
//

#import "KDLoggerViewController.h"
#import "KDLogger.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface KDLoggerViewController () {
    UITextView *_textView;

    NSFileHandle *_logFileHandler;
}

@end

@implementation KDLoggerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView {
    _textView = [[UITextView alloc] init];
    _textView.editable = NO;
    
    self.view = _textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _logFileHandler = [NSFileHandle fileHandleForReadingAtPath:KDDebuggerGetLogFilePath()];
    
    __weak KDLoggerViewController *weakself = self;
    [_logFileHandler setReadabilityHandler:^(NSFileHandle *handler) {
        NSData *data = [handler readDataToEndOfFile];
        
        dispatch_async( dispatch_get_main_queue(),^{
            [((UITextView *)weakself.view).textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
            [weakself performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
        });
        
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(copyToPasteboard)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)copyToPasteboard {
    [[UIPasteboard generalPasteboard] setString:_textView.text];
    
    [KDAlertView showMessage:@"Copied to pasteboard" cancelButtonTitle:@"OK"];
}

- (void)scrollToBottom {
    [_textView scrollRectToVisible:CGRectMake(0, _textView.contentSize.height - 1, 320, 1) animated:YES];
}

- (void)dealloc {
    [_logFileHandler setReadabilityHandler:nil];
    [_logFileHandler closeFile];
}

@end
