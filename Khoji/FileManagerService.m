#import <Foundation/Foundation.h>
#import "FileManagerService.h"

@implementation FileManagerService

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static FileManagerService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public Methods

- (void)openFileAtPath:(NSString *)path {
    [self.delegate hideSearchWindow];
    if ([self hasStoredAccessForFolderContainingFileAtPath:path]) {
        NSURL *url = [[NSURL fileURLWithPath:path] standardizedURL];
        [[NSWorkspace sharedWorkspace] openURL:url];
        [self.delegate showSearchWindow];
    } else {
        AccessibleDirectory directory = [self directoryForPath:path];
        if (directory != AccessibleDirectoryNone) {
            [self requestAccessToFolder:directory completion:^{
                [self openFileAtPath:path];
            }];
        } else {
            NSLog(@"cannot determine folder access for path: %@", path);
        }
    }
}

- (void)reestablishAccessToFolder {
    NSData *bookmarkData = [[NSUserDefaults standardUserDefaults] dataForKey:@"folderAccessBookmark"];
    if (!bookmarkData) {
        return;
    }
    
    BOOL isStale = NO;
    NSError *error = nil;
    NSURL *bookmarkedURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
    
    if (isStale) {
        NSLog(@"bookmark data is stale. Need to request access again.");
        return;
    }
    
    if ([bookmarkedURL startAccessingSecurityScopedResource]) {
        // Access has been reestablished.
    } else {
        NSLog(@"failed to re-establish access using bookmark.");
    }
}

#pragma mark - Private Methods

- (BOOL)hasStoredAccessForFolderContainingFileAtPath:(NSString *)path {
    NSData *bookmarkData = [[NSUserDefaults standardUserDefaults] dataForKey:@"folderAccessBookmark"];
    if (!bookmarkData) {
        return NO;
    }
    
    BOOL isStale = NO;
    NSError *error = nil;
    NSURL *bookmarkedURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
    
    if (isStale || error) {
        NSLog(@"bookmark data is stale or error resolving bookmark: %@", error);
        return NO;
    }
    
    [bookmarkedURL startAccessingSecurityScopedResource];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSURL *fileDirectoryURL = [fileURL URLByDeletingLastPathComponent];
    BOOL hasAccess = [bookmarkedURL isEqual:fileDirectoryURL];
    [bookmarkedURL stopAccessingSecurityScopedResource];
    
    return hasAccess;
}

- (AccessibleDirectory)directoryForPath:(NSString *)path {
    if ([path containsString:@"Downloads"]) {
        return AccessibleDirectoryDownloads;
    } else if ([path containsString:@"Documents"]) {
        return AccessibleDirectoryDocuments;
    } else if ([path containsString:@"Desktop"]) {
        return AccessibleDirectoryDesktop;
    }
    return AccessibleDirectoryNone;
}

- (void)requestAccessToFolder:(AccessibleDirectory)directory completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

@end

