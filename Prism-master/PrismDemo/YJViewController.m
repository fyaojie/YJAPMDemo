//
//  YJViewController.m
//  PrismDemo
//
//  Created by love on 2018/9/20.
//  Copyright © 2018年 tany. All rights reserved.
//

#import "YJViewController.h"

#import "Next_ViewController.h"
#define kBoundary @"aa"
#define boundary @"----WebKitFormBoundaryFoBXvlPSGohXlI5z"
#define kStreamUploadUrl @"http://10.5.80.187:3004/upload/stream"
#define kFormUploadUrl   @"http://10.5.80.187:3004/upload/"

@interface YJViewController () <NSURLSessionTaskDelegate>

@property (strong, nonatomic) UIProgressView *progressView;
//@property (strong, nonatomic) NSURLSession *session;
//@property (strong, nonatomic) NSData *resumeData;   // 用于存储暂停下载时的数据
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (nonatomic, strong) NSURLSession *backgroundSession;

@end

@implementation YJViewController

#pragma mark View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.backgroundSession = [self getDownloadURLSession];
    
    // 隐藏点击按钮
    UILabel *starLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 100, 60)];
    starLabel.text = @"开始上传";
    starLabel.backgroundColor = [UIColor redColor];
    starLabel.userInteractionEnabled = YES;
    [self.view addSubview:starLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [starLabel addGestureRecognizer:tap];
    
    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 200, 100, 60)];
    backLabel.text = @"push";
    backLabel.backgroundColor = [UIColor yellowColor];
    backLabel.userInteractionEnabled = YES;
    [self.view addSubview:backLabel];
    UITapGestureRecognizer *backtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backtapAction)];
    [backLabel addGestureRecognizer:backtap];
    
}

- (void)backtapAction {
    //    NSLog(@"%@",@[][1]);
    
    Next_ViewController *next = [[Next_ViewController alloc]init];
    [self.navigationController pushViewController:next animated:YES];
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

- (void)bgUploadStreamForm
{
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
    self.uploadTask = [self.backgroundSession uploadTaskWithStreamedRequest:request];
    [self.uploadTask resume];
}

- (NSURLSession *)getDownloadURLSession {
    
    NSURLSession *session = nil;
    NSString *identifier = [self backgroundSessionIdentifier];
    identifier = @"aaa";
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForResource = 24*60*60;
    session = [NSURLSession sessionWithConfiguration:sessionConfig
                                            delegate:self
                                       delegateQueue:[NSOperationQueue mainQueue]];
    return session;
}

- (NSString *)backgroundSessionIdentifier {
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    bundleId = @"aaa";
    NSString *identifier = [NSString stringWithFormat:@"%@.BackgroundSession", bundleId];
    return identifier;
}

- (void)tapAction {
    self.progressView.hidden = NO;
    self.progressView.progress = 0;
    [self bgUploadStreamForm];
}

-(NSData *)getBodyData {
    //5.拼接数据
    NSMutableData *fileData = [NSMutableData data];
    //5.1 拼接文件参数
    [fileData appendData:[[NSString stringWithFormat:@"--%@",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // name="file":参数,是固定的
    // filename:文件上传到服务器以什么名字来保存,随便
    [fileData appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"Snip20151228_572.png\"" dataUsingEncoding:NSUTF8StringEncoding]];
    //Content-Type:要上传的文件的类型 (MIMEType)
    [fileData appendData: [@"Content-Type: image/jpg" dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [UIImage imageNamed:@"aaaaaa.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    [fileData appendData:imageData];
    
    //5.2 拼接非文件参数
    [fileData appendData:[[NSString stringWithFormat:@"--%@",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //username:同file 是服务器规定
    [fileData appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[@"dashen9" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:[[NSString stringWithFormat:@"--%@--",kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return fileData;
}

#pragma mark ----------------------
#pragma mark NSURLSessionDataDelegate



-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    float progress = 1.0 * totalBytesSent/totalBytesExpectedToSend;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"完成 %@", [NSThread currentThread]);
}



//#pragma mark Getters & Setters
//- (NSURLSession *)session {
//        if (! _session) {
//    // 创建会话配置
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//
//    // 创建会话
//    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//        }
//    return _session;
//}


//- (void)sendData {
//    //1.创建会话对象,设置代理
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    int i = 1;
//    NSString *urla = i > 0 ? @"http://api.jianidai.com:8090/api/fs/uploadFile/upload" : @"http://120.25.226.186:32812/upload";
//    //2.创建请求对象
//    NSURL *url =[NSURL URLWithString:urla];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    //2.1 修改请求方法
//    request.HTTPMethod = @"POST";
//
//    //2.2 设置请求头
//    NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary];
//    [request setValue:header forHTTPHeaderField:@"Content-Type"];
//
//    //3.创建上传task
//    /*
//     30      第一个参数:请求对象
//     31      第二个参数:要上传文件的参数(二进制数据
//     32      第三个参数:completionHandler
//     33         data:服务器返回的结果(响应体信息)
//     34         response:响应头
//     35      */
//    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:[self getBodyData] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //5.解析结果
//        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
//    }];
//
//    //4.执行任务
//    [uploadTask resume];
//}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(100, 350, 100, 10)];
        _progressView.progress = 0;
        _progressView.progressTintColor = [UIColor blueColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
