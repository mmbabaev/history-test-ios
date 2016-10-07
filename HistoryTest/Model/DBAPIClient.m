//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DBAPIClient.h"

@interface DBAPIClient()

@property (strong, nonatomic) AFHTTPRequestSerializer *reqSerializer;

@end

static DBAPIClient *_sharedClient = nil;

@implementation DBAPIClient


+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[DBAPIClient baseUrl]]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.reqSerializer = [AFHTTPRequestSerializer serializer];
        [self.reqSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.reqSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [self setRequestSerializer:self.reqSerializer];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        self.companyHeaderEnabled = YES;
        self.clientHeaderEnabled = YES;
        self.cityHeaderEnabled = YES;
        
        // API version
        [self setValue:[DBAPIClient restAPIVersion] forHeader:@"Version"];
        
        // Locale/Language
        [self setValue:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forHeader:@"Language"];
    }
    return self;
}

+ (NSString *)baseUrl {
    return @"testappall.1.doubleb-automation-production.appspot.com/api/";
//    return [[ApplicationConfig db_AppBaseUrl] stringByAppendingString:@"api/"];
}

// Dirty way to change base url
+ (void)changeBaseUrl{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[DBAPIClient baseUrl]]];
}

+ (NSString *)restAPIVersion {
    // 0 - initial API version
    // 1 - Share
    // 2 - New start logic
    // 3 - Significant bug in apps with shipping and takeout(was on 2 version)
    // 4 - Review
    // 4 - Unified application
    // 5 - New order screen design
    // 6
    // 7 - Bug with bonus positions (was on 6 version)
    // 8 - Multiple Parse Keys on server
    
    return @"8";
}


@end