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

@implementation UploadManager

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)upload:(NSData *)data name:(NSString *)name ext:(NSString *)ext progress:(void (^)(float progress))progress
	completion:(void (^)(NSString *link, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *child = [NSString stringWithFormat:@"%@/%@/%lld.%@", [FUser currentId], name, [[NSDate date] timestamp], ext];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRStorageReference *reference = [[[FIRStorage storage] reference] child:child];
	FIRStorageUploadTask *task = [reference putData:data metadata:nil completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		if (progress != nil) progress((float) snapshot.progress.completedUnitCount / (float) snapshot.progress.totalUnitCount);
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		[task removeAllObservers];
		[reference downloadURLWithCompletion:^(NSURL *URL, NSError *error)
		{
			if (error == nil)
			{
				if (completion != nil) completion(URL.absoluteString, nil);
			}
			else if (completion != nil) completion(nil, [NSError description:@"URL fetch failed." code:101]);
		}];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[task observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot)
	{
		[task removeAllObservers];
		if (completion != nil) completion(nil, [NSError description:@"Upload failed." code:100]);
	}];
}

@end
