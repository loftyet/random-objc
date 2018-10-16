//
//  DataViewController.m
//  Conversion
//
//  Created by l.jiang on 10/15/18.
//  Copyright © 2018 U. of Arizona. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [NSString stringWithFormat:@"%@", self.dataObject[@"index"]];
    self.instructionLabel.text =  self.dataObject[@"instruction"];
}

- (IBAction)onCancel:(id)sender {
    
}

- (IBAction)onRecord:(id)sender {
    
}

@end
