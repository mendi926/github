//
//  AssocViewController.m
//  WordAssoc
//
//  Created by Armend H on 02/08/15.
//  Copyright (c) 2015 Armend H. All rights reservfed.
//

#import "AssocViewController.h"
#import "AssocStore.h"
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>
#import "NSString+Levenshtein.h"



@interface AssocViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *fieldA;
@property (weak, nonatomic) IBOutlet UIButton *fieldB;
@property (weak, nonatomic) IBOutlet UIButton *fieldC;
@property (weak, nonatomic) IBOutlet UIButton *fieldD;
@property (weak, nonatomic) IBOutlet UIButton *currentAssoc;


@property (weak, nonatomic) IBOutlet UITextField *textFieldZ;

@property (nonatomic) BOOL didRevealField;

@end

@implementation AssocViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
        
        int selectedAssocFromDefaults = (int)[defaults integerForKey: @"selectedAssoc"];
        
        _selectedAssoc = selectedAssocFromDefaults == 0 ? 1 : selectedAssocFromDefaults;
        _didRevealField = NO;
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.fieldA setTag:0];
    [self.fieldB setTag:1];
    [self.fieldC setTag:2];
    [self.fieldD setTag:3];
    [self.textFieldZ setTag:4];
    
    self.textFieldZ.returnKeyType = UIReturnKeyDone;
    self.textFieldZ.delegate = self;
    
    [self setAssoc];
   
}



- (IBAction)changeLetter:(id)sender {

    int index = [self segmentIndex];
    
    [self.fieldA setTitle:self.assocSetProgress[index] forState:UIControlStateNormal];
    [self.fieldB setTitle:self.assocSetProgress[index+1] forState:UIControlStateNormal];
    [self.fieldC setTitle:self.assocSetProgress[index+2] forState:UIControlStateNormal];
    [self.fieldD setTitle:self.assocSetProgress[index+3] forState:UIControlStateNormal];
    
    BOOL enab;
    
    if (index == 0) {
        enab = NO;
    } else {
        enab = YES;
    }
    
    self.fieldA.enabled = enab;
    self.fieldB.enabled = enab;
    self.fieldC.enabled = enab;
    self.fieldD.enabled = enab;
    
    
    self.textFieldZ.text = self.assocSetProgress[index+4];

}

- (IBAction)revealField:(id)sender {
    
    int index = [self segmentIndex];
    
    int field = (int)[sender tag];
    
    index += field;
    
    self.assocSetProgress[index]=self.assocSet[index];
    
    [sender setTitle:self.assocSetProgress[index] forState:UIControlStateNormal];
    
    self.didRevealField = YES;
    
}

- (int)segmentIndex{
    
    NSInteger segIndex = [self.segmentedControl selectedSegmentIndex];
    int index;
    
    switch (segIndex) {
            //for case Z
        case 0: index = 0;            break;
            //for case A
        case 1: index = 5;            break;
            //for case B
        case 2: index = 10;           break;
            //for case C
        case 3: index = 15;           break;
            //for case D
        case 4: index = 20;           break;
        default:break;
    }
    return index;
}

-  (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    int index = [self segmentIndex];
    
    int field = (int)[textField tag];
    
    index += field;
    
    if (![self compareStrings:textField.text withString:self.assocSet[index]]) {
        NSLog(@"Incorrect");
        return YES;
    } else {
        NSLog(@"Correct!");
    }
    
    self.assocSetProgress[index] = self.assocSet[index];
    
    textField.text = self.assocSetProgress[index];
    
    [self showMessage:index];
    
    if (index == 4){
        return YES;
    }
    
    int segIndex = (int)[self.segmentedControl selectedSegmentIndex];
    
    self.assocSetProgress[segIndex-1] = self.assocSet[index];
 
    return YES;
}
- (IBAction)pickNumber:(id)sender {
    
    // Create an array of strings you want to show in the picker:
    NSMutableArray *numbers = [[NSMutableArray alloc]init];
    
    for (int i = 1; i < 33; i++) {
        
        NSNumber *nr = [NSNumber numberWithInt:i];
        
        [numbers addObject:nr];
        
    }
    
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a set"
                                            rows:numbers
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           if (self.didRevealField) {
                                               [[AssocStore sharedStore]insertLoadAssocProgress:self.assocSetProgress indexNumber:self.selectedAssoc];
                                               
                                               self.didRevealField = NO;
                                           }
                                           
                                           self.selectedAssoc = [selectedValue intValue];
                                           
                                           [self setAssoc];
                                           
                                       } cancelBlock:nil
                                          origin:sender];
}
- (IBAction)showOptions:(id)sender {
    
    NSArray *options = @[@"Reset set", @"Reveal set"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select an option"
                                            rows:options
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           switch (selectedIndex) {
                                               case 0:
                                                   [self resetSet];
                                                   break;
                                                   
                                               case 1:
                                                   [self revealSet];
                                                   break;
                                                         
                                               default:
                                                   break;
                                           }
                                           
                                           
                                       } cancelBlock:nil
                                          origin:sender];
}


- (void) resetSet{
    
    [[AssocStore sharedStore] resetAssocProgress:self.selectedAssoc];
    _assocSetProgress = [NSMutableArray arrayWithArray:[[AssocStore sharedStore]assocSetProgress]];
    
    [self changeLetter:nil];
}

- (void) revealSet{
    
    [[AssocStore sharedStore] revealSet:self.selectedAssoc];
    _assocSetProgress = [NSMutableArray arrayWithArray:[[AssocStore sharedStore]assocSetProgress]];
    
    [self changeLetter:nil];
    
}

- (void)setAssoc{
    
    [[AssocStore sharedStore]loadAssoc:self.selectedAssoc];
    [[AssocStore sharedStore]loadAssocProgress:self.selectedAssoc];
    
      
    _assocSet = [NSMutableArray arrayWithArray:[[AssocStore sharedStore]assocSet]];
    
    _assocSetProgress = [NSMutableArray arrayWithArray:[[AssocStore sharedStore]assocSetProgress]];
    
    [self changeLetter:nil];
    
    [self.currentAssoc setTitle:[NSString stringWithFormat:@"%d/32", self.selectedAssoc] forState:UIControlStateNormal];
    
}

- (IBAction)nextSet:(id)sender {
    
    if (_selectedAssoc < 32) {
        
        if (self.didRevealField) {
            [[AssocStore sharedStore]insertLoadAssocProgress:self.assocSetProgress indexNumber:self.selectedAssoc];
            
            self.didRevealField = NO;
        }
        
        
        self.selectedAssoc += 1;
        [self setAssoc];
    }
}

- (IBAction)prevSet:(id)sender {
    
    if (_selectedAssoc > 1) {
        
        if (self.didRevealField) {
            [[AssocStore sharedStore]insertLoadAssocProgress:self.assocSetProgress indexNumber:self.selectedAssoc];
            
            self.didRevealField = NO;
        }
        
        self.selectedAssoc -= 1;
        [self setAssoc];
    }
}

- (BOOL) compareStrings: (NSString *)stringOne withString: (NSString *)stringTwo{
    
    stringOne = stringOne.lowercaseString;
    stringTwo = stringTwo.lowercaseString;
    
    int lvDistance = [stringTwo computeLevenshteinDistanceWithString:stringOne];
    
    if (stringOne.length < 7 && lvDistance < 3) {
            return YES;
    } else if (stringOne.length > 6 && lvDistance < 4) {
            return YES;
    }
    
    return NO;
}

- (void)showMessage: (int) index {
    
    NSString *answer;
    
    if (index != 4) {
        answer = @"Sakte!";
    } else {
        answer = @"Sakte. Ju keni gjetur zgjidhjen perfundimtare!";
    }
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:answer
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -160; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}



@end
