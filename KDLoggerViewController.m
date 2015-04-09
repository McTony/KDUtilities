//
//  KDLoggerViewController.m
//  Moving
//
//  Created by Blankwonder on 8/12/14.
//  Copyright (c) 2014 Sensoro. All rights reserved.
//

#import "KDLoggerViewController.h"
#import "KDLogger.h"

@interface KDLoggerViewController () {
    UITextView *_textView;

    NSMutableString *_content;
}

@end

@implementation KDLoggerViewController

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    __strong static id sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

+ (UINavigationController *)sharedNavigationController {
    static UINavigationController *__nvc;
    if (!__nvc) {
        __nvc = [[UINavigationController alloc] initWithRootViewController:[self sharedInstance]];
    }
    ((KDLoggerViewController *)[self sharedInstance]).navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:[self sharedInstance] action:@selector(dismiss)];
    ((KDLoggerViewController *)[self sharedInstance]).navigationItem.title = @"Console";
    
    return __nvc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _textView = [[UITextView alloc] init];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _textView.frame = self.view.bounds;

    [self.view addSubview:_textView];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setupHandler {
    KDDebuggerSetLogCustomActionBlock(^(NSString *message) {
        dispatch_async( dispatch_get_main_queue(),^{
            [_textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:message]];
            [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
        });
    });
}

- (void)scrollToBottom {
    [_textView scrollRectToVisible:CGRectMake(0, _textView.contentSize.height - 1, 320, 1) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
