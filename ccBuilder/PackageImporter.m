#import "PackageImporter.h"

#import "ProjectSettings.h"
#import "ProjectSettings+Packages.h"
#import "NSString+Packages.h"
#import "SBErrors.h"
#import "PackageUtil.h"
#import "NotificationNames.h"
#import "NSError+SBErrors.h"
#import "MiscConstants.h"
#import "RMPackage.h"

@implementation PackageImporter

- (id)init
{
    self = [super init];
    if (self)
    {
        // default until we get some injection framework running
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (BOOL)importPackageWithName:(NSString *)packageName error:(NSError **)error
{
    NSString *fullPath = [_projectSettings fullPathForPackageName:packageName];

    return [self importPackagesWithPaths:@[fullPath] error:nil];
}

- (NSArray *)allPackagesInPaths:(NSArray *)paths
{
    if (!paths)
    {
        return nil;
    }

    NSMutableArray *result = [NSMutableArray array];
    for (NSString *path in paths)
    {
        if ([path hasPackageSuffix])
        {
            RMPackage *aPackage = [[RMPackage alloc] init];
            aPackage.dirPath = path;

            [result addObject:aPackage];
        }
    }
    return result;
}

- (BOOL)importPackagesWithPaths:(NSArray *)packagePaths error:(NSError **)error
{
    if (!packagePaths || packagePaths.count == 0)
    {
        [NSError setNewErrorWithCode:error code:SBNoPackagePathsToImport message:[NSString stringWithFormat:@"No paths to import given"]];
        return NO;
    }

    NSArray *filteredPaths = [self allPackagesInPaths:packagePaths];
    if (filteredPaths.count == 0)
    {
        [NSError setNewErrorWithCode:error code:SBPathWithoutPackageSuffix message:[NSString stringWithFormat:@"No paths to import given with .%@ suffix", PACKAGE_NAME_SUFFIX]];
        return NO;
    }

    PackagePathBlock block = [self packagePathImportBlock];

    PackageUtil *packageUtil = [[PackageUtil alloc] init];
    return [packageUtil enumeratePackages:filteredPaths
                                    error:error
                      prevailingErrorCode:SBImportingPackagesError
                         errorDescription:@"One or more packages could not be imported."
                                    block:block];
}

- (PackagePathBlock)packagePathImportBlock
{
    return ^BOOL(RMPackage *packageToImport, NSError **localError)
    {
        if ([_projectSettings isResourcePathInProject:packageToImport.dirPath])
        {
            [NSError setNewErrorWithCode:localError code:SBPackageAlreayInProject message:@"Package already in project folder."];
            return NO;
        }

        NSString *packageName = [[packageToImport.dirPath lastPathComponent] stringByDeletingPathExtension];
        NSString *newPathInPackagesFolder = [_projectSettings fullPathForPackageName:packageName];

        if (![_projectSettings isPathInPackagesFolder:packageToImport.dirPath])
        {
            if (![_fileManager copyItemAtPath:packageToImport.dirPath toPath:newPathInPackagesFolder error:localError])
            {
                return NO;
            }
        }

        if ([_projectSettings addResourcePath:newPathInPackagesFolder error:localError])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RESOURCE_PATHS_CHANGED object:self];
            return YES;
        }

        return NO;
    };
}

@end