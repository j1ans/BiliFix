#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static long long GlobalNeedToPlayAvid =0; // hook 给 playurl用
/*
%hook NSURLSession //works in ios8 and ios9 , cant work in ios7.

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    NSString *URLString = [[request URL] absoluteString]; //get original url
    NSLog(@"[NSURLSession] find : :%@",URLString);
    
    if ([URLString containsString:@"https://interface.bilibili.com/playurl?"]) {
        NSLog(@"[NSURLSession] Successful find playurl");

        NSString *resultPlayURLString = [URLString stringByReplacingOccurrencesOfString:@"https://interface.bilibili.com/playurl?" withString:@"http://bil.api.iakb.org/playurl?"];
        NSLog(@"[NSURLSession] Successful hook playurl : %@", resultPlayURLString);
        resultPlayURLString = [NSString stringWithFormat:@"%@%@%lld",resultPlayURLString,@"&avid=",GlobalNeedToPlayAvid]; //在参数链接后+page+avid
        NSLog(@"[AppendWithPlayPage] success to append page arg");   
        NSURL *newURL = [NSURL URLWithString:resultPlayURLString];
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [newRequest setURL:newURL];
        
        return %orig(newRequest, completionHandler);
    }else if ([URLString containsString:@"http://interface.bilibili.com/playurl?"]) {
        NSLog(@"[NSURLSession] Successful find playurl");

        NSString *resultPlayURLString = [URLString stringByReplacingOccurrencesOfString:@"http://interface.bilibili.com/playurl?" withString:@"http://bil.api.iakb.org/playurl?"];
        NSLog(@"[NSURLSession] Successful hook playurl : %@", resultPlayURLString);
        resultPlayURLString = [NSString stringWithFormat:@"%@%@%lld",resultPlayURLString,@"&avid=",GlobalNeedToPlayAvid]; //在参数链接后+page+avid
        NSLog(@"[AppendWithPlayPage] success to append page arg");
        NSURL *newURL = [NSURL URLWithString:resultPlayURLString];
        NSMutableURLRequest *newRequest = [request mutableCopy];
        [newRequest setURL:newURL];
        
        return %orig(newRequest, completionHandler);
    }
    
    return %orig(request, completionHandler);
}

%end
*/
%hook NSURLRequest

// Hook +requestWithURL:cachePolicy:timeoutInterval: hook任意一个就行 api都调用了
+ (instancetype)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {

    NSString *originalURLString = [URL absoluteString];
    if([originalURLString rangeOfString:@"https://interface.bilibili.com/playurl?"].location != NSNotFound){ //containstring是ios8 api
        NSString *newURLString = [originalURLString stringByReplacingOccurrencesOfString:@"https://interface.bilibili.com/playurl?"
                                                                            withString:@"http://bil.api.iakb.org/playurl?"];
        newURLString = [NSString stringWithFormat:@"%@%@%lld",newURLString,@"&avid=",GlobalNeedToPlayAvid]; //在参数链接后+avid
        NSLog(@"[AppendWithPlayPage] success to append page arg"); 
        NSLog(@"[initWithURL] Successful get playurl : %@", originalURLString);
        NSURL *newURL = [NSURL URLWithString:newURLString];
        return %orig(newURL, cachePolicy, timeoutInterval);
    }else{
        return %orig(URL, cachePolicy, timeoutInterval);//  调用原方法
    }


}


/*- (instancetype)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {

    NSString *originalURLString = [URL absoluteString];
    NSString *newURLString = [originalURLString stringByReplacingOccurrencesOfString:@"https://interface.bilibili.com/playurl?"
                                                                            withString:@"http://bil.api.iakb.org/playurl?"];
    if([newURLString containsString :@"http://bil.api.iakb.org/playurl?"]){
    newURLString = [NSString stringWithFormat:@"%@%@%i",newURLString,@"&page=",GlobalNeedToPlayPage]; //在参数链接后+page
    NSLog(@"[AppendWithPlayPage] success to append page arg");
    NSLog(@"[initWithURL] Successful hook playurl : %@", originalURLString);
    }
    NSURL *newURL = [NSURL URLWithString:newURLString];

    



        return %orig(newURL, cachePolicy, timeoutInterval);
}
*/
%end

%hook BiliPlayerHelper

- (id)privateGenerateMediaSourceFromAvid:(long long)avid 
                                  andPage:(int)page 
                                  typeTag:(id)typeTag 
                                available:(double *)available 
                           sourceQuality:(int)sourceQuality 
                               isDownload:(char)isDownload {

    GlobalNeedToPlayAvid = avid;
    NSLog(@"[prvateGenerateMediaSourceFromAvid]: Get [avid]=%lld", GlobalNeedToPlayAvid);
    id result = %orig(avid, page, typeTag, available, sourceQuality, isDownload);

    return result;
}
%end

