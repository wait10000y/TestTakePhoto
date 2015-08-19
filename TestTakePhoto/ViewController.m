//
//  ViewController.m
//  TestTakePhoto
//
//  Created by wsliang on 15/6/10.
//  Copyright (c) 2015年 wsliang. All rights reserved.
//

#import "ViewController.h"

#import "FDTakeController.h"

@interface ViewController ()<FDTakeDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) FDTakeController *mTakes;
@property (nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak,nonatomic) UITableViewCell *imageCell;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  self.mTakes = [[FDTakeController alloc] init];
  self.mTakes.delegate = self;
  self.mTakes.defaultToFrontCamera = YES;
  self.mTakes.allowsEditingPhoto = YES;
  self.mTakes.autoConvertVideo = YES;
  
  _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
  _webView.allowsInlineMediaPlayback = YES;
  _webView.mediaPlaybackRequiresUserAction = YES;
  [self.view addSubview:_webView];
  _webView.hidden = YES;
  [self addNotification];
  
}

-(void)addNotification
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vedioStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];// 播放器即将播放通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vedioFinished:) name:@"UIMoviePlayerControllerWillExitFullscreenNotification" object:nil];// 播放器即将退出通知
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}

-(void)vedioStarted:(id)tag
{
  NSLog(@"---- vedio play started ----");
}

-(void)vedioFinished:(id)tag
{
  NSLog(@"---- vedio play finished ----");
  self.webView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionTakePhoto:(UIButton*)sender
{
  if (sender.tag==0) {
    [self.mTakes takePhotoOrChooseFromLibrary];
  }else if (sender.tag == 1){
    [self.mTakes takePhotoOrVideoOrChooseFromLibrary];
  }

}


-(void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
  NSLog(@"---------- didCancelAfterAttempting ------------");
}

-(void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
  NSLog(@"---------- gotPhoto:%@ , info:%@ ------------",NSStringFromCGSize(photo.size),info);
//  NSData *imageData = UIImagePNGRepresentation(photo);
//  [imageData writeToFile:nil atomically:YES];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  if (cell) {
    cell.imageView.image = photo;
  }else{
    NSLog(@"----- no cell -------");
  }
  [self.tableView reloadData];
  
}

-(void)takeController:(FDTakeController *)controller gotVideo:(NSURL *)video withInfo:(NSDictionary *)info
{
  NSLog(@"---------- gotVideo:%@ info:%@ ------------",video,info);
  self.webView.hidden = NO;
  NSString *strVideoAddress = [NSString stringWithFormat:@"<html><body><video tabindex='0' controls='controls' autoplay='autoplay'><source src='%@'></video></body></html>", [video absoluteString]];
  [self.webView loadHTMLString:strVideoAddress baseURL:nil];
//  [controller removeFileWithUrl:video];
}

-(void)takeController:(FDTakeController *)controller didFailAfterAttempting:(BOOL)madeAttempt
{
  NSLog(@"---------- didFailAfterAttempting ------------");
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *tCellId = @"cellId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tCellId];
  if (!cell) {
    cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tCellId];
  }
  cell.textLabel.text = [NSString stringWithFormat:@"title - - -%d",indexPath.row];
//  cell.imageView.image = nil;
  return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    [self.mTakes takePhotoOrChooseFromLibrary];
    self.imageCell = [tableView cellForRowAtIndexPath:indexPath];
  }
  
}







@end
