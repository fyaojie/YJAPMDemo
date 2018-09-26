//
//  Next_ViewController.m
//  NSURLSession1
//
//  Created by 李永俊 on 2018/8/13.
//

#import "Next_ViewController.h"
#define boundary @"----WebKitFormBoundaryFoBXvlPSGohXlI5z"
@interface Next_ViewController ()<NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSData *resumeData;   // 用于存储暂停下载时的数据
@property (nonatomic, strong) NSURLSessionUploadTask *nextuploadTask;
@end

@implementation Next_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    __weak wself = self;
//    [BRSAgent setDelegate:self];
    [self.view setBackgroundColor:[UIColor redColor]];
    UILabel *starLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 100, 60)];
    starLabel.text = @"开始下载";
    starLabel.backgroundColor = [UIColor yellowColor];
    starLabel.userInteractionEnabled = YES;
    [self.view addSubview:starLabel];
    
    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 200, 100, 60)];
    backLabel.text = @"返回";
    backLabel.backgroundColor = [UIColor yellowColor];
    backLabel.userInteractionEnabled = YES;
    [self.view addSubview:backLabel];
    UITapGestureRecognizer *backtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backtapAction)];
    [backLabel addGestureRecognizer:backtap];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [starLabel addGestureRecognizer:tap];
}

- (void)backtapAction {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapAction {
    // 创建下载任务
//    self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:@"https://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"]];
//
//    // 执行任务
//    [self.downloadTask resume];
    [self bgUploadStreamForm];
}



- (void)dealloc {
    NSLog(@"Next_ViewController = dealloc");
}

#pragma mark Session Download Delegate Method
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.progressView.hidden = YES;     // 下载完成后隐藏进度条
//        self.cancelButton.hidden = YES;     // 下载完成后隐藏Cancel按钮
//        self.imageView.image = [UIImage imageWithData:data];
    });
    
    // 销毁会话
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // 输出NSLog所在行和方法名称
    NSLog(@"%d %s",__LINE__ ,__PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (double) totalBytesWritten / totalBytesExpectedToWrite;
     NSLog(@"progress = %f",progress);
//    dispatch_async(dispatch_get_main_queue(), ^{
////        self.progressView.progress = progress;
//    });
}
#pragma mark Getters & Setters
- (NSURLSession *)session
{
    if (! _session)
    {
        // 创建会话配置
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // 创建会话
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    return _session;
}

- (void)bgUploadStreamForm {
    NSLog(@"%s", __func__);
    NSURL *url = [NSURL URLWithString:@"http://api.jianidai.com:8090/api/fs/uploadFile/upload"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"aaaaaa" ofType:@"jpg"];
    NSData *bodydata = [self buildBodyDataWithPicPath:path];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%zd", bodydata.length] forHTTPHeaderField:@"Content-Length"];
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:bodydata];
    self.nextuploadTask = [self.session uploadTaskWithStreamedRequest:request];
    [self.nextuploadTask resume];
}

-(NSData*)buildBodyDataWithPicPath:(NSString *)path{
    NSMutableData *bodyData = [NSMutableData data];
    NSMutableString *bodyStr = [NSMutableString string];
    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"sampleFile\"; filename=\"icon.jpg\""];
    [bodyStr appendFormat:@"\r\n\r\n"];
    
    NSData *start = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:start];
    NSData *picData = [NSData dataWithContentsOfFile:path];
    [bodyData appendData:picData];
    
    bodyStr = [NSMutableString string];
    [bodyStr appendFormat:@"\r\n--%@--",boundary];
    
    NSData *endData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:endData];
    return bodyData;
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend  {
    NSLog(@"aaaa == ");
}

- (void)BRSAgentURLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double) totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"BRSAgentURLSession progress = %f",progress);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
