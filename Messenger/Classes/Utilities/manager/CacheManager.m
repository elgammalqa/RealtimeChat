//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "utilities.h"

@implementation CacheManager

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)cleanupExpired
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FUser currentId] != nil)
	{
		if ([FUser keepMedia] == KEEPMEDIA_WEEK)
			[CacheManager cleanupExpired:7];

		if ([FUser keepMedia] == KEEPMEDIA_MONTH)
			[CacheManager cleanupExpired:30];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)cleanupExpired:(NSInteger)days
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *file; BOOL isDir;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDate *past = [[NSDate date] dateByAddingTimeInterval:-days*24*60*60];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Clear Documents files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *extensions = @[@"jpg", @"mp4", @"m4a"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[Dir document]];
	while ((file = [enumerator nextObject]) != nil)
	{
		NSString *path = [Dir document:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([extensions containsObject:ext])
			{
				NSDate *created = [File created:path];
				if ([created compare:past] == NSOrderedAscending)
					[File remove:path];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Clear Caches files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Dir cache] error:nil])
	{
		NSString *path = [Dir cache:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([ext isEqualToString:@"mp4"])
			{
				NSDate *created = [File created:path];
				if ([created compare:past] == NSOrderedAscending)
					[File remove:path];
			}
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)cleanupManual:(BOOL)isLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *file; BOOL isDir;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Clear Documents files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *extensions = isLogout ? @[@"jpg", @"mp4", @"m4a", @"manual", @"loading"] : @[@"jpg", @"mp4", @"m4a"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[Dir document]];
	while ((file = [enumerator nextObject]) != nil)
	{
		NSString *path = [Dir document:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([extensions containsObject:ext])
			{
				[File remove:path];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Clear Caches files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Dir cache] error:nil])
	{
		NSString *path = [Dir cache:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([ext isEqualToString:@"mp4"])
			{
				[File remove:path];
			}
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (long long)total
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	long long total = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *file; BOOL isDir;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Count Documents files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *extensions = @[@"jpg", @"mp4", @"m4a"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[Dir document]];
	while ((file = [enumerator nextObject]) != nil)
	{
		NSString *path = [Dir document:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([extensions containsObject:ext])
			{
				total += [File size:path];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Count Caches files
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Dir cache] error:nil])
	{
		NSString *path = [Dir cache:file];
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
		if (isDir == NO)
		{
			NSString *ext = [path pathExtension];
			if ([ext isEqualToString:@"mp4"])
			{
				total += [File size:path];
			}
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return total;
}

@end
