//
//  VTER1HistoryViewController.m
//  ERModule
//
//  Created by yangweichao on 2021/4/13.
//

#import "UIColor+Extensions.h"
#import "UIView+Additional.h"
#import "VTER1HistoryViewController.h"
#import "VTER1HistoryCell.h"
#import "ERRecordECG.h"
#import "ERSyncManager.h"
#import "ECGReportInfoData.h"
#import "VTCustomText.h"
#import "VTMarco.h"
#import "ViaReportWave.h"
#import "ERECGReport.h"
#import "ViaPDFManager.h"
#import <Masonry.h>
#import "ERPdfReportViewController.h"
#import "MBProgressHUD.h"
#import "ERFileManager.h"

@interface VTER1HistoryViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic, copy) NSString *previewPath;

@end

@implementation VTER1HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"本地报告";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left"] style:UIBarButtonItemStylePlain target:self action:@selector(backToReal)];
    self.navigationItem.leftBarButtonItem = leftItem;
    _listArray = [NSMutableArray arrayWithArray:[ERRecordECG findAll]];
    [_listTableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewData:) name:@"RecordEcgSaved" object:nil];
}


- (void)backToReal{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)addNewData:(NSNotification *)notification{
    NSDictionary *dic = [notification userInfo];
    ERRecordECG *ecg = [dic objectForKey:@"ecg"];
    [_listArray addObject:ecg];
    [_listTableView reloadData];
}

#pragma mark --- 生成报告

- (NSString *)generateERAIReportFile:(ERRecordECG *)ecg{
    NSMutableArray *subViews = [NSMutableArray arrayWithCapacity:8];
    
    // 创建患者信息卡片
    ECGReportInfoData *userInfo = [[NSBundle mainBundle] loadNibNamed:@"ECGReportInfoData" owner:self options:nil].lastObject;
    userInfo.bounds = CGRectMake(0, 0, 0, 140);
    userInfo.member = [VTCustomText sharedInstance].user;
    userInfo.ecgRecord = ecg;
    [subViews addObject:userInfo];
    
    NSDictionary *dic = [ecg dataDicFromData];
    // 创建AI分析建议
    NSArray *aiResultList = [dic objectForKey:@"aiResultList"];
    for (int i=0; i < aiResultList.count; i++) {
        NSDictionary * tmpDic = aiResultList[i];
        NSString * tmp = tmpDic[@"phoneContent"];
        NSString * phoneText =[tmp stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        NSString *sugStr = [NSString stringWithFormat:@"%@\n%@",tmpDic[@"aiDiagnosis"],phoneText];
        UILabel *sugLab = [[UILabel alloc] init];
        sugLab.font = [UIFont systemFontOfSize:11];
        sugLab.text = sugStr;
        sugLab.textColor = [UIColor colorWithHex:000000];
        sugLab.numberOfLines = 0;
        sugLab.layer.borderWidth = 1;
        sugLab.layer.borderColor = [UIColor blackColor].CGColor;
        CGRect r = [sugStr boundingRectWithSize:CGSizeMake(wave_width, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                           context:nil];
        sugLab.bounds = CGRectMake(0, 0, r.size.width, r.size.height + 14);
        [subViews addObject:sugLab];
    }
    
    // 创建心电波形片段
    NSArray *pointsArr = [ecg readShortFilePoints];
    CGFloat scale = [pointsArr[2] doubleValue];
    NSArray *fragmentList = [dic objectForKey:@"fragmentList"];
    fragmentList = [fragmentList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"startPose"] integerValue] > [obj2[@"startPose"] integerValue];
    }];
    NSArray *posList = [dic objectForKey:@"posList"];
    NSArray *labelList = [dic objectForKey:@"labelList"];
    for (NSDictionary *fragment in fragmentList) {
        // 获取心电波形片段点数据
        NSInteger startPose = [fragment[@"startPose"] integerValue] / 2; NSInteger endPose = [fragment[@"endPose"] integerValue] / 2;
        NSArray *waveArray = [pointsArr subarrayWithRange:NSMakeRange(3, pointsArr.count - 3)];   // 点数据数组前3位为标记位, 取点数据时需剔除
        // 获取tag数组
        NSInteger tagStartIndex = [posList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { if ([obj integerValue] / 2 >= startPose) { *stop = YES; } return *stop; }];
        NSInteger tagEndIndex = [posList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { if ([obj integerValue] / 2 > endPose) { *stop = YES; } return *stop; }];
        if (tagEndIndex > posList.count) { tagEndIndex = posList.count; }
        NSArray *tagLocations = [posList subarrayWithRange:NSMakeRange(tagStartIndex, tagEndIndex - tagStartIndex)];
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:10];       // 还原成125采样率后的下标数组
        [tagLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { [arrM addObject:[NSString stringWithFormat:@"%ld", [obj integerValue] / 2]]; }];
        NSArray *tagArray = [labelList subarrayWithRange:NSMakeRange(tagStartIndex, tagEndIndex - tagStartIndex)];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = (NSDate *)[formatter dateFromString:ecg.startTime];
        NSInteger mi = [date timeIntervalSince1970] + (startPose / 125);
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *timeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:mi]];
        
        ViaReportWave *ecgWave = [[ViaReportWave alloc] initWithFrame:CGRectMake(0, 0, 0, H_PER_ROW+viapadding)
                                                            waveArray:waveArray
                                                                range:NSMakeRange(startPose, endPose - startPose)
                                                                   hz:125
                                                                ruler:1.0
                                                                scale:scale];
        ecgWave.ecgTagArr = tagArray;
        ecgWave.tagLocations = arrM;
        ecgWave.startTime = timeStr;
        ecgWave.symptom = fragment[@"name"];
        
        [subViews addObject:ecgWave];
    }
    
    // 创建页底字符
    NSString *remindStr = @"*由于检测者基本健康情况、检测环境以及设备状态受多因素影响，本报告结果供参考，请您关注心脏健康，根据建议及时就医。 \r\n客服电话：400-622-1120。";
    UILabel *remindLabel = [[UILabel alloc] init];
    remindLabel.font = [UIFont systemFontOfSize:11];
    remindLabel.text = remindStr;
    remindLabel.textColor = [UIColor colorWithHex:000000];
    remindLabel.numberOfLines = 0;
    CGRect labr = [remindStr boundingRectWithSize:CGSizeMake(wave_width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}
                                       context:nil];
    CGSize labelSize = labr.size;
    remindLabel.bounds = CGRectMake(0, 0, labelSize.width, labelSize.height + 14);
    [subViews addObject:remindLabel];
    
    NSArray *imageArr = [self generatePDFPage:subViews];
    
    NSString *filePath = [ecg.startTime stringByAppendingString:@".pdf"];
    [ViaPDFManager createPDFFileWithImage:imageArr toDestFile:filePath];
    return filePath;
}

- (NSArray <UIImage *> *)generatePDFPage:(NSMutableArray <UIView *> *)subViews {
    NSMutableArray <UIImage *> *imageArrM = [NSMutableArray arrayWithCapacity:4];
    do {
        ERECGReport *report = [[ERECGReport alloc] initWithFrame:CGRectMake(0, 0, whole_width, whole_height)];
        CGFloat height = report.contentView.bounds.size.height;
        while (height > subViews.firstObject.bounds.size.height) {
            [report.contentView addSubview:subViews.firstObject];
            [subViews.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(report.contentView);
                make.top.equalTo(report.contentView).offset(report.contentView.bounds.size.height - height);
                make.height.mas_equalTo(subViews.firstObject.bounds.size.height);
            }];
            [subViews.firstObject layoutIfNeeded];
            
            height -= subViews.firstObject.bounds.size.height + 10;
            [subViews removeObject:subViews.firstObject];
        }
        [report layoutIfNeeded];
        [imageArrM addObject:[report captureView]];
    } while (subViews.count > 0);
    return imageArrM;
}

#pragma mark --- 查看报告

- (void)previewWithEcg:(ERRecordECG *)ecg andIndex:(NSInteger)index{
    if ([ecg.aiReportUrl rangeOfString:@".pdf"].location == NSNotFound) {
        [self showWaitLoadingAnimationWithText:@"正在生成报告..."];
        ecg.aiReportUrl = [self generateERAIReportFile:ecg];
        [ecg update];
        [self.listArray replaceObjectAtIndex:index withObject:ecg];
        [_listTableView reloadData];
    }
    NSString *path = [ViaPDFManager pdfDestPath:ecg.aiReportUrl];
    [self previewAndShared:path];
}

- (void)previewAndShared:(NSString *)path{
    [self showWaitLoadingAnimationWithText:@"正在打开报告..."];
    _previewPath = path;
    ERPdfReportViewController *qlPC = [[ERPdfReportViewController alloc] init];
    qlPC.pdfPath = _previewPath;
    [self presentViewController:qlPC animated:YES completion:^{
        [self hiddenWaitAnimation];
    }];
}

#pragma mark --- delegate && datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"er1Identifier";
    VTER1HistoryCell *cell = (VTER1HistoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"VTER1HistoryCell" owner:nil options:nil].lastObject;
        
    }
    ERRecordECG *ecg = _listArray[_listArray.count - 1 - indexPath.section]; //逆序显示
    
    cell.dateLab.text = [ecg.startTime substringToIndex:ecg.startTime.length-3];
    cell.fromLab.text = (ecg.manaul ? @"手动采集" : @"自动采集");
    cell.fromLab.textColor = (ecg.manaul ? [UIColor colorWithRed:245/255.0 green:230/255.0 blue:42/255.0 alpha:1/1.0] : [UIColor colorWithRed:61/255.0 green:90/255.0 blue:254/255.0 alpha:1/1.0]);
    if ([ecg.isShowAiResult isEqualToString:@"1"]) {
        cell.aiResultLab.text = ecg.aiDiagnosis;
        cell.hrValLab.text = ecg.hr;
    }else{
        cell.aiResultLab.text = @"";
        cell.hrValLab.text = @"--";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    [v setBackgroundColor:[UIColor blackColor]];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __block NSInteger index = _listArray.count - 1 - indexPath.section;
    ERRecordECG *ecg = _listArray[index];
    if ([ecg.isShowAiResult isEqualToString:@"1"]) {
        [self previewWithEcg:ecg andIndex:index];
    }else{
        [self showWaitLoadingAnimationWithText:@"正在获取AI分析结果..."];
        [ERSyncManager syncRecordEcg:ecg.fileUrl finished:^(NSString * _Nullable msg, NSInteger code, NSDictionary * _Nullable response) {
            if (code == 200) {
                /**
                 @property (nonatomic, copy) NSString *hr;
                 @property (nonatomic, copy) NSString *isShowAiResult;
                 @property (nonatomic, copy) NSString *shortRangeTime;
                 @property (nonatomic, copy) NSString *sendTime;
                 @property (nonatomic, copy) NSString *levelCode;
                 @property (nonatomic, copy) NSString *aiResult;
                 @property (nonatomic, copy) NSString *aiDiagnosis;
                 */
                [ecg setResponseData:response];
                [ecg setHr:[response objectForKey:@"hr"]];
                [ecg setIsShowAiResult:[response objectForKey:@"isShowAiResult"]];
                [ecg setShortRangeTime:[response objectForKey:@"shortRangeTime"]];
                [ecg setSendTime:[response objectForKey:@"sendTime"]];
                [ecg setLevelCode:[response objectForKey:@"levelCode"]];
                [ecg setAiResult:[response objectForKey:@"aiResult"]];
                [ecg setAiDiagnosis:[response objectForKey:@"aiDiagnosis"]];
                [ecg update];
                [self.listArray replaceObjectAtIndex:index withObject:ecg];
                [self previewWithEcg:ecg andIndex:index];
            }
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger index = _listArray.count - 1 - indexPath.section;
        ERRecordECG *ecg = _listArray[index];
        if (ecg.fileUrl.length != 0) { // 删除本地文件
            NSString *fileName = ecg.fileUrl.lastPathComponent;
            NSString *fileFold = [ecg.fileUrl componentsSeparatedByString:@"/"].firstObject;
            [ERFileManager deleteFile:fileName inDirectory:fileFold];
        }
        if (ecg.aiReportUrl.length != 0) {  //删除PDF文件
            [ViaPDFManager deletePdfWithPath:ecg.aiReportUrl];
        }
        [ecg deleteObject];
        [_listArray removeObjectAtIndex:index];
        [_listTableView reloadData];
    }
}

- (void)showWaitLoadingAnimationWithText:(NSString*)text
{
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:888];
    if (hud == nil) {
        CGSize size = self.view.bounds.size;
        hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake(size.width/2 - 70/2, size.height/2 - 70/2, 70, 70)];
//        hud.dimBackground = NO;
        hud.tag = 888;
        [self.view addSubview:hud];
    }
    [self.view bringSubviewToFront:hud];
    hud.contentColor = [UIColor blackColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    hud.bezelView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    hud.label.text = text;
    hud.label.textColor = [UIColor darkTextColor];
    [hud showAnimated:YES];
}

- (void)hiddenWaitAnimation
{
    MBProgressHUD* hud = (MBProgressHUD*)[self.view viewWithTag:888];
    if(hud != nil)
    {
        [hud hideAnimated:YES];
        [hud removeFromSuperview];
    }
}


#pragma mark --- dealloc

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
