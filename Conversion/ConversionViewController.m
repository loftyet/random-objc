//
//  ConversionViewController.m
//  Conversion
//
//  Created by l.jiang on 10/19/18.
//  Copyright © 2018 U. of Arizona. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import CoreMedia.CMTime;
@import ParseLiveQuery;
@import Parse;
@import SVProgressHUD;
@import AVKit;

#import "Message.h"
#import "Sample.h"
#import "ConversionViewController.h"
#import "AAPLPlayerView.h"


@interface ConversionViewController ()<UITextViewDelegate>
@property AVPlayerItem *playerItem;

@property (readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) PFLiveQueryClient *client;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;

@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UIButton *correctButton;
@property (nonatomic, weak) IBOutlet UILabel *agentSaysContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *agentThinksContentLabel;
@property (nonatomic, weak) IBOutlet UITextView *userSaysTextView;
@property (nonatomic, strong) AVPlayer *avPlayer;

@end

@implementation ConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.client = [[PFLiveQueryClient alloc] init];
    self.query = [PFQuery queryWithClassName:@"Message"];
    [self.query whereKey:@"objectId" notEqualTo:@"asdfas"];
    self.subscription = [self.client subscribeToQuery:self.query];
    
    [self.subscription addSubscribeHandler:^(PFQuery<Message *> * _Nonnull query) {
        NSLog(@"subscribed");
    }];
    [self.subscription addCreateHandler:^(PFQuery<Message *> * _Nonnull query, PFObject * _Nonnull obj) {
        NSLog(@"created %@", obj[@"playerName"]);
        
    }];
    [self.subscription addUpdateHandler:^(PFQuery * _Nonnull query, PFObject * _Nonnull obj) {
        NSLog(@"Update");
    }];
    
    [self.subscription addErrorHandler:^(PFQuery * _Nonnull query, NSError * _Nonnull error) {
        NSLog(@"Error");
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }];
}

-(void)updateUI:(PFObject *)message {
    if ([message isKindOfClass:[message class]]) {
        Message *aMessage = (Message *)message;
        self.agentSaysContentLabel.text = aMessage.agentSays;
        self.agentThinksContentLabel.text = aMessage.agentThinks;
        
        Sample *sample = aMessage.videoSample;
        
        //2018-10-30-04-47-0.mov
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        NSURL *outputFileURL = [documentsURL URLByAppendingPathComponent:sample.videoFile.name];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[outputFileURL absoluteString]]) {
            [self playVideo:outputFileURL];
        } else {
            PFFile *videoFile = sample.videoFile;
            [videoFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                } else {
                    NSError *error = nil;
                    [data writeToFile:[outputFileURL absoluteString] options:NSDataWritingAtomic error:&error];
                    NSLog(@"Write returned error: %@", [error localizedDescription]);
                    if (error == nil) {
                       [self playVideo:outputFileURL];
                    }
                }
            }];
           
        }
    }
}



#pragma mark - Play video
-(void)playVideo:(NSURL*) url {
//    NSURL *aUrl = [[NSURL alloc] initWithString:@"https://s3-eu-west-1.amazonaws.com/alf-proeysen/Bakvendtland-MASTER.mp4"];
//
    NSLog(@"played file :%@", url.absoluteString);
    // create a player view controller
    self.avPlayer = [AVPlayer playerWithURL:url];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    
    controller.view.frame = CGRectMake(124.5,75,126,163);
    controller.player = self.avPlayer;
//    controller.showsPlaybackControls = YES;
    [self.avPlayer pause];
    [self.avPlayer play];
}


#pragma mark - IBAction

- (IBAction)onReset:(id)sender {
    self.agentSaysContentLabel.text = @"";
    self.agentThinksContentLabel.text = @"";
    self.userSaysTextView.text = @"";
}

- (IBAction)onStop:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Quit or Continue" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tag = 3;
    UIAlertAction* quitAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                              {
                                  if (self.player.rate != 1.0) {
                                      // not playing foward so play
                                      if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
                                          // at end so got back to begining
                                          self.currentTime = kCMTimeZero;
                                      }
                                      [self.player play];
                                  } else {
                                      // playing so pause
                                      [self.player pause];
                                  }
                                  [self dismissViewControllerAnimated:YES completion:^{
                                      
                                  }];
                                  
                              }];
    [alertController addAction:quitAction];
    UIAlertAction* continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                              {
                                  
                                  
                              }];
    [alertController addAction:continueAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)onCorrect:(id)sender {
    self.userSaysTextView.text = @"";
}

- (IBAction)onShare:(id)sender {
    [SVProgressHUD showInfoWithStatus:@"not ready yet"];
}


- (IBAction)onSubscribe:(id)sender {
    [SVProgressHUD showInfoWithStatus:@"not ready yet"];
}


#pragma mark - UITextView Delegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -200., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y +200., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}
@end
