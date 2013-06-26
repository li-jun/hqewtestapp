//
//  AudioRecordViewController.m
//  hqewtestapp
//
//  Created by lijun on 13-6-13.
//  Copyright (c) 2013年 Shenzhen Huaqiang electronic trading network Co., Ltd. All rights reserved.
//
//

#import "AudioRecordViewController.h"
#import "SpeexCodec.h"

@interface AudioRecordViewController ()
{
    AVAudioRecorder *audioRecorder;
    NSString *recorderFilePath;
    AVAudioSession * audioSession;
    BOOL isInited;
    AVAudioPlayer * avPlayer;
    NSString *speexFilePath;
}
@end

@implementation AudioRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isInited = NO;
    self.lblHint.textColor = [UIColor blackColor];
    self.lblHint.text = @"手指按住录音按钮不放即可开始录音！";
    audioSession = [AVAudioSession sharedInstance];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRecordTouchDown:(id)sender {
    [self prepareToRecord];
    self.lblHint.textColor = [UIColor greenColor];
    self.lblHint.text = @"手指离开即可结束录音！";
    [audioRecorder record];
}

- (IBAction)btnRecordTouchInside:(id)sender {
    [audioRecorder stop];
}

- (IBAction)btnRecordTouchUpOutside:(id)sender {
    [audioRecorder stop];
}

- (IBAction)btnPlayTouchUpInside:(id)sender {
    if (!recorderFilePath || [recorderFilePath isEqualToString:@""]) {
        recorderFilePath = @"/var/mobile/Applications/2D168187-5C79-44F0-B1C2-52FE4C547DE4/Documents/2013-06-17-16-41-15.caf";
    }
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    if(error){
        NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    
    avPlayer = nil;
    avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderFilePath] error:&error];
    if (error) {
        NSLog(@"AVAudioPlayer: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        return;
    }
    [avPlayer prepareToPlay];
    [avPlayer play];
    
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:recorderFilePath error:nil] fileSize];
    self.lblHint.textColor = [UIColor redColor];
    self.lblHint.text = [NSString stringWithFormat:@"当前录音文件大小: %lld（bytes）", fileSize];
}

- (IBAction)btnReturnTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnConvertSpeexTouchUpInside:(id)sender {
    NSData *PCMData = [NSData dataWithContentsOfFile:recorderFilePath];
    
    NSData *SpeexData = EncodeWAVEToSpeex(PCMData, 1, 16);
    
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *caldate = [dateFormatter stringFromDate:now];
    speexFilePath = [NSString stringWithFormat:@"%@/%@_speex.caf", [HqewIO getDocPath], caldate];
    
    BOOL isSaveSuccess = [SpeexData writeToFile:speexFilePath atomically:YES];
    
    if (isSaveSuccess) {
        long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:speexFilePath error:nil] fileSize];
        self.lblSpeex.textColor = [UIColor redColor];
        self.lblSpeex.text = [NSString stringWithFormat:@"转换后录音文件大小: %lld（bytes）", fileSize];
    }
    else {
        self.lblSpeex.text = @"转换保存文件失败！";
    }
}

- (IBAction)btnPlaySpeexTouchUpInside:(id)sender {
    NSError *error;
    NSData *PCMData = [NSData dataWithContentsOfFile:speexFilePath];
    NSData *NewPCMData = DecodeSpeexToWAVE(PCMData);
    
    avPlayer = nil;
    avPlayer = [[AVAudioPlayer alloc] initWithData:NewPCMData error:&error];
    if (!avPlayer) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    //avPlayer.delegate = self; // 设置代理
    avPlayer.numberOfLoops = 0;// 不循环播放
    [avPlayer prepareToPlay];// 准备播放
    [avPlayer play];// 开始播放
}

- (IBAction)btnPlayAndroidSound:(id)sender {
    NSString *soundFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.caf"];
    
    NSError *error;
    NSData *PCMData = [NSData dataWithContentsOfFile:soundFilePath];
    NSData *NewPCMData = DecodeSpeexToWAVE(PCMData);
    
    avPlayer = nil;
    avPlayer = [[AVAudioPlayer alloc] initWithData:NewPCMData error:&error];
    if (!avPlayer) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    //avPlayer.delegate = self; // 设置代理
    avPlayer.numberOfLoops = 0;// 不循环播放
    [avPlayer prepareToPlay];// 准备播放
    [avPlayer play];// 开始播放
}

- (void) prepareToRecord
{
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    //[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *caldate = [dateFormatter stringFromDate:now];
    recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", [HqewIO getDocPath], caldate];
    NSLog(@"%@", recorderFilePath);
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!audioRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [audioRecorder setDelegate:self];
    [audioRecorder prepareToRecord];
    //[audioRecorder  peakPowerForChannel:0];
    audioRecorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (!audioHWAvailable) {
        UIAlertView *cantRecordAlert =  
        [[UIAlertView alloc] initWithTitle: @"Warning"  
                                   message: @"Audio input hardware not available"  
                                  delegate: nil  
                         cancelButtonTitle:@"OK"  
                         otherButtonTitles:nil];  
        [cantRecordAlert show];  
        return;  
    }
    isInited = YES;
}

#pragma mark AVAudioRecorderDelegate

/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"record successful!");
    [audioSession setActive:NO error:nil];
    
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:recorderFilePath error:nil] fileSize];
    self.lblHint.textColor = [UIColor redColor];
    self.lblHint.text = [NSString stringWithFormat:@"当前录音文件大小: %lld（bytes）", fileSize];
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"record failed!");
    [audioSession setActive:NO error:nil];
    self.lblHint.textColor = [UIColor blackColor];
    self.lblHint.text = @"手指按住录音按钮不放即可开始录音！";
}
- (void)viewDidUnload {
    [self setLblHint:nil];
    [self setLblSpeex:nil];
    [super viewDidUnload];
}
@end
