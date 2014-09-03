//
//  ReadPdfViewController.m
//  TradingRisk
//
//  Created by Hector on 9/3/14.
//  Copyright (c) 2014 Hector. All rights reserved.
//

#import "ReadPdfViewController.h"

#import "ReaderBookDelegate.h"
#import "ReaderViewController.h"

@interface ReadPdfViewController () <ReaderViewControllerDelegate>

@end

@implementation ReadPdfViewController

UIWindow *mainWindow; // Main App Window
ReaderViewController *readerViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];

//    
//    mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; // Main application window
//    
//	mainWindow.backgroundColor = [UIColor grayColor]; // Neutral gray window background color
    
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed
	{
		readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
		[self presentViewController:readerViewController animated:YES completion:NULL];


	}
    
//	[mainWindow makeKeyAndVisible];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    NSLog(@"Cerrando");
	[self dismissViewControllerAnimated:YES completion:NULL];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
