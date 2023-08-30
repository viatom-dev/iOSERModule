//
//  ERSyncManager.m
//  ERModule
//
//  Created by yangweichao on 2021/4/12.
//

#import "ERSyncManager.h"
#import "ERFileManager.h"
#import "ERRecordECG.h"
#import "VTCustomText.h"

#import <AFNetworking.h>
/// 上线更新为正式服务器
//#if 1
//
//#define AIECGAnalysisURL @"https://lepucare.viatomtech.com.cn/huawei_ecg_analysis"
//
//#else
//
//#define AIECGAnalysisURL @"https://ai.viatomtech.com.cn/huawei_ecg_analysis"
//
//#endif


#define DominURL @"https://open.lepudev.com"
#define AIECGAnalysisPathComponent @"/api/v1/ecg/analysis/request"
#define AIECGStatusPathComponent @"/api/v1/ecg/analysis/batch_status/query"
#define AIECGResultPathComponent @"/api/v1/ecg/analysis/result/query"


static NSString * const secret = @"e8a5df03c087fe2330de283e908afe25";
static NSString * const token = @"7843e203999d8f80e325476f08c16412";
static NSString * const language = @"zh-CN";
static NSString * const application_id = @"com.guoyao";

static NSString * const band = @"Lepu";
static NSString * const model = @"er1";
static NSString * const sn = @"GY2308281100A";


@interface ERSyncManager ()

@end

@implementation ERSyncManager


static ERSyncManager *_instance = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [ERSyncManager sharedInstance];
}
-(id)copyWithZone:(NSZone *)zone{
    return [ERSyncManager sharedInstance];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [ERSyncManager sharedInstance];
}


- (void)commonHeaderWithManager:(AFHTTPSessionManager *)manager {
    [manager.requestSerializer setValue:secret forHTTPHeaderField:@"secret"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"access-token"];
    [manager.requestSerializer setValue:language forHTTPHeaderField:@"language"];
    
}


- (void)commitECGRecord:(ERRecordECG *)ecgModel finished:(SyncEcgFileCallBack)callback {
    NSString *fileName = ecgModel.fileUrl.lastPathComponent;
    NSString *fileFold = [ecgModel.fileUrl componentsSeparatedByString:@"/"].firstObject;
    NSData *data = [ERFileManager readFile:fileName inDirectory:fileFold];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (![str hasPrefix:@"F-0-01"]) {
        str = [@"F-0-01," stringByAppendingString:str];
    }
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [DominURL stringByAppendingString:AIECGAnalysisPathComponent];
    NSDictionary *ecgInfoDict = [self ecgInfoWithECGRecord:ecgModel];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self commonHeaderWithManager:manager];
    [manager POST:urlString parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"analyse_file" fileName:ecgModel.fileUrl.lastPathComponent mimeType:@".txt"];
        NSData *prettyJson = [NSJSONSerialization dataWithJSONObject:ecgInfoDict options:NSJSONWritingPrettyPrinted error:nil];
        [formData appendPartWithFormData:prettyJson name:@"ecg_info"];
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *msg = [responseObject objectForKey:@"message"];
            NSInteger code = [[responseObject objectForKey:@"code"] intValue];
            NSDictionary* dataInfo = [responseObject objectForKey:@"data"];
            if (code == 0) {
                ecgModel.analysis_id = dataInfo[@"analysis_id"];
                ecgModel.status = AIStatusIng;
                ecgModel.responseVer = 1;
                [ecgModel update];
                [self queryStatusWithId:ecgModel.analysis_id finished:callback];
            } else {
                callback(msg, -1, nil);
            }
        }else{
            callback(nil, -1, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        callback(nil, error.code, nil);
    }];
}

- (void)queryStatusWithId:(NSString *)analysis_id finished:(SyncEcgFileCallBack)callback {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *urlString = [DominURL stringByAppendingString:AIECGStatusPathComponent];
        //        NSDictionary *param = @{@"analysis_ids": @[analysis_id]};
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSString *parameters = [NSString stringWithFormat:@"{\"analysis_ids\":[\"%@\"]}", analysis_id];
        NSData *data = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *headers = @{
            @"secret": secret,
            @"access-token": token,
            @"language": language,
            @"Content-Type": @"application/json"
        };
        [request setAllHTTPHeaderFields:headers];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSString *msg = [responseObject objectForKey:@"message"];
                NSInteger code = [[responseObject objectForKey:@"code"] intValue];
                if (code == 0) {
                    NSArray *dataInfo = [responseObject objectForKey:@"data"];
                    __block NSDictionary *dict;
                    [dataInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *aid = obj[@"analysis_id"];
                        if ([analysis_id isEqualToString:aid]) {
                            dict = obj;
                            *stop = YES;
                        }
                    }];
                    if (dict) { // 理论都走这里
                        NSString *statusCode = dict[@"analysis_status"];
                        if (statusCode.integerValue == AIStatusIng) {
                            // 进行中
                            [self queryStatusWithId:analysis_id finished:callback];
                        } else if (statusCode.integerValue == AIStatusFinshed) {
                            // 查询结果
                            [self queryResultWithId:analysis_id finished:callback];
                        } else {
                            // 发生错误
                            callback(msg, statusCode.integerValue, nil);
                        }
                        
                    } else {
                        [self queryStatusWithId:analysis_id finished:callback];
                    }
                    
                } else {
                    callback(msg, -1, nil);
                }
            }else{
                callback(error.description, -1, nil);
            }
        }] resume] ;
    });
}

- (void)queryResultWithId:(NSString *)analysis_id finished:(SyncEcgFileCallBack)callback {
    NSString *urlString = [DominURL stringByAppendingString:AIECGResultPathComponent];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *parameters = [NSString stringWithFormat:@"{\"analysis_id\":\"%@\"}", analysis_id];
    NSData *data = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *headers = @{
        @"secret": secret,
        @"access-token": token,
        @"language": language,
        @"Content-Type": @"application/json"
    };
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *msg = [responseObject objectForKey:@"message"];
            NSInteger code = [[responseObject objectForKey:@"code"] intValue];
            if (code == 0) {
                NSDictionary *dataInfo = [responseObject objectForKey:@"data"];
                callback(msg, code, dataInfo);
            } else {
                callback(msg, -1, nil);
            }
        }else{
            callback(error.description, -1, nil);
        }
    }] resume];
}




// 生成对应的json字典
- (NSDictionary *)ecgInfoWithECGRecord:(ERRecordECG *)ecgModel {
    NSDictionary *userDict = @{
        @"name": (ecgModel.nickName.length != 0 ? ecgModel.nickName : [VTCustomText sharedInstance].user.nickName),
        @"phone": (ecgModel.phone.length != 0 ? ecgModel.phone : [VTCustomText sharedInstance].user.phone),
        @"gender": (ecgModel.gender.length != 0 ? ecgModel.gender : [VTCustomText sharedInstance].user.gender),
        @"birthday": (ecgModel.dateBirth.length != 0 ? ecgModel.dateBirth : [VTCustomText sharedInstance].user.dateBirth),
        @"id_number": (ecgModel.idcard.length != 0 ? ecgModel.idcard : [VTCustomText sharedInstance].user.idcard),
        @"height": @"170",
        @"weight": @"80"
    };
    NSDictionary *deviceDict = @{
        @"sn": sn,
        @"band": band,
        @"model": model
    };
    NSDictionary *ecgDict = @{
        @"measure_time": ecgModel.startTime,
        @"duration": @"30",
        @"sample_rate": @"125",
        @"lead": @"II"
    };
    NSMutableDictionary *ecgInfoDict = [NSMutableDictionary dictionary];
    [ecgInfoDict setValue:userDict forKey:@"user"];
    [ecgInfoDict setValue:@"1" forKey:@"analysis_type"];
    [ecgInfoDict setValue:@"1" forKey:@"service_ability"];
    [ecgInfoDict setValue:token forKey:@"access_token"];
    [ecgInfoDict setValue:application_id forKey:@"application_id"];
    [ecgInfoDict setValue:deviceDict forKey:@"device"];
    [ecgInfoDict setValue:ecgDict forKey:@"ecg"];
    
    return ecgInfoDict.copy;
}


@end
