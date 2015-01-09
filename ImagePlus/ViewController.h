//
//  ViewController.h
//  ImagePlus
//
//  Created by James Stiehl on 1/8/15.
//  Copyright (c) 2015 James Stiehl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLImageEditor.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLImageEditorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property UIImage *originalImage;

@end

