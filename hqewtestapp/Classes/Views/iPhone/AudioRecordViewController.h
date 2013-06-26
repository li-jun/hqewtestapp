//
//  AudioRecordViewController.h
//  hqewtestapp
//
//  Created by lijun on 13-6-13.
//  Copyright (c) 2013年 Shenzhen Huaqiang electronic trading network Co., Ltd. All rights reserved.
//
//  系统名称：hqewtestapp
//  功能描述：
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HqewIO.h"
#import <CoreFoundation/CoreFoundation.h>

@interface AudioRecordViewController : UIViewController<AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHint;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeex;
- (IBAction)btnRecordTouchDown:(id)sender;
- (IBAction)btnRecordTouchInside:(id)sender;
- (IBAction)btnRecordTouchUpOutside:(id)sender;
- (IBAction)btnPlayTouchUpInside:(id)sender;
- (IBAction)btnReturnTouchUpInside:(id)sender;
- (IBAction)btnConvertSpeexTouchUpInside:(id)sender;
- (IBAction)btnPlaySpeexTouchUpInside:(id)sender;
- (IBAction)btnPlayAndroidSound:(id)sender;
@end
