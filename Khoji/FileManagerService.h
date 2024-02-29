#ifndef FileManagerService_h
#define FileManagerService_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

//forward
@protocol WindowManagerDelegate;

// Redefine the AccessibleDirectory enum
typedef NS_ENUM(NSUInteger, AccessibleDirectory) {
    AccessibleDirectoryDownloads,
    AccessibleDirectoryDocuments,
    AccessibleDirectoryDesktop,
    AccessibleDirectoryNone // Represents an undefined directory
};

@interface FileManagerService : NSObject

@property (weak, nonatomic) id<WindowManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)openFileAtPath:(NSString *)path;
- (void)reestablishAccessToFolder;

@end

#endif /* FileManagerService_h */

