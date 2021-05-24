//
//  ERSyncManager.m
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import "ERSyncManager.h"
#import "ERFileManager.h"
#import <AFNetworking.h>


/// 上线更新为正式服务器
#if 0

#define AIECGAnalysisURL @"https://lepucare.viatomtech.com.cn/huawei_ecg_analysis"

#else

#define AIECGAnalysisURL @"https://ai.viatomtech.com.cn/huawei_ecg_analysis"

#endif

@implementation ERSyncManager

+(void)syncRecordEcg:(NSString *)recordFileUrl finished:(SyncEcgFileCallBack)callback{
    NSString *fileName = recordFileUrl.lastPathComponent;
    NSString *fileFold = [recordFileUrl componentsSeparatedByString:@"/"].firstObject;
    NSData *data = [ERFileManager readFile:fileName inDirectory:fileFold];
    NSString *urlString = AIECGAnalysisURL;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 300.0f;
    
    [manager POST:urlString parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"ecgFile" fileName:recordFileUrl.lastPathComponent mimeType:@"ecgFile"];
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *msg = [responseObject objectForKey:@"msg"];
            NSInteger code = [[responseObject objectForKey:@"code"] intValue];
            NSDictionary* dataInfo = [responseObject objectForKey:@"data"];
            
            callback(msg, code, dataInfo);
        }else{
            callback(nil, -1, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        callback(nil, error.code, nil);
    }];
}


@end
