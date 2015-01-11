//
//  ViewController.m
//  ImagePlus
//
//  Created by James Stiehl on 1/8/15.
//  Copyright (c) 2015 James Stiehl. All rights reserved.
//

#import "ViewController.h"
@import MessageUI;

@interface ViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.actionButton.enabled = FALSE;
}

- (IBAction)showActions:(id)sender {
    
    UIAlertController *actions = [UIAlertController alertControllerWithTitle:@"Image Options" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Save to Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //[self chooseImageFromLibrary];
        UIImageWriteToSavedPhotosAlbum(self.backgroundImage.image, nil, nil, nil);
    }];
    
    [actions addAction:library];
    
    UIAlertAction *email = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self emailPhoto];

    }];
    
    [actions addAction:email];

    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self presentImageEditorWithImage:self.backgroundImage.image];
    }];
    
    [actions addAction:edit];
    
    UIAlertAction *revert = [UIAlertAction actionWithTitle:@"Revert to Original" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.backgroundImage.image = self.originalImage;

    }];
    
    [actions addAction:revert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actions addAction:cancel];
    
    [self presentViewController:actions animated:YES completion:^{
        
    }];
}


- (IBAction)showAddImages:(id)sender {
    
    UIAlertController *addMedia = [UIAlertController alertControllerWithTitle:@"Add Image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseImageFromLibrary];
    }];
    
    [addMedia addAction:library];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePicture];
    }];
    
    [addMedia addAction:camera];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [addMedia addAction:cancel];
    
    [self presentViewController:addMedia animated:YES completion:^{
        
    }];
    
}

-(void) chooseImageFromLibrary {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.originalImage = chosenImage;
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:chosenImage];
    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)takePicture{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];

        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = YES;

        [self presentViewController:picker animated:YES completion:^{
            
        }];
    } else {
        UIAlertController *noCamera = [UIAlertController alertControllerWithTitle:@"Camera Error!" message:@"No camera available" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        [noCamera addAction:confirm];
        [self presentViewController:noCamera animated:YES completion:nil];
        
    }
    
}

- (void)presentImageEditorWithImage:(UIImage*)image
{
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    editor.delegate = self;
    
    [self presentViewController:editor animated:YES completion:nil];
}

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    self.backgroundImage.image = image;
    self.actionButton.enabled = TRUE;
    [self saveImage:image];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

-(void)emailPhoto {
    
    if([MFMailComposeViewController canSendMail]){
       MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
       email.mailComposeDelegate = self;
       [email setSubject:@"Image from Image Plus"];
       [email addAttachmentData:self.imageData mimeType:@"image/jpeg" fileName:@"chosen.jpg"];
       [email setMessageBody:@"Checkout this awesome photographic image!" isHTML:FALSE];
       [self presentViewController:email animated:TRUE completion:nil];
        
    } else {
        
        UIAlertController *noEmail = [UIAlertController alertControllerWithTitle:@"Email Error!" message:@"Cannot Email From This Device" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        
        [noEmail addAction:confirm];
        [self presentViewController:noEmail animated:YES completion:nil];
        
    }

}

- (void)saveImage: (UIImage *)image
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"chosen.png"];
        NSData* data = UIImageJPEGRepresentation(self.backgroundImage.image,1.0);
        self.imageData = data;
        [data writeToFile:path atomically:YES];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    NSLog(@"%@", error);
    [self dismissViewControllerAnimated:YES completion:nil];
    self.backgroundImage.image = nil;
    self.actionButton.enabled = FALSE;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)successAlert{
    //ad an alert saying that image was sent
    //THIS IS NOT WORKING
    NSString *message = [NSString stringWithFormat:@"Your image was succesfully emailed!"];
    UIAlertController *emailSent = [UIAlertController alertControllerWithTitle:@"Success!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [emailSent addAction:ok];
}

@end
